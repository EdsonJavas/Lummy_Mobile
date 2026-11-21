import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'package:lummy/core/providers/child_profile_controller.dart';
import 'package:lummy/core/providers/child_theme_color_controller.dart';
import 'package:lummy/core/theme/design_tokens.dart';
import 'package:lummy/core/theme/lummy_cores.dart';
import 'package:lummy/screens/child/widgets/drawer/child_drawer.dart';
import 'package:lummy/screens/child/widgets/v1/child_bottom_nav.dart';
import 'package:lummy/screens/child/widgets/v1/child_shell_scope.dart';
import 'package:lummy/shared/widgets/widgets.dart';

import 'expenses_screen.dart';
import 'goals_screen.dart';
import 'home_page.dart';
import 'lessons_screen.dart';

/// Casca da área da criança (redesenho V1).
///
/// - As 4 abas continuam num `IndexedStack` (D15): todas montam no primeiro
///   build e guardam o estado ao trocar de aba.
/// - Menu de baixo em cápsula + degradê branco (C-1), por cima do conteúdo.
/// - Menu lateral novo (`ChildDrawer`), aberto pelo avatar de qualquer aba via
///   `ChildShellScope.read(context)?.openDrawer()`.
/// - Segue o modo claro/escuro do app: as cores vêm de `context.cores`
///   (`LummyCores`), registradas nos dois temas.
/// - Carrega a cor do tema e o perfil da criança ao abrir.
class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  int _currentIndex = ChildTabs.inicio;
  DateTime? _lastBackPress;

  final List<Widget> _pages = const [
    HomePage(),
    ExpensesScreen(),
    GoalsScreen(),
    LessonsScreen(),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<ChildThemeColorController>().loadForCurrentUser();
      context.read<ChildProfileController>().loadForCurrentUser();
    });
  }

  bool get _drawerAberto => _scaffoldKey.currentState?.isDrawerOpen ?? false;

  void _abrirMenu() => _scaffoldKey.currentState?.openDrawer();

  void _fecharMenu() {
    if (_drawerAberto) _scaffoldKey.currentState?.closeDrawer();
  }

  void _irParaAba(int index) {
    _fecharMenu();
    if (index == _currentIndex) return;
    setState(() => _currentIndex = index);
  }

  void _depoisDeFecharMenu(void Function(BuildContext shellContext) acao) {
    _fecharMenu();
    // O contexto do Scaffold continua montado depois de fechar o menu.
    final ctx = _scaffoldKey.currentContext ?? context;
    acao(ctx);
  }

  Future<bool> _onWillPop() async {
    // Menu lateral aberto: o voltar só fecha o menu.
    if (_drawerAberto) {
      _fecharMenu();
      return false;
    }

    // Se não estiver na primeira aba, volta para ela
    if (_currentIndex != ChildTabs.inicio) {
      setState(() => _currentIndex = ChildTabs.inicio);
      return false;
    }

    // Se já estiver na primeira aba, verifica double tap para sair
    final now = DateTime.now();
    if (_lastBackPress == null ||
        now.difference(_lastBackPress!) > const Duration(seconds: 2)) {
      _lastBackPress = now;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Pressione voltar novamente para sair',
            style: LummyFonts.body(color: context.cores.fundo),
          ),
          duration: const Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
          // Acima da cápsula do menu de baixo.
          margin: const EdgeInsets.fromLTRB(
            16,
            16,
            16,
            16 +
                ChildBottomNavMetrics.capsuleBottom +
                ChildBottomNavMetrics.capsuleHeight,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          backgroundColor: context.cores.tinta,
        ),
      );
      return false;
    }

    // Fecha o app
    SystemNavigator.pop();
    return true;
  }

  @override
  Widget build(BuildContext context) {
    final inset = MediaQuery.viewPaddingOf(context).bottom;
    final cores = context.cores;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      // Barras do sistema na cor do fundo, com ícones que contrastam.
      value: (cores.escuro
              ? SystemUiOverlayStyle.light
              : SystemUiOverlayStyle.dark)
          .copyWith(
        systemNavigationBarColor: cores.fundo,
        systemNavigationBarIconBrightness: cores.brilhoDosIcones,
      ),
      // Avisos flutuantes aparecem acima da cápsula, não por cima dela.
      child: LummyFeedbackInset(
          bottom: ChildBottomNavMetrics.capsuleBottom +
              ChildBottomNavMetrics.capsuleHeight,
          child: ChildShellScope(
          currentTab: _currentIndex,
          openDrawer: _abrirMenu,
          closeDrawer: _fecharMenu,
          goToTab: _irParaAba,
          afterDrawerClosed: _depoisDeFecharMenu,
          child: PopScope(
            canPop: false,
            onPopInvokedWithResult: (didPop, result) async {
              if (didPop) return;
              final shouldPop = await _onWillPop();
              if (shouldPop && context.mounted) {
                Navigator.of(context).pop();
              }
            },
            child: Scaffold(
              key: _scaffoldKey,
              backgroundColor: cores.fundo,
              resizeToAvoidBottomInset: false,
              drawer: const ChildDrawer(),
              drawerScrimColor: context.cores.veu,
              // O menu abre pelo avatar (mockup), não arrastando da borda.
              drawerEnableOpenDragGesture: false,
              body: Stack(
                children: [
                  Positioned.fill(
                    child: ConnectivityBanner(
                      child: IndexedStack(index: _currentIndex, children: _pages),
                    ),
                  ),
                  const Positioned(
                    left: 0,
                    right: 0,
                    bottom: 0,
                    child: ChildBottomFade(),
                  ),
                  Positioned(
                    left: ChildBottomNavMetrics.capsuleSide,
                    right: ChildBottomNavMetrics.capsuleSide,
                    bottom: ChildBottomNavMetrics.capsuleBottom + inset,
                    child: ChildBottomNavCapsule(
                      currentIndex: _currentIndex,
                      onTap: _irParaAba,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
