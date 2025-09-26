import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lummy_login/main_navigation.dart';
import 'package:lummy_login/di/locator.dart';
import 'package:lummy_login/application/app_facade.dart';
import 'register_screen.dart';

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

    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF4A90E2).withOpacity(0.1),
              ),
              child: Center(
                child: CustomPaint(
                  size: const Size(24, 24),
                  painter: FingerprintIconPainter(
                    color: const Color(0xFF4A90E2),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Configurar Biometria',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Deseja habilitar a autenticação biométrica para facilitar seu próximo acesso?',
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: Colors.grey[700],
                height: 1.4,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF4A90E2).withOpacity(0.05),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: const Color(0xFF4A90E2).withOpacity(0.2),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.security,
                    color: const Color(0xFF4A90E2),
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Mais seguro e prático',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFF4A90E2),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(false);
              _navigateToMain();
            },
            child: Text(
              'Agora não',
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.grey[600],
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(context).pop(true);
              await _enableBiometricAndNavigate();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4A90E2),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            ),
            child: Text(
              'Habilitar',
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );

    if (result == false) {
      _navigateToMain();
    }
  }

  Future<void> _enableBiometricAndNavigate() async {
    final bio = locator<BiometricAuthService>();

    try {
      // Verificar se biometria está realmente disponível
      final isSupported = await bio.isDeviceSupported();
      final canCheck = await bio.canCheckBiometrics();

      print('Biometria - Suportada: $isSupported, Pode verificar: $canCheck');

      if (!isSupported || !canCheck) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Biometria não está disponível neste dispositivo.',
              style: GoogleFonts.poppins(fontSize: 14),
            ),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        );
        _navigateToMain();
        return;
      }

      // Testar autenticação biométrica
      final success = await bio.authenticate(reason: 'Configure sua biometria');

      print('Resultado da autenticação: $success');

      if (success) {
        await bio.setBiometricEnabled(true);
        await bio.cacheUserId('mock-user');
        print('Biometria configurada com sucesso');
        _navigateToMain();
      } else {
        // Se falhou, mostrar erro e navegar mesmo assim
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Autenticação biométrica cancelada ou falhou. Você pode tentar novamente.',
              style: GoogleFonts.poppins(fontSize: 14),
            ),
            backgroundColor: Colors.orange,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        );
        _navigateToMain();
      }
    } catch (e) {
      print('Erro na configuração biométrica: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Erro ao configurar biometria: ${e.toString()}',
            style: GoogleFonts.poppins(fontSize: 14),
          ),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      );
      _navigateToMain();
    }
  }

  void _navigateToMain() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => const MainNavigation(),
      ),
    );
  }

  Future<void> _testBiometric() async {
    try {
      final bio = locator<BiometricAuthService>();

      print('=== TESTE DE BIOMETRIA ===');

      final isSupported = await bio.isDeviceSupported();
      print('Dispositivo suporta biometria: $isSupported');

      final canCheck = await bio.canCheckBiometrics();
      print('Pode verificar biometria: $canCheck');

      final availableBiometrics = await bio.getAvailableBiometrics();
      print('Biometrias disponíveis: $availableBiometrics');

      final enabled = await bio.isBiometricEnabled();
      print('Biometria habilitada no app: $enabled');

      final cached = await bio.readCachedUserId();
      print('Usuário em cache: $cached');

      if (isSupported && canCheck && availableBiometrics.isNotEmpty) {
        print('Tentando autenticação...');
        final result = await bio.authenticate(reason: 'Teste de biometria');
        print('Resultado do teste: $result');

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Teste biométrico: ${result ? "SUCESSO" : "FALHOU"}',
              style: GoogleFonts.poppins(fontSize: 14),
            ),
            backgroundColor: result ? Colors.green : Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Biometria não está disponível para teste',
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
    } catch (e) {
      print('Erro no teste: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Erro no teste: ${e.toString()}',
            style: GoogleFonts.poppins(fontSize: 14),
          ),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      );
    }
  }

  Future<void> _handleLogin() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      await Future.delayed(const Duration(seconds: 2));

      // Simular login bem-sucedido
      final bio = locator<BiometricAuthService>();

      // Se biometria está disponível e habilitada, cachear o usuário
      if (_biometricAvailable && _biometricEnabled) {
        await bio.cacheUserId('mock-user');
        _cachedUserId = 'mock-user';
      }

      // Se biometria está disponível mas não habilitada, oferecer para habilitar
      if (_biometricAvailable && !_biometricEnabled) {
        _showBiometricSetupDialog();
        return;
      }

      setState(() {
        _isLoading = false;
      });

      // Navegar para a tela de configuração de perfil após login bem-sucedido
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const MainNavigation(),
        ),
      );
    }
  }

  Future<void> _authenticateWithBiometrics() async {
    try {
      final bio = locator<BiometricAuthService>();

      // Verificar se biometria ainda está disponível
      final isSupported = await bio.isDeviceSupported();
      final canCheck = await bio.canCheckBiometrics();
      final enabled = await bio.isBiometricEnabled();

      print(
          'Biometria - Suportada: $isSupported, Pode verificar: $canCheck, Habilitada: $enabled');

      if (!isSupported || !canCheck || !enabled) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Biometria não está disponível ou foi desabilitada.',
              style: GoogleFonts.poppins(fontSize: 14),
            ),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        );
        return;
      }

      final ok = await bio.authenticate(reason: 'Confirmar com biometria');
      print('Resultado da autenticação biométrica: $ok');

      if (!mounted) return;

      if (ok) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const MainNavigation()),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Autenticação biométrica cancelada ou falhou.',
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
    } catch (e) {
      print('Erro na autenticação biométrica: $e');
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Erro na autenticação biométrica: ${e.toString()}',
            style: GoogleFonts.poppins(fontSize: 14),
          ),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
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

    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: SingleChildScrollView(
        physics: const ClampingScrollPhysics(),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            minHeight: screenHeight,
          ),
          child: Stack(
            children: [
              // Fundo azul ocupando toda a tela
              Container(
                width: double.infinity,
                height: screenHeight,
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
                      height:
                          isVerySmallScreen ? 250 : (isSmallScreen ? 300 : 380),
                      width:
                          isVerySmallScreen ? 250 : (isSmallScreen ? 300 : 380),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(isVerySmallScreen
                            ? 125
                            : (isSmallScreen ? 150 : 190)),
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
                                    : (isSmallScreen ? 30 : 50)), // Responsivo

                            // Título "Faça Login" - responsivo
                            Text(
                              'Faça Login',
                              style: GoogleFonts.inter(
                                fontSize: isVerySmallScreen
                                    ? 24
                                    : 28, // Menor em telas pequenas
                                fontWeight: FontWeight.w600,
                                color: Colors.black,
                              ),
                            ),

                            SizedBox(
                                height:
                                    isVerySmallScreen ? 20 : 30), // Responsivo

                            // Campo Email estilizado
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF8F9FA),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: _emailFocused
                                      ? const Color(0xFF4A90E2)
                                      : Colors.transparent,
                                  width: 2,
                                ),
                                boxShadow: _emailFocused
                                    ? [
                                        BoxShadow(
                                          color: const Color(0xFF4A90E2)
                                              .withOpacity(0.1),
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
                                    color: Colors.black87,
                                    fontWeight: FontWeight.w500,
                                  ),
                                  decoration: InputDecoration(
                                    hintText: 'Seu E-mail',
                                    hintStyle: GoogleFonts.poppins(
                                      color: Colors.grey[500],
                                      fontSize: isVerySmallScreen ? 14 : 16,
                                      fontWeight: FontWeight.w400,
                                    ),
                                    prefixIcon: Icon(
                                      Icons.email_outlined,
                                      color: _emailFocused
                                          ? const Color(0xFF4A90E2)
                                          : Colors.grey[500],
                                      size: isVerySmallScreen
                                          ? 20
                                          : 22, // Responsivo
                                    ),
                                    border: InputBorder.none,
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
                                            r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                                        .hasMatch(value)) {
                                      return 'Por favor, insira um e-mail válido';
                                    }
                                    return null;
                                  },
                                ),
                              ),
                            ),

                            SizedBox(
                                height:
                                    isVerySmallScreen ? 12 : 16), // Responsivo

                            // Campo Senha estilizado
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF8F9FA),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: _passwordFocused
                                      ? const Color(0xFF4A90E2)
                                      : Colors.transparent,
                                  width: 2,
                                ),
                                boxShadow: _passwordFocused
                                    ? [
                                        BoxShadow(
                                          color: const Color(0xFF4A90E2)
                                              .withOpacity(0.1),
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
                                    color: Colors.black87,
                                    fontWeight: FontWeight.w500,
                                  ),
                                  decoration: InputDecoration(
                                    hintText: 'Sua Senha',
                                    hintStyle: GoogleFonts.poppins(
                                      color: Colors.grey[500],
                                      fontSize: isVerySmallScreen ? 14 : 16,
                                      fontWeight: FontWeight.w400,
                                    ),
                                    prefixIcon: Icon(
                                      Icons.lock_outline,
                                      color: _passwordFocused
                                          ? const Color(0xFF4A90E2)
                                          : Colors.grey[500],
                                      size: isVerySmallScreen ? 20 : 22,
                                    ),
                                    border: InputBorder.none,
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
                                            ? const Color(0xFF4A90E2)
                                            : Colors.grey[500],
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
                            ),

                            SizedBox(
                                height:
                                    isVerySmallScreen ? 20 : 30), // Responsivo

                            // Ícone de digital discreto (mostra só após 1º login habilitado)
                            if (_biometricAvailable &&
                                _biometricEnabled &&
                                _cachedUserId != null) ...[
                              Align(
                                alignment: Alignment.centerRight,
                                child: IconButton(
                                  tooltip: 'Entrar com digital',
                                  onPressed: _authenticateWithBiometrics,
                                  icon: SizedBox(
                                    width: 22,
                                    height: 22,
                                    child: CustomPaint(
                                      painter: FingerprintIconPainter(
                                          color: const Color(0xFF4A90E2)),
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(height: isVerySmallScreen ? 8 : 12),
                            ],

                            // Botão de debug temporário (remover depois)
                            if (_biometricAvailable) ...[
                              Center(
                                child: TextButton(
                                  onPressed: _testBiometric,
                                  child: Text(
                                    'Testar Biometria (Debug)',
                                    style: GoogleFonts.poppins(
                                      fontSize: 12,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ),
                              ),
                            ],

                            // Sem botão extra de digital – apenas ícone acima

                            // Botão Login com gradiente
                            Container(
                              width: double.infinity,
                              height: isVerySmallScreen ? 50 : 56, // Responsivo
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
                                onPressed: _isLoading ? null : _handleLogin,
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
                                            Colors.white,
                                          ),
                                        ),
                                      )
                                    : Text(
                                        'Login',
                                        style: GoogleFonts.poppins(
                                          fontSize: isVerySmallScreen ? 16 : 18,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                              ),
                            ),

                            SizedBox(
                                height:
                                    isVerySmallScreen ? 20 : 30), // Responsivo

                            // Link para criar conta - com navegação
                            Center(
                              child: GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          const RegisterScreen(),
                                    ),
                                  );
                                },
                                child: RichText(
                                  text: TextSpan(
                                    children: [
                                      TextSpan(
                                        text: 'Ainda não tem uma conta? ',
                                        style: GoogleFonts.poppins(
                                          color: const Color(0xFF9E9E9E),
                                          fontSize: isVerySmallScreen ? 12 : 14,
                                          fontWeight: FontWeight.w400,
                                        ),
                                      ),
                                      TextSpan(
                                        text: 'Crie uma conta',
                                        style: GoogleFonts.poppins(
                                          color: const Color(0xFF003092),
                                          fontSize: isVerySmallScreen ? 12 : 14,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),

                            SizedBox(
                                height:
                                    isVerySmallScreen ? 15 : 20), // Responsivo
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
      size.width * 0.75, 20, // Ponto de controle
      size.width * 0.5, 20, // Ponto médio
    );

    path.quadraticBezierTo(
      size.width * 0.25, 20, // Ponto de controle
      0, 60, // Ponto final
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
      Offset center, double radius, double startAngle, double sweepAngle) {
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
