import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lummy/core/constants/app_constants.dart';
import 'package:lummy/shared/widgets/widgets.dart';
import 'package:lummy/features/parent/presentation/bloc/parent_dashboard_cubit.dart';
import 'package:lummy/features/parent/presentation/bloc/parent_dashboard_state.dart';
import 'package:lummy/core/theme/design_tokens.dart';

/// Lista de transações aguardando aprovação.
///
/// Atualmente não é usada por nenhuma tela (era o método não utilizado
/// _buildPendingApprovals de ParentDashboardScreen).
class DashboardPendingApprovals extends StatelessWidget {
  final ParentDashboardState state;
  final EdgeInsetsGeometry? margin;

  const DashboardPendingApprovals({
    super.key,
    required this.state,
    this.margin,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin:
          margin ??
          const EdgeInsets.symmetric(horizontal: AppConstants.spacingLarge),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Text(
                  'Aguardando aprovação',
                  style: Theme.of(context).textTheme.headlineMedium,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              TextButton(
                onPressed: () {
                  // Navegar para todas as aprovações
                },
                child: Text(
                  'Ver todas',
                  style: LummyFonts.body(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppConstants.spacingMedium),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: state.pendingApprovals.take(3).length,
            separatorBuilder: (_, _) =>
                const SizedBox(height: AppConstants.spacingMedium),
            itemBuilder: (context, index) {
              final transaction = state.pendingApprovals[index];
              final cubit = context.read<ParentDashboardCubit>();

              return TransactionCard(
                transaction: transaction,
                onApprove: () {
                  cubit.approveTransaction(transaction.id);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Transação aprovada!'),
                      backgroundColor: LummyColors.emerald500,
                    ),
                  );
                },
                onReject: () {
                  cubit.rejectTransaction(transaction.id, 'Rejeitado');
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Transação rejeitada!'),
                      backgroundColor: LummyColors.red500,
                    ),
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }
}
