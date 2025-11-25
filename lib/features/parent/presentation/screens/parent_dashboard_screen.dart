import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../shared/widgets/widgets.dart';
import '../../../../domain/entities/user_entity.dart';
import '../bloc/parent_dashboard_cubit.dart';
import '../bloc/parent_dashboard_state.dart';
import '../widgets/parent_dashboard_skeleton.dart';
import 'parent_profile_screen.dart';
import 'parent_insights_screen.dart';

class ParentDashboardScreen extends StatefulWidget {
  final String parentId;
  final ValueChanged<int>? onNavigateToTab;

  const ParentDashboardScreen({
    super.key,
    required this.parentId,
    this.onNavigateToTab,
  });

  @override
  State<ParentDashboardScreen> createState() => _ParentDashboardScreenState();
}

class _ParentDashboardScreenState extends State<ParentDashboardScreen> {
  Future<void> _refresh(BuildContext context) async {
    await context.read<ParentDashboardCubit>().refresh();
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
                                  _buildQuickActions(context, state),
                                  const SizedBox(height: 32),
                                  _buildInsightsPreview(
                                    context,
                                    state,
                                    widget.parentId,
                                  ),
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
        ? const [
            Color(0xFF1E293B),
            Color(0xFF0F172A),
            Color(0xFF1E40AF),
          ]
        : const [
            Color(AppConstants.primaryBlue),
            Color(AppConstants.secondaryBlue),
            Color(AppConstants.purple),
          ];
    final topInset = MediaQuery.of(context).padding.top;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(20, topInset + 12, 20, 52),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: gradientColors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
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
              color: Colors.white.withOpacity(isDark ? 0.15 : 0.22),
              borderRadius: BorderRadius.circular(28),
              border: Border.all(
                color: Colors.white.withOpacity(isDark ? 0.2 : 0.3),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.15),
                  blurRadius: 20,
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
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.account_balance_wallet_rounded,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Saldo familiar disponível',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.white.withOpacity(0.9),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  AppFormatters.formatCurrency(state.walletBalance),
                  style: GoogleFonts.poppins(
                    fontSize: 38,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    letterSpacing: -0.5,
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
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ShaderMask(
          shaderCallback: (bounds) => LinearGradient(
            colors: isDark
                ? [
                    const Color(0xFF3B82F6),
                    const Color(0xFF8B5CF6),
                  ]
                : [
                    const Color(AppConstants.primaryBlue),
                    const Color(AppConstants.secondaryBlue),
                  ],
          ).createShader(bounds),
          child: Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
        ),
        if (subtitle != null) ...[
          const SizedBox(height: 6),
          Text(
            subtitle,
            style: GoogleFonts.poppins(
              fontSize: 13,
              color: theme.textTheme.bodyMedium?.color?.withOpacity(0.7),
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
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? [
                  const Color(0xFF1E40AF).withOpacity(0.15),
                  const Color(0xFF8B5CF6).withOpacity(0.12),
                ]
              : [
                  const Color(AppConstants.primaryBlue).withOpacity(0.08),
                  const Color(AppConstants.purple).withOpacity(0.06),
                ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isDark
              ? const Color(0xFF3B82F6).withOpacity(0.2)
              : const Color(AppConstants.primaryBlue).withOpacity(0.15),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
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
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(AppConstants.primaryBlue).withOpacity(0.12),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(
                  Icons.stacked_line_chart_rounded,
                  color: Color(AppConstants.primaryBlue),
                  size: 24,
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
                  color: const Color(AppConstants.successGreen),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _InsightPreviewChip(
                  label: 'Metas ativas',
                  value: '${state.goalSummaries.length}',
                  icon: Icons.flag_outlined,
                  color: const Color(AppConstants.purple),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Align(
            alignment: Alignment.centerRight,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(AppConstants.primaryBlue),
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 0,
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
              icon: const Icon(Icons.chevron_right_rounded, size: 20),
              label: Text(
                'Ver insights completos',
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
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
    final secondaryText = theme.textTheme.bodyMedium?.color?.withOpacity(0.7);
    final childrenCount = state.children.isEmpty ? 1 : state.children.length;
    final averagePerChild = state.walletBalance / childrenCount;

    return CustomCard(
      padding: const EdgeInsets.all(24),
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
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: const Color(AppConstants.primaryBlue)
                                .withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.account_balance_wallet_rounded,
                            color: Color(AppConstants.primaryBlue),
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Saldo disponível',
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: secondaryText,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      AppFormatters.formatCurrency(state.walletBalance),
                      style: GoogleFonts.poppins(
                        fontSize: 36,
                        fontWeight: FontWeight.w700,
                        color: theme.textTheme.titleLarge?.color,
                        letterSpacing: -0.5,
                      ),
                    ),
                  ],
                ),
              ),
              ElevatedButton.icon(
                onPressed: () {
                  // Ação futura de adicionar recursos
                },
                icon: const Icon(Icons.add_rounded, size: 20),
                label: Text(
                  'Adicionar',
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(AppConstants.accentOrange),
                  foregroundColor: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 0,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              _BalanceInfoChip(
                icon: Icons.child_care_rounded,
                label: 'Média por criança',
                value: AppFormatters.formatCurrency(averagePerChild),
                color: const Color(AppConstants.successGreen),
              ),
              _BalanceInfoChip(
                icon: Icons.pending_actions_rounded,
                label: 'Solicitações pendentes',
                value: state.pendingApprovalsCount.toString(),
                color: const Color(AppConstants.accentOrange),
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

  Widget _buildQuickActions(
    BuildContext context,
    ParentDashboardState state,
  ) {
    final quickActions = [
      _QuickActionData(
        title: 'Dependentes',
        subtitle: state.children.isEmpty
            ? 'Cadastre sua primeira criança'
            : '${state.children.length} cadastrados',
        icon: Icons.family_restroom_rounded,
        color: const Color(AppConstants.primaryBlue),
        onTap: () => widget.onNavigateToTab?.call(1),
      ),
      _QuickActionData(
        title: 'Distribuir recursos',
        subtitle: AppFormatters.formatCurrency(state.walletBalance),
        icon: Icons.payments_rounded,
        color: const Color(AppConstants.accentOrange),
        onTap: () => widget.onNavigateToTab?.call(2),
      ),
      _QuickActionData(
        title: 'Aprovações',
        subtitle: state.pendingApprovalsCount > 0
            ? '${state.pendingApprovalsCount} pendentes'
            : 'Nenhuma pendente',
        icon: Icons.verified_user_rounded,
        color: const Color(AppConstants.successGreen),
        onTap: () => widget.onNavigateToTab?.call(3),
        badgeCount: state.pendingApprovalsCount,
      ),
      _QuickActionData(
        title: 'Insights',
        subtitle: 'Veja tendências completas',
        icon: Icons.stacked_line_chart_rounded,
        color: const Color(AppConstants.purple),
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => BlocProvider.value(
                value: context.read<ParentDashboardCubit>(),
                child: ParentInsightsScreen(parentId: widget.parentId),
              ),
            ),
          );
        },
      ),
    ];

    final crossAxisCount = MediaQuery.of(context).size.width > 700 ? 4 : 2;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(
          context,
          title: 'Ações rápidas',
          subtitle: 'Separe o que precisa de mais atenção agora',
        ),
        const SizedBox(height: 16),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: quickActions.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: crossAxisCount > 2 ? 1.4 : 1.25,
          ),
          itemBuilder: (context, index) {
            final action = quickActions[index];
            return _QuickActionCard(data: action);
          },
        ),
      ],
    );
  }

  // ignore: unused_element
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

  // ignore: unused_element
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
  final Color color;

  const _BalanceInfoChip({
    required this.icon,
    required this.label,
    required this.value,
    this.color = const Color(AppConstants.primaryBlue),
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: color.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(width: 12),
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  label,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: theme.textTheme.bodySmall?.color,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: GoogleFonts.poppins(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: color,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickActionData {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback? onTap;
  final int badgeCount;

  const _QuickActionData({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    this.onTap,
    this.badgeCount = 0,
  });
}

class _QuickActionCard extends StatelessWidget {
  final _QuickActionData data;

  const _QuickActionCard({required this.data});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: data.onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: theme.cardTheme.color,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: data.color.withOpacity(0.2)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 12,
              offset: const Offset(0, 6),
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
                    color: data.color.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(
                    data.icon,
                    color: data.color,
                  ),
                ),
                if (data.badgeCount > 0) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: data.color,
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      data.badgeCount.toString(),
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ],
            ),
            const Spacer(),
            Text(
              data.title,
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: theme.textTheme.titleMedium?.color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              data.subtitle,
              style: GoogleFonts.poppins(
                fontSize: 13,
                color: theme.textTheme.bodyMedium?.color,
              ),
            ),
          ],
        ),
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
