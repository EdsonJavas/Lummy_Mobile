import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:lummy_login/core/utils/formatters.dart';
import 'package:lummy_login/shared/widgets/widgets.dart';
import 'package:lummy_login/features/parent/presentation/bloc/parent_dashboard_cubit.dart';
import 'package:lummy_login/features/parent/presentation/bloc/parent_dashboard_state.dart';
import 'package:lummy_login/screens/parent/parent_dashboard_screen.dart';
import 'package:lummy_login/screens/parent/parent_dependents_screen.dart';
import 'package:lummy_login/screens/parent/parent_distribution_screen.dart';
import 'package:lummy_login/screens/parent/parent_approvals_screen.dart';
import 'package:lummy_login/screens/parent/parent_settings_screen.dart';
import 'package:lummy_login/screens/parent/parent_subscription_screen.dart';
import 'package:lummy_login/screens/parent/parent_help_screen.dart';

class ParentMainNavigation extends StatefulWidget {
  final String parentId;
  final String? parentName;

  const ParentMainNavigation({
    super.key,
    required this.parentId,
    this.parentName,
  });

  @override
  State<ParentMainNavigation> createState() => _ParentMainNavigationState();
}

class _ParentMainNavigationState extends State<ParentMainNavigation>
    with SingleTickerProviderStateMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  late final ParentDashboardCubit _cubit;
  int _currentIndex = 0;
  DateTime? _lastBackPress;
  bool _drawerOpen = false;

  // Cores vibrantes consistentes com a versão infantil
  static const _navItems = [
    _NavItemData(
      icon: Iconsax.home_1,
      label: 'Início',
      color: Color(0xFF3B82F6), // Azul vibrante
    ),
    _NavItemData(
      icon: Iconsax.people,
      label: 'Filhos',
      color: Color(0xFF8B5CF6), // Roxo vibrante
    ),
    _NavItemData(
      icon: Iconsax.card_send,
      label: 'Enviar',
      color: Color(0xFFF59E0B), // Amarelo/Laranja vibrante
    ),
    _NavItemData(
      icon: Iconsax.shield_tick,
      label: 'Aprovar',
      color: Color(0xFF10B981), // Verde vibrante
    ),
  ];

  @override
  void initState() {
    super.initState();
    _cubit = ParentDashboardCubit()
      ..loadDashboard(widget.parentId, parentName: widget.parentName);
  }

  @override
  void dispose() {
    _cubit.close();
    super.dispose();
  }

  void _setTab(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  List<Widget> get _pages => [
    ParentDashboardScreen(
      parentId: widget.parentId,
      onNavigateToTab: _setTab,
      onOpenDrawer: () => setState(() => _drawerOpen = true),
    ),
    const ParentDependentsScreen(),
    const ParentDistributionScreen(),
    const ParentApprovalsScreen(),
  ];

  Future<bool> _onWillPop() async {
    // Se não estiver na primeira aba, volta para ela
    if (_currentIndex != 0) {
      setState(() => _currentIndex = 0);
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
            style: GoogleFonts.poppins(),
          ),
          duration: const Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          backgroundColor: const Color(0xFF121212),
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final screenWidth = MediaQuery.sizeOf(context).width;
    final drawerWidth = (screenWidth * 0.85).clamp(300.0, 380.0);

    return BlocProvider.value(
      value: _cubit,
      child: PopScope(
        canPop: false,
        onPopInvokedWithResult: (didPop, result) async {
          if (didPop) return;
          if (_drawerOpen) {
            setState(() => _drawerOpen = false);
            return;
          }
          final shouldPop = await _onWillPop();
          if (shouldPop && context.mounted) {
            Navigator.of(context).pop();
          }
        },
        child: Stack(
          children: [
            Scaffold(
              key: _scaffoldKey,
              body: ConnectivityBanner(
                child: IndexedStack(index: _currentIndex, children: _pages),
              ),
              bottomNavigationBar: _buildPremiumBottomNav(context, isDark),
            ),
            IgnorePointer(
              ignoring: !_drawerOpen,
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 220),
                curve: Curves.easeOutCubic,
                opacity: _drawerOpen ? 1 : 0,
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => setState(() => _drawerOpen = false),
                  child: Container(color: Colors.black.withOpacity(0.42)),
                ),
              ),
            ),
            Positioned(
              left: 0,
              top: 0,
              bottom: 0,
              width: drawerWidth,
              child: AnimatedSlide(
                offset: _drawerOpen ? Offset.zero : const Offset(-1, 0),
                duration: const Duration(milliseconds: 320),
                curve: Curves.easeOutCubic,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.28),
                        blurRadius: 24,
                        offset: const Offset(10, 0),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: const BorderRadius.only(
                      bottomRight: Radius.circular(24),
                    ),
                    child: BlocBuilder<ParentDashboardCubit, ParentDashboardState>(
                      builder: (context, state) {
                        return _ParentDrawer(
                          parentName: widget.parentName,
                          childrenCount: state.children.length,
                          subscriptionLabel: 'Ver plano',
                          onClose: () => setState(() => _drawerOpen = false),
                          onOpenSettings: () {
                            setState(() => _drawerOpen = false);
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => const ParentSettingsScreen(),
                              ),
                            );
                          },
                          onOpenSubscription: () {
                            setState(() => _drawerOpen = false);
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => const ParentSubscriptionScreen(),
                              ),
                            );
                          },
                          onOpenHelp: () {
                            setState(() => _drawerOpen = false);
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => const ParentHelpScreen(),
                              ),
                            );
                          },
                        );
                      },
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

  Widget _buildPremiumBottomNav(BuildContext context, bool isDark) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF121212) : Colors.white,
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withValues(alpha: 0.3)
                : Colors.black.withValues(alpha: 0.08),
            blurRadius: 24,
            offset: const Offset(0, -8),
          ),
        ],
        border: Border(
          top: BorderSide(
            color: isDark ? const Color(0xFF2D2D2D) : const Color(0xFFE2E8F0),
            width: 1,
          ),
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(_navItems.length, (index) {
              return Expanded(
                child: _buildNavItem(
                  index: index,
                  item: _navItems[index],
                  isDark: isDark,
                ),
              );
            }),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required int index,
    required _NavItemData item,
    required bool isDark,
  }) {
    final isSelected = _currentIndex == index;

    return Semantics(
      label: item.label,
      button: true,
      selected: isSelected,
      child: GestureDetector(
        onTap: () => _setTab(index),
        behavior: HitTestBehavior.opaque,
        child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Ícone com fundo animado
            AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeOutCubic,
              padding: EdgeInsets.all(isSelected ? 12 : 10),
              decoration: BoxDecoration(
                gradient: isSelected
                    ? LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [item.color, item.color.withValues(alpha: 0.85)],
                      )
                    : null,
                color: isSelected
                    ? null
                    : (isDark ? Colors.transparent : Colors.transparent),
                borderRadius: BorderRadius.circular(14),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: item.color.withValues(alpha: 0.4),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ]
                    : null,
              ),
              child: Icon(
                item.icon,
                color: isSelected
                    ? Colors.white
                    : (isDark
                          ? const Color(0xFF64748B)
                          : const Color(0xFF94A3B8)),
                size: isSelected ? 24 : 22,
              ),
            ),
            const SizedBox(height: 6),
            // Label com cor vibrante quando selecionado (maxLines + overflow evita assertion no TextPainter)
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 200),
              style: GoogleFonts.poppins(
                fontSize: isSelected ? 12 : 11,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                color: isSelected
                    ? item.color
                    : (isDark
                          ? const Color(0xFF64748B)
                          : const Color(0xFF94A3B8)),
              ),
              child: Text(
                item.label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
              ),
            ),
            // Indicador animado
            AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              margin: const EdgeInsets.only(top: 4),
              height: 3,
              width: isSelected ? 20 : 0,
              decoration: BoxDecoration(
                color: item.color,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ],
        ),
      ),
      ),
    );
  }
}

