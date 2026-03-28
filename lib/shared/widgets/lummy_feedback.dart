import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

enum LummyFeedbackType { success, error, warning, info }

class LummyFeedback {
  LummyFeedback._();

  static const _green = Color(0xFF10B981);
  static const _red = Color(0xFFEF4444);
  static const _orange = Color(0xFFF59E0B);
  static const _blue = Color(0xFF3B82F6);

  static Color _colorFor(LummyFeedbackType type) {
    switch (type) {
      case LummyFeedbackType.success:
        return _green;
      case LummyFeedbackType.error:
        return _red;
      case LummyFeedbackType.warning:
        return _orange;
      case LummyFeedbackType.info:
        return _blue;
    }
  }

  static IconData _iconFor(LummyFeedbackType type) {
    switch (type) {
      case LummyFeedbackType.success:
        return Icons.check_circle_rounded;
      case LummyFeedbackType.error:
        return Icons.error_rounded;
      case LummyFeedbackType.warning:
        return Icons.warning_rounded;
      case LummyFeedbackType.info:
        return Icons.info_rounded;
    }
  }

  static void show(
    BuildContext context, {
    required String message,
    LummyFeedbackType type = LummyFeedbackType.success,
    Duration duration = const Duration(seconds: 3),
  }) {
    final color = _colorFor(type);
    final icon = _iconFor(type);

    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(icon, color: Colors.white, size: 20),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  message,
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          backgroundColor: color,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          margin: const EdgeInsets.all(16),
          duration: duration,
          elevation: 6,
        ),
      );
  }

  static void success(BuildContext context, String message) =>
      show(context, message: message, type: LummyFeedbackType.success);

  static void error(BuildContext context, String message) =>
      show(context, message: message, type: LummyFeedbackType.error);

  static void warning(BuildContext context, String message) =>
      show(context, message: message, type: LummyFeedbackType.warning);

  static void info(BuildContext context, String message) =>
      show(context, message: message, type: LummyFeedbackType.info);

  /// Wraps an async operation with loading overlay feedback.
  /// Returns the result of [action]. Shows success/error SnackBar based on outcome.
  static Future<bool> withLoading(
    BuildContext context, {
    required Future<bool> Function() action,
    required String successMessage,
    String? errorMessage,
    String? errorStateGetter,
  }) async {
    final overlay = OverlayEntry(
      builder: (ctx) => _LoadingScrim(),
    );

    Overlay.of(context).insert(overlay);

    try {
      final ok = await action();
      overlay.remove();

      if (!context.mounted) return ok;

      if (ok) {
        success(context, successMessage);
      } else {
        error(context, errorMessage ?? 'Ocorreu um erro. Tente novamente.');
      }
      return ok;
    } catch (e) {
      overlay.remove();
      if (context.mounted) {
        error(context, errorMessage ?? 'Ocorreu um erro. Tente novamente.');
      }
      return false;
    }
  }
}

class _LoadingScrim extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: Colors.black26,
      child: Center(
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Theme.of(context).brightness == Brightness.dark
                ? const Color(0xFF1E1E2E)
                : Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 20,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: const SizedBox(
            width: 28,
            height: 28,
            child: CircularProgressIndicator(strokeWidth: 3),
          ),
        ),
      ),
    );
  }
}
