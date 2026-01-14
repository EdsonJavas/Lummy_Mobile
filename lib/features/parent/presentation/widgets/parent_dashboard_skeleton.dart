import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../shared/widgets/widgets.dart';

class ParentDashboardSkeleton extends StatelessWidget {
  const ParentDashboardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppConstants.spacingLarge,
          vertical: AppConstants.spacingLarge,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle(context, 'Visão geral'),
            const SizedBox(height: AppConstants.spacingMedium),
            const Row(
              children: [
                Expanded(
                  child: SkeletonLoader(
                    width: double.infinity,
                    height: 140,
                    borderRadius: BorderRadius.all(
                      Radius.circular(AppConstants.radiusLarge),
                    ),
                  ),
                ),
                SizedBox(width: AppConstants.spacingMedium),
                Expanded(
                  child: SkeletonLoader(
                    width: double.infinity,
                    height: 140,
                    borderRadius: BorderRadius.all(
                      Radius.circular(AppConstants.radiusLarge),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppConstants.spacingLarge),
            SkeletonLoader(
              width: double.infinity,
              height: 180,
              borderRadius: BorderRadius.circular(AppConstants.radiusLarge),
            ),
            const SizedBox(height: AppConstants.spacingLarge),
            _buildSectionTitle(context, 'Crianças'),
            const SizedBox(height: AppConstants.spacingMedium),
            ...List.generate(
              3,
              (index) => Padding(
                padding: EdgeInsets.only(
                  bottom: index == 2 ? 0 : AppConstants.spacingMedium,
                ),
                child: const Row(
                  children: [
                    SkeletonAvatar(size: 56),
                    SizedBox(width: AppConstants.spacingMedium),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SkeletonText(width: 160),
                          SizedBox(height: 8),
                          SkeletonText(width: 120, height: 12),
                        ],
                      ),
                    ),
                    SizedBox(width: AppConstants.spacingMedium),
                    SkeletonText(width: 80),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Text(
      title,
      style: GoogleFonts.poppins(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: Theme.of(context).colorScheme.onSurface,
      ),
    );
  }
}
