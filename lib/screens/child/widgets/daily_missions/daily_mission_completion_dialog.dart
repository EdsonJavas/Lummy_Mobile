import 'package:flutter/material.dart';
import 'package:lummy/core/theme/design_tokens.dart';

/// Diálogo exibido ao completar uma missão diária.
class DailyMissionCompletionDialog extends StatelessWidget {
  const DailyMissionCompletionDialog({
    super.key,
    required this.mission,
    required this.pointsEarned,
    required this.onContinue,
  });

  final Map<String, dynamic> mission;
  final int pointsEarned;

  /// Chamado pelo botão "Continuar" (fecha o diálogo e recarrega as missões).
  final VoidCallback onContinue;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      child: Container(
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: Theme.of(context).cardTheme.color,
          borderRadius: BorderRadius.circular(24),
          border: Theme.of(context).brightness == Brightness.dark
              ? Border.all(color: Theme.of(context).dividerColor, width: 1)
              : null,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Emoji em círculo
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    (mission['color'] as Color).withValues(alpha: 0.2),
                    (mission['color'] as Color).withValues(alpha: 0.1),
                  ],
                ),
                shape: BoxShape.circle,
                border: Border.all(
                  color: (mission['color'] as Color).withValues(alpha: 0.3),
                  width: 2,
                ),
              ),
              child: Text(
                mission['emoji'] as String,
                style: const TextStyle(fontSize: 56),
              ),
            ),
            const SizedBox(height: 24),
            // Título
            Text(
              'Missão Completa!',
              style: LummyFonts.body(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: Theme.of(context).textTheme.titleLarge?.color,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            // Nome da missão
            Text(
              mission['title'] as String,
              style: LummyFonts.body(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: Theme.of(context).textTheme.bodyMedium?.color,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            // Pontos ganhos
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 10,
              ),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    (mission['color'] as Color).withValues(alpha: 0.15),
                    (mission['color'] as Color).withValues(alpha: 0.08),
                  ],
                ),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: (mission['color'] as Color).withValues(alpha: 0.2),
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('⭐', style: TextStyle(fontSize: 20)),
                  const SizedBox(width: 8),
                  Text(
                    '+$pointsEarned pontos',
                    style: LummyFonts.body(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: mission['color'] as Color,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            // Botão
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: onContinue,
                style: ElevatedButton.styleFrom(
                  backgroundColor: mission['color'] as Color,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  'Continuar',
                  style: LummyFonts.body(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
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
