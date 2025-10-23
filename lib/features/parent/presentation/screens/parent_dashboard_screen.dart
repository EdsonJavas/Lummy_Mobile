import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lummy_login/domain/entities/user_entity.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../shared/widgets/widgets.dart';
import '../bloc/parent_dashboard_cubit.dart';
import '../bloc/parent_dashboard_state.dart';

class ParentDashboardScreen extends StatelessWidget {
  final String parentId;

  const ParentDashboardScreen({super.key, required this.parentId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ParentDashboardCubit()..loadDashboard(parentId),
      child: const _ParentDashboardView(),
    );
  }
}

class _ParentDashboardView extends StatelessWidget {
  const _ParentDashboardView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(AppConstants.backgroundLight),
      appBar: AppBar(
        title: Text(
          'Painel do Responsável',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        actions: [
          BlocBuilder<ParentDashboardCubit, ParentDashboardState>(
            builder: (context, state) {
              return IconButton(
                icon: Badge(
                  label: Text('${state.unreadNotificationsCount}'),
                  isLabelVisible: state.unreadNotificationsCount > 0,
                  child: const Icon(Icons.notifications_outlined),
                ),
                onPressed: () {
                  // Navegar para notificações
                },
              );
            },
          ),
        ],
      ),
      body: BlocBuilder<ParentDashboardCubit, ParentDashboardState>(
        builder: (context, state) {
          if (state.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state.error != null) {
            return Center(
              child: EmptyState(
                emoji: '😔',
                title: 'Ops!',
                message: state.error!,
                buttonText: 'Tentar Novamente',
                onButtonPressed: () {
                  // Reload
                },
              ),
            );
          }

          return SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              children: [
                const SizedBox(height: AppConstants.spacingLarge),
                _buildSummaryCards(context, state),
                const SizedBox(height: AppConstants.spacingLarge),
                _buildChildrenList(context, state),
                const SizedBox(height: AppConstants.spacingLarge),
                if (state.pendingApprovals.isNotEmpty)
                  _buildPendingApprovals(context, state),
                const SizedBox(height: AppConstants.spacingXLarge),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // Adicionar nova criança
        },
        backgroundColor: const Color(AppConstants.primaryBlue),
        icon: const Icon(Icons.person_add),
        label: Text(
          'Adicionar Criança',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  Widget _buildSummaryCards(BuildContext context, ParentDashboardState state) {
    final isSmallScreen =
        MediaQuery.of(context).size.height < AppConstants.smallScreenHeight;

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppConstants.spacingLarge,
      ),
      child: Row(
        children: [
          Expanded(
            child: CustomCard(
              gradient: const LinearGradient(
                colors: [
                  Color(AppConstants.primaryBlue),
                  Color(AppConstants.secondaryBlue),
                ],
              ),
              padding: EdgeInsets.all(isSmallScreen ? 16 : 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.people,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    '${state.children.length}',
                    style: GoogleFonts.poppins(
                      fontSize: 32,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    'Crianças',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.white.withOpacity(0.9),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: AppConstants.spacingMedium),
          Expanded(
            child: CustomCard(
              gradient: const LinearGradient(
                colors: [
                  Color(AppConstants.warningOrange),
                  Color(AppConstants.accentOrange),
                ],
              ),
              padding: EdgeInsets.all(isSmallScreen ? 16 : 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.pending_actions,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    '${state.pendingApprovalsCount}',
                    style: GoogleFonts.poppins(
                      fontSize: 32,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    'Pendentes',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.white.withOpacity(0.9),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChildrenList(BuildContext context, ParentDashboardState state) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppConstants.spacingLarge),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Suas Crianças',
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: const Color(AppConstants.textPrimary),
            ),
          ),
          const SizedBox(height: AppConstants.spacingMedium),
          if (state.children.isEmpty)
            const EmptyState(
              emoji: '👶',
              title: 'Nenhuma criança cadastrada',
              message:
                  'Adicione uma criança para começar a acompanhar as finanças!',
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: state.children.length,
              separatorBuilder: (_, __) =>
                  const SizedBox(height: AppConstants.spacingMedium),
              itemBuilder: (context, index) {
                final child = state.children[index];
                final spending = state.totalSpendingByChild[child.id] ?? 0.0;

                return CustomCard(
                  onTap: () {
                    context.read<ParentDashboardCubit>().selectChild(child);
                    // Navegar para detalhes da criança
                  },
                  child: Row(
                    children: [
                      Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          color: child.gender == Gender.male
                              ? const Color(
                                  AppConstants.primaryBlue,
                                ).withOpacity(0.1)
                              : const Color(AppConstants.pink).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(
                            AppConstants.radiusMedium,
                          ),
                        ),
                        child: Icon(
                          Icons.person,
                          color: child.gender == Gender.male
                              ? const Color(AppConstants.primaryBlue)
                              : const Color(AppConstants.pink),
                          size: 28,
                        ),
                      ),
                      const SizedBox(width: AppConstants.spacingMedium),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              child.name,
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: const Color(AppConstants.textPrimary),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Text(
                                  '${child.age} anos',
                                  style: GoogleFonts.poppins(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w400,
                                    color: const Color(
                                      AppConstants.textSecondary,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Container(
                                  width: 3,
                                  height: 3,
                                  decoration: const BoxDecoration(
                                    color: Color(AppConstants.textLight),
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Saldo: ${AppFormatters.formatCurrency(child.balance)}',
                                  style: GoogleFonts.poppins(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                    color: const Color(
                                      AppConstants.successGreen,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            'Gastos',
                            style: GoogleFonts.poppins(
                              fontSize: 11,
                              fontWeight: FontWeight.w400,
                              color: const Color(AppConstants.textSecondary),
                            ),
                          ),
                          Text(
                            AppFormatters.formatCurrency(spending),
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: const Color(AppConstants.textPrimary),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(width: AppConstants.spacingSmall),
                      const Icon(
                        Icons.chevron_right,
                        color: Color(AppConstants.textLight),
                      ),
                    ],
                  ),
                );
              },
            ),
        ],
      ),
    );
  }

  Widget _buildPendingApprovals(
    BuildContext context,
    ParentDashboardState state,
  ) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppConstants.spacingLarge),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Aguardando Aprovação',
                style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: const Color(AppConstants.textPrimary),
                ),
              ),
              TextButton(
                onPressed: () {
                  // Navegar para todas as aprovações
                },
                child: Text(
                  'Ver todas',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: const Color(AppConstants.primaryBlue),
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
            separatorBuilder: (_, __) =>
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
                      backgroundColor: Color(AppConstants.successGreen),
                    ),
                  );
                },
                onReject: () {
                  cubit.rejectTransaction(transaction.id, 'Rejeitado');
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Transação rejeitada!'),
                      backgroundColor: Color(AppConstants.errorRed),
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
