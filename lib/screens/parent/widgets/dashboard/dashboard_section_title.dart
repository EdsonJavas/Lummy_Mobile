import 'package:flutter/material.dart';
import 'package:lummy/core/theme/design_tokens.dart';

/// Título de seção com gradiente usado no dashboard do responsável.
class DashboardSectionTitle extends StatelessWidget {
  final String title;
  final String? subtitle;
  final bool isDark;

  const DashboardSectionTitle({
    super.key,
    required this.title,
    this.subtitle,
    required this.isDark,
  });

  static const _primaryBlue = LummyColors.blue500;
  static const _deepBlue = LummyColors.blue800;
  static const _purple = LummyColors.violet500;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ShaderMask(
          shaderCallback: (bounds) => LinearGradient(
            colors: isDark
                ? [_primaryBlue, _purple]
                : [_deepBlue, _primaryBlue],
          ).createShader(bounds),
          child: Text(
            title,
            style: LummyFonts.body(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
        ),
        if (subtitle != null) ...[
          const SizedBox(height: 6),
          Text(
            subtitle!,
            style: LummyFonts.body(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: isDark ? LummyColors.slate300 : LummyColors.slate500,
            ),
          ),
        ],
      ],
    );
  }
}
