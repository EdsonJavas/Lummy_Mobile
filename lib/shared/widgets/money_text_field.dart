import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class MoneyTextField extends StatefulWidget {
  final String? label;
  final String? hint;
  final double? initialValue;
  final ValueChanged<double?>? onChanged;
  final String? errorText;
  final bool enabled;
  final bool autofocus;
  final FocusNode? focusNode;
  final TextEditingController? controller;
  final EdgeInsetsGeometry? contentPadding;
  final bool showPrefix;
  final String prefixText;
  final Color? prefixColor;
  final double? fontSize;
  final FontWeight? fontWeight;
  final TextAlign textAlign;
  final bool isSmallScreen;

  const MoneyTextField({
    super.key,
    this.label,
    this.hint,
    this.initialValue,
    this.onChanged,
    this.errorText,
    this.enabled = true,
    this.autofocus = false,
    this.focusNode,
    this.controller,
    this.contentPadding,
    this.showPrefix = true,
    this.prefixText = 'R\$ ',
    this.prefixColor,
    this.fontSize,
    this.fontWeight,
    this.textAlign = TextAlign.start,
    this.isSmallScreen = false,
  });

  @override
  State<MoneyTextField> createState() => _MoneyTextFieldState();
}

class _MoneyTextFieldState extends State<MoneyTextField> {
  late TextEditingController _controller;
  late FocusNode _focusNode;
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? TextEditingController();
    _focusNode = widget.focusNode ?? FocusNode();

    if (widget.initialValue != null) {
      _controller.text = _formatCurrency(widget.initialValue!);
    }

    _focusNode.addListener(_onFocusChange);
  }

  @override
  void dispose() {
    if (widget.controller == null) {
      _controller.dispose();
    }
    if (widget.focusNode == null) {
      _focusNode.dispose();
    }
    super.dispose();
  }

  void _onFocusChange() {
    setState(() {
      _isFocused = _focusNode.hasFocus;
    });
  }

  String _formatCurrency(double value) {
    // Formatar como moeda brasileira: 1.234,56
    final formatter = NumberFormat.currency(
      locale: 'pt_BR',
      symbol: '',
      decimalDigits: 2,
    );
    return formatter.format(value).trim();
  }

  void _onTextChanged(String value) {
    // Comportamento de digitação por centavos: "1" -> "0,01", "12" -> "0,12", "123" -> "1,23"
    // Mantemos apenas dígitos e convertemos para double dividindo por 100
    final digitsOnly = value.replaceAll(RegExp(r'[^0-9]'), '');

    if (digitsOnly.isEmpty) {
      _controller.clear();
      widget.onChanged?.call(null);
      return;
    }

    final cents = double.parse(digitsOnly);
    final numericValue = cents / 100.0;
    final formattedValue = _formatCurrency(numericValue);

    if (_controller.text != formattedValue) {
      _controller.value = TextEditingValue(
        text: formattedValue,
        selection: TextSelection.collapsed(offset: formattedValue.length),
      );
    }

    widget.onChanged?.call(numericValue);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.label != null) ...[
          Text(
            widget.label!,
            style: GoogleFonts.poppins(
              fontSize: widget.isSmallScreen ? 14 : 16,
              fontWeight: FontWeight.w600,
              color: theme.textTheme.titleMedium?.color,
            ),
          ),
          const SizedBox(height: 8),
        ],
        Container(
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: _isFocused
                  ? const Color(0xFF3B82F6)
                  : isDark
                  ? const Color(0xFF2D3748)
                  : const Color(0xFFE2E8F0),
              width: _isFocused ? 2 : 1,
            ),
            boxShadow: _isFocused
                ? [
                    BoxShadow(
                      color: const Color(0xFF3B82F6).withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: TextFormField(
            controller: _controller,
            focusNode: _focusNode,
            enabled: widget.enabled,
            autofocus: widget.autofocus,
            textAlign: widget.textAlign,
            keyboardType: const TextInputType.numberWithOptions(decimal: false),
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            style: GoogleFonts.poppins(
              fontSize: widget.fontSize ?? (widget.isSmallScreen ? 18 : 20),
              fontWeight: widget.fontWeight ?? FontWeight.w600,
              color: theme.textTheme.titleLarge?.color,
            ),
            decoration: InputDecoration(
              hintText: widget.hint ?? '0,00',
              hintStyle: GoogleFonts.poppins(
                fontSize: widget.fontSize ?? (widget.isSmallScreen ? 18 : 20),
                fontWeight: FontWeight.w400,
                color: theme.textTheme.bodyMedium?.color,
              ),
              prefixText: widget.showPrefix ? widget.prefixText : null,
              prefixStyle: GoogleFonts.poppins(
                fontSize: widget.fontSize ?? (widget.isSmallScreen ? 18 : 20),
                fontWeight: widget.fontWeight ?? FontWeight.w600,
                color: widget.prefixColor ?? theme.textTheme.titleLarge?.color,
              ),
              suffixIcon: _controller.text.isNotEmpty
                  ? GestureDetector(
                      onTap: () {
                        _controller.clear();
                        widget.onChanged?.call(null);
                      },
                      child: Container(
                        margin: const EdgeInsets.all(8),
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: isDark
                              ? const Color(0xFF374151)
                              : const Color(0xFFF3F4F6),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.clear_rounded,
                          size: 16,
                          color: Color(0xFF9CA3AF),
                        ),
                      ),
                    )
                  : null,
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              errorBorder: InputBorder.none,
              focusedErrorBorder: InputBorder.none,
              filled: true,
              fillColor: isDark
                  ? const Color(0xFF1E293B).withOpacity(0.5)
                  : const Color(0xFFF8FAFC),
              contentPadding:
                  widget.contentPadding ??
                  EdgeInsets.symmetric(
                    horizontal: widget.isSmallScreen ? 16 : 20,
                    vertical: widget.isSmallScreen ? 16 : 20,
                  ),
              errorText: widget.errorText,
            ),
            onChanged: _onTextChanged,
          ),
        ),
        if (widget.errorText != null) ...[
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(
                Icons.error_outline_rounded,
                size: 16,
                color: Color(0xFFEF4444),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  widget.errorText!,
                  style: GoogleFonts.poppins(
                    fontSize: widget.isSmallScreen ? 12 : 14,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFFEF4444),
                  ),
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }
}
