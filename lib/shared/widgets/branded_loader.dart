import 'package:flutter/material.dart';

class BrandedLoader extends StatelessWidget {
  final double size;
  final String? label;
  final bool showShadow;

  const BrandedLoader({
    super.key,
    this.size = 72,
    this.label,
    this.showShadow = true,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final background = Theme.of(context).scaffoldBackgroundColor;

    // Conteúdo principal do loader
    Widget loaderContent = Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: SweepGradient(
          colors: [
            colorScheme.primary,
            colorScheme.secondary,
            colorScheme.primary,
          ],
        ),
        boxShadow: showShadow
            ? [
                BoxShadow(
                  color: colorScheme.primary.withOpacity(0.25),
                  blurRadius: 16,
                  offset: const Offset(0, 8),
                ),
              ]
            : null,
      ),
      padding: const EdgeInsets.all(6),
      child: Container(
        decoration: BoxDecoration(shape: BoxShape.circle, color: background),
        padding: const EdgeInsets.all(14),
        child: CircularProgressIndicator(
          strokeWidth: 3,
          valueColor: AlwaysStoppedAnimation<Color>(colorScheme.primary),
          backgroundColor: colorScheme.primary.withOpacity(0.1),
        ),
      ),
    );

    // Se não tiver label, retorna apenas o loader
    if (label == null) {
      return loaderContent;
    }

    // Com label - usa FittedBox para evitar overflow
    return FittedBox(
      fit: BoxFit.scaleDown,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          loaderContent,
          const SizedBox(height: 16),
          Text(
            label!,
            style: Theme.of(context).textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
