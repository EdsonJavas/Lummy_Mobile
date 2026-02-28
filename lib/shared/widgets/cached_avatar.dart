import 'package:flutter/material.dart';

class CachedAvatar extends StatelessWidget {
  final String imageUrl;
  final double size;
  final Color? borderColor;
  final double borderWidth;
  final IconData fallbackIcon;
  final Color? fallbackIconColor;

  const CachedAvatar({
    super.key,
    required this.imageUrl,
    this.size = 56,
    this.borderColor,
    this.borderWidth = 2,
    this.fallbackIcon = Icons.person,
    this.fallbackIconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: borderColor != null
            ? Border.all(color: borderColor!, width: borderWidth)
            : null,
        boxShadow: borderColor != null
            ? [
                BoxShadow(
                  color: borderColor!.withOpacity(0.2),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ]
            : null,
      ),
      child: ClipOval(
        child: Image.network(
          imageUrl,
          fit: BoxFit.cover,
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return Center(
              child: CircularProgressIndicator(
                value: loadingProgress.expectedTotalBytes != null
                    ? loadingProgress.cumulativeBytesLoaded /
                          loadingProgress.expectedTotalBytes!
                    : null,
                strokeWidth: 2,
                color: borderColor ?? Theme.of(context).colorScheme.primary,
              ),
            );
          },
          errorBuilder: (context, error, stackTrace) {
            return Container(
              color: (borderColor ?? Theme.of(context).colorScheme.primary)
                  .withOpacity(0.1),
              child: Icon(
                fallbackIcon,
                color:
                    fallbackIconColor ??
                    borderColor ??
                    Theme.of(context).colorScheme.primary,
                size: size * 0.5,
              ),
            );
          },
        ),
      ),
    );
  }
}
