import 'package:flutter/material.dart';
import 'package:lummy/shared/widgets/widgets.dart';

/// Esqueleto exibido enquanto as estatísticas do perfil carregam.
class ProfileSkeletonLoader extends StatelessWidget {
  const ProfileSkeletonLoader({
    super.key,
    required this.screenHeight,
  });

  final double screenHeight;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          // Header skeleton
          Container(
            height: screenHeight * 0.60,
            width: double.infinity,
            decoration: BoxDecoration(color: Colors.grey[300]),
          ),
          Transform(
            transform: Matrix4.translationValues(0, -40, 0),
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Theme.of(context).scaffoldBackgroundColor,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(40),
                  topRight: Radius.circular(40),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20.0, 50.0, 20.0, 0.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Stats skeleton
                    const SkeletonText(width: 150, height: 24),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: SkeletonLoader(
                            width: double.infinity,
                            height: 140,
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: SkeletonLoader(
                            width: double.infinity,
                            height: 140,
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    // Achievements skeleton
                    const SkeletonText(width: 150, height: 24),
                    const SizedBox(height: 16),
                    SkeletonLoader(
                      width: double.infinity,
                      height: 200,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    const SizedBox(height: 20),
                    // Settings skeleton
                    const SkeletonText(width: 120, height: 24),
                    const SizedBox(height: 16),
                    ...List.generate(
                      4,
                      (index) => Padding(
                        padding: EdgeInsets.only(bottom: index == 3 ? 0 : 12),
                        child: SkeletonLoader(
                          width: double.infinity,
                          height: 70,
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
