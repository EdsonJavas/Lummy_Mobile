import 'package:flutter/material.dart';

import 'package:lummy/shared/widgets/widgets.dart';
import 'package:lummy/core/theme/design_tokens.dart';

/// Gradient header: back button, avatar, user info and compact stats.
class ParentProfileHeader extends StatelessWidget {
  final bool isDark;
  final String userName;
  final String userEmail;
  final String? avatarUrl;
  final int childrenCount;
  final double totalChildrenBalance;
  final DateTime? createdAt;
  final VoidCallback onBack;

  const ParentProfileHeader({
    super.key,
    required this.isDark,
    required this.userName,
    required this.userEmail,
    required this.avatarUrl,
    required this.childrenCount,
    required this.totalChildrenBalance,
    required this.createdAt,
    required this.onBack,
  });

  // URL do avatar padrão (fallback quando não há foto)
  static const _avatarUrlDefault =
      'https://hebbkx1anhila5yf.public.blob.vercel-storage.com/Lum%202-0CkW5uvZjaDxIjCSextrqE198N99r7.png';

  // Paleta de cores vibrantes
  static const _blue = LummyColors.blue500;
  static const _purple = LummyColors.violet500;
  static const _green = LummyColors.emerald500;
  static const _orange = LummyColors.amber500;
  static const _pink = LummyColors.pink500;

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? const [LummyColors.indigo950, LummyColors.indigo900, LummyColors.violet900]
              : const [LummyColors.violet600, LummyColors.violet500, LummyColors.violet400],
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(32),
          bottomRight: Radius.circular(32),
        ),
      ),
      child: Stack(
        children: [
          // Círculos decorativos (menores)
          Positioned(
            top: -30,
            right: -30,
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.08),
              ),
            ),
          ),
          Positioned(
            bottom: 20,
            left: -20,
            child: Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.05),
              ),
            ),
          ),

          // Conteúdo compacto
          Padding(
            padding: EdgeInsets.fromLTRB(20, topPadding + 8, 20, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Barra superior
                Row(
                  children: [
                    GestureDetector(
                      onTap: onBack,
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.arrow_back_ios_new_rounded,
                          color: Colors.white,
                          size: 18,
                        ),
                      ),
                    ),
                    const Expanded(child: SizedBox()),
                    Text(
                      'Meu Perfil',
                      style: LummyFonts.body(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                    const Expanded(child: SizedBox()),
                    const SizedBox(width: 40),
                  ],
                ),
                const SizedBox(height: 16),

                // Avatar + Info em Row
                Row(
                  children: [
                    // Avatar compacto
                    Stack(
                      children: [
                        Container(
                          width: 80,
                          height: 80,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: SweepGradient(
                              colors: [_purple, _blue, _pink, _orange, _purple],
                            ),
                          ),
                        ),
                        Positioned.fill(
                          child: Padding(
                            padding: const EdgeInsets.all(3),
                            child: Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.white,
                                  width: 3,
                                ),
                              ),
                              child: ClipOval(
                                child: CachedAvatar(
                                  imageUrl: avatarUrl ?? _avatarUrlDefault,
                                  size: 74,
                                ),
                              ),
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: _green,
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 2),
                            ),
                            child: const Icon(
                              Icons.check_rounded,
                              color: Colors.white,
                              size: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(width: 16),

                    // Info do usuário
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                              userName,
                              style: LummyFonts.body(
                                fontSize: 22,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(
                                Icons.email_rounded,
                                size: 14,
                                color: Colors.white.withValues(alpha: 0.8),
                              ),
                              const SizedBox(width: 6),
                              Flexible(
                                child: Text(
                                  userEmail,
                                  style: LummyFonts.body(
                                    fontSize: 13,
                                    color: Colors.white.withValues(alpha: 0.85),
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          // Badge inline
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.shield_rounded,
                                  color: Colors.white,
                                  size: 12,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  'Responsável',
                                  style: LummyFonts.body(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Stats compactos
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildCompactStat(
                        value: childrenCount.toString(),
                        label: childrenCount == 1 ? 'Filho' : 'Filhos',
                        icon: Icons.child_care_rounded,
                      ),
                      Container(
                        width: 1,
                        height: 30,
                        color: Colors.white.withValues(alpha: 0.3),
                      ),
                      _buildCompactStat(
                        value: 'R\$${totalChildrenBalance.toStringAsFixed(0)}',
                        label: 'Saldo Total',
                        icon: Icons.account_balance_wallet_rounded,
                      ),
                      Container(
                        width: 1,
                        height: 30,
                        color: Colors.white.withValues(alpha: 0.3),
                      ),
                      _buildCompactStat(
                        value: _getMemberSinceShort(),
                        label: 'Membro',
                        icon: Icons.access_time_rounded,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getMemberSinceShort() {
    if (createdAt == null) return '—';
    final months = DateTime.now().difference(createdAt!).inDays ~/ 30;
    if (months < 1) return '<1m';
    return '${months}m';
  }

  Widget _buildCompactStat({
    required String value,
    required String label,
    required IconData icon,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: Colors.white.withValues(alpha: 0.9), size: 18),
        const SizedBox(height: 4),
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            value,
            style: LummyFonts.body(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
        ),
        Text(
          label,
          style: LummyFonts.body(
            fontSize: 10,
            fontWeight: FontWeight.w500,
            color: Colors.white.withValues(alpha: 0.8),
          ),
        ),
      ],
    );
  }
}
