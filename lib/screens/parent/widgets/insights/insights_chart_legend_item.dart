import 'package:flutter/material.dart';
import 'package:lummy/core/theme/design_tokens.dart';

class InsightsChartLegendItem extends StatelessWidget {
  final String label;
  final Color color;

  const InsightsChartLegendItem({
    super.key,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: LummyFonts.body(
            fontSize: 11,
            fontWeight: FontWeight.w500,
            color: LummyColors.slate500,
          ),
        ),
      ],
    );
  }
}
