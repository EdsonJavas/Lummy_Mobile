import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:lummy/core/services/connectivity_service.dart';
import 'package:lummy/screens/child/main_navigation.dart';
import 'package:lummy/di/locator.dart';
import 'package:lummy/application/app_facade.dart';
import 'package:lummy/core/result.dart';
import 'package:lummy/domain/entities/user_entity.dart';
import 'package:lummy/screens/parent/parent_main_navigation.dart';
import 'package:lummy/services/family_service.dart';
import 'package:lummy/core/theme/app_theme.dart';
import 'package:lummy/core/providers/theme_provider.dart';
import 'package:lummy/screens/auth/register_screen.dart';
import 'package:lummy/screens/auth/widgets/login/login_astronaut_illustration.dart';
import 'package:lummy/screens/auth/widgets/login/login_biometric_button.dart';
import 'package:lummy/screens/auth/widgets/login/login_biometric_setup_dialog.dart';
import 'package:lummy/screens/auth/widgets/login/login_different_account_dialog.dart';
import 'package:lummy/screens/auth/widgets/login/login_email_field.dart';
import 'package:lummy/screens/auth/widgets/login/login_forgot_password_dialog.dart';
import 'package:lummy/screens/auth/widgets/login/login_forgot_password_link.dart';
import 'package:lummy/screens/auth/widgets/login/login_form_panel.dart';
import 'package:lummy/screens/auth/widgets/login/login_logo_header.dart';
import 'package:lummy/screens/auth/widgets/login/login_offline_card.dart';
import 'package:lummy/screens/auth/widgets/login/login_password_field.dart';
import 'package:lummy/screens/auth/widgets/login/login_register_prompt.dart';
import 'package:lummy/screens/auth/widgets/login/login_submit_button.dart';
import 'package:lummy/screens/auth/widgets/login/login_title.dart';
import 'package:lummy/core/utils/app_log.dart';
import 'package:lummy/core/theme/design_tokens.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isPasswordVisible = false;
  bool _isLoading = false;
  bool _emailFocused = false;
  bool _passwordFocused = false;
  bool _biometricAvailable = false;
  bool _biometricEnabled = false;
  String? _cachedUserId;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _loadBiometricState();
  }

  Future<void> _loadBiometricState() async {
    final bio = locator<BiometricAuthService>();
    final supported = await bio.canCheckBiometrics();
    final enabled = await bio.isBiometricEnabled();
    final cached = await bio.readCachedUserId();
    setState(() {
      _biometricAvailable = supported;
      _biometricEnabled = enabled;
      _cachedUserId = cached;
    });
  }

  Future<void> _showBiometricSetupDialog() async {
    setState(() {
      _isLoading = false;
    });

    // Mostrar diálogo perguntando se deseja salvar a digital
    final shouldEnable = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => const LoginBiometricSetupDialog(),
    );

    if (shouldEnable == true) {
      final bio = locator<BiometricAuthService>();
      await bio.cacheCredentials(
        _emailController.text.trim(),
        _passwordController.text,
      );
      await bio.setBiometricEnabled(true);
      setState(() {
        _biometricEnabled = true;
      });
    }
  }

  /// Diálogo quando o usuário entrou com uma conta diferente da última que usou digital.
  Future<bool?> _showDifferentAccountBiometricDialog() async {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => const LoginDifferentAccountDialog(),
    );
  }

  Future<void> _navigateAccordingToProfile(String userId) async {
    final familyService = locator<FamilyService>();

    try {
      
      final profile = await familyService.fetchUserProfile(userId);

      if (!mounted) return;

      if (profile is ParentEntity) {
        if (!mounted) return;
        context.read<ThemeProvider>().setPreLoginLightOnly(false);
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => ParentMainNavigation(
              parentId: profile.id,
              parentName: profile.name,
            ),
          ),
        );
      } else if (profile is ChildEntity) {
        if (!mounted) return;
        context.read<ThemeProvider>().setPreLoginLightOnly(false);
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const MainNavigation()),
        );
      } else {
        appLog('⚠️ Perfil não encontrado para o usuário: $userId');
        _showLoginError(
          'Não encontramos o perfil desta conta.\n\n'
          'Se você ainda não terminou o cadastro, conclua-o e tente de novo. '
          'Se o problema continuar, fale com o suporte.',
        );
      }
    } catch (e, stackTrace) {
      appLog('❌ Erro ao navegar para perfil: $e');
      appLog('   Stack trace: $stackTrace');
      if (!mounted) return;
      _showLoginError(
        'Não foi possível carregar as informações do usuário.\n\n'
        'Erro: ${e.toString()}\n\n'
        'Verifique sua conexão com a internet e tente novamente.',
      );
    }
  }

  void _showLoginError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: LummyFonts.body(fontSize: 14)),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  Future<void> _showForgotPasswordDialog() async {
    final emailController = TextEditingController(text: _emailController.text);
    final formKey = GlobalKey<FormState>();

    final sent = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => LoginForgotPasswordDialog(
        formKey: formKey,
        emailController: emailController,
        onSubmit: () async {
          if (!formKey.currentState!.validate()) return;
          final email = emailController.text.trim();
          try {
            await Supabase.instance.client.auth.resetPasswordForEmail(email);
            if (context.mounted) Navigator.of(context).pop(true);
          } on AuthException catch (e) {
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    e.message.contains('rate limit') ? 'Muitas tentativas. Tente novamente em alguns minutos.' : e.message,
                    style: LummyFonts.body(fontSize: 14),
                  ),
                  backgroundColor: Colors.red,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            }
          } catch (e) {
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Erro ao enviar. Verifique sua conexão.',
                    style: LummyFonts.body(fontSize: 14),
                  ),
                  backgroundColor: Colors.red,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            }
          }
        },
      ),
    );

    if (sent == true && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle_rounded, color: Colors.white, size: 22),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Verifique seu e-mail. Enviamos um link para redefinir sua senha.',
                  style: LummyFonts.body(fontSize: 14, fontWeight: FontWeight.w500),
                ),
              ),
            ],
          ),
          backgroundColor: LummyColors.emerald500,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 5),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    }
  }

  Future<void> _handleLogin() async {
    if (_formKey.currentState!.validate()) {
      if (!context.read<ConnectivityService>().isOnline) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Sem internet. Conecte-se e toque em TENTAR NOVAMENTE no aviso acima.',
              style: LummyFonts.body(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            behavior: SnackBarBehavior.floating,
            backgroundColor: LummyColors.orange600,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
        return;
      }

      setState(() {
        _isLoading = true;
      });

      final appFacade = locator<AppFacade>();
      final result = await appFacade.login(
        _emailController.text,
        _passwordController.text,
      );

      setState(() {
        _isLoading = false;
      });

      if (result is Success<String>) {
        final userId = result.value;
        final bio = locator<BiometricAuthService>();
        final currentEmail = _emailController.text.trim();

        // Ler quem estava guardado ANTES de sobrescrever (para saber se é outra conta)
        final cachedEmailBefore = await bio.readCachedUserId();

        // Sempre guardar esta conta como última que fez login (digital abre na última conta)
        await bio.cacheUserId(currentEmail);
        setState(() => _cachedUserId = currentEmail);

        if (_biometricAvailable) {
          final isDifferentAccount = cachedEmailBefore != null &&
              cachedEmailBefore.trim().toLowerCase() != currentEmail.trim().toLowerCase();
          final hadBiometricEnabled = await bio.isBiometricEnabled();

          if (isDifferentAccount && hadBiometricEnabled) {
            // Entrou com outra conta; a digital estava ativa noutra → perguntar se quer usar nesta
            final wantToAdd = await _showDifferentAccountBiometricDialog();
            if (wantToAdd == true) {
              await bio.cacheCredentials(currentEmail, _passwordController.text);
              await bio.setBiometricEnabled(true);
              setState(() => _biometricEnabled = true);
            } else {
              await bio.setBiometricEnabled(false);
              await bio.clearCachedUser();
              setState(() => _biometricEnabled = false);
            }
          } else if (!hadBiometricEnabled) {
            // Mesma conta ou primeira vez: perguntar se quer ativar digital
            await _showBiometricSetupDialog();
          } else {
            // Mesma conta com digital já ativa: atualizar senha em cache
            await bio.cacheCredentials(currentEmail, _passwordController.text);
          }
        }
        await _navigateAccordingToProfile(userId);
      } else {
        final errorMsg = result.error?.message ?? 'Erro desconhecido ao fazer login';
        appLog('❌ Erro no login: $errorMsg');
        _showLoginError(errorMsg);
      }
    }
  }

  Future<void> _authenticateWithBiometrics() async {
    if (_cachedUserId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Nenhum usuário salvo para autenticação biométrica.',
            style: LummyFonts.body(fontSize: 14),
          ),
          backgroundColor: Colors.orange,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      );
      return;
    }

    if (!context.read<ConnectivityService>().isOnline) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Sem internet. A biometria precisa de conexão para validar o login.',
            style: LummyFonts.body(fontSize: 14, fontWeight: FontWeight.w500),
          ),
          behavior: SnackBarBehavior.floating,
          backgroundColor: LummyColors.orange600,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
      return;
    }

    try {
      final bio = locator<BiometricAuthService>();

      // Verificar se biometria ainda está disponível
      final isSupported = await bio.isDeviceSupported();
      final canCheck = await bio.canCheckBiometrics();
      final enabled = await bio.isBiometricEnabled();

      if (!isSupported || !canCheck || !enabled) {
        // Se biometria não está mais disponível, desabilitar e limpar cache
        await bio.setBiometricEnabled(false);
        await bio.clearCachedUser();
        setState(() {
          _biometricEnabled = false;
          _cachedUserId = null;
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Biometria não está mais disponível. Use email e senha para fazer login.',
                style: LummyFonts.body(fontSize: 14),
              ),
              backgroundColor: Colors.orange,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          );
        }
        return;
      }

      final ok = await bio.authenticate(reason: 'Confirmar com biometria');

      if (!mounted) return;

      if (ok) {
        setState(() => _isLoading = true);

        try {
          final appFacade = locator<AppFacade>();
          final loginResult = await appFacade.loginWithBiometrics(
            _cachedUserId!,
          );

          if (!mounted) return;

          setState(() => _isLoading = false);

          if (loginResult is Success<String>) {
            await _navigateAccordingToProfile(loginResult.value);
          } else {
            _showLoginError(
              loginResult.error?.message ??
                  'Erro ao fazer login com biometria. Tente fazer login com email e senha.',
            );
          }
        } catch (e) {
          if (!mounted) return;
          setState(() => _isLoading = false);
          _showLoginError(
            'Erro ao processar login biométrico: ${e.toString()}',
          );
        }
      } else {
        // Usuário cancelou ou falhou - apenas informar, não bloquear
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Autenticação biométrica cancelada. Use email e senha para fazer login.',
                style: LummyFonts.body(fontSize: 14),
              ),
              backgroundColor: Colors.blue,
              behavior: SnackBarBehavior.floating,
              duration: const Duration(seconds: 2),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          );
        }
      }
    } catch (e) {
      appLog('Erro na autenticação biométrica: $e');
      if (!mounted) return;

      // Em caso de erro, desabilitar biometria para evitar loops
      try {
        final bio = locator<BiometricAuthService>();
        await bio.setBiometricEnabled(false);
        await bio.clearCachedUser();
        setState(() {
          _biometricEnabled = false;
          _cachedUserId = null;
        });
      } catch (_) {
        // Ignorar erro ao limpar
      }

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Erro na autenticação biométrica. Use email e senha para fazer login.',
            style: LummyFonts.body(fontSize: 14),
          ),
          backgroundColor: Colors.orange,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 3),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      );
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

    // Tema lido com o context da tela, ou seja, ACIMA do wrapper
    // Theme(AppTheme.lightTheme) abaixo (mesmo valor que o build usava antes).
    final theme = Theme.of(context);

    // Tela de login sempre em tema claro (não aplica dark mode)
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
              // Fundo sempre claro (login não usa dark mode)
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

              // Logo no topo - usando Google Fonts
              LoginLogoHeader(
                isVerySmallScreen: isVerySmallScreen,
                theme: theme,
              ),

              // Astronauta - totalmente responsivo
              Positioned(
                top: isVerySmallScreen
                    ? screenHeight * 0.08
                    : screenHeight * 0.10,
                left: screenWidth * 0.15,
                right: screenWidth * 0.05,
                child: LoginAstronautIllustration(
                  isVerySmallScreen: isVerySmallScreen,
                  isSmallScreen: isSmallScreen,
                ),
              ),

              // Formulário na parte inferior - totalmente responsivo
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: LoginFormPanel(
                  isVerySmallScreen: isVerySmallScreen,
                  screenHeight: screenHeight,
                  keyboardHeight: keyboardHeight,
                  theme: theme,
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          height: isVerySmallScreen
                              ? 20
                              : (isSmallScreen ? 30 : 50),
                        ), // Responsivo
                        // Título "Faça Login" - "og" em laranja e azul como Lummy
                        LoginTitle(
                          isVerySmallScreen: isVerySmallScreen,
                          theme: theme,
                        ),

                        SizedBox(
                          height: isVerySmallScreen ? 12 : 16,
                        ), // Responsivo
                        // Botão de Login com Biometria
                        if (_biometricAvailable &&
                            _biometricEnabled &&
                            _cachedUserId != null)
                          LoginBiometricButton(
                            isVerySmallScreen: isVerySmallScreen,
                            onPressed: _authenticateWithBiometrics,
                          ),

                        // Campo Email estilizado
                        LoginEmailField(
                          controller: _emailController,
                          isFocused: _emailFocused,
                          onFocusChange: (hasFocus) {
                            setState(() {
                              _emailFocused = hasFocus;
                            });
                          },
                          isVerySmallScreen: isVerySmallScreen,
                          theme: theme,
                        ),

                        SizedBox(
                          height: isVerySmallScreen ? 12 : 16,
                        ), // Responsivo
                        // Campo Senha estilizado
                        LoginPasswordField(
                          controller: _passwordController,
                          isPasswordVisible: _isPasswordVisible,
                          isFocused: _passwordFocused,
                          onFocusChange: (hasFocus) {
                            setState(() {
                              _passwordFocused = hasFocus;
                            });
                          },
                          onToggleVisibility: () {
                            setState(() {
                              _isPasswordVisible =
                                  !_isPasswordVisible;
                            });
                          },
                          isVerySmallScreen: isVerySmallScreen,
                          theme: theme,
                        ),

                        LoginForgotPasswordLink(
                          isVerySmallScreen: isVerySmallScreen,
                          onPressed: _isLoading ? null : _showForgotPasswordDialog,
                        ),

                        SizedBox(
                          height: isVerySmallScreen ? 16 : 20,
                        ), // Responsivo
                        // Botão de Login
                        LoginSubmitButton(
                          isLoading: _isLoading,
                          isVerySmallScreen: isVerySmallScreen,
                          onPressed: _handleLogin,
                        ),

                        SizedBox(
                          height: isVerySmallScreen ? 16 : 20,
                        ), // Responsivo
                        // Link para Registrar
                        LoginRegisterPrompt(
                          isVerySmallScreen: isVerySmallScreen,
                          theme: theme,
                          onRegisterTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    const RegisterScreen(),
                              ),
                            );
                          },
                        ),

                        SizedBox(
                          height: isVerySmallScreen ? 15 : 20,
                        ), // Responsivo
                      ],
                    ),
                  ),
                ),
              ),
              Consumer<ConnectivityService>(
                builder: (context, connectivity, _) {
                  final pad = MediaQuery.paddingOf(context);
                  return Positioned(
                    top: pad.top + 8,
                    left: 16,
                    right: 16,
                    child: AnimatedSize(
                      duration: const Duration(milliseconds: 280),
                      curve: Curves.easeInOutCubic,
                      alignment: Alignment.topCenter,
                      clipBehavior: Clip.hardEdge,
                      child: connectivity.isOnline
                          ? const SizedBox(width: double.infinity, height: 0)
                          : LoginOfflineCard(
                              onRetry: () => connectivity.recheck(),
                              compact: isVerySmallScreen,
                            ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
      ),
    );
  }
}
