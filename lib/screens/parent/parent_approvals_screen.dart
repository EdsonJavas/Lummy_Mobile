import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:lummy_login/application/app_facade.dart';
import 'package:lummy_login/di/locator.dart';
import 'package:lummy_login/shared/widgets/widgets.dart';
import 'package:lummy_login/features/parent/presentation/bloc/parent_dashboard_cubit.dart';
import 'package:lummy_login/features/parent/presentation/bloc/parent_dashboard_state.dart';
import 'package:lummy_login/features/parent/presentation/widgets/parent_dashboard_skeleton.dart';

class ParentApprovalsScreen extends StatelessWidget {
  const ParentApprovalsScreen({super.key});

  // Paleta de cores vibrantes
  static const _green = Color(0xFF10B981);
  static const _red = Color(0xFFEF4444);
  static const _blue = Color(0xFF3B82F6);

  static String _friendlyLoadError(String raw) {
    final s = raw.toLowerCase();
    if (s.contains('socket') ||
        s.contains('failed host') ||
        s.contains('network') ||
        s.contains('connection')) {
      return 'Sem conexão ou servidor indisponível. Verifique a internet e tente de novo.';
    }
    if (s.contains('timeout')) {
      return 'A conexão demorou demais. Tente novamente em instantes.';
    }
    return 'Não foi possível carregar as solicitações. Puxe para atualizar ou use o botão abaixo.';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark
          ? const Color(0xFF121212)
          : const Color(0xFFF8FAFC),
      body: BrandedRefreshIndicator(
        onRefresh: () => context.read<ParentDashboardCubit>().refresh(),
        color: _green,
        child: BlocBuilder<ParentDashboardCubit, ParentDashboardState>(
          builder: (context, state) {
            final cubit = context.read<ParentDashboardCubit>();

            if (state.isLoading && state.pendingApprovals.isEmpty) {
              return const CustomScrollView(
                physics: AlwaysScrollableScrollPhysics(
                  parent: BouncingScrollPhysics(),
                ),
                slivers: [
                  SliverFillRemaining(
                    child: ParentDashboardSkeleton(),
                  ),
                ],
              );
            }

            if (!state.isLoading &&
                state.error != null &&
                state.pendingApprovals.isEmpty) {
              final msg = _friendlyLoadError(state.error!);
              return CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(
                  parent: BouncingScrollPhysics(),
                ),
                slivers: [
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 28),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.error_outline_rounded,
                            size: 56,
                            color: isDark
                                ? const Color(0xFF94A3B8)
                                : const Color(0xFF64748B),
                          ),
                          const SizedBox(height: 20),
                          Text(
                            msg,
                            textAlign: TextAlign.center,
                            style: GoogleFonts.poppins(
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                              height: 1.45,
                              color: isDark
                                  ? Colors.white
                                  : const Color(0xFF1E293B),
                            ),
                          ),
                          const SizedBox(height: 28),
                          FilledButton.icon(
                            onPressed: () => cubit.refresh(),
                            icon: const Icon(Icons.refresh_rounded),
                            label: Text(
                              'Tentar de novo',
                              style: GoogleFonts.poppins(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            style: FilledButton.styleFrom(
                              backgroundColor: _green,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: 14,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            }

            return CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(
                parent: BouncingScrollPhysics(),
              ),
              slivers: [
                // Header com gradiente
                SliverToBoxAdapter(child: _buildHeader(context, state, isDark)),
                if (state.error != null && state.pendingApprovals.isNotEmpty)
                  SliverToBoxAdapter(
                    child: _buildActionErrorBanner(
                      context,
                      state.error!,
                      cubit,
                      isDark,
                    ),
                  ),
                // Lista de aprovações ou estado vazio
                if (state.pendingApprovals.isEmpty)
                  SliverFillRemaining(
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(28),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    _green.withOpacity(0.15),
                                    _blue.withOpacity(0.1),
                                  ],
                                ),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.verified_rounded,
                                size: 64,
                                color: _green,
                              ),
                            ),
                            const SizedBox(height: 24),
                            Text(
                              'Tudo em dia! ✨',
                              style: GoogleFonts.poppins(
                                fontSize: 22,
                                fontWeight: FontWeight.w600,
                                color: isDark
                                    ? Colors.white
                                    : const Color(0xFF1E293B),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Não há solicitações pendentes no momento. Quando seus filhos fizerem pedidos, eles aparecerão aqui.',
                              textAlign: TextAlign.center,
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                color: isDark
                                    ? const Color(0xFF94A3B8)
                                    : const Color(0xFF64748B),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  )
                else
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(20, 24, 20, 100),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate((context, index) {
                        final transaction = state.pendingApprovals[index];
                        final cubit = context.read<ParentDashboardCubit>();

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: _buildApprovalCard(
                            context,
                            transaction,
                            cubit,
                            isDark,
                          ),
                        );
                      }, childCount: state.pendingApprovals.length),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeader(
    BuildContext context,
    ParentDashboardState state,
    bool isDark,
  ) {
    final topPadding = MediaQuery.of(context).padding.top;
    final pendingCount = state.pendingApprovals.length;

    return Container(
      padding: EdgeInsets.fromLTRB(20, topPadding + 20, 20, 32),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? const [Color(0xFF064E3B), Color(0xFF065F46), Color(0xFF047857)]
              : const [Color(0xFF10B981), Color(0xFF059669), Color(0xFF047857)],
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(32),
          bottomRight: Radius.circular(32),
        ),
        boxShadow: [
          BoxShadow(
            color: _green.withOpacity(isDark ? 0.2 : 0.3),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(
                  Icons.verified_user_rounded,
                  color: Colors.white,
                  size: 28,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Aprovações',
                        style: GoogleFonts.poppins(
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    Text(
                      'Gerencie as solicitações',
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        fontWeight: FontWeight.w400,
                        color: Colors.white.withOpacity(0.8),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              // Badge de pendentes
              if (pendingCount > 0)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.15),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        decoration: const BoxDecoration(
                          color: _red,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '$pendingCount',
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF1E293B),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          if (pendingCount > 0) ...[
            const SizedBox(height: 24),
            // Info card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.15),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: Colors.white.withOpacity(0.2)),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.info_outline_rounded,
                    color: Colors.white,
                    size: 22,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Deslize para a direita para aprovar ou esquerda para recusar',
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        color: Colors.white.withOpacity(0.9),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildActionErrorBanner(
    BuildContext context,
    String error,
    ParentDashboardCubit cubit,
    bool isDark,
  ) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
      child: Material(
        color: isDark
            ? const Color(0xFF7F1D1D).withValues(alpha: 0.4)
            : const Color(0xFFFEF2F2),
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 10, 4, 10),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.warning_amber_rounded, color: _red, size: 22),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  error,
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    height: 1.35,
                    color: isDark
                        ? const Color(0xFFFCA5A5)
                        : const Color(0xFF991B1B),
                  ),
                ),
              ),
              IconButton(
                icon: Icon(
                  Icons.close_rounded,
                  size: 20,
                  color: isDark ? Colors.white54 : Colors.black54,
                ),
                onPressed: cubit.clearError,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildApprovalCard(
    BuildContext context,
    dynamic transaction,
    ParentDashboardCubit cubit,
    bool isDark,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF121212) : Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.2 : 0.06),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          // Card content
          Padding(
            padding: const EdgeInsets.all(20),
            child: TransactionCard(
              transaction: transaction,
              onApprove: null,
              onReject: null,
            ),
          ),
          // Action buttons
          Container(
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF121212) : const Color(0xFFF8FAFC),
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(24),
                bottomRight: Radius.circular(24),
              ),
            ),
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: _buildActionButton(
                    label: 'Recusar',
                    icon: Icons.close_rounded,
                    color: _red,
                    isDark: isDark,
                    onTap: () async {
                      await LummyFeedback.withLoading(
                        context,
                        action: () => cubit.rejectTransaction(
                          transaction.id,
                          'Rejeitado',
                        ),
                        successMessage: 'Transação rejeitada!',
                        errorMessage:
                            cubit.state.error ?? 'Erro ao rejeitar.',
                      );
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildActionButton(
                    label: 'Aprovar',
                    icon: Icons.check_rounded,
                    color: _green,
                    isDark: isDark,
                    isPrimary: true,
                    onTap: () async {
                      final bio = locator<BiometricAuthService>();
                      final ok = await bio.authenticateSensitiveAction(
                        reason: 'Confirme para aprovar a transação',
                      );
                      if (!ok || !context.mounted) return;
                      await LummyFeedback.withLoading(
                        context,
                        action: () =>
                            cubit.approveTransaction(transaction.id),
                        successMessage: 'Transação aprovada!',
                        errorMessage:
                            cubit.state.error ?? 'Erro ao aprovar.',
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required String label,
    required IconData icon,
    required Color color,
    required bool isDark,
    required VoidCallback onTap,
    bool isPrimary = false,
  }) {
    if (isPrimary) {
      return Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: [color, color.withOpacity(0.8)]),
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.4),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(14),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 14),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(icon, color: Colors.white, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    label,
                    style: GoogleFonts.poppins(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: color.withOpacity(isDark ? 0.15 : 0.1),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: color.withOpacity(isDark ? 0.3 : 0.2),
          width: 1.5,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 14),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, color: color, size: 20),
                const SizedBox(width: 8),
                Text(
                  label,
                  style: GoogleFonts.poppins(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: color,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

}
