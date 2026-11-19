import 'package:flutter/material.dart';

import 'package:lummy/core/theme/design_tokens.dart';

/// Gradient header of the missions manager: back button, title and stats.
class MissionsManagerHeader extends StatelessWidget {
  final bool isDark;
  final String childName;
  final List<Map<String, dynamic>> childDailyMissions;
  final List<Map<String, dynamic>> customMissions;
  final List<Map<String, dynamic>> allMissions;
  final VoidCallback onBack;

  const MissionsManagerHeader({
    super.key,
    required this.isDark,
    required this.childName,
    required this.childDailyMissions,
    required this.customMissions,
    required this.allMissions,
    required this.onBack,
  });

  static const _purple = LummyColors.violet500;
  static const _purpleDark = LummyColors.violet700;

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;
    final completedToday = childDailyMissions
        .where((m) => m['is_completed'] == true)
        .length;
    final totalToday = childDailyMissions.length;

    return Container(
      padding: EdgeInsets.fromLTRB(20, topPadding + 12, 20, 24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [LummyColors.indigo950, _purpleDark.withValues(alpha: 0.7)]
              : [_purple, _purpleDark],
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(28),
          bottomRight: Radius.circular(28),
        ),
        boxShadow: [
          BoxShadow(
            color: _purple.withValues(alpha: isDark ? 0.15 : 0.25),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top row: back + title
          Row(
            children: [
              _headerBackButton(),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Missões',
                      style: LummyFonts.body(
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      childName,
                      style: LummyFonts.body(
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        color: Colors.white.withValues(alpha: 0.8),
                      ),
                    ),
                  ],
                ),
              ),
              // Mini avatar
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(14),
                ),
                alignment: Alignment.center,
                child: const Icon(
                  Icons.rocket_launch_rounded,
                  color: Colors.white,
                  size: 22,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          // Stats row
          Row(
            children: [
              _buildHeaderStat(
                '$completedToday/$totalToday',
                'Concluídas hoje',
                Icons.check_circle_outline_rounded,
              ),
              const SizedBox(width: 12),
              _buildHeaderStat(
                '${customMissions.length}',
                'Personalizadas',
                Icons.auto_awesome_rounded,
              ),
              const SizedBox(width: 12),
              _buildHeaderStat(
                '${allMissions.length}',
                'Disponíveis',
                Icons.list_alt_rounded,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _headerBackButton() {
    return Material(
      color: Colors.white.withValues(alpha: 0.15),
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onBack,
        borderRadius: BorderRadius.circular(12),
        child: const SizedBox(
          width: 44,
          height: 44,
          child: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Colors.white,
            size: 18,
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderStat(String value, String label, IconData icon) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.1),
          ),
        ),
        child: Column(
          children: [
            Icon(icon, color: Colors.white, size: 18),
            const SizedBox(height: 4),
            Text(
              value,
              style: LummyFonts.body(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
            Text(
              label,
              style: LummyFonts.body(
                fontSize: 10,
                fontWeight: FontWeight.w400,
                color: Colors.white.withValues(alpha: 0.75),
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
