// register_screen.dart
import 'package:flutter/material.dart';
import 'package:lummy/core/theme/app_theme.dart';
import 'package:lummy/di/locator.dart';
import 'package:lummy/domain/repositories/auth_repository.dart';
import 'package:lummy/services/family_service.dart';
import 'package:lummy/screens/auth/register_children_screen.dart';
import 'package:lummy/models/responsavel_model.dart';
import 'package:lummy/core/theme/design_tokens.dart';
import 'package:lummy/screens/auth/widgets/register/register_email_field.dart';
import 'package:lummy/screens/auth/widgets/register/register_hero_illustration.dart';
import 'package:lummy/screens/auth/widgets/register/register_login_link.dart';
import 'package:lummy/screens/auth/widgets/register/register_logo.dart';
import 'package:lummy/screens/auth/widgets/register/register_name_cpf_fields.dart';
import 'package:lummy/screens/auth/widgets/register/register_password_fields.dart';
import 'package:lummy/screens/auth/widgets/register/register_submit_button.dart';
import 'package:lummy/screens/auth/widgets/register/register_title.dart';

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

        final emailRaw = _emailController.text.trim();
        final emailStatus =
            await familyService.getEmailRegistrationStatus(emailRaw);
        if (emailStatus == EmailRegistrationStatus.usedByChild) {
          setState(() => _isLoading = false);
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Este e-mail já é de uma conta de dependente. '
                'Use outro e-mail para cadastrar o responsável.',
                style: LummyFonts.body(fontWeight: FontWeight.w500),
              ),
              backgroundColor: LummyColors.red500,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          );
          return;
        }
        if (emailStatus == EmailRegistrationStatus.usedByParent) {
          setState(() => _isLoading = false);
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Este e-mail já está cadastrado como responsável.',
                style: LummyFonts.body(fontWeight: FontWeight.w500),
              ),
              backgroundColor: LummyColors.red500,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          );
          return;
        }

        final cpfRaw = _cpfController.text.replaceAll(RegExp(r'[^0-9]'), '');
        final cpfStatus =
            await familyService.getCpfRegistrationStatus(cpfRaw);
        if (cpfStatus == CpfRegistrationStatus.usedByChild) {
          setState(() => _isLoading = false);
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Este CPF já está vinculado a uma conta de dependente. '
                'Use outro CPF para o responsável.',
                style: LummyFonts.body(fontWeight: FontWeight.w500),
              ),
              backgroundColor: LummyColors.red500,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          );
          return;
        }
        if (cpfStatus == CpfRegistrationStatus.usedByParent) {
          setState(() => _isLoading = false);
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Este CPF já está cadastrado como responsável.',
                style: LummyFonts.body(fontWeight: FontWeight.w500),
              ),
              backgroundColor: LummyColors.red500,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          );
          return;
        }

        // Criar conta no Supabase Auth
        final registerResult = await authRepo.register(
          email: emailRaw,
          password: _passwordController.text,
          name: _nameController.text.trim(),
          metadata: {
            'cpf': cpfRaw,
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
              backgroundColor: LummyColors.red500,
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
          cpf: cpfRaw,
          email: emailRaw,
        );

        setState(() {
          _isLoading = false;
        });

        if (!mounted) return;

        // Criar objeto Responsavel com o ID do Supabase
        final responsavel = Responsavel(
          nome: _nameController.text.trim(),
          cpf: cpfRaw,
          email: emailRaw,
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
            backgroundColor: LummyColors.red500,
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

    // Theme from ABOVE the light override below; the extracted sections
    // receive it so they keep reading the same values as before.
    final theme = Theme.of(context);

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
                          colors: [LummyColors.brandBlue, LummyColors.brandBlueDark],
                        ),
                ),
              ),

              // Logo no topo - SUBIDO (menos padding)
              RegisterLogo(
                theme: theme,
                isVerySmallScreen: isVerySmallScreen,
              ),

              // Astronauta - mesmo tamanho da tela de login
              Positioned(
                top: isVerySmallScreen
                    ? screenHeight * 0.08
                    : screenHeight * 0.10,
                left: screenWidth * 0.15,
                right: screenWidth * 0.05,
                child: RegisterHeroIllustration(
                  isVerySmallScreen: isVerySmallScreen,
                  isSmallScreen: isSmallScreen,
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
                          color: Colors.black.withValues(alpha: 0.1),
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
                            RegisterTitle(
                              theme: theme,
                              isVerySmallScreen: isVerySmallScreen,
                            ),

                            SizedBox(height: isVerySmallScreen ? 18 : 24),

                            // Nome e CPF lado a lado
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  flex: 2,
                                  child: RegisterNameField(
                                    theme: theme,
                                    isVerySmallScreen: isVerySmallScreen,
                                    controller: _nameController,
                                    focused: _nameFocused,
                                    onFocusChange: (hasFocus) {
                                      setState(() {
                                        _nameFocused = hasFocus;
                                      });
                                    },
                                  ),
                                ),
                                SizedBox(width: isVerySmallScreen ? 10 : 14),
                                Expanded(
                                  child: RegisterCpfField(
                                    theme: theme,
                                    isVerySmallScreen: isVerySmallScreen,
                                    controller: _cpfController,
                                    focused: _cpfFocused,
                                    onFocusChange: (hasFocus) {
                                      setState(() {
                                        _cpfFocused = hasFocus;
                                      });
                                    },
                                    formatCPF: _formatCPF,
                                    isValidCPF: _isValidCPF,
                                  ),
                                ),
                              ],
                            ),

                            SizedBox(height: isVerySmallScreen ? 14 : 18),

                            // Campo E-mail do responsável
                            RegisterEmailField(
                              theme: theme,
                              isVerySmallScreen: isVerySmallScreen,
                              controller: _emailController,
                              focused: _emailFocused,
                              onFocusChange: (hasFocus) {
                                setState(() {
                                  _emailFocused = hasFocus;
                                });
                              },
                            ),

                            SizedBox(height: isVerySmallScreen ? 14 : 18),

                            // Senha e Confirmar senha lado a lado
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: RegisterPasswordField(
                                    theme: theme,
                                    isVerySmallScreen: isVerySmallScreen,
                                    controller: _passwordController,
                                    focused: _passwordFocused,
                                    isVisible: _isPasswordVisible,
                                    onFocusChange: (hasFocus) {
                                      setState(() {
                                        _passwordFocused = hasFocus;
                                      });
                                    },
                                    onToggleVisibility: () {
                                      setState(() {
                                        _isPasswordVisible = !_isPasswordVisible;
                                      });
                                    },
                                  ),
                                ),
                                SizedBox(width: isVerySmallScreen ? 10 : 14),
                                Expanded(
                                  child: RegisterConfirmPasswordField(
                                    theme: theme,
                                    isVerySmallScreen: isVerySmallScreen,
                                    controller: _confirmPasswordController,
                                    passwordController: _passwordController,
                                    focused: _confirmPasswordFocused,
                                    isVisible: _isConfirmPasswordVisible,
                                    onFocusChange: (hasFocus) {
                                      setState(() {
                                        _confirmPasswordFocused = hasFocus;
                                      });
                                    },
                                    onToggleVisibility: () {
                                      setState(() {
                                        _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
                                      });
                                    },
                                  ),
                                ),
                              ],
                            ),

                            SizedBox(height: isVerySmallScreen ? 15 : 20),

                            // Botão Avançar com gradiente
                            RegisterSubmitButton(
                              isVerySmallScreen: isVerySmallScreen,
                              isLoading: _isLoading,
                              onPressed: _isLoading ? null : _handleRegister,
                            ),

                            SizedBox(height: isVerySmallScreen ? 15 : 20),

                            // Link para fazer login
                            RegisterLoginLink(
                              isVerySmallScreen: isVerySmallScreen,
                              onTap: () {
                                Navigator.pop(context);
                              },
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
