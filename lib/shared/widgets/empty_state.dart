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
  final IconData? icon;
  final Color? iconColor;

  const EmptyState({
    super.key,
    required this.emoji,
    required this.title,
    required this.message,
    this.buttonText,
    this.onButtonPressed,
    this.icon,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    final isSmallScreen =
        MediaQuery.of(context).size.height < AppConstants.smallScreenHeight;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final titleColor =
        isDark ? Colors.white : const Color(AppConstants.textPrimary);
    final subtitleColor =
        isDark ? const Color(0xFF94A3B8) : const Color(AppConstants.textSecondary);

    return Semantics(
      label: '$title. $message',
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppConstants.spacingXLarge),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                Container(
                  width: isSmallScreen ? 80 : 96,
                  height: isSmallScreen ? 80 : 96,
                  decoration: BoxDecoration(
                    color: (iconColor ?? const Color(AppConstants.primaryBlue))
                        .withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: Icon(
                    icon,
                    size: isSmallScreen ? 36 : 44,
                    color: iconColor ?? const Color(AppConstants.primaryBlue),
                  ),
                ),
              ] else ...[
                ExcludeSemantics(
                  child: Text(
                    emoji,
                    style: TextStyle(fontSize: isSmallScreen ? 60 : 80),
                  ),
                ),
              ],
              const SizedBox(height: AppConstants.spacingLarge),
              Text(
                title,
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: isSmallScreen ? 18 : 20,
                  fontWeight: FontWeight.w600,
                  color: titleColor,
                ),
              ),
              const SizedBox(height: AppConstants.spacingSmall),
              Text(
                message,
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: isSmallScreen ? 14 : 15,
                  fontWeight: FontWeight.w400,
                  color: subtitleColor,
                  height: 1.5,
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
      ),
    );
  }
}
