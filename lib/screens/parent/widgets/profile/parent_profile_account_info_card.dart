import 'package:flutter/material.dart';

import 'package:lummy/core/theme/design_tokens.dart';

/// "Sua conta" card (e-mail and member since).
class ParentProfileAccountInfoCard extends StatelessWidget {
  final bool isDark;
  final String userEmail;
  final DateTime? createdAt;

  const ParentProfileAccountInfoCard({
    super.key,
    required this.isDark,
    required this.userEmail,
    required this.createdAt,
  });

  static const _green = LummyColors.emerald500;

  @override
  Widget build(BuildContext context) {
    final memberSince = createdAt != null
        ? '${createdAt!.day.toString().padLeft(2, '0')}/${createdAt!.month.toString().padLeft(2, '0')}/${createdAt!.year}'
        : '—';

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? LummyColors.darkMaterial : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.15 : 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: _green.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.person_rounded, color: _green, size: 20),
              ),
              const SizedBox(width: 12),
              Text(
                'Sua conta',
                style: LummyFonts.body(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: isDark ? Colors.white : LummyColors.slate800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildInfoRow(
            Icons.email_outlined,
            'E-mail',
            userEmail.isNotEmpty ? userEmail : '—',
            isDark,
          ),
          const SizedBox(height: 12),
          _buildInfoRow(
            Icons.calendar_today_rounded,
            'Membro desde',
            memberSince,
            isDark,
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(
    IconData icon,
    String label,
    String value,
    bool isDark,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: isDark ? LummyColors.slate500 : LummyColors.slate400),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: LummyFonts.body(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: isDark ? LummyColors.slate400 : LummyColors.slate500,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: LummyFonts.body(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.white : LummyColors.slate800,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
