import 'package:flutter/material.dart';

class BrandedRefreshIndicator extends StatelessWidget {
  final Future<void> Function() onRefresh;
  final Widget child;
  final Color? color;
  final Color? backgroundColor;

  const BrandedRefreshIndicator({
    super.key,
    required this.onRefresh,
    required this.child,
    this.color,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final defaultColor = color ?? colorScheme.primary;
    final defaultBackground = backgroundColor ?? Theme.of(context).scaffoldBackgroundColor;

    return RefreshIndicator(
      color: defaultColor,
      backgroundColor: defaultBackground,
      strokeWidth: 3,
      displacement: 40,
      onRefresh: onRefresh,
      child: child,
    );
  }
}

