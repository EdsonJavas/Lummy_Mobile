import 'package:flutter/material.dart';
import 'package:lummy/core/theme/design_tokens.dart';

/// Faixa no topo do login quando não há internet (alinhada ao visual Lummy).
class LoginOfflineCard extends StatelessWidget {
  final VoidCallback onRetry;
  final bool compact;

  const LoginOfflineCard({
    super.key,
    required this.onRetry,
    required this.compact,
  });

  static const _accent = LummyColors.orange600;
  static const _accentSoft = LummyColors.orange50;
  static const _title = LummyColors.slate800;
  static const _subtitle = LummyColors.slate500;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      elevation: 0,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(
          horizontal: compact ? 12 : 14,
          vertical: compact ? 10 : 12,
        ),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.96),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: _accent.withValues(alpha: 0.35),
            width: 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.14),
              blurRadius: 18,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final narrow = constraints.maxWidth < 340;
            final iconBox = Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: _accentSoft,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.wifi_off_rounded,
                color: _accent,
                size: 22,
              ),
            );

            final titleStyle = LummyFonts.body(
              fontSize: compact ? 13 : 14,
              fontWeight: FontWeight.w700,
              height: 1.2,
              color: _title,
            );
            final bodyStyle = LummyFonts.body(
              fontSize: compact ? 11.5 : 12,
              fontWeight: FontWeight.w500,
              height: 1.3,
              color: _subtitle,
            );
            final actionStyle = LummyFonts.body(
              fontSize: compact ? 12 : 13,
              fontWeight: FontWeight.w600,
              color: LummyColors.brandBlue,
            );

            final textBlock = Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Sem conexão com a internet', style: titleStyle),
                  const SizedBox(height: 2),
                  Text(
                    'Você precisa estar online para entrar ou criar conta.',
                    style: bodyStyle,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            );

            final retry = TextButton(
              onPressed: onRetry,
              style: TextButton.styleFrom(
                foregroundColor: LummyColors.brandBlue,
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                minimumSize: const Size(48, 40),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: Text('TENTAR NOVAMENTE', style: actionStyle),
            );

            if (narrow) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      iconBox,
                      const SizedBox(width: 10),
                      textBlock,
                    ],
                  ),
                  const SizedBox(height: 6),
                  Align(
                    alignment: Alignment.centerRight,
                    child: retry,
                  ),
                ],
              );
            }

            return Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                iconBox,
                const SizedBox(width: 12),
                textBlock,
                retry,
              ],
            );
          },
        ),
      ),
    );
  }
}
