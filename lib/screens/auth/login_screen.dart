import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lummy_login/screens/child/main_navigation.dart';
import 'package:lummy_login/di/locator.dart';
import 'package:lummy_login/application/app_facade.dart';
import 'package:lummy_login/core/result.dart';
import 'package:lummy_login/domain/entities/user_entity.dart';
import 'package:lummy_login/screens/parent/parent_main_navigation.dart';
import 'package:lummy_login/services/family_service.dart';
import 'package:lummy_login/utils/login_debug_helper.dart';
import 'package:lummy_login/core/theme/app_theme.dart';
import 'package:lummy_login/screens/auth/register_screen.dart';

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
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        elevation: 0,
        child: Container(
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: Theme.of(context).cardTheme.color,
            borderRadius: BorderRadius.circular(28),
            border: Theme.of(context).brightness == Brightness.dark
                ? Border.all(color: const Color(0xFF475569), width: 1)
                : null,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.15),
                blurRadius: 30,
                offset: const Offset(0, 15),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Ícone de biometria
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: Theme.of(context).brightness == Brightness.dark
                        ? [
                            const Color(0xFF3B82F6).withOpacity(0.2),
                            const Color(0xFF8B5CF6).withOpacity(0.1),
                          ]
                        : [
                            const Color(0xFF1E40AF).withOpacity(0.1),
                            const Color(0xFF8B5CF6).withOpacity(0.05),
                          ],
                  ),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Theme.of(context).brightness == Brightness.dark
                        ? const Color(0xFF3B82F6).withOpacity(0.3)
                        : const Color(0xFF1E40AF).withOpacity(0.2),
                    width: 2,
                  ),
                ),
                child: Icon(
                  Icons.fingerprint,
                  size: 64,
                  color: Theme.of(context).brightness == Brightness.dark
                      ? const Color(0xFF3B82F6)
                      : const Color(0xFF1E40AF),
                ),
              ),
              const SizedBox(height: 24),
              // Título
              ShaderMask(
                shaderCallback: (bounds) => LinearGradient(
                  colors: Theme.of(context).brightness == Brightness.dark
                      ? [const Color(0xFF3B82F6), const Color(0xFF8B5CF6)]
                      : [const Color(0xFF1E293B), const Color(0xFF1E293B)],
                ).createShader(bounds),
                child: Text(
                  'Ativar Biometria?',
                  style: GoogleFonts.poppins(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 12),
              // Descrição
              Text(
                'Salve sua digital para fazer login de forma rápida e segura nos próximos acessos!',
                style: GoogleFonts.poppins(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: Theme.of(context).textTheme.bodyMedium?.color,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 28),
              // Botões
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Navigator.of(context).pop(false),
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            Theme.of(context).brightness == Brightness.dark
                            ? const Color(0xFF334155)
                            : const Color(0xFFF1F5F9),
                        foregroundColor: Theme.of(context).brightness == Brightness.dark
                            ? const Color(0xFFE2E8F0)
                            : Theme.of(context).textTheme.bodyMedium?.color,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                          side: BorderSide(
                            color:
                                Theme.of(context).brightness == Brightness.dark
                                ? const Color(0xFF475569)
                                : const Color(0xFFE2E8F0),
                            width: 1,
                          ),
                        ),
                        elevation: 0,
                      ),
                      child: Text(
                        'Agora Não',
                        style: GoogleFonts.poppins(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Navigator.of(context).pop(true),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF3B82F6),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        elevation: 0,
                      ),
                      child: Text(
                        'Ativar',
                        style: GoogleFonts.poppins(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
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
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        elevation: 0,
        child: Container(
          padding: const EdgeInsets.all(28),
          decoration: BoxDecoration(
            color: Theme.of(context).cardTheme.color,
            borderRadius: BorderRadius.circular(24),
            border: Theme.of(context).brightness == Brightness.dark
                ? Border.all(color: const Color(0xFF475569), width: 1)
                : null,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.12),
                blurRadius: 24,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.fingerprint,
                size: 56,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(height: 20),
              Text(
                'Outra conta',
                style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: Theme.of(context).textTheme.titleLarge?.color,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              Text(
                'Você entrou com uma conta diferente da última. Deseja usar digital para esta conta daqui pra frente?',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Theme.of(context).textTheme.bodyMedium?.color,
                  height: 1.45,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(false),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: Text(
                        'Não',
                        style: GoogleFonts.poppins(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton(
                      onPressed: () => Navigator.of(context).pop(true),
                      style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: Text(
                        'Sim, usar digital',
                        style: GoogleFonts.poppins(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _navigateAccordingToProfile(String userId) async {
    final familyService = locator<FamilyService>();

    try {
      debugPrint('🚀 Navegando para perfil do usuário: $userId');
      
      final profile = await familyService.fetchUserProfile(userId);

      if (!mounted) return;

      if (profile is ParentEntity) {
        debugPrint('✅ Navegando para dashboard do responsável: ${profile.name}');
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
        debugPrint('✅ Navegando para dashboard da criança: ${profile.name}');
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const MainNavigation()),
        );
      } else {
        debugPrint('⚠️ Perfil não encontrado para o usuário: $userId');
        
        // Executar diagnóstico
        final diagnosis = await LoginDebugHelper.diagnoseLoginIssue(userId);
        debugPrint('📊 Resultado do diagnóstico: $diagnosis');
        
        String errorMessage = 'Não encontramos o perfil associado a esta conta.\n\n';
        errorMessage += 'Diagnóstico: ${diagnosis['diagnosis'] ?? 'Erro desconhecido'}\n\n';
        errorMessage += 'Isso pode acontecer se:\n';
        errorMessage += '• Você ainda não completou o cadastro\n';
        errorMessage += '• Há um problema de conexão com o banco de dados\n';
        errorMessage += '• Há problema de permissões (RLS) no Supabase\n\n';
        errorMessage += 'Tente fazer o cadastro novamente ou entre em contato com o suporte.';
        
        _showLoginError(errorMessage);
      }
    } catch (e, stackTrace) {
      debugPrint('❌ Erro ao navegar para perfil: $e');
      debugPrint('   Stack trace: $stackTrace');
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
        content: Text(message, style: GoogleFonts.poppins(fontSize: 14)),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  Future<void> _handleLogin() async {
    if (_formKey.currentState!.validate()) {
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
        debugPrint('❌ Erro no login: $errorMsg');
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
            style: GoogleFonts.poppins(fontSize: 14),
          ),
          backgroundColor: Colors.orange,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
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
                style: GoogleFonts.poppins(fontSize: 14),
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
                style: GoogleFonts.poppins(fontSize: 14),
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
      debugPrint('Erro na autenticação biométrica: $e');
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

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Erro na autenticação biométrica. Use email e senha para fazer login.',
            style: GoogleFonts.poppins(fontSize: 14),
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
                    colors: [Color(0xFF4A90E2), Color(0xFF357ABD)],
                  ),
                ),
              ),

              // Logo no topo - usando Google Fonts
              SafeArea(
                child: Padding(
                  padding: EdgeInsets.only(
                    left: 24.0,
                    top: isVerySmallScreen ? 10 : 20, // Reduzido de 30
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
                                color: Theme.of(context).brightness == Brightness.dark
                                    ? const Color(0xFF60A5FA)
                                    : const Color(0xFF003092),
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

              // Astronauta - totalmente responsivo
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
                        : (isSmallScreen ? 300 : 380), // Mais responsivo
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

              // Formulário na parte inferior - totalmente responsivo
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: ClipPath(
                  clipper: FormTopClipper(),
                  child: Container(
                    constraints: BoxConstraints(
                      minHeight: isVerySmallScreen
                          ? screenHeight * 0.55
                          : screenHeight * 0.5,
                      maxHeight: isVerySmallScreen
                          ? screenHeight * 0.75
                          : screenHeight * 0.7,
                    ),
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardTheme.color,
                      border: Theme.of(context).brightness == Brightness.dark
                          ? Border.all(color: const Color(0xFF475569))
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
                        left: isVerySmallScreen
                            ? 20.0
                            : 24.0, // Menos padding em telas pequenas
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
                            SizedBox(
                              height: isVerySmallScreen
                                  ? 20
                                  : (isSmallScreen ? 30 : 50),
                            ), // Responsivo
                            // Título "Faça Login" - "og" em laranja e azul como Lummy
                            RichText(
                              text: TextSpan(
                                style: GoogleFonts.poppins(
                                  fontSize: isVerySmallScreen ? 24 : 28,
                                  fontWeight: FontWeight.w600,
                                  color: Theme.of(context).brightness == Brightness.dark
                                      ? Colors.white
                                      : const Color(0xFF1E293B),
                                ),
                                children: [
                                  const TextSpan(text: 'Faça L'),
                                  TextSpan(
                                    text: 'o',
                                    style: GoogleFonts.poppins(
                                      fontSize: isVerySmallScreen ? 24 : 28,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.orange,
                                    ),
                                  ),
                                  TextSpan(
                                    text: 'g',
                                    style: GoogleFonts.poppins(
                                      fontSize: isVerySmallScreen ? 24 : 28,
                                      fontWeight: FontWeight.w600,
                                      color: Theme.of(context).brightness == Brightness.dark
                                          ? const Color(0xFF60A5FA)
                                          : const Color(0xFF003092),
                                    ),
                                  ),
                                  const TextSpan(text: 'in'),
                                ],
                              ),
                            ),

                            SizedBox(
                              height: isVerySmallScreen ? 12 : 16,
                            ), // Responsivo
                            // Botão de Login com Biometria
                            if (_biometricAvailable &&
                                _biometricEnabled &&
                                _cachedUserId != null)
                              Padding(
                                padding: EdgeInsets.only(
                                  bottom: isVerySmallScreen ? 16 : 20,
                                ),
                                child: SizedBox(
                                  width: double.infinity,
                                  child: OutlinedButton.icon(
                                    onPressed: _authenticateWithBiometrics,
                                    icon: const Icon(
                                      Icons.fingerprint,
                                      color: Color(0xFF4A90E2),
                                    ),
                                    label: Text(
                                      'Entrar com Digital',
                                      style: GoogleFonts.poppins(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        color: const Color(0xFF4A90E2),
                                      ),
                                    ),
                                    style: OutlinedButton.styleFrom(
                                      side: const BorderSide(
                                        color: Color(0xFF4A90E2),
                                        width: 2,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 16,
                                      ),
                                    ),
                                  ),
                                ),
                              ),

                            // Campo Email estilizado
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
                                  fontSize: isVerySmallScreen
                                      ? 14
                                      : 16, // Responsivo
                                  color: Theme.of(
                                    context,
                                  ).textTheme.bodyLarge?.color,
                                  fontWeight: FontWeight.w500,
                                ),
                                decoration: InputDecoration(
                                  hintText: 'Seu E-mail',
                                  hintStyle: GoogleFonts.poppins(
                                    color: Theme.of(
                                      context,
                                    ).inputDecorationTheme.hintStyle?.color,
                                    fontSize: isVerySmallScreen ? 14 : 16,
                                    fontWeight: FontWeight.w400,
                                  ),
                                  prefixIcon: Icon(
                                    Icons.email_outlined,
                                    color: _emailFocused
                                        ? Theme.of(context).colorScheme.primary
                                        : Theme.of(context).iconTheme.color,
                                    size: isVerySmallScreen
                                        ? 20
                                        : 22, // Responsivo
                                  ),
                                  filled: true,
                                  fillColor: Theme.of(
                                    context,
                                  ).inputDecorationTheme.fillColor,
                                  contentPadding: EdgeInsets.symmetric(
                                    horizontal: isVerySmallScreen ? 16 : 20,
                                    vertical: isVerySmallScreen ? 14 : 18,
                                  ),
                                  errorStyle: GoogleFonts.poppins(
                                    fontSize: isVerySmallScreen ? 10 : 12,
                                  ),
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Por favor, insira seu e-mail';
                                  }
                                  if (!RegExp(
                                    r'^[\w-\.]+@[\w-]+\.[\w-]{2,4}$',
                                  ).hasMatch(value)) {
                                    return 'Por favor, insira um e-mail válido';
                                  }
                                  return null;
                                },
                              ),
                            ),

                            SizedBox(
                              height: isVerySmallScreen ? 12 : 16,
                            ), // Responsivo
                            // Campo Senha estilizado
                            Focus(
                              onFocusChange: (hasFocus) {
                                setState(() {
                                  _passwordFocused = hasFocus;
                                });
                              },
                              child: TextFormField(
                                controller: _passwordController,
                                obscureText: !_isPasswordVisible,
                                style: GoogleFonts.poppins(
                                  fontSize: isVerySmallScreen ? 14 : 16,
                                  color: Theme.of(
                                    context,
                                  ).textTheme.bodyLarge?.color,
                                  fontWeight: FontWeight.w500,
                                ),
                                decoration: InputDecoration(
                                  hintText: 'Sua Senha',
                                  hintStyle: GoogleFonts.poppins(
                                    color: Theme.of(
                                      context,
                                    ).inputDecorationTheme.hintStyle?.color,
                                    fontSize: isVerySmallScreen ? 14 : 16,
                                    fontWeight: FontWeight.w400,
                                  ),
                                  prefixIcon: Icon(
                                    Icons.lock_outline,
                                    color: _passwordFocused
                                        ? Theme.of(context).colorScheme.primary
                                        : Theme.of(context).iconTheme.color,
                                    size: isVerySmallScreen ? 20 : 22,
                                  ),
                                  filled: true,
                                  fillColor: Theme.of(
                                    context,
                                  ).inputDecorationTheme.fillColor,
                                  contentPadding: EdgeInsets.symmetric(
                                    horizontal: isVerySmallScreen ? 16 : 20,
                                    vertical: isVerySmallScreen ? 14 : 18,
                                  ),
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                      _isPasswordVisible
                                          ? Icons.visibility_outlined
                                          : Icons.visibility_off_outlined,
                                      color: _passwordFocused
                                          ? Theme.of(
                                              context,
                                            ).colorScheme.primary
                                          : Theme.of(context).iconTheme.color,
                                      size: isVerySmallScreen ? 20 : 22,
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        _isPasswordVisible =
                                            !_isPasswordVisible;
                                      });
                                    },
                                  ),
                                  errorStyle: GoogleFonts.poppins(
                                    fontSize: isVerySmallScreen ? 10 : 12,
                                  ),
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Por favor, insira sua senha';
                                  }
                                  if (value.length < 6) {
                                    return 'A senha deve ter pelo menos 6 caracteres';
                                  }
                                  return null;
                                },
                              ),
                            ),

                            SizedBox(
                              height: isVerySmallScreen ? 16 : 20,
                            ), // Responsivo
                            // Botão de Login
                            Container(
                              width: double.infinity,
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [
                                    Color(0xFFFF8C42),
                                    Color(0xFFFF5722),
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius: BorderRadius.circular(
                                  isVerySmallScreen ? 25 : 28,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(
                                      0xFFFF8C42,
                                    ).withOpacity(0.3),
                                    blurRadius: 12,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: ElevatedButton(
                                onPressed: _isLoading ? null : _handleLogin,
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
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 12,
                                  ),
                                  child: _isLoading
                                      ? SizedBox(
                                          height: isVerySmallScreen ? 18 : 20,
                                          width: isVerySmallScreen ? 18 : 20,
                                          child:
                                              const CircularProgressIndicator(
                                                strokeWidth: 2,
                                                valueColor:
                                                    AlwaysStoppedAnimation<
                                                      Color
                                                    >(Colors.white),
                                              ),
                                        )
                                      : Text(
                                          'Entrar',
                                          style: GoogleFonts.poppins(
                                            fontSize: isVerySmallScreen
                                                ? 16
                                                : 18,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                ),
                              ),
                            ),

                            SizedBox(
                              height: isVerySmallScreen ? 16 : 20,
                            ), // Responsivo
                            // Link para Registrar
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'Não tem uma conta?',
                                  style: GoogleFonts.poppins(
                                    fontSize: isVerySmallScreen ? 12 : 14,
                                    color: Theme.of(context).brightness == Brightness.dark
                                        ? const Color(0xFFCBD5E1)
                                        : Theme.of(context).textTheme.bodyMedium?.color,
                                  ),
                                ),
                                TextButton(
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            const RegisterScreen(),
                                      ),
                                    );
                                  },
                                  child: Text(
                                    'Registre-se',
                                    style: GoogleFonts.poppins(
                                      fontSize: isVerySmallScreen ? 12 : 14,
                                      fontWeight: FontWeight.w600,
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.primary,
                                    ),
                                  ),
                                ),
                              ],
                            ),

                            SizedBox(
                              height: isVerySmallScreen ? 15 : 20,
                            ), // Responsivo
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

// Classe personalizada para criar a curva na parte superior do formulário
class FormTopClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();

    // Começar do canto inferior esquerdo
    path.moveTo(0, size.height);

    // Linha para o canto inferior direito
    path.lineTo(size.width, size.height);

    // Linha para o canto superior direito (mas um pouco abaixo para criar a curva)
    path.lineTo(size.width, 60);

    // Criar uma curva suave na parte superior
    path.quadraticBezierTo(
      size.width * 0.75,
      20, // Ponto de controle
      size.width * 0.5,
      20, // Ponto médio
    );

    path.quadraticBezierTo(
      size.width * 0.25,
      20, // Ponto de controle
      0,
      60, // Ponto final
    );

    // Fechar o caminho
    path.close();

    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

// Painter para o ícone pequeno de digital
class FingerprintIconPainter extends CustomPainter {
  final Color color;

  FingerprintIconPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width * 0.35;

    // Desenhar linhas simples da digital
    final lines = [
      // Linha superior
      _createArcPath(center, radius * 0.3, -0.3, 0.6),
      // Linha do meio
      _createArcPath(center, radius * 0.5, -0.2, 0.4),
      // Linha inferior
      _createArcPath(center, radius * 0.7, -0.1, 0.2),
    ];

    for (final line in lines) {
      canvas.drawPath(line, paint);
    }

    // Pontos da digital
    final dotPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final dots = [
      Offset(center.dx - radius * 0.2, center.dy - radius * 0.1),
      Offset(center.dx + radius * 0.15, center.dy - radius * 0.2),
      Offset(center.dx - radius * 0.1, center.dy + radius * 0.1),
      Offset(center.dx + radius * 0.2, center.dy + radius * 0.05),
    ];

    for (final dot in dots) {
      canvas.drawCircle(dot, 0.8, dotPaint);
    }
  }

  Path _createArcPath(
    Offset center,
    double radius,
    double startAngle,
    double sweepAngle,
  ) {
    final path = Path();
    path.addArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepAngle,
    );
    return path;
  }

  @override
  bool shouldRepaint(FingerprintIconPainter oldDelegate) {
    return oldDelegate.color != color;
  }
}
