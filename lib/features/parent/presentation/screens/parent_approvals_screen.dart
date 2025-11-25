import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../shared/widgets/widgets.dart';
import '../bloc/parent_dashboard_cubit.dart';
import '../bloc/parent_dashboard_state.dart';
import '../widgets/parent_dashboard_skeleton.dart';

class ParentApprovalsScreen extends StatelessWidget {
  const ParentApprovalsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BrandedRefreshIndicator(
        onRefresh: () => context.read<ParentDashboardCubit>().refresh(),
        child: SafeArea(
          child: BlocBuilder<ParentDashboardCubit, ParentDashboardState>(
            builder: (context, state) {
              if (state.isLoading && state.pendingApprovals.isEmpty) {
                return const ParentDashboardSkeleton();
              }

              if (state.pendingApprovals.isEmpty) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 24),
                    child: EmptyState(
                      emoji: '✅',
                      title: 'Nenhuma aprovação pendente',
                      message:
                          'Quando seus filhos solicitarem transações, elas aparecerão aqui.',
                    ),
                  ),
                );
              }

              return ListView.separated(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
                itemCount: state.pendingApprovals.length + 1,
                separatorBuilder: (_, __) =>
                    const SizedBox(height: AppConstants.spacingMedium),
                itemBuilder: (context, index) {
                  if (index == 0) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Solicitações pendentes',
                          style: Theme.of(context).textTheme.displaySmall,
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Autorize ou recuse rapidamente os pedidos enviados.',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        const SizedBox(height: AppConstants.spacingMedium),
                      ],
                    );
                  }

                  final transaction = state.pendingApprovals[index - 1];
                  final cubit = context.read<ParentDashboardCubit>();

                  return TransactionCard(
                    transaction: transaction,
                    onApprove: () {
                      cubit.approveTransaction(transaction.id);
                      _showSnack(
                        context,
                        message: 'Transação aprovada! 🎉',
                        color: const Color(AppConstants.successGreen),
                      );
                    },
                    onReject: () {
                      cubit.rejectTransaction(transaction.id, 'Rejeitado');
                      _showSnack(
                        context,
                        message: 'Transação rejeitada!',
                        color: const Color(AppConstants.errorRed),
                      );
                    },
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }

  void _showSnack(
    BuildContext context, {
    required String message,
    required Color color,
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }
}

