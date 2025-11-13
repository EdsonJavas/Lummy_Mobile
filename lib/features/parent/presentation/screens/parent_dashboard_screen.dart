import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../shared/widgets/widgets.dart';
import '../../../../domain/entities/user_entity.dart';
import '../bloc/parent_dashboard_cubit.dart';
import '../bloc/parent_dashboard_state.dart';
import '../widgets/allowance_distribution_card.dart';
import '../widgets/analytics_panels.dart';
import '../widgets/parent_dashboard_skeleton.dart';
import 'parent_profile_screen.dart';

class ParentDashboardScreen extends StatelessWidget {
  final String parentId;

  const ParentDashboardScreen({super.key, required this.parentId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ParentDashboardCubit()..loadDashboard(parentId),
      child: _ParentDashboardView(parentId: parentId),
    );
  }
}

class _ParentDashboardView extends StatefulWidget {
  final String parentId;

  const _ParentDashboardView({required this.parentId});

  @override
  State<_ParentDashboardView> createState() => _ParentDashboardViewState();
}

class _ParentDashboardViewState extends State<_ParentDashboardView> {
  Future<void> _refresh(BuildContext context) async {
    await context.read<ParentDashboardCubit>().loadDashboard(widget.parentId);
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            Expanded(
              child: BlocBuilder<ParentDashboardCubit, ParentDashboardState>(
                builder: (context, state) {
                  if (state.isLoading && state.children.isEmpty) {
                    return const ParentDashboardSkeleton();
                  }

                  if (state.error != null) {
                    return Center(
                      child: EmptyState(
                        emoji: '⚠️',
                        title: 'Não foi possível carregar os dados',
                        message: 'Tente atualizar a tela para sincronizar novamente.',
                        buttonText: 'Tentar novamente',
                        onButtonPressed: () => _refresh(context),
                      ),
                    );
                  }

                  return Stack(
                    children: [
                      RefreshIndicator(
                        color: colorScheme.primary,
                        onRefresh: () => _refresh(context),
                        child: SingleChildScrollView(
                          physics: const AlwaysScrollableScrollPhysics(
                            parent: BouncingScrollPhysics(),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppConstants.spacingLarge,
                              vertical: AppConstants.spacingLarge,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildFinancialHeader(context, state),
                                const SizedBox(height: AppConstants.spacingLarge),
                                _buildSummaryCards(context, state),
                                const SizedBox(height: AppConstants.spacingLarge),
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
                                const SizedBox(height: AppConstants.spacingLarge),
                                ParentAnalyticsPanels(
                                  monthlyTrend: state.monthlyTrend,
                                  monthExpenseTotal: state.monthExpenseTotal,
                                  monthIncomeTotal: state.monthIncomeTotal,
                                  categoryBreakdown: state.categoryBreakdown,
                                  goalSummaries: state.goalSummaries,
                                ),
                                const SizedBox(height: AppConstants.spacingLarge),
                                _buildChildrenList(context, state),
                                const SizedBox(height: AppConstants.spacingLarge),
                                if (state.pendingApprovals.isNotEmpty)
                                  _buildPendingApprovals(context, state),
                                const SizedBox(height: AppConstants.spacingXLarge),
                              ],
                            ),
                          ),
                        ),
                      ),
                      if (state.isLoading)
                        Positioned.fill(
                          child: Container(
                            color: Theme.of(context)
                                .scaffoldBackgroundColor
                                .withOpacity(0.7),
                            child: const Center(
                              child: BrandedLoader(
                                label: 'Atualizando informações...',
                              ),
                            ),
                          ),
                        ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // Adicionar nova criança
        },
        backgroundColor: colorScheme.primary,
        icon: const Icon(Icons.person_add),
        label: Text(
          'Adicionar criança',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final isSmallScreen = screenHeight < AppConstants.smallScreenHeight;

    return BlocBuilder<ParentDashboardCubit, ParentDashboardState>(
      builder: (context, state) {
        return Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppConstants.spacingLarge,
            vertical: AppConstants.spacingMedium,
          ),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [
                Color(AppConstants.primaryBlue),
                Color(AppConstants.secondaryBlue),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(AppConstants.primaryBlue).withOpacity(0.3),
                blurRadius: 20,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Olá, Responsável',
                      style: GoogleFonts.poppins(
                        fontSize: isSmallScreen ? 24 : 28,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Gerencie as finanças da família',
                      style: GoogleFonts.poppins(
                        fontSize: isSmallScreen ? 14 : 16,
                        fontWeight: FontWeight.w400,
                        color: Colors.white.withOpacity(0.9),
                      ),
                    ),
                  ],
                ),
              ),
              Row(
                children: [
                  if (state.unreadNotificationsCount > 0)
                    Stack(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.notifications_outlined),
                          color: Colors.white,
                          onPressed: () {
                            // Navegar para notificações
                          },
                        ),
                        Positioned(
                          right: 8,
                          top: 8,
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: const BoxDecoration(
                              color: Color(0xFFEF4444),
                              shape: BoxShape.circle,
                            ),
                            child: Text(
                              '${state.unreadNotificationsCount}',
                              style: GoogleFonts.poppins(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const ParentProfileScreen(),
                        ),
                      );
                    },
                    child: Container(
                      width: isSmallScreen ? 50 : 56,
                      height: isSmallScreen ? 50 : 56,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.white,
                          width: 2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.person,
                        color: Color(AppConstants.primaryBlue),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFinancialHeader(
    BuildContext context,
    ParentDashboardState state,
  ) {
    final isSmallScreen =
        MediaQuery.of(context).size.height < AppConstants.smallScreenHeight;

    return CustomCard(
      gradient: const LinearGradient(
        colors: [
          Color(AppConstants.primaryBlue),
          Color(AppConstants.secondaryBlue),
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      padding: EdgeInsets.all(isSmallScreen ? 20 : 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.18),
              borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
            ),
            child: const Icon(
              Icons.account_balance_wallet_outlined,
              color: Colors.white,
              size: 28,
            ),
          ),
          const SizedBox(height: AppConstants.spacingMedium),
          Text(
            'Saldo disponível',
            style: GoogleFonts.poppins(
              fontSize: isSmallScreen ? 16 : 18,
              fontWeight: FontWeight.w500,
              color: Colors.white.withOpacity(0.85),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            AppFormatters.formatCurrency(state.walletBalance),
            style: GoogleFonts.poppins(
              fontSize: isSmallScreen ? 32 : 36,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: AppConstants.spacingLarge),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: _buildHeaderMetric(
                  label: 'Receitas do mês',
                  value: AppFormatters.formatCurrency(state.monthIncomeTotal),
                  icon: Icons.trending_up_rounded,
                  color: const Color(AppConstants.successGreen),
                ),
              ),
              const SizedBox(width: AppConstants.spacingMedium),
              Expanded(
                child: _buildHeaderMetric(
                  label: 'Despesas do mês',
                  value: AppFormatters.formatCurrency(state.monthExpenseTotal),
                  icon: Icons.trending_down_rounded,
                  color: const Color(AppConstants.accentOrange),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderMetric({
    required String label,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.18),
            borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(width: AppConstants.spacingSmall),
        Flexible(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: Colors.white.withOpacity(0.7),
                ),
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                value,
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryCards(BuildContext context, ParentDashboardState state) {
    final isSmallScreen =
        MediaQuery.of(context).size.height < AppConstants.smallScreenHeight;
    final rawWidth =
        MediaQuery.of(context).size.width - (AppConstants.spacingLarge * 2);
    final availableWidth = rawWidth > 0 ? rawWidth : MediaQuery.of(context).size.width;
    final twoColumnBase =
        (availableWidth - AppConstants.spacingMedium).clamp(200, availableWidth);
    final twoColumnWidth = (twoColumnBase.toDouble()) / 2;

    final cards = [
      _SummaryCardData(
        title: 'Crianças cadastradas',
        value: '${state.children.length}',
        icon: Icons.people_outline,
        gradient: const LinearGradient(
          colors: [
            Color(AppConstants.primaryBlue),
            Color(AppConstants.purple),
          ],
        ),
      ),
      _SummaryCardData(
        title: 'Solicitações pendentes',
        value: '${state.pendingApprovalsCount}',
        icon: Icons.pending_actions_outlined,
        gradient: const LinearGradient(
          colors: [
            Color(AppConstants.warningOrange),
            Color(AppConstants.accentOrange),
          ],
        ),
      ),
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppConstants.spacingLarge,
      ),
      child: Wrap(
        spacing: AppConstants.spacingMedium,
        runSpacing: AppConstants.spacingMedium,
        children: cards
            .map(
              (card) => SizedBox(
                width: availableWidth >= 720 ? twoColumnWidth : availableWidth,
                child: CustomCard(
                  gradient: card.gradient,
                  padding: EdgeInsets.all(isSmallScreen ? 18 : 22),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius:
                              BorderRadius.circular(AppConstants.radiusSmall),
                        ),
                        child: Icon(
                          card.icon,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        card.value,
                        style: GoogleFonts.poppins(
                          fontSize: 28,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        card.title,
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
            )
            .toList(),
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
            'Dependentes',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: AppConstants.spacingMedium),
          if (state.children.isEmpty)
            const EmptyState(
              emoji: '👥',
              title: 'Nenhum dependente cadastrado',
              message: 'Inclua uma criança para começar a acompanhar os dados.',
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
                  color: Theme.of(context).colorScheme.surface,
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
                              ? const Color(AppConstants.primaryBlue)
                                  .withOpacity(0.1)
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
                                color: Theme.of(context).colorScheme.onSurface,
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
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurface
                                        .withOpacity(0.65),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Container(
                                  width: 3,
                                  height: 3,
                                  decoration: BoxDecoration(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurface
                                        .withOpacity(0.25),
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Flexible(
                                  child: Text(
                                    'Saldo: ${AppFormatters.formatCurrency(child.balance)}',
                                    style: GoogleFonts.poppins(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                      color: const Color(AppConstants.successGreen),
                                    ),
                                    overflow: TextOverflow.ellipsis,
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
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurface
                                  .withOpacity(0.6),
                            ),
                          ),
                          Text(
                            AppFormatters.formatCurrency(spending),
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(width: AppConstants.spacingSmall),
                      Icon(
                        Icons.chevron_right,
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withOpacity(0.4),
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
                  style: GoogleFonts.poppins(
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

class _SummaryCardData {
  final String title;
  final String value;
  final IconData icon;
  final LinearGradient gradient;

  const _SummaryCardData({
    required this.title,
    required this.value,
    required this.icon,
    required this.gradient,
  });
}