class _NavItemData {
  final IconData icon;
  final String label;
  final Color color;

  const _NavItemData({
    required this.icon,
    required this.label,
    required this.color,
  });
}

/// Saldo fixo para exibição no drawer (teste).
const _kDrawerBalance = 2200.0;

/// Drawer — header grande com saldo; opções no estilo Visão Geral; fecha via onClose.
class _ParentDrawer extends StatefulWidget {
  final String? parentName;
  final int childrenCount;
  final String subscriptionLabel;
  final VoidCallback? onClose;
  final VoidCallback onOpenSettings;
  final VoidCallback onOpenSubscription;
  final VoidCallback onOpenHelp;

  const _ParentDrawer({
    required this.parentName,
    required this.childrenCount,
    required this.subscriptionLabel,
    this.onClose,
    required this.onOpenSettings,
    required this.onOpenSubscription,
    required this.onOpenHelp,
  });

  @override
  State<_ParentDrawer> createState() => _ParentDrawerState();
}

class _ParentDrawerState extends State<_ParentDrawer> {
  bool _balanceVisible = true;

  static const _accent = Color(0xFF8B5CF6);
  static const _blue = Color(0xFF3B82F6);
  static const _green = Color(0xFF10B981);
  static const _avatarUrl =
      'https://hebbkx1anhila5yf.public.blob.vercel-storage.com/Lum%202-0CkW5uvZjaDxIjCSextrqE198N99r7.png';

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surface = isDark ? const Color(0xFF1E1E1E) : const Color(0xFFF8FAFC);
    final headerGradient = isDark
        ? const [Color(0xFF1E1B4B), Color(0xFF312E81), Color(0xFF4C1D95)]
        : const [Color(0xFF7C3AED), Color(0xFF8B5CF6), Color(0xFFA78BFA)];
    final textSecondary = isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);
    final closeIconColor = isDark ? textSecondary : Colors.white;

    final name = widget.parentName?.trim().isNotEmpty == true ? widget.parentName! : 'Responsável';
    final childrenText = widget.childrenCount == 0
        ? '0 filhos'
        : widget.childrenCount == 1
            ? '1 filho'
            : '${widget.childrenCount} filhos';

    return Material(
      color: surface,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header maior: gradiente + avatar grande + nome/filhos/plano + bloco saldo
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: headerGradient,
                ),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(24),
                ),
              ),
              child: Stack(
                children: [
                  Positioned(
                    top: -24,
                    right: -24,
                    child: Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withOpacity(0.08),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 24,
                    left: -16,
                    child: Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withOpacity(0.05),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 12, 12, 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Material(
                              color: Colors.transparent,
                              child: InkWell(
                                onTap: widget.onClose ?? () => Navigator.of(context).pop(),
                                borderRadius: BorderRadius.circular(12),
                                child: Container(
                                  width: 40,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  alignment: Alignment.center,
                                  child: Icon(
                                    Icons.chevron_left_rounded,
                                    color: closeIconColor,
                                    size: 24,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Container(
                              width: 72,
                              height: 72,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.white.withOpacity(0.95),
                                  width: 2.5,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: _accent.withValues(alpha: 0.45),
                                    blurRadius: 14,
                                    spreadRadius: 0,
                                  ),
                                ],
                              ),
                              child: const ClipOval(
                                child: CachedAvatar(
                                  imageUrl: _avatarUrl,
                                  size: 72,
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    name,
                                    style: GoogleFonts.poppins(
                                      color: Colors.white,
                                      fontSize: 18,
                                      fontWeight: FontWeight.w700,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '$childrenText · ${widget.subscriptionLabel}',
                                    style: GoogleFonts.poppins(
                                      color: Colors.white.withOpacity(0.88),
                                      fontSize: 13,
                                      fontWeight: FontWeight.w500,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        // Bloco saldo (estilo perfil)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.account_balance_wallet_rounded,
                                color: Colors.white.withOpacity(0.9),
                                size: 20,
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      'Saldo disponível',
                                      style: GoogleFonts.poppins(
                                        color: Colors.white.withOpacity(0.85),
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      _balanceVisible
                                          ? AppFormatters.formatCurrency(_kDrawerBalance)
                                          : 'R\$ •••••••',
                                      style: GoogleFonts.poppins(
                                        color: Colors.white,
                                        fontSize: 18,
                                        fontWeight: FontWeight.w700,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                              Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  onTap: () => setState(() => _balanceVisible = !_balanceVisible),
                                  borderRadius: BorderRadius.circular(20),
                                  child: Padding(
                                    padding: const EdgeInsets.all(6),
                                    child: Icon(
                                      _balanceVisible
                                          ? Icons.visibility_rounded
                                          : Icons.visibility_off_rounded,
                                      color: Colors.white.withOpacity(0.9),
                                      size: 24,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            // Opções em formato de lista, estilo dos cards da Visão Geral
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _DrawerListTile(
                    icon: Icons.settings_outlined,
                    label: 'Configurações',
                    subtitle: 'Preferências e notificações',
                    iconColor: _blue,
                    isDark: isDark,
                    onTap: widget.onOpenSettings,
                  ),
                  const SizedBox(height: 14),
                  _DrawerListTile(
                    icon: Icons.workspace_premium_outlined,
                    label: 'Assinatura',
                    subtitle: 'Planos e benefícios',
                    iconColor: _accent,
                    isDark: isDark,
                    onTap: widget.onOpenSubscription,
                  ),
                  const SizedBox(height: 14),
                  _DrawerListTile(
                    icon: Icons.help_outline_rounded,
                    label: 'Ajuda',
                    subtitle: 'Tire suas dúvidas',
                    iconColor: _green,
                    isDark: isDark,
                    onTap: widget.onOpenHelp,
                  ),
                ],
              ),
            ),
            const Spacer(),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
              child: Center(
                child: Text(
                  '© Lummy',
                  style: GoogleFonts.poppins(
                    color: textSecondary,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Item do drawer no estilo dos cards da Visão Geral (gradiente, borda, sombra) — lista.
class _DrawerListTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String subtitle;
  final Color iconColor;
  final bool isDark;
  final VoidCallback onTap;

  const _DrawerListTile({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.iconColor,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // Mesmo estilo do _CompactInfoCard da Visão Geral
    final darkTop = Color.alphaBlend(iconColor.withAlpha(30), const Color(0xFF1E293B));
    final darkBorder = Color.alphaBlend(
      iconColor.withAlpha(52),
      const Color(0xFF334155),
    );
    final labelColor = isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);
    final textColor = isDark ? const Color(0xFFF8FAFC) : const Color(0xFF1E293B);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: isDark
                  ? [darkTop, const Color(0xFF1E293B)]
                  : [Colors.white, iconColor.withOpacity(0.04)],
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isDark ? darkBorder : iconColor.withOpacity(0.15),
              width: 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: isDark
                    ? iconColor.withAlpha(30)
                    : iconColor.withOpacity(0.08),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      iconColor.withOpacity(isDark ? 0.3 : 0.2),
                      iconColor.withOpacity(isDark ? 0.14 : 0.1),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: iconColor, size: 20),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      label,
                      style: GoogleFonts.poppins(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: textColor,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: labelColor,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                color: textColor.withOpacity(0.45),
                size: 24,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
