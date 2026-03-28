import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/services/connectivity_service.dart';

class ConnectivityBanner extends StatelessWidget {
  final Widget child;

  const ConnectivityBanner({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Consumer<ConnectivityService>(
      builder: (context, connectivity, _) {
        return Column(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 350),
              curve: Curves.easeInOut,
              height: connectivity.isOnline ? 0 : null,
              child: connectivity.isOnline
                  ? const SizedBox.shrink()
                  : _OfflineBanner(connectivity: connectivity),
            ),
            Expanded(child: child),
          ],
        );
      },
    );
  }
}

class _OfflineBanner extends StatelessWidget {
  final ConnectivityService connectivity;

  const _OfflineBanner({required this.connectivity});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Material(
      color: isDark ? const Color(0xFF7F1D1D) : const Color(0xFFFEF2F2),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Row(
            children: [
              Icon(
                Icons.wifi_off_rounded,
                size: 20,
                color: isDark ? const Color(0xFFFCA5A5) : const Color(0xFFDC2626),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Sem conexão com a internet',
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: isDark
                        ? const Color(0xFFFCA5A5)
                        : const Color(0xFFDC2626),
                  ),
                ),
              ),
              GestureDetector(
                onTap: () => connectivity.recheck(),
                child: Text(
                  'Tentar',
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: isDark
                        ? const Color(0xFFFCA5A5)
                        : const Color(0xFFDC2626),
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
