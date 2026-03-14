// register_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lummy_login/core/theme/app_theme.dart';
import 'package:lummy_login/di/locator.dart';
import 'package:lummy_login/domain/repositories/auth_repository.dart';
import 'package:lummy_login/services/family_service.dart';
import 'package:lummy_login/screens/auth/register_children_screen.dart';
import 'package:lummy_login/models/responsavel_model.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _cpfController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  bool _isLoading = false;
  bool _nameFocused = false;
  bool _cpfFocused = false;
  bool _emailFocused = false;
  bool _passwordFocused = false;
  bool _confirmPasswordFocused = false;

  @override
  void dispose() {
    _nameController.dispose();
    _cpfController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
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

  Future<void> _handleRegister() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        // Verificar se o locator está inicializado
        if (!locator.isRegistered<AuthRepository>()) {
          throw Exception(
            'Sistema ainda não foi inicializado. Aguarde alguns instantes.',
          );
        }

        final authRepo = locator<AuthRepository>();
        final familyService = locator<FamilyService>();

        // Criar conta no Supabase Auth
        final registerResult = await authRepo.register(
          email: _emailController.text.trim(),
          password: _passwordController.text,
          name: _nameController.text.trim(),
          metadata: {
            'cpf': _cpfController.text.replaceAll(RegExp(r'[^0-9]'), ''),
            'role': 'parent',
          },
        );

        if (!registerResult.isSuccess) {
          setState(() {
            _isLoading = false;
          });

          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                registerResult.error?.message ?? 'Erro ao criar conta',
              ),
              backgroundColor: const Color(0xFFEF4444),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          );
          return;
        }

        // Salvar dados adicionais na tabela responsaveis
        final userId = registerResult.when(
          success: (id) => id,
          failure: (_) => throw Exception('Erro ao registrar'),
        );
        await familyService.createResponsavelData(
          userId: userId,
          nome: _nameController.text.trim(),
          cpf: _cpfController.text.replaceAll(RegExp(r'[^0-9]'), ''),
          email: _emailController.text.trim(),
        );

        setState(() {
          _isLoading = false;
        });

        if (!mounted) return;

        // Criar objeto Responsavel com o ID do Supabase
        final responsavel = Responsavel(
          nome: _nameController.text.trim(),
          cpf: _cpfController.text.replaceAll(RegExp(r'[^0-9]'), ''),
          email: _emailController.text.trim(),
          senha: _passwordController.text,
        );

        // Passar para próxima tela
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => RegisterChildrenScreen(
              responsavel: responsavel,
              parentUserId: userId,
            ),
          ),
        );
      } catch (e) {
        setState(() {
          _isLoading = false;
        });

        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao criar conta: $e'),
            backgroundColor: const Color(0xFFEF4444),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;

    // Responsividade para telas muito pequenas
    final isVerySmallScreen = screenHeight < 650;
    final isSmallScreen = screenHeight < 700;

    // Tela de cadastro sempre em tema claro (não aplica dark mode)
    return Theme(
      data: AppTheme.lightTheme,
      child: Scaffold(
        backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
        resizeToAvoidBottomInset: true,
        body: SingleChildScrollView(
          physics: const ClampingScrollPhysics(),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: screenHeight),
            child: Stack(
              children: [
                // Fundo sempre claro (cadastro não usa dark mode)
                Container(
                  width: double.infinity,
                  height: screenHeight,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                          colors: [Color(0xFF4A90E2), Color(0xFF357ABD)],
                        ),
                ),
              ),

              // Logo no topo - SUBIDO (menos padding)
              SafeArea(
                child: Padding(
                  padding: EdgeInsets.only(
                    left: 24.0,
                    top: isVerySmallScreen ? 10 : 20,
                  ),
                  child: Row(
                    children: [
                      RichText(
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: 'Lu',
                              style: GoogleFonts.paytoneOne(
                                fontSize: isVerySmallScreen ? 28 : 32,
                                fontWeight: FontWeight.w400,
                                color:
                                    Theme.of(context).brightness ==
                                        Brightness.dark
                                    ? Colors.white
                                    : Colors.black,
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
                                color:
                                    Theme.of(context).brightness ==
                                        Brightness.dark
                                    ? Colors.white
                                    : Colors.black,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Astronauta - mesmo tamanho da tela de login
              Positioned(
                top: isVerySmallScreen
                    ? screenHeight * 0.08
                    : screenHeight * 0.10,
                left: screenWidth * 0.15,
                right: screenWidth * 0.05,
                child: Center(
                  child: SvgPicture.network(
                    'https://hebbkx1anhila5yf.public.blob.vercel-storage.com/astronauta-lummy-OXK8DpNpgdSxKxNZKtIyQynALBlh6n.svg',
                    height: isVerySmallScreen
                        ? 250
                        : (isSmallScreen ? 300 : 380),
                    fit: BoxFit.contain,
                    placeholderBuilder: (context) => Container(
                      height: isVerySmallScreen
                          ? 250
                          : (isSmallScreen ? 300 : 380),
                      width: isVerySmallScreen
                          ? 250
                          : (isSmallScreen ? 300 : 380),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(
                          isVerySmallScreen ? 125 : (isSmallScreen ? 150 : 190),
                        ),
                      ),
                      child: Icon(
                        Icons.person,
                        size: isVerySmallScreen
                            ? 100
                            : (isSmallScreen ? 120 : 180),
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),

              // Formulário na parte inferior - curvatura original (ClipPath)
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: ClipPath(
                  clipper: FormTopClipper(),
                  child: Container(
                    constraints: BoxConstraints(
                      minHeight: isVerySmallScreen
                          ? screenHeight * 0.65
                          : screenHeight * 0.60,
                      maxHeight: isVerySmallScreen
                          ? screenHeight * 0.85
                          : screenHeight * 0.80,
                    ),
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardTheme.color,
                      border: Theme.of(context).brightness == Brightness.dark
                          ? Border.all(color: Theme.of(context).dividerColor)
                          : null,
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
                      left: isVerySmallScreen ? 22.0 : 28.0,
                      right: isVerySmallScreen ? 22.0 : 28.0,
                      top: isVerySmallScreen ? 24.0 : 32.0,
                      bottom:
                          (isVerySmallScreen ? 24.0 : 32.0) + keyboardHeight,
                    ),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(
                              height: isVerySmallScreen
                                  ? 15
                                  : (isSmallScreen ? 25 : 35),
                            ),

                            // Título "Crie sua conta" - responsivo
                            ShaderMask(
                              shaderCallback: (bounds) => LinearGradient(
                                colors:
                                    Theme.of(context).brightness ==
                                        Brightness.dark
                                    ? [
                                        const Color(0xFF3B82F6),
                                        const Color(0xFF8B5CF6),
                                      ] // Azul → Roxo como no site
                                    : [
                                        Theme.of(
                                              context,
                                            ).textTheme.titleLarge?.color ??
                                            const Color(0xFF1E293B),
                                        Theme.of(
                                              context,
                                            ).textTheme.titleLarge?.color ??
                                            const Color(0xFF1E293B),
                                      ],
                              ).createShader(bounds),
                              child: Text(
                                'Crie sua conta de Responsável',
                                style: GoogleFonts.poppins(
                                  fontSize: isVerySmallScreen ? 24 : 28,
                                  fontWeight: FontWeight.w600,
                                  color: Colors
                                      .white, // This color is masked by the shader
                                ),
                              ),
                            ),

                            SizedBox(height: isVerySmallScreen ? 18 : 24),

                            // Nome e CPF lado a lado
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  flex: 2,
                                  child: Focus(
                                    onFocusChange: (hasFocus) {
                                      setState(() {
                                        _nameFocused = hasFocus;
                                      });
                                    },
                                    child: TextFormField(
                                      controller: _nameController,
                                      keyboardType: TextInputType.name,
                                      textCapitalization: TextCapitalization.words,
                                      style: GoogleFonts.poppins(
                                        fontSize: isVerySmallScreen ? 15 : 17,
                                        color: Theme.of(context).textTheme.bodyLarge?.color,
                                        fontWeight: FontWeight.w500,
                                      ),
                                      decoration: InputDecoration(
                                        hintText: 'Nome do responsável',
                                        hintStyle: GoogleFonts.poppins(
                                          color: Theme.of(context).inputDecorationTheme.hintStyle?.color,
                                          fontSize: isVerySmallScreen ? 15 : 16,
                                          fontWeight: FontWeight.w400,
                                        ),
                                        prefixIcon: Icon(
                                          Icons.person_outline,
                                          color: _nameFocused
                                              ? Theme.of(context).colorScheme.primary
                                              : Theme.of(context).iconTheme.color,
                                          size: isVerySmallScreen ? 22 : 24,
                                        ),
                                        filled: true,
                                        fillColor: Theme.of(context).inputDecorationTheme.fillColor,
                                        contentPadding: EdgeInsets.symmetric(
                                          horizontal: isVerySmallScreen ? 18 : 22,
                                          vertical: isVerySmallScreen ? 16 : 20,
                                        ),
                                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                                        enabledBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(14),
                                          borderSide: BorderSide(
                                            color: Theme.of(context).dividerColor.withOpacity(0.8),
                                            width: 1.2,
                                          ),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(14),
                                          borderSide: BorderSide(
                                            color: Theme.of(context).colorScheme.primary,
                                            width: 2,
                                          ),
                                        ),
                                        errorBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(14),
                                          borderSide: BorderSide(
                                            color: Theme.of(context).colorScheme.error,
                                            width: 1.2,
                                          ),
                                        ),
                                        focusedErrorBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(14),
                                          borderSide: BorderSide(
                                            color: Theme.of(context).colorScheme.error,
                                            width: 2,
                                          ),
                                        ),
                                        errorStyle: GoogleFonts.poppins(
                                          fontSize: isVerySmallScreen ? 11 : 12,
                                        ),
                                      ),
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return 'Insira o nome';
                                        }
                                        if (value.trim().length < 2) {
                                          return 'Nome com 2+ caracteres';
                                        }
                                        return null;
                                      },
                                    ),
                                  ),
                                ),
                                SizedBox(width: isVerySmallScreen ? 10 : 14),
                                Expanded(
                                  child: Focus(
                                    onFocusChange: (hasFocus) {
                                      setState(() {
                                        _cpfFocused = hasFocus;
                                      });
                                    },
                                    child: TextFormField(
                                      controller: _cpfController,
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
                                      style: GoogleFonts.poppins(
                                        fontSize: isVerySmallScreen ? 15 : 17,
                                        color: Theme.of(context).textTheme.bodyLarge?.color,
                                        fontWeight: FontWeight.w500,
                                      ),
                                      decoration: InputDecoration(
                                        hintText: 'CPF',
                                        hintStyle: GoogleFonts.poppins(
                                          color: Theme.of(context).inputDecorationTheme.hintStyle?.color,
                                          fontSize: isVerySmallScreen ? 15 : 16,
                                          fontWeight: FontWeight.w400,
                                        ),
                                        prefixIcon: Icon(
                                          Icons.badge_outlined,
                                          color: _cpfFocused
                                              ? Theme.of(context).colorScheme.primary
                                              : Theme.of(context).iconTheme.color,
                                          size: isVerySmallScreen ? 22 : 24,
                                        ),
                                        filled: true,
                                        fillColor: Theme.of(context).inputDecorationTheme.fillColor,
                                        contentPadding: EdgeInsets.symmetric(
                                          horizontal: isVerySmallScreen ? 18 : 22,
                                          vertical: isVerySmallScreen ? 16 : 20,
                                        ),
                                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                                        enabledBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(14),
                                          borderSide: BorderSide(
                                            color: Theme.of(context).dividerColor.withOpacity(0.8),
                                            width: 1.2,
                                          ),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(14),
                                          borderSide: BorderSide(
                                            color: Theme.of(context).colorScheme.primary,
                                            width: 2,
                                          ),
                                        ),
                                        errorBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(14),
                                          borderSide: BorderSide(
                                            color: Theme.of(context).colorScheme.error,
                                            width: 1.2,
                                          ),
                                        ),
                                        focusedErrorBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(14),
                                          borderSide: BorderSide(
                                            color: Theme.of(context).colorScheme.error,
                                            width: 2,
                                          ),
                                        ),
                                        errorStyle: GoogleFonts.poppins(
                                          fontSize: isVerySmallScreen ? 11 : 12,
                                        ),
                                      ),
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return 'Insira o CPF';
                                        }
                                        if (!_isValidCPF(value)) {
                                          return 'CPF inválido';
                                        }
                                        return null;
                                      },
                                    ),
                                  ),
                                ),
                              ],
                            ),

                            SizedBox(height: isVerySmallScreen ? 14 : 18),

                            // Campo E-mail do responsável
                            Focus(
                              onFocusChange: (hasFocus) {
                                setState(() {
                                  _emailFocused = hasFocus;
                                });
                              },
                              child: TextFormField(
                                controller: _emailController,
                                keyboardType: TextInputType.emailAddress,
                                style: GoogleFonts.poppins(
                                  fontSize: isVerySmallScreen ? 15 : 17,
                                  color: Theme.of(
                                    context,
                                  ).textTheme.bodyLarge?.color,
                                  fontWeight: FontWeight.w500,
                                ),
                                decoration: InputDecoration(
                                  hintText: 'E-mail do responsável',
                                  hintStyle: GoogleFonts.poppins(
                                    color: Theme.of(
                                      context,
                                    ).inputDecorationTheme.hintStyle?.color,
                                    fontSize: isVerySmallScreen ? 15 : 16,
                                    fontWeight: FontWeight.w400,
                                  ),
                                  prefixIcon: Icon(
                                    Icons.email_outlined,
                                    color: _emailFocused
                                        ? Theme.of(context).colorScheme.primary
                                        : Theme.of(context).iconTheme.color,
                                    size: isVerySmallScreen ? 22 : 24,
                                  ),
                                  filled: true,
                                  fillColor: Theme.of(
                                    context,
                                  ).inputDecorationTheme.fillColor,
                                  contentPadding: EdgeInsets.symmetric(
                                    horizontal: isVerySmallScreen ? 18 : 22,
                                    vertical: isVerySmallScreen ? 16 : 20,
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(14),
                                    borderSide: BorderSide(
                                      color: Theme.of(context).dividerColor.withOpacity(0.8),
                                      width: 1.2,
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(14),
                                    borderSide: BorderSide(
                                      color: Theme.of(context).colorScheme.primary,
                                      width: 2,
                                    ),
                                  ),
                                  errorBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(14),
                                    borderSide: BorderSide(
                                      color: Theme.of(context).colorScheme.error,
                                      width: 1.2,
                                    ),
                                  ),
                                  focusedErrorBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(14),
                                    borderSide: BorderSide(
                                      color: Theme.of(context).colorScheme.error,
                                      width: 2,
                                    ),
                                  ),
                                  errorStyle: GoogleFonts.poppins(
                                    fontSize: isVerySmallScreen ? 11 : 12,
                                  ),
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Por favor, insira o e-mail do responsável';
                                  }
                                  if (!RegExp(
                                    r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                                  ).hasMatch(value)) {
                                    return 'Por favor, insira um e-mail válido';
                                  }
                                  return null;
                                },
                              ),
                            ),

                            SizedBox(height: isVerySmallScreen ? 14 : 18),

                            // Senha e Confirmar senha lado a lado
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Focus(
                                    onFocusChange: (hasFocus) {
                                      setState(() {
                                        _passwordFocused = hasFocus;
                                      });
                                    },
                                    child: TextFormField(
                                      controller: _passwordController,
                                      obscureText: !_isPasswordVisible,
                                      style: GoogleFonts.poppins(
                                        fontSize: isVerySmallScreen ? 15 : 17,
                                        color: Theme.of(context).textTheme.bodyLarge?.color,
                                        fontWeight: FontWeight.w500,
                                      ),
                                      decoration: InputDecoration(
                                        hintText: 'Sua Senha',
                                        hintStyle: GoogleFonts.poppins(
                                          color: Theme.of(context).inputDecorationTheme.hintStyle?.color,
                                          fontSize: isVerySmallScreen ? 15 : 16,
                                          fontWeight: FontWeight.w400,
                                        ),
                                        prefixIcon: Icon(
                                          Icons.lock_outline,
                                          color: _passwordFocused
                                              ? Theme.of(context).colorScheme.primary
                                              : Theme.of(context).iconTheme.color,
                                          size: isVerySmallScreen ? 22 : 24,
                                        ),
                                        filled: true,
                                        fillColor: Theme.of(context).inputDecorationTheme.fillColor,
                                        contentPadding: EdgeInsets.symmetric(
                                          horizontal: isVerySmallScreen ? 18 : 22,
                                          vertical: isVerySmallScreen ? 16 : 20,
                                        ),
                                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                                        enabledBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(14),
                                          borderSide: BorderSide(
                                            color: Theme.of(context).dividerColor.withOpacity(0.8),
                                            width: 1.2,
                                          ),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(14),
                                          borderSide: BorderSide(
                                            color: Theme.of(context).colorScheme.primary,
                                            width: 2,
                                          ),
                                        ),
                                        errorBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(14),
                                          borderSide: BorderSide(
                                            color: Theme.of(context).colorScheme.error,
                                            width: 1.2,
                                          ),
                                        ),
                                        focusedErrorBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(14),
                                          borderSide: BorderSide(
                                            color: Theme.of(context).colorScheme.error,
                                            width: 2,
                                          ),
                                        ),
                                        suffixIcon: IconButton(
                                          icon: Icon(
                                            _isPasswordVisible
                                                ? Icons.visibility_outlined
                                                : Icons.visibility_off_outlined,
                                            color: _passwordFocused
                                                ? Theme.of(context).colorScheme.primary
                                                : Theme.of(context).iconTheme.color,
                                            size: isVerySmallScreen ? 22 : 24,
                                          ),
                                          onPressed: () {
                                            setState(() {
                                              _isPasswordVisible = !_isPasswordVisible;
                                            });
                                          },
                                        ),
                                        errorStyle: GoogleFonts.poppins(
                                          fontSize: isVerySmallScreen ? 11 : 12,
                                        ),
                                      ),
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return 'Insira a senha';
                                        }
                                        if (value.length < 6) {
                                          return 'Mín. 6 caracteres';
                                        }
                                        return null;
                                      },
                                    ),
                                  ),
                                ),
                                SizedBox(width: isVerySmallScreen ? 10 : 14),
                                Expanded(
                                  child: Focus(
                                    onFocusChange: (hasFocus) {
                                      setState(() {
                                        _confirmPasswordFocused = hasFocus;
                                      });
                                    },
                                    child: TextFormField(
                                      controller: _confirmPasswordController,
                                      obscureText: !_isConfirmPasswordVisible,
                                      style: GoogleFonts.poppins(
                                        fontSize: isVerySmallScreen ? 15 : 17,
                                        color: Theme.of(context).textTheme.bodyLarge?.color,
                                        fontWeight: FontWeight.w500,
                                      ),
                                      decoration: InputDecoration(
                                        hintText: 'Confirme a Senha',
                                        hintStyle: GoogleFonts.poppins(
                                          color: Theme.of(context).inputDecorationTheme.hintStyle?.color,
                                          fontSize: isVerySmallScreen ? 15 : 16,
                                          fontWeight: FontWeight.w400,
                                        ),
                                        prefixIcon: Icon(
                                          Icons.lock_outline,
                                          color: _confirmPasswordFocused
                                              ? Theme.of(context).colorScheme.primary
                                              : Theme.of(context).iconTheme.color,
                                          size: isVerySmallScreen ? 22 : 24,
                                        ),
                                        filled: true,
                                        fillColor: Theme.of(context).inputDecorationTheme.fillColor,
                                        contentPadding: EdgeInsets.symmetric(
                                          horizontal: isVerySmallScreen ? 18 : 22,
                                          vertical: isVerySmallScreen ? 16 : 20,
                                        ),
                                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                                        enabledBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(14),
                                          borderSide: BorderSide(
                                            color: Theme.of(context).dividerColor.withOpacity(0.8),
                                            width: 1.2,
                                          ),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(14),
                                          borderSide: BorderSide(
                                            color: Theme.of(context).colorScheme.primary,
                                            width: 2,
                                          ),
                                        ),
                                        errorBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(14),
                                          borderSide: BorderSide(
                                            color: Theme.of(context).colorScheme.error,
                                            width: 1.2,
                                          ),
                                        ),
                                        focusedErrorBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(14),
                                          borderSide: BorderSide(
                                            color: Theme.of(context).colorScheme.error,
                                            width: 2,
                                          ),
                                        ),
                                        suffixIcon: IconButton(
                                          icon: Icon(
                                            _isConfirmPasswordVisible
                                                ? Icons.visibility_outlined
                                                : Icons.visibility_off_outlined,
                                            color: _confirmPasswordFocused
                                                ? Theme.of(context).colorScheme.primary
                                                : Theme.of(context).iconTheme.color,
                                            size: isVerySmallScreen ? 22 : 24,
                                          ),
                                          onPressed: () {
                                            setState(() {
                                              _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
                                            });
                                          },
                                        ),
                                        errorStyle: GoogleFonts.poppins(
                                          fontSize: isVerySmallScreen ? 11 : 12,
                                        ),
                                      ),
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return 'Confirme a senha';
                                        }
                                        if (value != _passwordController.text) {
                                          return 'Senhas não coincidem';
                                        }
                                        return null;
                                      },
                                    ),
                                  ),
                                ),
                              ],
                            ),

                            SizedBox(height: isVerySmallScreen ? 15 : 20),

                            // Botão Avançar com gradiente
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
                                  isVerySmallScreen ? 25 : 28,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFFFF8C42).withOpacity(0.3),
                                    blurRadius: 12,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: ElevatedButton(
                                onPressed: _isLoading ? null : _handleRegister,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.transparent,
                                  foregroundColor: Colors.white,
                                  elevation: 0,
                                  shadowColor: Colors.transparent,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(
                                      isVerySmallScreen ? 25 : 28,
                                    ),
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
                                                Colors.white,
                                              ),
                                        ),
                                      )
                                    : Text(
                                        'Avançar',
                                        style: GoogleFonts.poppins(
                                          fontSize: isVerySmallScreen ? 16 : 18,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                              ),
                            ),

                            SizedBox(height: isVerySmallScreen ? 15 : 20),

                            // Link para fazer login
                            Center(
                              child: GestureDetector(
                                onTap: () {
                                  Navigator.pop(context);
                                },
                                child: RichText(
                                  text: TextSpan(
                                    children: [
                                      TextSpan(
                                        text: 'Já tem uma conta Lummy? ',
                                        style: GoogleFonts.poppins(
                                          color: const Color(0xFF9E9E9E),
                                          fontSize: isVerySmallScreen ? 12 : 14,
                                          fontWeight: FontWeight.w400,
                                        ),
                                      ),
                                      TextSpan(
                                        text: 'Faça L',
                                        style: GoogleFonts.poppins(
                                          color: const Color(0xFF9E9E9E),
                                          fontSize: isVerySmallScreen ? 12 : 14,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      TextSpan(
                                        text: 'o',
                                        style: GoogleFonts.poppins(
                                          color: Colors.orange,
                                          fontSize: isVerySmallScreen ? 12 : 14,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      TextSpan(
                                        text: 'g',
                                        style: GoogleFonts.poppins(
                                          color: const Color(0xFF003092),
                                          fontSize: isVerySmallScreen ? 12 : 14,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      TextSpan(
                                        text: 'in',
                                        style: GoogleFonts.poppins(
                                          color: const Color(0xFF9E9E9E),
                                          fontSize: isVerySmallScreen ? 12 : 14,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
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
    path.quadraticBezierTo(size.width * 0.75, 20, size.width * 0.5, 20);
    path.quadraticBezierTo(size.width * 0.25, 20, 0, 60);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
