import 'package:flutter/material.dart';
import 'package:lummy/core/theme/design_tokens.dart';

enum LummyFeedbackType { success, error, warning, info }

class LummyFeedback {
  LummyFeedback._();

  static const _green = LummyColors.emerald500;
  static const _red = LummyColors.red500;
  static const _orange = LummyColors.amber500;
  static const _blue = LummyColors.blue500;

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
                  style: LummyFonts.body(
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
          margin: EdgeInsets.fromLTRB(
            16,
            16,
            16,
            16 + LummyFeedbackInset.of(context),
          ),
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
                ? LummyColors.darkNavySurface
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

/// Espaço extra embaixo dos avisos flutuantes de [LummyFeedback], para não
/// cobrirem um menu que flutua no fim da tela (a cápsula da área da criança).
class LummyFeedbackInset extends InheritedWidget {
  const LummyFeedbackInset({
    super.key,
    required this.bottom,
    required super.child,
  });

  /// Altura ocupada pelo menu flutuante, a partir do fim da área útil.
  final double bottom;

  static double of(BuildContext context) =>
      context.getInheritedWidgetOfExactType<LummyFeedbackInset>()?.bottom ?? 0;

  @override
  bool updateShouldNotify(LummyFeedbackInset oldWidget) =>
      oldWidget.bottom != bottom;
}
