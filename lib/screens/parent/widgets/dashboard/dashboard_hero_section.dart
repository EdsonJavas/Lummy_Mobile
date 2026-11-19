import 'package:flutter/material.dart';
import 'package:lummy/core/utils/formatters.dart';
import 'package:lummy/shared/widgets/widgets.dart';
import 'package:lummy/features/parent/presentation/bloc/parent_dashboard_state.dart';
import 'package:lummy/core/theme/design_tokens.dart';

/// Hero do dashboard do responsável: saudação, avatar e card de saldo.
class DashboardHeroSection extends StatelessWidget {
  final ParentDashboardState state;
  final bool isDark;
  final bool balanceVisible;
  final VoidCallback onToggleBalanceVisibility;
  /// Abre o drawer; quando não null, o ícone hambúrguer é exibido no header.
  final VoidCallback? onOpenDrawer;
  /// Padding à esquerda no hero (usado quando o ícone do drawer não está no hero).
  final double heroLeftPadding;
  final VoidCallback onOpenProfile;

  const DashboardHeroSection({
    super.key,
    required this.state,
    required this.isDark,
    required this.balanceVisible,
    required this.onToggleBalanceVisibility,
    required this.onOpenDrawer,
    required this.heroLeftPadding,
    required this.onOpenProfile,
  });

  // Extrai o primeiro nome do usuário
  String _getFirstName(String? fullName) {
    if (fullName == null || fullName.isEmpty) {
      return 'Responsável';
    }
    final parts = fullName.trim().split(' ');
    return parts.first;
  }

  @override
  Widget build(BuildContext context) {
    final topInset = MediaQuery.of(context).padding.top;

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
      ),
      child: Stack(
        children: [
          // Círculos decorativos (igual ao perfil)
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
          Padding(
            padding: EdgeInsets.fromLTRB(20, topInset + 16, 20, 88),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Linha "Olá, nome" + avatar; ícone hambúrguer no header quando onOpenDrawer != null (rola com a tela)
                Padding(
                  padding: EdgeInsets.only(left: onOpenDrawer != null ? 0 : heroLeftPadding),
                  child: Row(
                    children: [
                      if (onOpenDrawer != null) ...[
                        Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: onOpenDrawer,
                            borderRadius: BorderRadius.circular(12),
                            child: const Padding(
                              padding: EdgeInsets.all(10),
                              child: Icon(
                                Icons.menu_rounded,
                                color: Colors.white,
                                size: 26,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                      ],
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            FittedBox(
                              fit: BoxFit.scaleDown,
                              alignment: Alignment.centerLeft,
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    'Olá, ',
                                    style: LummyFonts.body(
                                      fontSize: 26,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white,
                                    ),
                                  ),
                                  ShaderMask(
                                    shaderCallback: (bounds) => const LinearGradient(
                                      colors: [LummyColors.amber400, LummyColors.amber500],
                                    ).createShader(bounds),
                                    child: Text(
                                      _getFirstName(state.parentName),
                                      style: LummyFonts.body(
                                        fontSize: 26,
                                        fontWeight: FontWeight.w700,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'Gerencie as finanças da família',
                              style: LummyFonts.body(
                                fontSize: 15,
                                fontWeight: FontWeight.w400,
                                color: Colors.white.withValues(alpha: 0.85),
                              ),
                            ),
                          ],
                        ),
                      ),
                      GestureDetector(
                        onTap: onOpenProfile,
                        child: Container(
                          width: 52,
                          height: 52,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.5),
                              width: 2.5,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.2),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: const ClipOval(
                            child: CachedAvatar(
                              imageUrl:
                                  'https://hebbkx1anhila5yf.public.blob.vercel-storage.com/Lum%202-0CkW5uvZjaDxIjCSextrqE198N99r7.png',
                              size: 52,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
          const SizedBox(height: 28),
          // Card de saldo principal - saldo do responsável (mantém alinhamento normal)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.white.withValues(alpha: isDark ? 0.12 : 0.2),
                  Colors.white.withValues(alpha: isDark ? 0.06 : 0.1),
                ],
              ),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.3),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.2),
                  blurRadius: 24,
                  offset: const Offset(0, 12),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.savings_rounded,
                        color: Colors.white,
                        size: 18,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Saldo da Família (Responsável)',
                        style: LummyFonts.body(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: Colors.white.withValues(alpha: 0.9),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        'Disponível',
                        style: LummyFonts.body(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: Colors.white.withValues(alpha: 0.9),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                // Saldo com FittedBox + olho para ocultar/mostrar (UX)
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerLeft,
                        child: Text(
                          balanceVisible
                              ? AppFormatters.formatCurrency(state.walletBalance)
                              : 'R\$ •••••••',
                          style: LummyFonts.body(
                            fontSize: 38,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                            letterSpacing: -1,
                            height: 1.1,
                          ),
                        ),
                      ),
                    ),
                    Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: onToggleBalanceVisibility,
                        borderRadius: BorderRadius.circular(20),
                        child: Padding(
                          padding: const EdgeInsets.all(8),
                          child: Icon(
                            balanceVisible
                                ? Icons.visibility_rounded
                                : Icons.visibility_off_rounded,
                            color: Colors.white.withValues(alpha: 0.9),
                            size: 26,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Diminui ao enviar para os filhos',
                  style: LummyFonts.body(
                    fontSize: 11,
                    fontWeight: FontWeight.w400,
                    color: Colors.white.withValues(alpha: 0.85),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
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
}
