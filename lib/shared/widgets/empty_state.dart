import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/app_constants.dart';
import 'custom_button.dart';

class EmptyState extends StatelessWidget {
  final String emoji;
  final String title;
  final String message;
  final String? buttonText;
  final VoidCallback? onButtonPressed;

  const EmptyState({
    super.key,
    required this.emoji,
    required this.title,
    required this.message,
    this.buttonText,
    this.onButtonPressed,
  });

  @override
  Widget build(BuildContext context) {
    final isSmallScreen =
        MediaQuery.of(context).size.height < AppConstants.smallScreenHeight;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.spacingXLarge),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(emoji, style: TextStyle(fontSize: isSmallScreen ? 60 : 80)),
            const SizedBox(height: AppConstants.spacingLarge),
            Text(
              title,
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: isSmallScreen ? 18 : 20,
                fontWeight: FontWeight.w600,
                color: const Color(AppConstants.textPrimary),
              ),
            ),
            const SizedBox(height: AppConstants.spacingSmall),
            Text(
              message,
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: isSmallScreen ? 14 : 16,
                fontWeight: FontWeight.w400,
                color: const Color(AppConstants.textSecondary),
              ),
            ),
            if (buttonText != null && onButtonPressed != null) ...[
              const SizedBox(height: AppConstants.spacingXLarge),
              CustomButton(
                text: buttonText!,
                onPressed: onButtonPressed,
                type: ButtonType.primary,
                size: ButtonSize.medium,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
