import 'package:flutter/material.dart';
import 'package:lummy/core/theme/design_tokens.dart';

/// Cartão de uma missão diária com barra de progresso e ação de completar.
class DailyMissionCard extends StatelessWidget {
  const DailyMissionCard({
    super.key,
    required this.mission,
    required this.isSmallScreen,
    required this.onComplete,
  });

  final Map<String, dynamic> mission;
  final bool isSmallScreen;

  /// Recebe o id da missão a ser completada.
  final ValueChanged<String> onComplete;

  @override
  Widget build(BuildContext context) {
    final progress = mission['progress'] as int;
    final total = mission['total'] as int;
    final isCompleted = mission['isCompleted'] as bool;
    final progressPercent = total > 0
        ? (progress / total).clamp(0.0, 1.0)
        : 0.0;

    return Container(
      padding: EdgeInsets.all(isSmallScreen ? 16.0 : 20.0),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isCompleted
              ? (mission['color'] as Color).withValues(alpha: 0.3)
              : Theme.of(context).brightness == Brightness.dark
              ? Theme.of(context).dividerColor
              : LummyColors.slate200,
          width: isCompleted ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: (mission['color'] as Color).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    mission['emoji'] as String,
                    style: const TextStyle(fontSize: 28),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      mission['title'] as String,
                      style: LummyFonts.body(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).textTheme.titleLarge?.color,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      mission['description'] as String,
                      style: LummyFonts.body(
                        fontSize: 13,
                        fontWeight: FontWeight.w400,
                        color: Theme.of(context).textTheme.bodyMedium?.color,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: (mission['color'] as Color).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '+${mission['points']}',
                  style: LummyFonts.body(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: mission['color'] as Color,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Barra de progresso
          Row(
            children: [
              Expanded(
                child: Container(
                  height: 8,
                  decoration: BoxDecoration(
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Theme.of(context).dividerColor
                        : LummyColors.slate200,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: FractionallySizedBox(
                    alignment: Alignment.centerLeft,
                    widthFactor: progressPercent,
                    child: Container(
                      decoration: BoxDecoration(
                        color: mission['color'] as Color,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                '$progress/$total',
                style: LummyFonts.body(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).textTheme.bodyMedium?.color,
                ),
              ),
            ],
          ),
          if (!isCompleted) ...[
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => onComplete(mission['id'] as String),
                style: ElevatedButton.styleFrom(
                  backgroundColor: mission['color'] as Color,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  'Completar Missão',
                  style: LummyFonts.body(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
          if (isCompleted) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: LummyColors.emerald500.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.check_circle,
                    color: LummyColors.emerald500,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Missão Concluída!',
                    style: LummyFonts.body(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: LummyColors.emerald500,
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
