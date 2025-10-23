import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/app_constants.dart';

class CustomTextField extends StatefulWidget {
  final TextEditingController controller;
  final String hintText;
  final String? labelText;
  final IconData? prefixIcon;
  final Widget? suffixIcon;
  final bool obscureText;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final void Function(bool)? onFocusChange;
  final TextCapitalization textCapitalization;
  final bool enabled;
  final int? maxLines;
  final int? maxLength;

  const CustomTextField({
    super.key,
    required this.controller,
    required this.hintText,
    this.labelText,
    this.prefixIcon,
    this.suffixIcon,
    this.obscureText = false,
    this.keyboardType,
    this.inputFormatters,
    this.validator,
    this.onChanged,
    this.onFocusChange,
    this.textCapitalization = TextCapitalization.none,
    this.enabled = true,
    this.maxLines = 1,
    this.maxLength,
  });

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  bool _isFocused = false;

  @override
  Widget build(BuildContext context) {
    final isSmallScreen =
        MediaQuery.of(context).size.height < AppConstants.smallScreenHeight;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        color: const Color(AppConstants.backgroundGray),
        borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
        border: Border.all(
          color: _isFocused
              ? const Color(AppConstants.primaryBlue)
              : Colors.transparent,
          width: 2,
        ),
        boxShadow: _isFocused
            ? [
                BoxShadow(
                  color: const Color(AppConstants.primaryBlue).withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ]
            : [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
      ),
      child: Focus(
        onFocusChange: (hasFocus) {
          setState(() {
            _isFocused = hasFocus;
          });
          widget.onFocusChange?.call(hasFocus);
        },
        child: TextFormField(
          controller: widget.controller,
          obscureText: widget.obscureText,
          keyboardType: widget.keyboardType,
          inputFormatters: widget.inputFormatters,
          textCapitalization: widget.textCapitalization,
          enabled: widget.enabled,
          maxLines: widget.maxLines,
          maxLength: widget.maxLength,
          style: GoogleFonts.poppins(
            fontSize: isSmallScreen ? 14 : 16,
            color: const Color(AppConstants.textPrimary),
            fontWeight: FontWeight.w500,
          ),
          decoration: InputDecoration(
            hintText: widget.hintText,
            labelText: widget.labelText,
            hintStyle: GoogleFonts.poppins(
              color: const Color(AppConstants.textSecondary),
              fontSize: isSmallScreen ? 14 : 16,
              fontWeight: FontWeight.w400,
            ),
            labelStyle: GoogleFonts.poppins(
              color: _isFocused
                  ? const Color(AppConstants.primaryBlue)
                  : const Color(AppConstants.textSecondary),
              fontSize: isSmallScreen ? 12 : 14,
              fontWeight: FontWeight.w500,
            ),
            prefixIcon: widget.prefixIcon != null
                ? Icon(
                    widget.prefixIcon,
                    color: _isFocused
                        ? const Color(AppConstants.primaryBlue)
                        : const Color(AppConstants.textSecondary),
                    size: isSmallScreen ? 20 : 22,
                  )
                : null,
            suffixIcon: widget.suffixIcon,
            border: InputBorder.none,
            contentPadding: EdgeInsets.symmetric(
              horizontal: isSmallScreen ? 16 : 20,
              vertical: isSmallScreen ? 14 : 18,
            ),
            errorStyle: GoogleFonts.poppins(fontSize: isSmallScreen ? 10 : 12),
            counterText: '',
          ),
          validator: widget.validator,
          onChanged: widget.onChanged,
        ),
      ),
    );
  }
}
