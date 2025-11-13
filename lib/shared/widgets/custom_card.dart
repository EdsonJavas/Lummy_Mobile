import 'package:flutter/material.dart';
import '../../core/constants/app_constants.dart';

enum CardStyle { filled, outlined, elevated }

class CustomCard extends StatelessWidget {
  final Widget child;
  final CardStyle style;
  final Color? color;
  final EdgeInsetsGeometry? padding;
  final VoidCallback? onTap;
  final double? elevation;
  final Gradient? gradient;

  const CustomCard({
    super.key,
    required this.child,
    this.style = CardStyle.filled,
    this.color,
    this.padding,
    this.onTap,
    this.elevation,
    this.gradient,
  });

  @override
  Widget build(BuildContext context) {
    final Widget cardChild = Container(
      padding: padding ?? const EdgeInsets.all(AppConstants.spacingLarge),
      decoration: BoxDecoration(
        color: gradient == null
            ? (color ?? const Color(AppConstants.backgroundWhite))
            : null,
        gradient: gradient,
        borderRadius: BorderRadius.circular(AppConstants.radiusLarge),
        border: style == CardStyle.outlined
            ? Border.all(color: const Color(AppConstants.borderLight), width: 1)
            : null,
        boxShadow: style == CardStyle.elevated || elevation != null
            ? [
                BoxShadow(
                  color: Colors.black.withOpacity(elevation ?? 0.04),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ]
            : null,
      ),
      child: child,
    );

    if (onTap != null) {
      return InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppConstants.radiusLarge),
        child: cardChild,
      );
    }

    return cardChild;
  }
}
