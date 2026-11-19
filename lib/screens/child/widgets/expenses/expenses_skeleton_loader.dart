import 'package:flutter/material.dart';
import 'package:lummy/shared/widgets/widgets.dart';

/// Skeleton exibido enquanto os gastos carregam.
class ExpensesSkeletonLoader extends StatelessWidget {
  const ExpensesSkeletonLoader({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header skeleton
          const SkeletonText(width: 150, height: 32),
          const SizedBox(height: 8),
          const SkeletonText(width: 200, height: 16),
          const SizedBox(height: 24),
          // Total card skeleton
          SkeletonLoader(
            width: double.infinity,
            height: 120,
            borderRadius: BorderRadius.circular(16),
          ),
          const SizedBox(height: 24),
          // Chart skeleton
          SkeletonLoader(
            width: double.infinity,
            height: 250,
            borderRadius: BorderRadius.circular(16),
          ),
          const SizedBox(height: 24),
          // Categories skeleton
          const SkeletonText(width: 120, height: 20),
          const SizedBox(height: 16),
          ...List.generate(
            5,
            (index) => Padding(
              padding: EdgeInsets.only(bottom: index == 4 ? 0 : 12),
              child: Row(
                children: [
                  SkeletonLoader(
                    width: 48,
                    height: 48,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SkeletonText(width: 120, height: 16),
                        SizedBox(height: 4),
                        SkeletonText(width: 80, height: 12),
                      ],
                    ),
                  ),
                  const SkeletonText(width: 60, height: 16),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
