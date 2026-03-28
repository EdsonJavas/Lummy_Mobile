import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:lummy_login/core/services/connectivity_service.dart';

/// Debug/testing screen that shows device info, connectivity status,
/// and useful diagnostics for testing on real devices.
class DeviceInfoScreen extends StatelessWidget {
  const DeviceInfoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? const Color(0xFF0F0F0F) : const Color(0xFFF1F5F9);
    final titleColor = isDark ? Colors.white : const Color(0xFF0F172A);
    final subtitleColor =
        isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);
    final cardBg = isDark ? const Color(0xFF1A1A2E) : Colors.white;
    final borderColor =
        isDark ? const Color(0xFF2D2D2D) : const Color(0xFFE2E8F0);

    final mq = MediaQuery.of(context);
    final connectivity = context.watch<ConnectivityService>();

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        title: Text(
          'Informações do Dispositivo',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        backgroundColor: Colors.transparent,
        foregroundColor: titleColor,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _section(
            'Dispositivo',
            [
              _row('Plataforma', Platform.operatingSystem),
              _row('Versão OS', Platform.operatingSystemVersion),
              _row('Dart', Platform.version.split(' ').first),
              _row('Locale', Platform.localeName),
            ],
            cardBg,
            borderColor,
            titleColor,
            subtitleColor,
          ),
          const SizedBox(height: 16),
          _section(
            'Tela',
            [
              _row('Tamanho', '${mq.size.width.toInt()} x ${mq.size.height.toInt()}'),
              _row('Pixel ratio', '${mq.devicePixelRatio.toStringAsFixed(1)}x'),
              _row('Padding top', '${mq.padding.top.toInt()}'),
              _row('Padding bottom', '${mq.padding.bottom.toInt()}'),
              _row('Orientação', mq.orientation.name),
              _row('Brilho', isDark ? 'Escuro' : 'Claro'),
            ],
            cardBg,
            borderColor,
            titleColor,
            subtitleColor,
          ),
          const SizedBox(height: 16),
          _section(
            'Conectividade',
            [
              _row('Status', connectivity.isOnline ? 'Online' : 'Offline'),
            ],
            cardBg,
            borderColor,
            titleColor,
            subtitleColor,
          ),
          const SizedBox(height: 16),
          _section(
            'Acessibilidade',
            [
              _row('Escala de texto', '${mq.textScaler.scale(1.0).toStringAsFixed(2)}x'),
              _row('Bold text', mq.boldText ? 'Sim' : 'Não'),
              _row('Animações reduzidas', mq.disableAnimations ? 'Sim' : 'Não'),
              _row('Alto contraste', mq.highContrast ? 'Sim' : 'Não'),
            ],
            cardBg,
            borderColor,
            titleColor,
            subtitleColor,
          ),
        ],
      ),
    );
  }

  Widget _section(
    String title,
    List<Widget> children,
    Color cardBg,
    Color borderColor,
    Color titleColor,
    Color subtitleColor,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: titleColor,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: cardBg,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: borderColor),
          ),
          child: Column(children: children),
        ),
      ],
    );
  }

  Widget _row(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.poppins(fontSize: 13, color: const Color(0xFF64748B)),
          ),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
