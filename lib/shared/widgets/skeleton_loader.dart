import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:lummy/core/theme/design_tokens.dart';

class SkeletonLoader extends StatelessWidget {
  final double width;
  final double height;
  final BorderRadius? borderRadius;

  const SkeletonLoader({
    super.key,
    required this.width,
    required this.height,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Shimmer.fromColors(
      baseColor: isDark ? LummyColors.slate800 : LummyColors.slate200,
      highlightColor: isDark
          ? LummyColors.slate700
          : LummyColors.slate100,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: isDark ? LummyColors.slate800 : LummyColors.slate200,
          borderRadius: borderRadius ?? BorderRadius.circular(8),
        ),
      ),
    );
  }
}

class SkeletonAvatar extends StatelessWidget {
  final double size;

  const SkeletonAvatar({super.key, this.size = 56});

  @override
  Widget build(BuildContext context) {
    return SkeletonLoader(
      width: size,
      height: size,
      borderRadius: BorderRadius.circular(size / 2),
    );
  }
}

class SkeletonText extends StatelessWidget {
  final double width;
  final double height;

  const SkeletonText({super.key, required this.width, this.height = 16});

  @override
  Widget build(BuildContext context) {
    return SkeletonLoader(
      width: width,
      height: height,
      borderRadius: BorderRadius.circular(4),
    );
  }
}
