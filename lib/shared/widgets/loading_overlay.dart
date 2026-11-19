import 'package:flutter/material.dart';
import '../../core/constants/app_constants.dart';
import 'package:lummy/core/theme/design_tokens.dart';

class LoadingOverlay extends StatelessWidget {
  final String? message;

  const LoadingOverlay({super.key, this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black.withValues(alpha: 0.5),
      child: Center(
        child: Container(
          padding: const EdgeInsets.all(AppConstants.spacingXLarge),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(AppConstants.radiusLarge),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(
                  LummyColors.brandBlue,
                ),
              ),
              if (message != null) ...[
                const SizedBox(height: AppConstants.spacingLarge),
                Text(
                  message!,
                  textAlign: TextAlign.center,
                  style: LummyFonts.body(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: LummyColors.slate800,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
