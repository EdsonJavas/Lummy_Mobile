import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../shared/widgets/widgets.dart';
import '../bloc/parent_dashboard_cubit.dart';
import '../bloc/parent_dashboard_state.dart';
import '../widgets/allowance_distribution_card.dart';
import '../widgets/parent_dashboard_skeleton.dart';

class ParentDistributionScreen extends StatelessWidget {
  const ParentDistributionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BrandedRefreshIndicator(
        onRefresh: () => context.read<ParentDashboardCubit>().refresh(),
        child: SafeArea(
          child: BlocBuilder<ParentDashboardCubit, ParentDashboardState>(
            builder: (context, state) {
              if (state.isLoading && state.children.isEmpty) {
                return const ParentDashboardSkeleton();
              }

              if (state.children.isEmpty) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 24),
                    child: EmptyState(
                      emoji: '🧒',
                      title: 'Nenhuma criança cadastrada',
                      message:
                          'Cadastre pelo menos uma criança para distribuir recursos.',
                    ),
                  ),
                );
              }

              return ListView(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
                children: [
                  Text(
                    'Distribuir recursos',
                    style: Theme.of(context).textTheme.displaySmall,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Envie valores para cada criança de maneira rápida e justa.',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 24),
                  _buildWalletSummary(context, state),
                  const SizedBox(height: 20),
                  AllowanceDistributionCard(
                    availableBalance: state.walletBalance,
                    children: state.children,
                    onDistributeEqually: (amount) => context
                        .read<ParentDashboardCubit>()
                        .distributeAmount(amount),
                    onDepositToChild: (childId, amount) => context
                        .read<ParentDashboardCubit>()
                        .transferToChild(childId, amount),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildWalletSummary(
    BuildContext context,
    ParentDashboardState state,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppConstants.radiusLarge),
        gradient: LinearGradient(
          colors: [
            const Color(AppConstants.primaryBlue).withOpacity(0.12),
            const Color(AppConstants.secondaryBlue).withOpacity(0.08),
          ],
        ),
        border: Border.all(
          color: const Color(AppConstants.primaryBlue).withOpacity(0.2),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              Icons.savings_rounded,
              color: Color(AppConstants.primaryBlue),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Saldo disponível',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: Theme.of(context)
                        .textTheme
                        .bodyMedium
                        ?.color
                        ?.withOpacity(0.8),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  AppFormatters.formatCurrency(state.walletBalance),
                  style: GoogleFonts.poppins(
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                    color: Theme.of(context).textTheme.titleLarge?.color,
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

