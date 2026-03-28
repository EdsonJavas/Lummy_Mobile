import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/app_constants.dart';

enum ButtonType { primary, secondary, outline, text }

enum ButtonSize { small, medium, large }

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final ButtonType type;
  final ButtonSize size;
  final bool isLoading;
  final IconData? icon;
  final Color? customColor;
  final double? width;

  const CustomButton({
    super.key,
    required this.text,
    this.onPressed,
    this.type = ButtonType.primary,
    this.size = ButtonSize.medium,
    this.isLoading = false,
    this.icon,
    this.customColor,
    this.width,
  });

  @override
  Widget build(BuildContext context) {
    final isSmallScreen =
        MediaQuery.of(context).size.height < AppConstants.smallScreenHeight;

    // Tamanhos baseados no ButtonSize
    final double fontSize;
    final double padding;
    final double height;

    switch (size) {
      case ButtonSize.small:
        fontSize = isSmallScreen ? 12 : 14;
        padding = isSmallScreen ? 12 : 16;
        height = 48;
        break;
      case ButtonSize.medium:
        fontSize = isSmallScreen ? 14 : 16;
        padding = isSmallScreen ? 16 : 20;
        height = isSmallScreen ? 48 : 52;
        break;
      case ButtonSize.large:
        fontSize = isSmallScreen ? 16 : 18;
        padding = isSmallScreen ? 20 : 24;
        height = isSmallScreen ? 50 : 56;
        break;
    }

    // Cores baseadas no ButtonType
    Color backgroundColor;
    Color foregroundColor;
    BorderSide borderSide;
    List<BoxShadow>? boxShadow;

    switch (type) {
      case ButtonType.primary:
        backgroundColor = customColor ?? const Color(AppConstants.accentOrange);
        foregroundColor = Colors.white;
        borderSide = BorderSide.none;
        boxShadow = [
          BoxShadow(
            color: (customColor ?? const Color(AppConstants.accentOrange))
                .withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ];
        break;
      case ButtonType.secondary:
        backgroundColor = customColor ?? const Color(AppConstants.primaryBlue);
        foregroundColor = Colors.white;
        borderSide = BorderSide.none;
        boxShadow = [
          BoxShadow(
            color: (customColor ?? const Color(AppConstants.primaryBlue))
                .withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ];
        break;
      case ButtonType.outline:
        backgroundColor = Colors.transparent;
        foregroundColor = customColor ?? const Color(AppConstants.primaryBlue);
        borderSide = BorderSide(
          color: customColor ?? const Color(AppConstants.primaryBlue),
          width: 2,
        );
        boxShadow = null;
        break;
      case ButtonType.text:
        backgroundColor = Colors.transparent;
        foregroundColor = customColor ?? const Color(AppConstants.primaryBlue);
        borderSide = BorderSide.none;
        boxShadow = null;
        break;
    }

    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        gradient: type == ButtonType.primary || type == ButtonType.secondary
            ? LinearGradient(
                colors: [backgroundColor, backgroundColor.withOpacity(0.8)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )
            : null,
        borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
        boxShadow: boxShadow,
      ),
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor:
              type == ButtonType.primary || type == ButtonType.secondary
              ? Colors.transparent
              : backgroundColor,
          foregroundColor: foregroundColor,
          elevation: 0,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
            side: borderSide,
          ),
          padding: EdgeInsets.symmetric(horizontal: padding),
        ),
        child: isLoading
            ? SizedBox(
                height: fontSize + 4,
                width: fontSize + 4,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(foregroundColor),
                ),
              )
            : Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (icon != null) ...[
                    Icon(icon, size: fontSize + 2),
                    const SizedBox(width: AppConstants.spacingSmall),
                  ],
                  Flexible(
                    child: Text(
                      text,
                      style: GoogleFonts.poppins(
                        fontSize: fontSize,
                        fontWeight: FontWeight.w600,
                      ),
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
