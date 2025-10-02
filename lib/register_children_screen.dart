import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'responsavel_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RegisterChildrenScreen extends StatefulWidget {
  final Responsavel responsavel;

  const RegisterChildrenScreen({super.key, required this.responsavel});
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

  String _selectedGender = '';
  bool _isPasswordVisible = false;
  bool _isLoading = false;
  bool _nameFocused = false;
  bool _cpfFocused = false;
  bool _emailFocused = false;
  bool _passwordFocused = false;
  bool _ageFocused = false;

  String? _responsavelId;

  @override
  void initState() {
    super.initState();
    _criarResponsavelNoFirestore();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _cpfController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _ageController.dispose();
    super.dispose();
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

  Future<void> _criarResponsavelNoFirestore() async {
    final firestore = FirebaseFirestore.instance;
    try {
      final docRef = await firestore.collection("responsaveis").add({
        "nome": widget.responsavel.nome,
        "cpf": widget.responsavel.cpf,
        "email": widget.responsavel.email,
        "senha": widget.responsavel.senha,
        "createdAt": FieldValue.serverTimestamp(),
      });

      setState(() {
        _responsavelId = docRef.id;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erro ao criar responsável: $e")),
      );
    }
  }

  Future<void> _handleRegisterChild() async {
    if (_formKey.currentState!.validate()) {
      if (_selectedGender.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text("Selecione o sexo da criança"),
            backgroundColor: const Color(0xFFEF4444),
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
        );
        return;
      }

      if (_responsavelId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text("Responsável ainda não foi criado"),
            backgroundColor: const Color(0xFFEF4444),
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
        );
        return;
      }

      setState(() => _isLoading = true);

      try {
        await FirebaseFirestore.instance
            .collection("responsaveis")
            .doc(_responsavelId)
            .collection("children")
            .add({
          "nome": _nameController.text.trim(),
          "cpf": _cpfController.text.replaceAll(RegExp(r'[^0-9]'), ''),
          "email": _emailController.text.trim(),
          "senha": _passwordController.text,
          "idade": int.tryParse(_ageController.text.trim()) ?? 0,
          "sexo": _selectedGender,
          "createdAt": FieldValue.serverTimestamp(),
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text("Criança adicionada com sucesso!"),
            backgroundColor: const Color(0xFF10B981),
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
        );

        // Limpar formulário
        _formKey.currentState?.reset();
        _nameController.clear();
        _cpfController.clear();
        _emailController.clear();
        _passwordController.clear();
        _ageController.clear();
        setState(() {
          _selectedGender = '';
        });
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Erro ao adicionar criança: $e"),
            backgroundColor: const Color(0xFFEF4444),
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
        );
      }

      setState(() => _isLoading = false);
    }
  }

  Widget _buildGenderSelector() {
    final screenHeight = MediaQuery.of(context).size.height;
    final isVerySmallScreen = screenHeight < 650;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Sexo da criança',
          style: GoogleFonts.poppins(
            fontSize: isVerySmallScreen ? 14 : 16,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF1E293B),
          ),
        ),
        SizedBox(height: isVerySmallScreen ? 8 : 12),
        Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedGender = 'Masculino';
                  });
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  padding: EdgeInsets.all(isVerySmallScreen ? 16 : 20),
                  decoration: BoxDecoration(
                    color: _selectedGender == 'Masculino'
                        ? const Color(0xFF1E40AF).withOpacity(0.1)
                        : Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: _selectedGender == 'Masculino'
                          ? const Color(0xFF1E40AF)
                          : const Color(0xFFE2E8F0),
                      width: _selectedGender == 'Masculino' ? 2 : 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.04),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Container(
                        width: isVerySmallScreen ? 32 : 40,
                        height: isVerySmallScreen ? 32 : 40,
                        decoration: BoxDecoration(
                          color: _selectedGender == 'Masculino'
                              ? const Color(0xFF1E40AF)
                              : const Color(0xFF64748B).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          Icons.person,
                          color: _selectedGender == 'Masculino'
                              ? Colors.white
                              : const Color(0xFF64748B),
                          size: isVerySmallScreen ? 16 : 20,
                        ),
                      ),
                      SizedBox(height: isVerySmallScreen ? 8 : 12),
                      Text(
                        'Menino',
                        style: GoogleFonts.poppins(
                          fontSize: isVerySmallScreen ? 12 : 14,
                          fontWeight: FontWeight.w600,
                          color: _selectedGender == 'Masculino'
                              ? const Color(0xFF1E40AF)
                              : const Color(0xFF64748B),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            SizedBox(width: isVerySmallScreen ? 12 : 16),
            Expanded(
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedGender = 'Feminino';
                  });
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  padding: EdgeInsets.all(isVerySmallScreen ? 16 : 20),
                  decoration: BoxDecoration(
                    color: _selectedGender == 'Feminino'
                        ? const Color(0xFFEC4899).withOpacity(0.1)
                        : Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: _selectedGender == 'Feminino'
                          ? const Color(0xFFEC4899)
                          : const Color(0xFFE2E8F0),
                      width: _selectedGender == 'Feminino' ? 2 : 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.04),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Container(
                        width: isVerySmallScreen ? 32 : 40,
                        height: isVerySmallScreen ? 32 : 40,
                        decoration: BoxDecoration(
                          color: _selectedGender == 'Feminino'
                              ? const Color(0xFFEC4899)
                              : const Color(0xFF64748B).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          Icons.person,
                          color: _selectedGender == 'Feminino'
                              ? Colors.white
                              : const Color(0xFF64748B),
                          size: isVerySmallScreen ? 16 : 20,
                        ),
                      ),
                      SizedBox(height: isVerySmallScreen ? 8 : 12),
                      Text(
                        'Menina',
                        style: GoogleFonts.poppins(
                          fontSize: isVerySmallScreen ? 12 : 14,
                          fontWeight: FontWeight.w600,
                          color: _selectedGender == 'Feminino'
                              ? const Color(0xFFEC4899)
                              : const Color(0xFF64748B),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String hintText,
    required IconData icon,
    required bool isFocused,
    required Function(bool) onFocusChange,
    required String? Function(String?) validator,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    bool obscureText = false,
    Widget? suffixIcon,
    TextCapitalization textCapitalization = TextCapitalization.none,
  }) {
    final screenHeight = MediaQuery.of(context).size.height;
    final isVerySmallScreen = screenHeight < 650;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FA),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isFocused ? const Color(0xFF1E40AF) : Colors.transparent,
          width: 2,
        ),
        boxShadow: isFocused
            ? [
                BoxShadow(
                  color: const Color(0xFF1E40AF).withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ]
            : [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
      ),
      child: Focus(
        onFocusChange: onFocusChange,
        child: TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          inputFormatters: inputFormatters,
          obscureText: obscureText,
          textCapitalization: textCapitalization,
          style: GoogleFonts.poppins(
            fontSize: isVerySmallScreen ? 14 : 16,
            color: const Color(0xFF1E293B),
            fontWeight: FontWeight.w500,
          ),
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: GoogleFonts.poppins(
              color: const Color(0xFF64748B),
              fontSize: isVerySmallScreen ? 14 : 16,
              fontWeight: FontWeight.w400,
            ),
            prefixIcon: Icon(
              icon,
              color:
                  isFocused ? const Color(0xFF1E40AF) : const Color(0xFF64748B),
              size: isVerySmallScreen ? 20 : 22,
            ),
            suffixIcon: suffixIcon,
            border: InputBorder.none,
            contentPadding: EdgeInsets.symmetric(
              horizontal: isVerySmallScreen ? 16 : 20,
              vertical: isVerySmallScreen ? 14 : 18,
            ),
            errorStyle: GoogleFonts.poppins(
              fontSize: isVerySmallScreen ? 10 : 12,
            ),
          ),
          validator: validator,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;

    final isVerySmallScreen = screenHeight < 650;
    final isSmallScreen = screenHeight < 700;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      resizeToAvoidBottomInset: true,
      body: SingleChildScrollView(
        physics: const ClampingScrollPhysics(),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            minHeight: screenHeight,
          ),
          child: Stack(
            children: [
              // Header com gradiente azul - similar ao LoginScreen
              Container(
                width: double.infinity,
                height: isVerySmallScreen
                    ? screenHeight * 0.35
                    : screenHeight * 0.4,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Color(0xFF4A90E2),
                      Color(0xFF357ABD),
                    ],
                  ),
                ),
              ),

              // Logo no topo
              SafeArea(
                child: Padding(
                  padding: EdgeInsets.only(
                    left: 24.0,
                    top: isVerySmallScreen ? 10 : 20,
                  ),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.arrow_back,
                            color: Colors.white,
                            size: 24,
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
                                fontSize: isVerySmallScreen ? 28 : 32,
                                fontWeight: FontWeight.w400,
                                color: Colors.black,
                              ),
                            ),
                            TextSpan(
                              text: 'm',
                              style: GoogleFonts.paytoneOne(
                                fontSize: isVerySmallScreen ? 28 : 32,
                                fontWeight: FontWeight.w400,
                                color: Colors.orange,
                              ),
                            ),
                            TextSpan(
                              text: 'm',
                              style: GoogleFonts.paytoneOne(
                                fontSize: isVerySmallScreen ? 28 : 32,
                                fontWeight: FontWeight.w400,
                                color: const Color(0xFF003092),
                              ),
                            ),
                            TextSpan(
                              text: 'y',
                              style: GoogleFonts.paytoneOne(
                                fontSize: isVerySmallScreen ? 28 : 32,
                                fontWeight: FontWeight.w400,
                                color: Colors.black,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Ilustração simples no header
              Positioned(
                top: isVerySmallScreen
                    ? screenHeight * 0.12
                    : screenHeight * 0.15,
                left: screenWidth * 0.25,
                right: screenWidth * 0.25,
                child: Container(
                  height: isVerySmallScreen ? 80 : 100,
                  width: isVerySmallScreen ? 80 : 100,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(50),
                  ),
                  child: Icon(
                    Icons.child_care,
                    size: isVerySmallScreen ? 40 : 50,
                    color: Colors.white,
                  ),
                ),
              ),

              // Formulário na parte inferior - similar ao LoginScreen
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: ClipPath(
                  clipper: FormTopClipper(),
                  child: Container(
                    constraints: BoxConstraints(
                      minHeight: isVerySmallScreen
                          ? screenHeight * 0.7
                          : screenHeight * 0.65,
                      maxHeight: isVerySmallScreen
                          ? screenHeight * 0.9
                          : screenHeight * 0.85,
                    ),
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 20,
                          offset: const Offset(0, -5),
                        ),
                      ],
                    ),
                    child: SingleChildScrollView(
                      padding: EdgeInsets.only(
                        left: isVerySmallScreen ? 20.0 : 24.0,
                        right: isVerySmallScreen ? 20.0 : 24.0,
                        top: isVerySmallScreen ? 20.0 : 24.0,
                        bottom:
                            (isVerySmallScreen ? 20.0 : 24.0) + keyboardHeight,
                      ),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(height: isVerySmallScreen ? 25 : 40),

                            // Título
                            Text(
                              'Cadastrar Criança',
                              style: GoogleFonts.poppins(
                                fontSize: isVerySmallScreen ? 24 : 28,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF1E293B),
                              ),
                            ),

                            const SizedBox(height: 8),

                            Text(
                              'Adicione os dados da criança para continuar',
                              style: GoogleFonts.poppins(
                                fontSize: isVerySmallScreen ? 14 : 16,
                                fontWeight: FontWeight.w400,
                                color: const Color(0xFF64748B),
                              ),
                            ),

                            SizedBox(height: isVerySmallScreen ? 20 : 30),

                            // Campo Nome
                            _buildInputField(
                              controller: _nameController,
                              hintText: 'Nome da criança',
                              icon: Icons.person_outline,
                              isFocused: _nameFocused,
                              onFocusChange: (hasFocus) {
                                setState(() {
                                  _nameFocused = hasFocus;
                                });
                              },
                              textCapitalization: TextCapitalization.words,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Por favor, insira o nome da criança';
                                }
                                if (value.trim().length < 2) {
                                  return 'Nome deve ter pelo menos 2 caracteres';
                                }
                                return null;
                              },
                            ),

                            SizedBox(height: isVerySmallScreen ? 12 : 16),

                            // Seletor de sexo
                            _buildGenderSelector(),

                            SizedBox(height: isVerySmallScreen ? 12 : 16),

                            // Campo Idade
                            _buildInputField(
                              controller: _ageController,
                              hintText: 'Idade da criança',
                              icon: Icons.cake_outlined,
                              isFocused: _ageFocused,
                              keyboardType: TextInputType.number,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                                LengthLimitingTextInputFormatter(2),
                              ],
                              onFocusChange: (hasFocus) {
                                setState(() {
                                  _ageFocused = hasFocus;
                                });
                              },
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Por favor, insira a idade da criança';
                                }
                                final age = int.tryParse(value);
                                if (age == null || age < 1 || age > 17) {
                                  return 'Idade deve ser entre 1 e 17 anos';
                                }
                                return null;
                              },
                            ),

                            SizedBox(height: isVerySmallScreen ? 12 : 16),

                            // Campo CPF
                            _buildInputField(
                              controller: _cpfController,
                              hintText: 'CPF da criança',
                              icon: Icons.badge_outlined,
                              isFocused: _cpfFocused,
                              keyboardType: TextInputType.number,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                                LengthLimitingTextInputFormatter(11),
                                TextInputFormatter.withFunction(
                                    (oldValue, newValue) {
                                  final formatted = _formatCPF(newValue.text);
                                  return TextEditingValue(
                                    text: formatted,
                                    selection: TextSelection.collapsed(
                                        offset: formatted.length),
                                  );
                                }),
                              ],
                              onFocusChange: (hasFocus) {
                                setState(() {
                                  _cpfFocused = hasFocus;
                                });
                              },
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Por favor, insira o CPF da criança';
                                }
                                if (!_isValidCPF(value)) {
                                  return 'Por favor, insira um CPF válido';
                                }
                                return null;
                              },
                            ),

                            SizedBox(height: isVerySmallScreen ? 12 : 16),

                            // Campo E-mail
                            _buildInputField(
                              controller: _emailController,
                              hintText: 'E-mail da criança',
                              icon: Icons.email_outlined,
                              isFocused: _emailFocused,
                              keyboardType: TextInputType.emailAddress,
                              onFocusChange: (hasFocus) {
                                setState(() {
                                  _emailFocused = hasFocus;
                                });
                              },
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Por favor, insira o e-mail da criança';
                                }
                                if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                                    .hasMatch(value)) {
                                  return 'Por favor, insira um e-mail válido';
                                }
                                return null;
                              },
                            ),

                            SizedBox(height: isVerySmallScreen ? 12 : 16),

                            // Campo Senha
                            _buildInputField(
                              controller: _passwordController,
                              hintText: 'Senha da criança',
                              icon: Icons.lock_outline,
                              isFocused: _passwordFocused,
                              obscureText: !_isPasswordVisible,
                              onFocusChange: (hasFocus) {
                                setState(() {
                                  _passwordFocused = hasFocus;
                                });
                              },
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _isPasswordVisible
                                      ? Icons.visibility_outlined
                                      : Icons.visibility_off_outlined,
                                  color: _passwordFocused
                                      ? const Color(0xFF1E40AF)
                                      : const Color(0xFF64748B),
                                  size: isVerySmallScreen ? 20 : 22,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _isPasswordVisible = !_isPasswordVisible;
                                  });
                                },
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Por favor, insira a senha da criança';
                                }
                                if (value.length < 6) {
                                  return 'A senha deve ter pelo menos 6 caracteres';
                                }
                                return null;
                              },
                            ),

                            SizedBox(height: isVerySmallScreen ? 25 : 35),

                            // Botão Cadastrar Criança
                            Container(
                              width: double.infinity,
                              height: isVerySmallScreen ? 50 : 56,
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [
                                    Color(0xFFFF8C42),
                                    Color(0xFFFF7A28),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(
                                    isVerySmallScreen ? 25 : 28),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFFFF8C42)
                                        .withOpacity(0.3),
                                    blurRadius: 12,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: ElevatedButton(
                                onPressed:
                                    _isLoading ? null : _handleRegisterChild,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.transparent,
                                  foregroundColor: Colors.white,
                                  elevation: 0,
                                  shadowColor: Colors.transparent,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(
                                        isVerySmallScreen ? 25 : 28),
                                  ),
                                ),
                                child: _isLoading
                                    ? SizedBox(
                                        height: isVerySmallScreen ? 18 : 20,
                                        width: isVerySmallScreen ? 18 : 20,
                                        child: const CircularProgressIndicator(
                                          strokeWidth: 2,
                                          valueColor:
                                              AlwaysStoppedAnimation<Color>(
                                                  Colors.white),
                                        ),
                                      )
                                    : Text(
                                        'Cadastrar Criança',
                                        style: GoogleFonts.poppins(
                                          fontSize: isVerySmallScreen ? 16 : 18,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                              ),
                            ),

                            SizedBox(height: isVerySmallScreen ? 15 : 20),

                            // Botão para adicionar mais crianças
                            Center(
                              child: TextButton.icon(
                                onPressed: () async {
                                  await _handleRegisterChild();
                                },
                                icon: const Icon(
                                  Icons.add_circle_outline,
                                  color: Color(0xFF1E40AF),
                                  size: 20,
                                ),
                                label: Text(
                                  'Adicionar outra criança',
                                  style: GoogleFonts.poppins(
                                    color: const Color(0xFF1E40AF),
                                    fontSize: isVerySmallScreen ? 14 : 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),

                            SizedBox(height: isVerySmallScreen ? 15 : 20),
                          ],
                        ),
                      ),
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
}

class FormTopClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();

    path.moveTo(0, size.height);
    path.lineTo(size.width, size.height);
    path.lineTo(size.width, 60);

    path.quadraticBezierTo(
      size.width * 0.75,
      20,
      size.width * 0.5,
      20,
    );

    path.quadraticBezierTo(
      size.width * 0.25,
      20,
      0,
      60,
    );

    path.close();

    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
