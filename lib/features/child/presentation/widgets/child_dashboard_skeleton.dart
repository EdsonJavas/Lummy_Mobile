import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../shared/widgets/widgets.dart';

class ChildDashboardSkeleton extends StatelessWidget {
  const ChildDashboardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final isSmallScreen = screenHeight < AppConstants.smallScreenHeight;

    return SafeArea(
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          children: [
            // Header skeleton
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppConstants.spacingLarge,
                vertical: AppConstants.spacingMedium,
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SkeletonText(width: 150, height: 28),
                      SizedBox(height: 8),
                      SkeletonText(width: 200, height: 16),
                    ],
                  ),
                  SkeletonAvatar(size: 56),
                ],
              ),
            ),
            const SizedBox(height: AppConstants.spacingLarge),
            // Balance card skeleton
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppConstants.spacingLarge,
              ),
              child: SkeletonLoader(
                width: double.infinity,
                height: isSmallScreen ? 180 : 200,
                borderRadius: BorderRadius.circular(AppConstants.radiusLarge),
              ),
            ),
            const SizedBox(height: AppConstants.spacingLarge),
            // Goal card skeleton
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppConstants.spacingLarge,
              ),
              child: SkeletonLoader(
                width: double.infinity,
                height: 120,
                borderRadius: BorderRadius.circular(AppConstants.radiusLarge),
              ),
            ),
            const SizedBox(height: AppConstants.spacingLarge),
            // Quick actions skeleton
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppConstants.spacingLarge,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: List.generate(
                  4,
                  (index) => Column(
                    children: [
                      SkeletonLoader(
                        width: 60,
                        height: 60,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      const SizedBox(height: 8),
                      const SkeletonText(width: 60, height: 12),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: AppConstants.spacingLarge),
            // Recent transactions skeleton
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppConstants.spacingLarge,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SkeletonText(width: 150, height: 20),
                  const SizedBox(height: AppConstants.spacingMedium),
                  ...List.generate(
                    3,
                    (index) => Padding(
                      padding: EdgeInsets.only(
                        bottom: index == 2 ? 0 : AppConstants.spacingMedium,
                      ),
                      child: Row(
                        children: [
                          SkeletonLoader(
                            width: 48,
                            height: 48,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          const SizedBox(width: AppConstants.spacingMedium),
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
            ),
            const SizedBox(height: AppConstants.spacingLarge),
            // Achievements skeleton
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppConstants.spacingLarge,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SkeletonText(width: 150, height: 20),
                  const SizedBox(height: AppConstants.spacingMedium),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: List.generate(
                        5,
                        (index) => Padding(
                          padding: EdgeInsets.only(
                            right: index == 4 ? 0 : AppConstants.spacingMedium,
                          ),
                          child: Column(
                            children: [
                              SkeletonLoader(
                                width: 60,
                                height: 60,
                                borderRadius: BorderRadius.circular(16),
                              ),
                              const SizedBox(height: 8),
                              const SkeletonText(width: 60, height: 12),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppConstants.spacingXLarge),
          ],
        ),
      ),
    );
  }
}

