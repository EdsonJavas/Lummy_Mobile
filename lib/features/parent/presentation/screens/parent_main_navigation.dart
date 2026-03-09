import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

import '../bloc/parent_dashboard_cubit.dart';
import 'parent_dashboard_screen.dart';
import 'parent_dependents_screen.dart';
import 'parent_distribution_screen.dart';
import 'parent_approvals_screen.dart';

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
  late final ParentDashboardCubit _cubit;
  int _currentIndex = 0;
  DateTime? _lastBackPress;

  // Cores vibrantes consistentes com a versão infantil
  static const _navItems = [
    _NavItemData(
      icon: Icons.home_rounded,
      label: 'Início',
      color: Color(0xFF3B82F6), // Azul vibrante
    ),
    _NavItemData(
      icon: Icons.family_restroom_rounded,
      label: 'Filhos',
      color: Color(0xFF8B5CF6), // Roxo vibrante
    ),
    _NavItemData(
      icon: Icons.payments_rounded,
      label: 'Enviar',
      color: Color(0xFFF59E0B), // Amarelo/Laranja vibrante
    ),
    _NavItemData(
      icon: Icons.verified_user_rounded,
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
    ParentDashboardScreen(parentId: widget.parentId, onNavigateToTab: _setTab),
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
          backgroundColor: const Color(0xFF1E293B),
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

    return BlocProvider.value(
      value: _cubit,
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
          body: IndexedStack(index: _currentIndex, children: _pages),
          bottomNavigationBar: _buildPremiumBottomNav(context, isDark),
        ),
      ),
    );
  }

  Widget _buildPremiumBottomNav(BuildContext context, bool isDark) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
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
            color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
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

    return GestureDetector(
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
            // Label com cor vibrante quando selecionado
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
              child: Text(item.label),
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
