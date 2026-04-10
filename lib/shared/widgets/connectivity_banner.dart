import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../core/services/connectivity_service.dart';

/// Envolve o corpo principal com um aviso compacto quando offline, sem quebrar layout.
class ConnectivityBanner extends StatefulWidget {
  final Widget child;

  const ConnectivityBanner({super.key, required this.child});

  @override
  State<ConnectivityBanner> createState() => _ConnectivityBannerState();
}

class _ConnectivityBannerState extends State<ConnectivityBanner>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && mounted) {
      context.read<ConnectivityService>().recheck();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ConnectivityService>(
      builder: (context, connectivity, _) {
        return Column(
          children: [
            AnimatedSize(
              duration: const Duration(milliseconds: 280),
              curve: Curves.easeInOutCubic,
              alignment: Alignment.topCenter,
              clipBehavior: Clip.hardEdge,
              child: connectivity.isOnline
                  ? const SizedBox(width: double.infinity, height: 0)
                  : _OfflineBanner(connectivity: connectivity),
            ),
            Expanded(child: widget.child),
          ],
        );
      },
    );
  }
}

class _OfflineBanner extends StatelessWidget {
  final ConnectivityService connectivity;

  const _OfflineBanner({required this.connectivity});

  static const _iconSize = 22.0;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor =
        isDark ? const Color(0xFFFCA5A5) : const Color(0xFFDC2626);
    final bg = isDark ? const Color(0xFF7F1D1D) : const Color(0xFFFEF2F2);
    final screenW = MediaQuery.sizeOf(context).width;
    final narrow = screenW < 360;

    final messageStyle = GoogleFonts.poppins(
      fontSize: narrow ? 12.5 : 13,
      fontWeight: FontWeight.w500,
      height: 1.25,
      color: textColor,
    );

    final actionStyle = GoogleFonts.poppins(
      fontSize: narrow ? 12.5 : 13,
      fontWeight: FontWeight.w600,
      color: textColor,
    );

    return Material(
      color: bg,
      child: SafeArea(
        bottom: false,
        minimum: EdgeInsets.zero,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final useStacked = narrow || constraints.maxWidth < 340;

            if (useStacked) {
              return Padding(
                padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(top: 2),
                          child: Icon(
                            Icons.wifi_off_rounded,
                            size: _iconSize,
                            color: textColor,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'Sem conexão com a internet. Os dados podem estar desatualizados.',
                            style: messageStyle,
                            maxLines: 4,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () => connectivity.recheck(),
                        style: TextButton.styleFrom(
                          foregroundColor: textColor,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 4,
                          ),
                          minimumSize: const Size(48, 40),
                          tapTargetSize: MaterialTapTargetSize.padded,
                        ),
                        child: Text('TENTAR NOVAMENTE', style: actionStyle),
                      ),
                    ),
                  ],
                ),
              );
            }

            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Icon(
                    Icons.wifi_off_rounded,
                    size: _iconSize,
                    color: textColor,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Sem conexão com a internet',
                      style: messageStyle,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  TextButton(
                    onPressed: () => connectivity.recheck(),
                    style: TextButton.styleFrom(
                      foregroundColor: textColor,
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      minimumSize: const Size(48, 40),
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: Text('TENTAR NOVAMENTE', style: actionStyle),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
