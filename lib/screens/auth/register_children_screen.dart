import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lummy_login/core/constants/app_constants.dart';
import 'package:lummy_login/models/responsavel_model.dart';
import 'package:lummy_login/screens/parent/parent_subscription_screen.dart';
import 'package:lummy_login/di/locator.dart';
import 'package:lummy_login/services/family_service.dart';
import 'package:lummy_login/domain/repositories/auth_repository.dart';

class RegisterChildrenScreen extends StatefulWidget {
  final Responsavel responsavel;
  final String parentUserId;

  const RegisterChildrenScreen({
    super.key,
    required this.responsavel,
    required this.parentUserId,
  });

  @override
  State<RegisterChildrenScreen> createState() => _RegisterChildrenScreenState();
}

class _RegisterChildrenScreenState extends State<RegisterChildrenScreen>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _cpfController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _ageController = TextEditingController();

  // Cores vibrantes - consistentes com o app
  static const _blue = Color(0xFF3B82F6);
  static const _purple = Color(0xFF8B5CF6);
  static const _orange = Color(0xFFF59E0B);
  static const _green = Color(0xFF10B981);
  static const _pink = Color(0xFFEC4899);
  static const _red = Color(0xFFEF4444);

  String _selectedGender = '';
  bool _isPasswordVisible = false;
  bool _isLoading = false;

  late AnimationController _bounceController;
  late Animation<double> _bounceAnimation;

  FamilyService get _familyService => locator<FamilyService>();
  AuthRepository get _authRepo => locator<AuthRepository>();

  @override
  void initState() {
    super.initState();
    _bounceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    _bounceAnimation = Tween<double>(begin: 0, end: 10).animate(
      CurvedAnimation(parent: _bounceController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _bounceController.dispose();
    _nameController.dispose();
    _cpfController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _ageController.dispose();
    super.dispose();
  }

  String _formatCPF(String cpf) {
    cpf = cpf.replaceAll(RegExp(r'[^0-9]'), '');
    if (cpf.length <= 3) return cpf;
    if (cpf.length <= 6) return '${cpf.substring(0, 3)}.${cpf.substring(3)}';
    if (cpf.length <= 9) {
      return '${cpf.substring(0, 3)}.${cpf.substring(3, 6)}.${cpf.substring(6)}';
    }
    return '${cpf.substring(0, 3)}.${cpf.substring(3, 6)}.${cpf.substring(6, 9)}-${cpf.substring(9, 11)}';
  }

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

  Future<void> _handleRegisterChild() async {
    if (_formKey.currentState!.validate()) {
      if (_selectedGender.isEmpty) {
        if (!mounted) return;
        _showSnackBar('Selecione o sexo da criança', _red);
        return;
      }

      final existingChildren =
          await _familyService.countChildrenForParent(widget.parentUserId);
      if (!mounted) return;
      if (existingChildren >= AppConstants.lummyForYouMaxChildren) {
        await showDialog<void>(
          context: context,
          builder: (ctx) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: Text(
              'Limite do Lummy For You',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w700,
                fontSize: 18,
              ),
            ),
            content: Text(
              'Este plano inclui até ${AppConstants.lummyForYouMaxChildren} dependentes. '
              'Para cadastrar mais filhos, o indicado é o Lummy Pro, com dependentes ilimitados.',
              style: GoogleFonts.poppins(fontSize: 14, height: 1.4),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: Text(
                  'Entendi',
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w600,
                    color: _purple,
                  ),
                ),
              ),
              FilledButton(
                onPressed: () {
                  Navigator.of(ctx).pop();
                  Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => const ParentSubscriptionScreen(),
                    ),
                  );
                },
                style: FilledButton.styleFrom(
                  backgroundColor: _purple,
                  foregroundColor: Colors.white,
                ),
                child: Text(
                  'Ver planos',
                  style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
        );
        return;
      }

      final childEmail = _emailController.text.trim();
      if (FamilyService.normalizeSignupEmail(childEmail) ==
          FamilyService.normalizeSignupEmail(widget.responsavel.email)) {
        if (!mounted) return;
        _showSnackBar(
          'O e-mail do dependente deve ser diferente do e-mail do responsável.',
          _red,
        );
        return;
      }

      final emailStatus =
          await _familyService.getEmailRegistrationStatus(childEmail);
      if (emailStatus == EmailRegistrationStatus.usedByParent) {
        if (!mounted) return;
        _showSnackBar(
          'Este e-mail já está em uso em uma conta de responsável. '
          'Use outro e-mail para o dependente.',
          _red,
        );
        return;
      }
      if (emailStatus == EmailRegistrationStatus.usedByChild) {
        if (!mounted) return;
        _showSnackBar(
          'Este e-mail já está em uso em outra conta de dependente.',
          _red,
        );
        return;
      }

      final childCpf =
          _cpfController.text.replaceAll(RegExp(r'[^0-9]'), '');
      if (FamilyService.normalizeSignupCpf(childCpf) ==
          FamilyService.normalizeSignupCpf(widget.responsavel.cpf)) {
        if (!mounted) return;
        _showSnackBar(
          'O CPF do dependente deve ser diferente do CPF do responsável.',
          _red,
        );
        return;
      }

      final cpfStatus =
          await _familyService.getCpfRegistrationStatus(childCpf);
      if (cpfStatus == CpfRegistrationStatus.usedByParent) {
        if (!mounted) return;
        _showSnackBar(
          'Este CPF já está em uso em uma conta de responsável. '
          'Use outro CPF para o dependente.',
          _red,
        );
        return;
      }
      if (cpfStatus == CpfRegistrationStatus.usedByChild) {
        if (!mounted) return;
        _showSnackBar(
          'Este CPF já está em uso em outra conta de dependente.',
          _red,
        );
        return;
      }

      setState(() => _isLoading = true);

      try {
        if (!locator.isRegistered<AuthRepository>()) {
          throw Exception('Sistema ainda não foi inicializado.');
        }

        // 1) Cria o usuário da criança no Auth (isso troca a sessão atual)
        final registerResult = await _authRepo.register(
          email: childEmail,
          password: _passwordController.text,
          name: _nameController.text.trim(),
          metadata: {
            'cpf': childCpf,
            'role': 'child',
            'parent_id': widget.parentUserId,
            'idade': int.tryParse(_ageController.text.trim()) ?? 0,
            'sexo': _selectedGender,
          },
        );

        if (!registerResult.isSuccess) {
          setState(() => _isLoading = false);
          if (!mounted) return;
          _showSnackBar(
            registerResult.error?.message ?? 'Erro ao criar conta',
            _red,
          );
          return;
        }

        final childUserId = registerResult.when(
          success: (id) => id,
          failure: (_) => throw Exception('Erro ao registrar criança'),
        );

        // 2) Cria o registro na tabela children
        await _familyService.addChildData(
          childUserId: childUserId,
          responsavelId: widget.parentUserId,
          nome: _nameController.text.trim(),
          cpf: childCpf,
          email: childEmail,
          idade: int.tryParse(_ageController.text.trim()) ?? 0,
          sexo: _selectedGender,
        );

        // 3) Reativa a sessão do responsável (mantém ele logado)
        await _authRepo.login(
          email: widget.responsavel.email.trim(),
          password: widget.responsavel.senha,
        );

        if (!mounted) return;
        setState(() => _isLoading = false);
        _showSnackBar('Criança adicionada com sucesso!', _green);

        // Limpar formulário somente após tudo salvo
        _formKey.currentState?.reset();
        _nameController.clear();
        _cpfController.clear();
        _emailController.clear();
        _passwordController.clear();
        _ageController.clear();
        setState(() => _selectedGender = '');
      } catch (e) {
        if (!mounted) return;
        setState(() => _isLoading = false);
        _showSnackBar('Erro ao salvar dados: $e', _red);
      }
    }
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: GoogleFonts.poppins(fontWeight: FontWeight.w500),
        ),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final topPadding = MediaQuery.of(context).padding.top;

    return Scaffold(
      backgroundColor: isDark
          ? const Color(0xFF121212)
          : const Color(0xFFF8FAFC),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          children: [
            // Header com gradiente
            _buildHeader(context, isDark, topPadding),

            // Conteúdo do formulário
            Transform.translate(
              offset: const Offset(0, -30),
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: isDark
                      ? const Color(0xFF121212)
                      : const Color(0xFFF8FAFC),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(32),
                    topRight: Radius.circular(32),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 30, 20, 40),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Título
                        _buildTitle(isDark),
                        const SizedBox(height: 24),

                        // Seletor de gênero
                        _buildGenderSelector(isDark),
                        const SizedBox(height: 20),

                        // Campos do formulário
                        _buildInputField(
                          controller: _nameController,
                          label: 'Nome da criança',
                          hint: 'Digite o nome completo',
                          icon: Icons.child_care_rounded,
                          color: _blue,
                          isDark: isDark,
                          textCapitalization: TextCapitalization.words,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Informe o nome';
                            }
                            if (value.trim().length < 2) {
                              return 'Nome muito curto';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),

                        _buildInputField(
                          controller: _ageController,
                          label: 'Idade',
                          hint: 'Ex: 10',
                          icon: Icons.cake_rounded,
                          color: _orange,
                          isDark: isDark,
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                            LengthLimitingTextInputFormatter(2),
                          ],
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Informe a idade';
                            }
                            final age = int.tryParse(value);
                            if (age == null || age < 1 || age > 17) {
                              return 'Idade entre 1 e 17';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),

                        _buildInputField(
                          controller: _cpfController,
                          label: 'CPF',
                          hint: '000.000.000-00',
                          icon: Icons.badge_rounded,
                          color: _purple,
                          isDark: isDark,
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                            LengthLimitingTextInputFormatter(11),
                            TextInputFormatter.withFunction((
                              oldValue,
                              newValue,
                            ) {
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
                              return 'Informe o CPF';
                            }
                            if (!_isValidCPF(value)) {
                              return 'CPF inválido';
                            }
                            if (FamilyService.normalizeSignupCpf(value) ==
                                FamilyService.normalizeSignupCpf(
                                  widget.responsavel.cpf,
                                )) {
                              return 'Use um CPF diferente do responsável';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),

                        _buildInputField(
                          controller: _emailController,
                          label: 'E-mail',
                          hint: 'email@exemplo.com',
                          icon: Icons.email_rounded,
                          color: _green,
                          isDark: isDark,
                          keyboardType: TextInputType.emailAddress,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Informe o e-mail';
                            }
                            if (!RegExp(
                              r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                            ).hasMatch(value)) {
                              return 'E-mail inválido';
                            }
                            if (FamilyService.normalizeSignupEmail(value) ==
                                FamilyService.normalizeSignupEmail(
                                  widget.responsavel.email,
                                )) {
                              return 'Use um e-mail diferente do responsável';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),

                        _buildInputField(
                          controller: _passwordController,
                          label: 'Senha',
                          hint: 'Mínimo 6 caracteres',
                          icon: Icons.lock_rounded,
                          color: _pink,
                          isDark: isDark,
                          obscureText: !_isPasswordVisible,
                          suffixIcon: IconButton(
                            icon: Icon(
                              _isPasswordVisible
                                  ? Icons.visibility_rounded
                                  : Icons.visibility_off_rounded,
                              color: _pink,
                            ),
                            onPressed: () {
                              setState(() {
                                _isPasswordVisible = !_isPasswordVisible;
                              });
                            },
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Informe a senha';
                            }
                            if (value.length < 6) {
                              return 'Mínimo 6 caracteres';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 32),

                        // Botão de cadastrar
                        _buildRegisterButton(isDark),
                        const SizedBox(height: 16),

                        // Botão adicionar outra criança
                        _buildAddAnotherButton(isDark),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, bool isDark, double topPadding) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(20, topPadding + 16, 20, 80),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? const [Color(0xFF1E3A5F), Color(0xFF312E81), Color(0xFF4C1D95)]
              : const [Color(0xFF3B82F6), Color(0xFF8B5CF6), Color(0xFF6366F1)],
        ),
      ),
      child: Column(
        children: [
          // Header com voltar e logo
          Row(
            children: [
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(
                    Icons.arrow_back_ios_new_rounded,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: 'Lu',
                      style: GoogleFonts.paytoneOne(
                        fontSize: 28,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                    TextSpan(
                      text: 'm',
                      style: GoogleFonts.paytoneOne(
                        fontSize: 28,
                        fontWeight: FontWeight.w700,
                        color: Colors.orange,
                      ),
                    ),
                    TextSpan(
                      text: 'm',
                      style: GoogleFonts.paytoneOne(
                        fontSize: 28,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF003092),
                      ),
                    ),
                    TextSpan(
                      text: 'y',
                      style: GoogleFonts.paytoneOne(
                        fontSize: 28,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 30),

          // Ícone de criança animado
          AnimatedBuilder(
            animation: _bounceAnimation,
            builder: (context, child) {
              return Transform.translate(
                offset: Offset(0, -_bounceAnimation.value),
                child: child,
              );
            },
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white.withOpacity(0.3),
                  width: 3,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.15),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: const Icon(
                Icons.child_care_rounded,
                size: 50,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTitle(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ShaderMask(
          shaderCallback: (bounds) => const LinearGradient(
            colors: [_blue, _purple],
          ).createShader(bounds),
          child: Text(
            'Cadastrar Criança',
            style: GoogleFonts.poppins(
              fontSize: 28,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Preencha os dados para criar a conta',
          style: GoogleFonts.poppins(
            fontSize: 15,
            color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
          ),
        ),
      ],
    );
  }

  Widget _buildGenderSelector(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Sexo da criança',
          style: GoogleFonts.poppins(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: isDark ? Colors.white : const Color(0xFF1E293B),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildGenderOption(
                label: 'Menino',
                icon: Icons.face_rounded,
                value: 'Masculino',
                color: _blue,
                isDark: isDark,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildGenderOption(
                label: 'Menina',
                icon: Icons.face_2_rounded,
                value: 'Feminino',
                color: _pink,
                isDark: isDark,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildGenderOption({
    required String label,
    required IconData icon,
    required String value,
    required Color color,
    required bool isDark,
  }) {
    final isSelected = _selectedGender == value;

    return GestureDetector(
      onTap: () => setState(() => _selectedGender = value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: isSelected
              ? LinearGradient(
                  colors: [color, color.withOpacity(0.8)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : null,
          color: isSelected
              ? null
              : (isDark ? const Color(0xFF121212) : Colors.white),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? color
                : (isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: color.withOpacity(0.4),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ]
              : [
                  BoxShadow(
                    color: Colors.black.withOpacity(isDark ? 0.2 : 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
        ),
        child: Column(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: isSelected
                    ? Colors.white.withOpacity(0.2)
                    : color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(
                icon,
                color: isSelected ? Colors.white : color,
                size: 28,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: isSelected
                    ? Colors.white
                    : (isDark ? Colors.white : const Color(0xFF1E293B)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    required Color color,
    required bool isDark,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    bool obscureText = false,
    Widget? suffixIcon,
    TextCapitalization textCapitalization = TextCapitalization.none,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: isDark ? Colors.white : const Color(0xFF1E293B),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF121212) : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(isDark ? 0.15 : 0.04),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: TextFormField(
            controller: controller,
            keyboardType: keyboardType,
            inputFormatters: inputFormatters,
            obscureText: obscureText,
            textCapitalization: textCapitalization,
            style: GoogleFonts.poppins(
              fontSize: 15,
              fontWeight: FontWeight.w500,
              color: isDark ? Colors.white : const Color(0xFF1E293B),
            ),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: GoogleFonts.poppins(
                fontSize: 14,
                color: isDark
                    ? const Color(0xFF64748B)
                    : const Color(0xFF94A3B8),
              ),
              prefixIcon: Container(
                margin: const EdgeInsets.all(12),
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              suffixIcon: suffixIcon,
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 16,
              ),
              errorStyle: GoogleFonts.poppins(fontSize: 11, color: _red),
            ),
            validator: validator,
          ),
        ),
      ],
    );
  }

  Widget _buildRegisterButton(bool isDark) {
    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [_purple, Color(0xFF7C3AED)]),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: _purple.withOpacity(0.4),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: _isLoading ? null : _handleRegisterChild,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          foregroundColor: Colors.white,
          elevation: 0,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: _isLoading
            ? const SizedBox(
                height: 24,
                width: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.person_add_rounded, size: 22),
                  const SizedBox(width: 10),
                  Text(
                    'Cadastrar Criança',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildAddAnotherButton(bool isDark) {
    return Center(
      child: TextButton.icon(
        onPressed: () async {
          await _handleRegisterChild();
        },
        icon: const Icon(Icons.add_circle_outline_rounded, color: _blue),
        label: Text(
          'Adicionar outra criança',
          style: GoogleFonts.poppins(
            color: _blue,
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
