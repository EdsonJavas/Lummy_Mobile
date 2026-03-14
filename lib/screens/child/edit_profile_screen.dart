import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _cpfController = TextEditingController();
  final _emailController = TextEditingController();
  final _ageController = TextEditingController();
  final _allowanceController = TextEditingController();

  String _selectedGender = '';
  bool _requiresApproval = true;
  bool _isLoading = false;
  bool _isLoadingData = true;
  String? _originalEmail;

  @override
  void initState() {
    super.initState();
    _loadProfileData();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _cpfController.dispose();
    _emailController.dispose();
    _ageController.dispose();
    _allowanceController.dispose();
    super.dispose();
  }

  Future<void> _loadProfileData() async {
    try {
      setState(() {
        _isLoadingData = true;
      });

      final supabase = Supabase.instance.client;
      final user = supabase.auth.currentUser;

      if (user == null) {
        debugPrint('❌ Usuário não autenticado');
        if (!mounted) return;
        Navigator.pop(context);
        return;
      }

      debugPrint('🔍 Carregando dados do perfil para usuário: ${user.id}');

      // Buscar dados na tabela children
      final childData = await supabase
          .from('children')
          .select('*')
          .eq('id', user.id)
          .maybeSingle();

      if (childData != null) {
        debugPrint('✅ Dados encontrados: $childData');

        setState(() {
          _nameController.text = childData['nome'] ?? '';
          _cpfController.text = childData['cpf'] ?? '';
          _emailController.text = childData['email'] ?? '';
          _ageController.text = (childData['idade'] ?? '').toString();
          _allowanceController.text = (childData['allowance'] ?? 0.0)
              .toString();
          _selectedGender = childData['sexo'] ?? '';
          _requiresApproval = childData['requires_approval'] ?? true;
          _originalEmail = childData['email'] ?? '';
        });
      } else {
        debugPrint('⚠️ Dados não encontrados na tabela children');
        // Usar dados do auth como fallback
        setState(() {
          _nameController.text = user.userMetadata?['name'] ?? '';
          _emailController.text = user.email ?? '';
          _originalEmail = user.email ?? '';
        });
      }
    } catch (e) {
      debugPrint('❌ Erro ao carregar dados do perfil: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Erro ao carregar dados do perfil: $e',
            style: GoogleFonts.poppins(fontWeight: FontWeight.w500),
          ),
          backgroundColor: const Color(0xFFEF4444),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      );
    } finally {
      setState(() {
        _isLoadingData = false;
      });
    }
  }

  // Função para formatar CPF
  String _formatCPF(String cpf) {
    cpf = cpf.replaceAll(RegExp(r'[^0-9]'), '');
    if (cpf.length <= 3) return cpf;
    if (cpf.length <= 6) return '${cpf.substring(0, 3)}.${cpf.substring(3)}';
    if (cpf.length <= 9) {
      return '${cpf.substring(0, 3)}.${cpf.substring(3, 6)}.${cpf.substring(6)}';
    }
    return '${cpf.substring(0, 3)}.${cpf.substring(3, 6)}.${cpf.substring(6, 9)}-${cpf.substring(9, 11)}';
  }

  // Função para validar CPF
  bool _isValidCPF(String cpf) {
    cpf = cpf.replaceAll(RegExp(r'[^0-9]'), '');
    if (cpf.length != 11) return false;
    if (RegExp(r'^(\d)\1*$').hasMatch(cpf)) return false;

    int sum = 0;
    for (int i = 0; i < 9; i++) {
      sum += int.parse(cpf[i]) * (10 - i);
    }
    int digit1 = 11 - (sum % 11);
    if (digit1 >= 10) digit1 = 0;

    sum = 0;
    for (int i = 0; i < 10; i++) {
      sum += int.parse(cpf[i]) * (11 - i);
    }
    int digit2 = 11 - (sum % 11);
    if (digit2 >= 10) digit2 = 0;

    return digit1 == int.parse(cpf[9]) && digit2 == int.parse(cpf[10]);
  }

  Future<void> _pickImage() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 75,
      );

      if (image != null) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Foto atualizada com sucesso! 📸',
              style: GoogleFonts.poppins(fontWeight: FontWeight.w500),
            ),
            backgroundColor: const Color(0xFF10B981),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Erro ao selecionar imagem',
            style: GoogleFonts.poppins(fontWeight: FontWeight.w500),
          ),
          backgroundColor: const Color(0xFFEF4444),
        ),
      );
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedGender.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Por favor, selecione o sexo',
            style: GoogleFonts.poppins(fontWeight: FontWeight.w500),
          ),
          backgroundColor: const Color(0xFFEF4444),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final supabase = Supabase.instance.client;
      final user = supabase.auth.currentUser;

      if (user == null) {
        throw Exception('Usuário não autenticado');
      }

      debugPrint('💾 Salvando alterações do perfil...');

      // Preparar dados para atualização
      final updatedData = <String, dynamic>{
        'nome': _nameController.text.trim(),
        'cpf': _cpfController.text.replaceAll(RegExp(r'[^0-9]'), ''),
        'email': _emailController.text.trim(),
        'idade': int.parse(_ageController.text.trim()),
        'sexo': _selectedGender,
        'allowance':
            double.tryParse(_allowanceController.text.replaceAll(',', '.')) ??
            0.0,
        'requires_approval': _requiresApproval,
        'updated_at': DateTime.now().toIso8601String(),
      };

      // Atualizar na tabela children
      await supabase.from('children').update(updatedData).eq('id', user.id);

      debugPrint('✅ Dados atualizados na tabela children');

      // Se o email foi alterado, atualizar também no auth.users
      if (_originalEmail != null &&
          _emailController.text.trim() != _originalEmail) {
        debugPrint('📧 Email alterado, atualizando no auth.users...');
        try {
          await supabase.auth.updateUser(
            UserAttributes(email: _emailController.text.trim()),
          );
          debugPrint('✅ Email atualizado no auth.users');
        } catch (e) {
          debugPrint('⚠️ Erro ao atualizar email no auth: $e');
          // Não falhar a operação se apenas o email não for atualizado
        }
      }

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Perfil atualizado com sucesso! ✨',
            style: GoogleFonts.poppins(fontWeight: FontWeight.w500),
          ),
          backgroundColor: const Color(0xFF10B981),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      );

      // Atualizar o email original para o novo valor
      _originalEmail = _emailController.text.trim();

      // Voltar para a tela anterior após um pequeno delay
      await Future.delayed(const Duration(milliseconds: 500));
      if (!mounted) return;
      Navigator.pop(
        context,
        true,
      ); // Retornar true indica que houve atualização
    } catch (e) {
      debugPrint('❌ Erro ao salvar perfil: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Erro ao salvar perfil: $e',
            style: GoogleFonts.poppins(fontWeight: FontWeight.w500),
          ),
          backgroundColor: const Color(0xFFEF4444),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoadingData) {
      return Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: AppBar(
          backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
          elevation: 0,
          centerTitle: true,
          title: Text(
            'Editar Perfil',
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'Editar Perfil',
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Avatar
              Center(
                child: Stack(
                  children: [
                    Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Theme.of(context).colorScheme.primary,
                          width: 3,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Theme.of(
                              context,
                            ).colorScheme.primary.withOpacity(0.3),
                            blurRadius: 12,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: ClipOval(
                        child: Image.network(
                          'https://hebbkx1anhila5yf.public.blob.vercel-storage.com/fotocriancafodase%201-MFp8K8GLj7deZeGCFVqMJVDVgEtfsc.png',
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              color: Theme.of(
                                context,
                              ).colorScheme.primary.withOpacity(0.1),
                              child: Icon(
                                Icons.person,
                                size: 60,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: GestureDetector(
                        onTap: _pickImage,
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.primary,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.2),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.camera_alt,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // Nome
              _buildTextField(
                controller: _nameController,
                label: 'Nome',
                icon: Icons.person_outline,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, insira seu nome';
                  }
                  if (value.trim().length < 2) {
                    return 'Nome deve ter pelo menos 2 caracteres';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // CPF
              _buildTextField(
                controller: _cpfController,
                label: 'CPF',
                icon: Icons.badge_outlined,
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(11),
                  TextInputFormatter.withFunction((oldValue, newValue) {
                    final formatted = _formatCPF(newValue.text);
                    return TextEditingValue(
                      text: formatted,
                      selection: TextSelection.collapsed(
                        offset: formatted.length,
                      ),
                    );
                  }),
                ],
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, insira seu CPF';
                  }
                  if (!_isValidCPF(value)) {
                    return 'Por favor, insira um CPF válido';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Email
              _buildTextField(
                controller: _emailController,
                label: 'E-mail',
                icon: Icons.email_outlined,
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, insira seu e-mail';
                  }
                  if (!RegExp(
                    r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                  ).hasMatch(value)) {
                    return 'Por favor, insira um e-mail válido';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Idade
              _buildTextField(
                controller: _ageController,
                label: 'Idade',
                icon: Icons.cake_outlined,
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(2),
                ],
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, insira sua idade';
                  }
                  final age = int.tryParse(value);
                  if (age == null || age < 1 || age > 17) {
                    return 'Idade deve ser entre 1 e 17 anos';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Sexo (Dropdown)
              DropdownButtonFormField<String>(
                initialValue: _selectedGender.isEmpty ? null : _selectedGender,
                decoration: InputDecoration(
                  labelText: 'Sexo',
                  prefixIcon: Icon(
                    Icons.person_outline,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  filled: true,
                  fillColor: Theme.of(context).inputDecorationTheme.fillColor,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: Theme.of(context).dividerColor,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: Theme.of(context).dividerColor,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: Theme.of(context).colorScheme.primary,
                      width: 2,
                    ),
                  ),
                  labelStyle: GoogleFonts.poppins(
                    color: Theme.of(
                      context,
                    ).inputDecorationTheme.labelStyle?.color,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                items: const [
                  DropdownMenuItem(
                    value: 'Masculino',
                    child: Text('Masculino'),
                  ),
                  DropdownMenuItem(value: 'Feminino', child: Text('Feminino')),
                  DropdownMenuItem(value: 'Outro', child: Text('Outro')),
                ],
                onChanged: (value) {
                  setState(() {
                    _selectedGender = value ?? '';
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, selecione o sexo';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Mesada (Allowance)
              _buildTextField(
                controller: _allowanceController,
                label: 'Valor da Mesada (R\$)',
                icon: Icons.attach_money_outlined,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                ],
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, insira o valor da mesada';
                  }
                  final amount = double.tryParse(value.replaceAll(',', '.'));
                  if (amount == null || amount < 0) {
                    return 'Por favor, insira um valor válido';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Requires Approval (Switch)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardTheme.color,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Theme.of(context).dividerColor),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.security_outlined,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Requer Aprovação',
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Theme.of(
                                context,
                              ).textTheme.titleMedium?.color,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Transações precisam de aprovação do responsável',
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              color: Theme.of(
                                context,
                              ).textTheme.bodyMedium?.color,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Switch(
                      value: _requiresApproval,
                      onChanged: (value) {
                        setState(() {
                          _requiresApproval = value;
                        });
                      },
                      activeThumbColor: Theme.of(context).colorScheme.primary,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // Botão de salvar
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _saveProfile,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 2,
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          ),
                        )
                      : Text(
                          'Salvar Alterações',
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    String? Function(String?)? validator,
    TextInputType? keyboardType,
    int maxLines = 1,
    List<TextInputFormatter>? inputFormatters,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Theme.of(context).colorScheme.primary),
        filled: true,
        fillColor: Theme.of(context).inputDecorationTheme.fillColor,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Theme.of(context).dividerColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Theme.of(context).dividerColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: Theme.of(context).colorScheme.primary,
            width: 2,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFEF4444)),
        ),
        labelStyle: GoogleFonts.poppins(
          color: Theme.of(context).inputDecorationTheme.labelStyle?.color,
          fontWeight: FontWeight.w500,
        ),
      ),
      style: GoogleFonts.poppins(
        fontSize: 16,
        color: Theme.of(context).textTheme.bodyLarge?.color,
      ),
      validator: validator,
      keyboardType: keyboardType,
      maxLines: maxLines,
      inputFormatters: inputFormatters,
    );
  }
}
