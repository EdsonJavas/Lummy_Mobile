import 'package:flutter/material.dart';

import 'package:lummy/core/theme/design_tokens.dart';

/// Barra de abas (Resumo / Missões / Transações / Metas).
class ControlPanelTabBar extends StatelessWidget {
  final TabController tabController;
  final bool isDark;

  const ControlPanelTabBar({
    super.key,
    required this.tabController,
    required this.isDark,
  });

  static const _blue = LummyColors.blue500;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
      child: Container(
        padding: const EdgeInsets.all(5),
        decoration: BoxDecoration(
          color: isDark ? LummyColors.slate800 : LummyColors.slate200,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.15 : 0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: TabBar(
          controller: tabController,
          indicator: BoxDecoration(
            gradient: const LinearGradient(
              colors: [LummyColors.blue500, LummyColors.violet500],
            ),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: _blue.withValues(alpha: 0.3),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          indicatorSize: TabBarIndicatorSize.tab,
          dividerColor: Colors.transparent,
          labelColor: Colors.white,
          unselectedLabelColor: isDark
              ? LummyColors.slate500
              : LummyColors.slate400,
          labelStyle: LummyFonts.body(
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
          unselectedLabelStyle: LummyFonts.body(
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
          labelPadding: const EdgeInsets.symmetric(horizontal: 4),
          tabs: const [
            Tab(text: 'Resumo', height: 38),
            Tab(text: 'Missões', height: 38),
            Tab(text: 'Transações', height: 38),
            Tab(text: 'Metas', height: 38),
          ],
        ),
      ),
    );
  }
}
