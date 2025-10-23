import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/app_constants.dart';
import '../../core/utils/formatters.dart';
import '../../domain/entities/goal_entity.dart';
import 'custom_card.dart';

class GoalCard extends StatelessWidget {
  final GoalEntity goal;
  final VoidCallback? onTap;
  final bool compact;

  const GoalCard({
    super.key,
    required this.goal,
    this.onTap,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final isSmallScreen =
        MediaQuery.of(context).size.height < AppConstants.smallScreenHeight;

    if (compact) {
      return _buildCompactCard(isSmallScreen);
    }

    return _buildFullCard(context, isSmallScreen);
  }

  Widget _buildCompactCard(bool isSmallScreen) {
    return CustomCard(
      onTap: onTap,
      style: CardStyle.filled,
      padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
      child: Row(
        children: [
          // Emoji
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(AppConstants.primaryBlue).withOpacity(0.1),
              borderRadius: BorderRadius.circular(AppConstants.radiusSmall),
            ),
            child: Text(
              goal.emoji,
              style: TextStyle(fontSize: isSmallScreen ? 16 : 20),
            ),
          ),
          const SizedBox(width: AppConstants.spacingMedium),
          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  goal.name,
                  style: GoogleFonts.poppins(
                    fontSize: isSmallScreen ? 14 : 16,
                    fontWeight: FontWeight.w600,
                    color: const Color(AppConstants.textPrimary),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  AppFormatters.formatCurrency(goal.remainingAmount),
                  style: GoogleFonts.poppins(
                    fontSize: isSmallScreen ? 11 : 12,
                    fontWeight: FontWeight.w400,
                    color: const Color(AppConstants.textSecondary),
                  ),
                ),
              ],
            ),
          ),
          // Progresso
          Text(
            '${goal.progressPercentage}%',
            style: GoogleFonts.poppins(
              fontSize: isSmallScreen ? 14 : 16,
              fontWeight: FontWeight.w700,
              color: const Color(AppConstants.primaryBlue),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFullCard(BuildContext context, bool isSmallScreen) {
    return CustomCard(
      onTap: onTap,
      style: CardStyle.filled,
      padding: EdgeInsets.all(isSmallScreen ? 16 : 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(AppConstants.primaryBlue).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppConstants.radiusSmall),
                ),
                child: Text(
                  goal.emoji,
                  style: TextStyle(fontSize: isSmallScreen ? 16 : 20),
                ),
              ),
              const SizedBox(width: AppConstants.spacingMedium),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      goal.name,
                      style: GoogleFonts.poppins(
                        fontSize: isSmallScreen ? 16 : 18,
                        fontWeight: FontWeight.w600,
                        color: const Color(AppConstants.textPrimary),
                      ),
                    ),
                    Text(
                      'Meta de economia',
                      style: GoogleFonts.poppins(
                        fontSize: isSmallScreen ? 12 : 14,
                        fontWeight: FontWeight.w400,
                        color: const Color(AppConstants.textSecondary),
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                '${goal.progressPercentage}%',
                style: GoogleFonts.poppins(
                  fontSize: isSmallScreen ? 16 : 18,
                  fontWeight: FontWeight.w700,
                  color: const Color(AppConstants.primaryBlue),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppConstants.spacingLarge),
          // Barra de progresso
          Container(
            height: 8,
            decoration: BoxDecoration(
              color: const Color(AppConstants.borderLight),
              borderRadius: BorderRadius.circular(4),
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: goal.progress,
              child: Container(
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [
                      Color(AppConstants.primaryBlue),
                      Color(AppConstants.secondaryBlue),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          ),
          const SizedBox(height: AppConstants.spacingMedium),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Economizado',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      color: const Color(AppConstants.textSecondary),
                    ),
                  ),
                  Text(
                    AppFormatters.formatCurrency(goal.currentAmount),
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: const Color(AppConstants.textPrimary),
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'Falta',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      color: const Color(AppConstants.textSecondary),
                    ),
                  ),
                  Text(
                    AppFormatters.formatCurrency(goal.remainingAmount),
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: const Color(AppConstants.primaryBlue),
                    ),
                  ),
                ],
              ),
            ],
          ),
          // Deadline se houver
          if (goal.hasDeadline) ...[
            const SizedBox(height: AppConstants.spacingMedium),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: goal.isOverdue
                    ? const Color(AppConstants.errorRed).withOpacity(0.1)
                    : const Color(AppConstants.primaryBlue).withOpacity(0.1),
                borderRadius: BorderRadius.circular(AppConstants.radiusSmall),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    goal.isOverdue
                        ? Icons.warning_amber_rounded
                        : Icons.calendar_today,
                    size: 14,
                    color: goal.isOverdue
                        ? const Color(AppConstants.errorRed)
                        : const Color(AppConstants.primaryBlue),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    goal.isOverdue
                        ? 'Prazo expirado'
                        : 'Faltam ${goal.daysUntilDeadline} dias',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: goal.isOverdue
                          ? const Color(AppConstants.errorRed)
                          : const Color(AppConstants.primaryBlue),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
