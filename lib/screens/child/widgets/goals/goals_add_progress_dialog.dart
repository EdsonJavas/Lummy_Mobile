import 'package:flutter/material.dart';
import 'package:lummy/core/theme/design_tokens.dart';
import 'package:lummy/models/goal.dart';
import 'package:lummy/shared/widgets/money_text_field.dart';

/// Conteúdo do diálogo "Adicionar Progresso" de uma meta.
class GoalsAddProgressDialog extends StatelessWidget {
  final Goal goal;
  final TextEditingController controller;
  final ValueChanged<double?> onAmountChanged;
  final VoidCallback onCancel;
  final VoidCallback onConfirm;

  const GoalsAddProgressDialog({
    super.key,
    required this.goal,
    required this.controller,
    required this.onAmountChanged,
    required this.onCancel,
    required this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
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
            // Header with icon
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [LummyColors.emerald500, LummyColors.emerald600],
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.add_circle, color: Colors.white, size: 24),
                  SizedBox(width: 8),
                  Text('💰', style: TextStyle(fontSize: 20)),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Adicionar Progresso',
              style: LummyFonts.body(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: LummyColors.slate800,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Quanto você economizou para "${goal.name}"?',
              textAlign: TextAlign.center,
              style: LummyFonts.body(
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: LummyColors.slate500,
              ),
            ),
            const SizedBox(height: 24),
            MoneyTextField(
              controller: controller,
              onChanged: onAmountChanged,
              isSmallScreen: false,
              fontSize: 18,
              fontWeight: FontWeight.w600,
              textAlign: TextAlign.center,
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
                        colors: [LummyColors.emerald500, LummyColors.emerald600],
                      ),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: LummyColors.emerald500.withValues(alpha: 0.3),
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
                        'Adicionar',
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
