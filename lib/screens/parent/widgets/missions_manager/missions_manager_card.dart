import 'package:flutter/material.dart';

import 'package:lummy/core/theme/design_tokens.dart';

// =============================================================================
// Mission Card (extracted for readability)
// =============================================================================

class MissionsManagerCard extends StatelessWidget {
  final String title;
  final String description;
  final String emoji;
  final int points;
  final bool isCompleted;
  final Color color;
  final bool isDark;
  final String? badge;
  final Color? badgeColor;
  final String? actionLabel;
  final VoidCallback? onAction;
  final VoidCallback? onDelete;

  const MissionsManagerCard({
    super.key,
    required this.title,
    required this.description,
    required this.emoji,
    required this.points,
    required this.isCompleted,
    required this.color,
    required this.isDark,
    this.badge,
    this.badgeColor,
    this.actionLabel,
    this.onAction,
    this.onDelete,
  });

  static const _green = LummyColors.emerald500;
  static const _red = LummyColors.red500;

  @override
  Widget build(BuildContext context) {
    final cardBg = isDark ? LummyColors.darkNavy : Colors.white;
    final borderColor = isCompleted
        ? _green.withValues(alpha: 0.3)
        : (isDark ? LummyColors.darkSurfaceHigh : color.withValues(alpha: 0.15));
    final titleColor = isDark ? Colors.white : LummyColors.slate900;
    final subtitleColor =
        isDark ? LummyColors.slate400 : LummyColors.slate500;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: borderColor, width: 1.5),
        boxShadow: [
          if (!isDark)
            BoxShadow(
              color: color.withValues(alpha: 0.06),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top row: emoji + title + badge
          Row(
            children: [
              // Emoji container with subtle gradient
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      color.withValues(alpha: 0.15),
                      color.withValues(alpha: 0.06),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(14),
                ),
                alignment: Alignment.center,
                child: Text(emoji, style: const TextStyle(fontSize: 24)),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            title,
                            style: LummyFonts.body(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: titleColor,
                              decoration: isCompleted
                                  ? TextDecoration.lineThrough
                                  : null,
                              decorationColor: _green,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (badge != null) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: (badgeColor ?? color)
                                  .withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              badge!,
                              style: LummyFonts.body(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: badgeColor ?? color,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    if (description.isNotEmpty) ...[
                      const SizedBox(height: 3),
                      Text(
                        description,
                        style: LummyFonts.body(
                          fontSize: 12,
                          color: subtitleColor,
                          height: 1.3,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Bottom row: points + status / actions
          Row(
            children: [
              // Points chip
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.star_rounded, color: color, size: 16),
                    const SizedBox(width: 4),
                    Text(
                      '+$points pts',
                      style: LummyFonts.body(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: color,
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),

              // Status / Action buttons
              if (isCompleted)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: _green.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.check_circle_rounded,
                        color: _green,
                        size: 16,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Concluída',
                        style: LummyFonts.body(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: _green,
                        ),
                      ),
                    ],
                  ),
                ),
              if (actionLabel != null && onAction != null)
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: onAction,
                    borderRadius: BorderRadius.circular(10),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 7,
                      ),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [color, color.withValues(alpha: 0.8)],
                        ),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        actionLabel!,
                        style: LummyFonts.body(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              if (onDelete != null) ...[
                const SizedBox(width: 8),
                Material(
                  color: _red.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                  child: InkWell(
                    onTap: onDelete,
                    borderRadius: BorderRadius.circular(10),
                    child: const Padding(
                      padding: EdgeInsets.all(8),
                      child: Icon(
                        Icons.delete_outline_rounded,
                        color: _red,
                        size: 18,
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
