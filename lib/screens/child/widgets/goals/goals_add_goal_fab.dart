import 'package:flutter/material.dart';
import 'package:lummy/core/theme/design_tokens.dart';

/// Botão flutuante "Nova meta".
class GoalsAddGoalFab extends StatelessWidget {
  final bool isSmallScreen;
  final VoidCallback onPressed;

  const GoalsAddGoalFab({
    super.key,
    required this.isSmallScreen,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton.extended(
      heroTag: 'fab_goals',
      onPressed: onPressed,
      backgroundColor: LummyColors.violet500,
      foregroundColor: Colors.white,
      icon: const Icon(Icons.add_rounded, size: 24),
      label: Text(
        'Nova meta',
        style: LummyFonts.body(
          fontSize: isSmallScreen ? 14 : 15,
          fontWeight: FontWeight.w700,
        ),
      ),
      elevation: 4,
    );
  }
}
