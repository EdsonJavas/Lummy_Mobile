import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// A gamified experience bar showing the child's XP level progress.
class XpProgressBar extends StatelessWidget {
  final int currentXp;
  final int xpForNextLevel;
  final int level;
  final int streakDays;

  const XpProgressBar({
    super.key,
    required this.currentXp,
    required this.xpForNextLevel,
    required this.level,
    this.streakDays = 0,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final progress =
        xpForNextLevel > 0 ? (currentXp / xpForNextLevel).clamp(0.0, 1.0) : 0.0;
    final cardBg = isDark ? const Color(0xFF1A1A2E) : Colors.white;
    final borderColor =
        isDark ? const Color(0xFF2D2D2D) : const Color(0xFFE2E8F0);
    final titleColor = isDark ? Colors.white : const Color(0xFF0F172A);
    final subtitleColor =
        isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);

    const purple = Color(0xFF8B5CF6);
    const orange = Color(0xFFF59E0B);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [purple, Color(0xFF6D28D9)],
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                alignment: Alignment.center,
                child: Text(
                  '$level',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Nível $level',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: titleColor,
                      ),
                    ),
                    Text(
                      '$currentXp / $xpForNextLevel XP',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: subtitleColor,
                      ),
                    ),
                  ],
                ),
              ),
              if (streakDays > 0) ...[
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: orange.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.local_fire_department_rounded,
                        color: orange,
                        size: 16,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '$streakDays dias',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: orange,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              backgroundColor: borderColor,
              valueColor: const AlwaysStoppedAnimation<Color>(purple),
            ),
          ),
        ],
      ),
    );
  }
}
