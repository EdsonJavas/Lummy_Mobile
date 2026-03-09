import 'package:flutter/material.dart';
import 'widgets.dart';

class ChildHomeSkeleton extends StatefulWidget {
  const ChildHomeSkeleton({super.key});

  @override
  State<ChildHomeSkeleton> createState() => _ChildHomeSkeletonState();
}

class _ChildHomeSkeletonState extends State<ChildHomeSkeleton>
    with SingleTickerProviderStateMixin {
  late AnimationController _shimmerController;

  @override
  void initState() {
    super.initState();
    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();
  }

  @override
  void dispose() {
    _shimmerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SingleChildScrollView(
      physics: const NeverScrollableScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header skeleton
          _buildHeaderSkeleton(isDark),
          const SizedBox(height: 20),
          // Balance card skeleton
          _buildBalanceCardSkeleton(isDark),
          const SizedBox(height: 20),
          // Goal card skeleton
          _buildGoalCardSkeleton(isDark),
          const SizedBox(height: 24),
          // Quick actions skeleton
          _buildQuickActionsSkeleton(isDark),
          const SizedBox(height: 24),
          // Education section skeleton
          _buildEducationSkeleton(isDark),
          const SizedBox(height: 24),
          // Achievements skeleton
          _buildAchievementsSkeleton(isDark),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildHeaderSkeleton(bool isDark) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          // Avatar
          SkeletonLoader(
            width: 48,
            height: 48,
            borderRadius: BorderRadius.circular(24),
          ),
          const SizedBox(width: 12),
          // Greeting text
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SkeletonText(width: 100, height: 14),
                SizedBox(height: 6),
                SkeletonText(width: 140, height: 20),
              ],
            ),
          ),
          // Notification icon
          SkeletonLoader(
            width: 44,
            height: 44,
            borderRadius: BorderRadius.circular(12),
          ),
        ],
      ),
    );
  }

  Widget _buildBalanceCardSkeleton(bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: SkeletonLoader(
        width: double.infinity,
        height: 160,
        borderRadius: BorderRadius.circular(24),
      ),
    );
  }

  Widget _buildGoalCardSkeleton(bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: SkeletonLoader(
        width: double.infinity,
        height: 120,
        borderRadius: BorderRadius.circular(20),
      ),
    );
  }

  Widget _buildQuickActionsSkeleton(bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SkeletonText(width: 180, height: 20),
          const SizedBox(height: 16),
          // First row
          Row(
            children: [
              Expanded(
                child: SkeletonLoader(
                  width: double.infinity,
                  height: 130,
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: SkeletonLoader(
                  width: double.infinity,
                  height: 130,
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Second row
          Row(
            children: [
              Expanded(
                child: SkeletonLoader(
                  width: double.infinity,
                  height: 130,
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: SkeletonLoader(
                  width: double.infinity,
                  height: 130,
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEducationSkeleton(bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SkeletonText(width: 160, height: 20),
          const SizedBox(height: 16),
          SkeletonLoader(
            width: double.infinity,
            height: 100,
            borderRadius: BorderRadius.circular(16),
          ),
        ],
      ),
    );
  }

  Widget _buildAchievementsSkeleton(bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SkeletonText(width: 140, height: 20),
          const SizedBox(height: 16),
          SizedBox(
            height: 100,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: 4,
              separatorBuilder: (_, _) => const SizedBox(width: 12),
              itemBuilder: (_, _) => SkeletonLoader(
                width: 80,
                height: 100,
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
