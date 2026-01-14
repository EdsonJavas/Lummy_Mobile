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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final defaultColor = color ?? const Color(0xFF3B82F6);
    final defaultBackground =
        backgroundColor ?? (isDark ? const Color(0xFF1E293B) : Colors.white);

    return RefreshIndicator(
      color: defaultColor,
      backgroundColor: defaultBackground,
      strokeWidth: 2.5,
      displacement: 30,
      edgeOffset: 0,
      onRefresh: onRefresh,
      child: child,
    );
  }
}
