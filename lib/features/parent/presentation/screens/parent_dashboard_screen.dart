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
import '../widgets/parent_dashboard_skeleton.dart';
import 'parent_profile_screen.dart';
import 'parent_insights_screen.dart';

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
        top: false,
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
                BrandedRefreshIndicator(
                  onRefresh: () => _refresh(context),
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(
                      parent: BouncingScrollPhysics(),
                    ),
                    child: Column(
                      children: [
                        _buildHeroSection(context, state),
                        Transform(
                          transform: Matrix4.translationValues(0, -32, 0),
                          child: Container(
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: Theme.of(context).scaffoldBackgroundColor,
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(36),
                                topRight: Radius.circular(36),
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.08),
                                  blurRadius: 25,
                                  offset: const Offset(0, -12),
                                ),
                              ],
                            ),
                            child: Padding(
                              padding:
                                  const EdgeInsets.fromLTRB(20, 40, 20, 32),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _buildSectionTitle(
                                    context,
                                    title: 'Visão geral',
                                    subtitle:
                                        'Resumo financeiro e ações rápidas',
                                  ),
                                  const SizedBox(height: 16),
                                  _buildBalanceCard(context, state),
                                  const SizedBox(height: 20),
                                  _buildOverviewGrid(context, state),
                                  const SizedBox(height: 32),
                                  _buildSectionTitle(
                                    context,
                                    title: 'Distribuição de recursos',
                                    subtitle:
                                        'Envie valores rapidamente para seus filhos',
                                  ),
                                  const SizedBox(height: 16),
                                  AllowanceDistributionCard(
                                    availableBalance: state.walletBalance,
                                    children: state.children,
                                    onDistributeEqually: (amount) => context
                                        .read<ParentDashboardCubit>()
                                        .distributeAmount(amount),
                                    onDepositToChild: (childId, amount) =>
                                        context
                                            .read<ParentDashboardCubit>()
                                            .transferToChild(childId, amount),
                                  ),
                                  const SizedBox(height: 32),
                                  _buildInsightsPreview(
                                    context,
                                    state,
                                    widget.parentId,
                                  ),
                                  const SizedBox(height: 32),
                                  _buildSectionTitle(
                                    context,
                                    title: 'Dependentes',
                                    subtitle:
                                        'Veja o status e o comportamento financeiro',
                                  ),
                                  const SizedBox(height: 16),
                                  _buildChildrenList(
                                    context,
                                    state,
                                    margin: EdgeInsets.zero,
                                  ),
                                  const SizedBox(height: 32),
                                  if (state.pendingApprovals.isNotEmpty) ...[
                                    _buildSectionTitle(
                                      context,
                                      title: 'Aguardando aprovação',
                                      subtitle:
                                          'Autorize ou recuse solicitações em aberto',
                                    ),
                                    const SizedBox(height: 16),
                                    _buildPendingApprovals(
                                      context,
                                      state,
                                      margin: EdgeInsets.zero,
                                    ),
                                    const SizedBox(height: 16),
                                  ],
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
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

  Widget _buildHeroSection(
    BuildContext context,
    ParentDashboardState state,
  ) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final gradientColors = isDark
        ? const [Color(0xFF1F1840), Color(0xFF6D28D9)]
        : const [Color(0xFF7C3AED), Color(0xFFEC4899)];
    final topInset = MediaQuery.of(context).padding.top;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(20, topInset + 12, 20, 52),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: gradientColors,
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Olá, responsável',
                      style: GoogleFonts.poppins(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Acompanhe e direcione os recursos da sua família em tempo real.',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: Colors.white.withOpacity(0.85),
                      ),
                    ),
                  ],
                ),
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
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.22),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white.withOpacity(0.35)),
                  ),
                  child: const Icon(
                    Icons.person_outline,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(isDark ? 0.14 : 0.25),
              borderRadius: BorderRadius.circular(32),
              border: Border.all(color: Colors.white.withOpacity(0.25)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.12),
                  blurRadius: 16,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Saldo familiar disponível',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: isDark
                        ? Colors.white.withOpacity(0.85)
                        : const Color(0xFF312E81),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  AppFormatters.formatCurrency(state.walletBalance),
                  style: GoogleFonts.poppins(
                    fontSize: 38,
                    fontWeight: FontWeight.w700,
                    color: isDark ? Colors.white : const Color(0xFF111827),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(
    BuildContext context, {
    required String title,
    String? subtitle,
  }) {
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: textTheme.titleLarge?.color,
          ),
        ),
        if (subtitle != null) ...[
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: GoogleFonts.poppins(
              fontSize: 13,
              color: textTheme.bodyMedium?.color?.withOpacity(0.75),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildInsightsPreview(
    BuildContext context,
    ParentDashboardState state,
    String parentId,
  ) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            theme.colorScheme.primary.withOpacity(0.1),
            theme.colorScheme.secondaryContainer.withOpacity(0.12),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: theme.colorScheme.primary.withOpacity(0.08),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  Icons.stacked_line_chart_rounded,
                  color: theme.colorScheme.primary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Insights e desempenho',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                    Text(
                      'Visualize gráficos detalhados de receitas, gastos e metas.',
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        color: theme.colorScheme.onSurface.withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _InsightPreviewChip(
                  label: 'Receitas vs. Despesas',
                  value:
                      '${state.monthIncomeTotal > 0 ? ((state.monthExpenseTotal / state.monthIncomeTotal) * 100).clamp(0, 999).toStringAsFixed(0) : '0'}%',
                  icon: Icons.pie_chart_outline_rounded,
                  color: theme.colorScheme.primary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _InsightPreviewChip(
                  label: 'Metas ativas',
                  value: '${state.goalSummaries.length}',
                  icon: Icons.flag_outlined,
                  color: theme.colorScheme.secondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Align(
            alignment: Alignment.centerRight,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => BlocProvider.value(
                      value: context.read<ParentDashboardCubit>(),
                      child: ParentInsightsScreen(parentId: parentId),
                    ),
                  ),
                );
              },
              icon: const Icon(Icons.chevron_right_rounded),
              label: Text(
                'Ver insights completos',
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBalanceCard(
    BuildContext context,
    ParentDashboardState state,
  ) {
    final theme = Theme.of(context);
    final secondaryText = theme.textTheme.bodyMedium?.color?.withOpacity(0.65);
    final childrenCount = state.children.isEmpty ? 1 : state.children.length;
    final averagePerChild = state.walletBalance / childrenCount;

    return CustomCard(
      padding: const EdgeInsets.all(20),
      color: theme.colorScheme.surface,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Saldo disponível para transferências',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: secondaryText,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      AppFormatters.formatCurrency(state.walletBalance),
                      style: GoogleFonts.poppins(
                        fontSize: 32,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              ElevatedButton.icon(
                onPressed: () {
                  // Ação futura de adicionar recursos
                },
                icon: const Icon(Icons.savings_outlined),
                label: const Text('Adicionar recursos'),
                style: ElevatedButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              _BalanceInfoChip(
                icon: Icons.child_care,
                label: 'Média por criança',
                value: AppFormatters.formatCurrency(averagePerChild),
              ),
              _BalanceInfoChip(
                icon: Icons.pending,
                label: 'Solicitações pendentes',
                value: state.pendingApprovalsCount.toString(),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildOverviewGrid(
    BuildContext context,
    ParentDashboardState state,
  ) {
    final stats = [
      _OverviewStatData(
        title: 'Receitas do mês',
        value: AppFormatters.formatCurrency(state.monthIncomeTotal),
        subtitle: 'Últimos 30 dias',
        icon: Icons.trending_up,
        color: const Color(0xFF10B981),
      ),
      _OverviewStatData(
        title: 'Despesas do mês',
        value: AppFormatters.formatCurrency(state.monthExpenseTotal),
        subtitle: 'Pagamentos aprovados',
        icon: Icons.trending_down,
        color: const Color(0xFFEF4444),
      ),
      _OverviewStatData(
        title: 'Dependentes ativos',
        value: '${state.children.length}',
        subtitle: 'Filhos cadastrados',
        icon: Icons.people_alt_rounded,
        color: const Color(0xFF3B82F6),
      ),
      _OverviewStatData(
        title: 'Dispersão média',
        value: state.children.isEmpty
            ? '—'
            : AppFormatters.formatCurrency(
                state.monthExpenseTotal / state.children.length,
              ),
        subtitle: 'Gasto mensal por criança',
        icon: Icons.scatter_plot,
        color: const Color(0xFFF59E0B),
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final isTwoColumns = width > 620;
        final itemWidth =
            isTwoColumns ? (width - 12) / 2 : width; // 12 = spacing
        return Wrap(
          spacing: 12,
          runSpacing: 12,
          children: stats
              .map(
                (stat) => SizedBox(
                  width: itemWidth,
                  child: _OverviewStatCard(data: stat),
                ),
              )
              .toList(),
        );
      },
    );
  }

  Widget _buildChildrenList(
    BuildContext context,
    ParentDashboardState state, {
    EdgeInsetsGeometry? margin,
  }) {
    return Container(
      margin: margin ??
          const EdgeInsets.symmetric(horizontal: AppConstants.spacingLarge),
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
    ParentDashboardState state, {
    EdgeInsetsGeometry? margin,
  }) {
    return Container(
      margin: margin ??
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

class _BalanceInfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _BalanceInfoChip({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.primary.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Icon(icon, color: theme.colorScheme.primary),
          const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: theme.textTheme.bodySmall?.color,
                    ),
                  ),
                  Text(
                    value,
                    style: GoogleFonts.poppins(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
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

class _OverviewStatCard extends StatelessWidget {
  final _OverviewStatData data;

  const _OverviewStatCard({required this.data});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return CustomCard(
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: data.color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(data.icon, color: data.color),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  data.title,
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    color: theme.textTheme.bodyMedium?.color,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  data.value,
                  style: GoogleFonts.poppins(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                if (data.subtitle != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    data.subtitle!,
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: theme.textTheme.bodySmall?.color
                          ?.withOpacity(0.7),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _OverviewStatData {
  final String title;
  final String value;
  final String? subtitle;
  final IconData icon;
  final Color color;

  const _OverviewStatData({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    this.subtitle,
  });
}

class _InsightPreviewChip extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _InsightPreviewChip({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? color.withOpacity(0.12) : color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: color.withOpacity(0.15)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: color),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: theme.colorScheme.onSurface.withOpacity(0.65),
                  ),
                ),
                Text(
                  value,
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.onSurface,
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
