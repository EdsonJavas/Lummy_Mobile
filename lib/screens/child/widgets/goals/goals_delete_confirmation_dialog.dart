import 'package:flutter/material.dart';
import 'package:lummy/core/theme/design_tokens.dart';
import 'package:lummy/models/goal.dart';

/// Conteúdo do diálogo de confirmação para excluir uma meta.
class GoalsDeleteConfirmationDialog extends StatelessWidget {
  final Goal goal;
  final VoidCallback onCancel;
  final VoidCallback onConfirm;

  const GoalsDeleteConfirmationDialog({
    super.key,
    required this.goal,
    required this.onCancel,
    required this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.white, LummyColors.slate50],
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: LummyColors.slate200, width: 1),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Warning icon
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [LummyColors.red500, LummyColors.red600],
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.warning_amber_rounded,
                    color: Colors.white,
                    size: 24,
                  ),
                  SizedBox(width: 8),
                  Text('⚠️', style: TextStyle(fontSize: 20)),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Excluir Meta',
              style: LummyFonts.body(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: LummyColors.slate800,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: LummyColors.red500.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: LummyColors.red500.withValues(alpha: 0.2),
                  width: 1,
                ),
              ),
              child: Column(
                children: [
                  Text(
                    'Tem certeza que deseja excluir',
                    textAlign: TextAlign.center,
                    style: LummyFonts.body(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: LummyColors.slate500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '"${goal.name}"',
                    textAlign: TextAlign.center,
                    style: LummyFonts.body(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: LummyColors.slate800,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Esta ação não pode ser desfeita.',
                    textAlign: TextAlign.center,
                    style: LummyFonts.body(
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      color: LummyColors.red500,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: onCancel,
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      'Cancelar',
                      style: LummyFonts.body(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: LummyColors.slate500,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [LummyColors.red500, LummyColors.red600],
                      ),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: LummyColors.red500.withValues(alpha: 0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: ElevatedButton(
                      onPressed: onConfirm,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        'Excluir',
                        style: LummyFonts.body(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
