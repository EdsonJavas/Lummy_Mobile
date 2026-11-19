import 'package:flutter/material.dart';

import 'package:lummy/core/theme/design_tokens.dart';

/// Gold gradient section title.
class AchievementsSectionTitle extends StatelessWidget {
  final String title;

  const AchievementsSectionTitle({super.key, required this.title});

  static const _orange = LummyColors.amber500;
  static const _gold = LummyColors.amber600;

  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      shaderCallback: (bounds) =>
          const LinearGradient(colors: [_gold, _orange]).createShader(bounds),
      child: Text(
        title,
        style: LummyFonts.body(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),
    );
  }
}
