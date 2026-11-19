import 'package:flutter/material.dart';

import 'package:lummy/core/theme/design_tokens.dart';

/// "Escanear QR Code" card with the scan / type-code buttons.
class DistributionScanQrSection extends StatelessWidget {
  final bool isDark;
  final VoidCallback onScan;
  final VoidCallback onTypeCode;

  const DistributionScanQrSection({
    super.key,
    required this.isDark,
    required this.onScan,
    required this.onTypeCode,
  });

  static const _blue = LummyColors.blue500;
  static const _purple = LummyColors.violet500;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [LummyColors.slate800, LummyColors.indigo900]
              : [_blue.withValues(alpha: 0.1), _purple.withValues(alpha: 0.1)],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isDark ? _purple.withValues(alpha: 0.3) : _blue.withValues(alpha: 0.2),
          width: 1.5,
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: [_blue, _purple]),
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: _blue.withValues(alpha: 0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.qr_code_scanner_rounded,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Escanear QR Code',
                      style: LummyFonts.body(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: isDark ? Colors.white : LummyColors.slate800,
                      ),
                    ),
                    Text(
                      'Seu filho pediu dinheiro? Escaneie!',
                      style: LummyFonts.body(
                        fontSize: 13,
                        color: isDark
                            ? LummyColors.slate400
                            : LummyColors.slate500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          // Botões de ação
          Row(
            children: [
              Expanded(
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: onScan,
                    borderRadius: BorderRadius.circular(14),
                    child: Container(
                      height: 54,
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [_blue, _purple],
                        ),
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [
                          BoxShadow(
                            color: _blue.withValues(alpha: 0.3),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.qr_code_scanner_rounded,
                            color: Colors.white,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Escanear',
                            style: LummyFonts.body(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: onTypeCode,
                    borderRadius: BorderRadius.circular(14),
                    child: Container(
                      height: 54,
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      decoration: BoxDecoration(
                        color: isDark
                            ? Colors.white.withValues(alpha: 0.1)
                            : _purple.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: _purple.withValues(alpha: isDark ? 0.3 : 0.3),
                          width: 1.5,
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.keyboard_rounded,
                            color: _purple,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Flexible(
                            child: Text(
                              'Digitar código',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: LummyFonts.body(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: _purple,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
