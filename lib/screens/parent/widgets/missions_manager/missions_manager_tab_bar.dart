import 'package:flutter/material.dart';

import 'package:lummy/core/theme/design_tokens.dart';

/// Segmented tab bar (Hoje / Criadas / Catálogo).
class MissionsManagerTabBar extends StatelessWidget {
  final TabController controller;
  final bool isDark;

  const MissionsManagerTabBar({
    super.key,
    required this.controller,
    required this.isDark,
  });

  static const _purple = LummyColors.violet500;
  static const _purpleDark = LummyColors.violet700;

  @override
  Widget build(BuildContext context) {
    final trackColor =
        isDark ? LummyColors.slate800 : LummyColors.violet100;
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 4),
      child: Container(
        height: 48,
        decoration: BoxDecoration(
          color: trackColor,
          borderRadius: BorderRadius.circular(14),
        ),
        child: TabBar(
          controller: controller,
          dividerHeight: 0,
          indicatorSize: TabBarIndicatorSize.tab,
          indicator: BoxDecoration(
            gradient: const LinearGradient(colors: [_purple, _purpleDark]),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: _purple.withValues(alpha: 0.3),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          labelColor: Colors.white,
          unselectedLabelColor:
              isDark ? LummyColors.slate400 : LummyColors.violet600,
          labelStyle:
              LummyFonts.body(fontSize: 13, fontWeight: FontWeight.w600),
          unselectedLabelStyle:
              LummyFonts.body(fontSize: 13, fontWeight: FontWeight.w500),
          padding: const EdgeInsets.all(3),
          tabs: const [
            Tab(text: 'Hoje'),
            Tab(text: 'Criadas'),
            Tab(text: 'Catálogo'),
          ],
        ),
      ),
    );
  }
}
