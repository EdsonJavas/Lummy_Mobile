import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:lummy/core/utils/formatters.dart';
import 'package:lummy/shared/widgets/widgets.dart';
import 'package:lummy/features/parent/presentation/bloc/parent_dashboard_cubit.dart';
import 'package:lummy/features/parent/presentation/bloc/parent_dashboard_state.dart';
import 'package:lummy/features/parent/presentation/widgets/parent_dashboard_skeleton.dart';
import 'package:lummy/core/theme/design_tokens.dart';

class ParentInsightsScreen extends StatefulWidget {
  final String parentId;

  const ParentInsightsScreen({super.key, required this.parentId});

  @override
  State<ParentInsightsScreen> createState() => _ParentInsightsScreenState();
}

class _ParentInsightsScreenState extends State<ParentInsightsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Paleta de cores vibrantes
  static const _purple = LummyColors.violet500;
  static const _blue = LummyColors.blue500;
  static const _green = LummyColors.emerald500;
  static const _red = LummyColors.red500;
  static const _orange = LummyColors.amber500;
  static const _pink = LummyColors.pink500;
  static const _cyan = LummyColors.cyan500;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark
          ? LummyColors.darkMaterial
          : LummyColors.slate50,
      body: BrandedRefreshIndicator(
        onRefresh: () =>
            context.read<ParentDashboardCubit>().loadDashboard(widget.parentId),
        color: _purple,
        child: BlocBuilder<ParentDashboardCubit, ParentDashboardState>(
          builder: (context, state) {
            if (state.isLoading && state.monthlyTrend.isEmpty) {
              return const ParentDashboardSkeleton();
            }

            if (state.error != null) {
              return Center(
                child: EmptyState(
                  emoji: '📊',
                  title: 'Não foi possível carregar os insights',
                  message: 'Puxe para atualizar e tentar novamente.',
                  buttonText: 'Atualizar',
                  onButtonPressed: () => context
                      .read<ParentDashboardCubit>()
                      .loadDashboard(widget.parentId),
                ),
              );
            }

            return CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                SliverToBoxAdapter(child: _buildHeader(context, state, isDark)),
                SliverToBoxAdapter(
                  child: _buildQuickStats(context, state, isDark),
                ),
                SliverToBoxAdapter(
                  child: _buildReportByChild(context, state, isDark),
                ),
                SliverToBoxAdapter(
                  child: _buildMonthlyChart(context, state, isDark),
                ),
                SliverToBoxAdapter(
                  child: _buildCategoryBreakdown(context, state, isDark),
                ),
                SliverToBoxAdapter(
                  child: _buildGoalsProgress(context, state, isDark),
                ),
                SliverToBoxAdapter(
                  child: _buildInsightNotes(context, state, isDark),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 100)),
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

    return Container(
      padding: EdgeInsets.fromLTRB(20, topPadding + 16, 20, 32),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? const [LummyColors.violet950, LummyColors.indigo900, LummyColors.violet900]
              : const [LummyColors.violet500, LummyColors.violet600, LummyColors.violet700],
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(32),
          bottomRight: Radius.circular(32),
        ),
        boxShadow: [
          BoxShadow(
            color: _purple.withValues(alpha: isDark ? 0.2 : 0.35),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Back button e título
          Row(
            children: [
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.arrow_back_ios_new_rounded,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Insights & Desempenho',
                      style: LummyFonts.body(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      'Análise financeira da família',
                      style: LummyFonts.body(
                        fontSize: 13,
                        fontWeight: FontWeight.w400,
                        color: Colors.white.withValues(alpha: 0.8),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.analytics_rounded,
                  color: Colors.white,
                  size: 26,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          // Card de resumo principal
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: _HeaderStatItem(
                        label: 'Receitas',
                        value: AppFormatters.formatCurrency(
                          state.monthIncomeTotal,
                        ),
                        icon: Icons.trending_up_rounded,
                        color: _green,
                      ),
                    ),
                    Container(
                      width: 1,
                      height: 50,
                      color: Colors.white.withValues(alpha: 0.2),
                    ),
                    Expanded(
                      child: _HeaderStatItem(
                        label: 'Despesas',
                        value: AppFormatters.formatCurrency(
                          state.monthExpenseTotal,
                        ),
                        icon: Icons.trending_down_rounded,
                        color: _red,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        state.monthIncomeTotal >= state.monthExpenseTotal
                            ? Icons.thumb_up_rounded
                            : Icons.warning_rounded,
                        color: state.monthIncomeTotal >= state.monthExpenseTotal
                            ? _green
                            : _orange,
                        size: 18,
                      ),
                      const SizedBox(width: 10),
                      Text(
                        state.monthIncomeTotal >= state.monthExpenseTotal
                            ? 'Balanço positivo este mês! 🎉'
                            : 'Atenção: despesas superaram receitas',
                        style: LummyFonts.body(
                          fontSize: 13,
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
    );
  }

  Widget _buildQuickStats(
    BuildContext context,
    ParentDashboardState state,
    bool isDark,
  ) {
    final balance = state.monthIncomeTotal - state.monthExpenseTotal;
    final savingsRate = state.monthIncomeTotal > 0
        ? ((balance / state.monthIncomeTotal) * 100).clamp(-999, 999)
        : 0.0;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
      child: Row(
        children: [
          Expanded(
            child: _QuickStatCard(
              label: 'Saldo do mês',
              value: AppFormatters.formatCurrency(balance),
              icon: Icons.account_balance_wallet_rounded,
              color: balance >= 0 ? _green : _red,
              isDark: isDark,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _QuickStatCard(
              label: 'Taxa de economia',
              value: '${savingsRate.toStringAsFixed(1)}%',
              icon: Icons.savings_rounded,
              color: savingsRate >= 0 ? _blue : _orange,
              isDark: isDark,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReportByChild(
    BuildContext context,
    ParentDashboardState state,
    bool isDark,
  ) {
    if (state.children.isEmpty || state.totalSpendingByChild.isEmpty) {
      return const SizedBox.shrink();
    }

    final totalSpent = state.totalSpendingByChild.values.fold<double>(0, (a, b) => a + b);

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isDark ? LummyColors.slate800 : Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isDark ? LummyColors.slate700 : LummyColors.slate200,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.06),
              blurRadius: 16,
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
                    color: _cyan.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.bar_chart_rounded, color: _cyan, size: 22),
                ),
                const SizedBox(width: 12),
                Text(
                  'Relatório por filho',
                  style: LummyFonts.body(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: isDark ? Colors.white : LummyColors.slate800,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Gastos dos últimos 30 dias',
              style: LummyFonts.body(
                fontSize: 13,
                color: isDark ? LummyColors.slate400 : LummyColors.slate500,
              ),
            ),
            const SizedBox(height: 16),
            ...state.children.map((child) {
              final spent = state.totalSpendingByChild[child.id] ?? 0;
              final pct = totalSpent > 0 ? (spent / totalSpent * 100) : 0.0;
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        child.name,
                        style: LummyFonts.body(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: isDark ? Colors.white : LummyColors.slate800,
                        ),
                      ),
                    ),
                    Text(
                      AppFormatters.formatCurrency(spent),
                      style: LummyFonts.body(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: _red,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: _cyan.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '${pct.toStringAsFixed(0)}%',
                        style: LummyFonts.body(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: _cyan,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildMonthlyChart(
    BuildContext context,
    ParentDashboardState state,
    bool isDark,
  ) {
    final maxValue = state.monthlyTrend.fold<double>(
      0,
      (max, point) =>
          [max, point.income, point.expense].reduce((a, b) => a > b ? a : b),
    );

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isDark ? LummyColors.slate800 : Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isDark ? LummyColors.slate700 : LummyColors.slate200,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.06),
              blurRadius: 16,
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
                    color: _purple.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.show_chart_rounded,
                    color: _purple,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Fluxo Mensal',
                        style: LummyFonts.body(
                          fontSize: 17,
                          fontWeight: FontWeight.w600,
                          color: isDark
                              ? Colors.white
                              : LummyColors.slate800,
                        ),
                      ),
                      Text(
                        'Comparativo dos últimos meses',
                        style: LummyFonts.body(
                          fontSize: 12,
                          color: isDark
                              ? LummyColors.slate400
                              : LummyColors.slate500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            // Legenda
            const Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                _ChartLegendItem(label: 'Receitas', color: _green),
                SizedBox(width: 16),
                _ChartLegendItem(label: 'Despesas', color: _red),
              ],
            ),
            const SizedBox(height: 20),
            // Gráfico de barras customizado
            if (state.monthlyTrend.isEmpty)
              SizedBox(
                height: 180,
                child: Center(
                  child: Text(
                    'Sem dados disponíveis',
                    style: LummyFonts.body(
                      color: isDark
                          ? LummyColors.slate400
                          : LummyColors.slate500,
                    ),
                  ),
                ),
              )
            else
              SizedBox(
                height: 180,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: state.monthlyTrend.asMap().entries.map((entry) {
                    final index = entry.key;
                    final point = entry.value;
                    final incomeHeight = maxValue > 0
                        ? (point.income / maxValue) * 140
                        : 0.0;
                    final expenseHeight = maxValue > 0
                        ? (point.expense / maxValue) * 140
                        : 0.0;

                    return Expanded(
                      child: Padding(
                        padding: EdgeInsets.only(
                          left: index == 0 ? 0 : 4,
                          right: index == state.monthlyTrend.length - 1 ? 0 : 4,
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                // Barra de receita
                                Flexible(
                                  child: Container(
                                    width: 14,
                                    height: incomeHeight.clamp(4, 140),
                                    decoration: BoxDecoration(
                                      gradient: const LinearGradient(
                                        begin: Alignment.bottomCenter,
                                        end: Alignment.topCenter,
                                        colors: [_green, LummyColors.emerald400],
                                      ),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 3),
                                // Barra de despesa
                                Flexible(
                                  child: Container(
                                    width: 14,
                                    height: expenseHeight.clamp(4, 140),
                                    decoration: BoxDecoration(
                                      gradient: const LinearGradient(
                                        begin: Alignment.bottomCenter,
                                        end: Alignment.topCenter,
                                        colors: [_red, LummyColors.red400],
                                      ),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              point.monthLabel,
                              style: LummyFonts.body(
                                fontSize: 10,
                                fontWeight: FontWeight.w500,
                                color: isDark
                                    ? LummyColors.slate400
                                    : LummyColors.slate500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryBreakdown(
    BuildContext context,
    ParentDashboardState state,
    bool isDark,
  ) {
    final colors = [_purple, _blue, _pink, _orange, _cyan, _green];

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isDark ? LummyColors.slate800 : Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isDark ? LummyColors.slate700 : LummyColors.slate200,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.06),
              blurRadius: 16,
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
                    color: _pink.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.pie_chart_rounded, color: _pink, size: 22),
                ),
                const SizedBox(width: 12),
                Text(
                  'Por Categoria',
                  style: LummyFonts.body(
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white : LummyColors.slate800,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            if (state.categoryBreakdown.isEmpty)
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Text(
                    'Sem categorias registradas',
                    style: LummyFonts.body(
                      color: isDark
                          ? LummyColors.slate400
                          : LummyColors.slate500,
                    ),
                  ),
                ),
              )
            else
              ...state.categoryBreakdown.asMap().entries.map((entry) {
                final index = entry.key;
                final item = entry.value;
                final color = colors[index % colors.length];
                final percentage = item.percentage.clamp(0, 100);

                return Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              color: color.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Center(
                              child: Text(
                                _getCategoryEmoji(item.category),
                                style: const TextStyle(fontSize: 16),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              item.category,
                              style: LummyFonts.body(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: isDark
                                    ? Colors.white
                                    : LummyColors.slate800,
                              ),
                            ),
                          ),
                          FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                              AppFormatters.formatCurrency(item.value),
                              style: LummyFonts.body(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: color,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Stack(
                        children: [
                          Container(
                            height: 8,
                            decoration: BoxDecoration(
                              color: color.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                          FractionallySizedBox(
                            widthFactor: percentage / 100,
                            child: Container(
                              height: 8,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [color, color.withValues(alpha: 0.7)],
                                ),
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Align(
                        alignment: Alignment.centerRight,
                        child: Text(
                          '${percentage.toStringAsFixed(1)}%',
                          style: LummyFonts.body(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: isDark
                                ? LummyColors.slate400
                                : LummyColors.slate500,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }),
          ],
        ),
      ),
    );
  }

  Widget _buildGoalsProgress(
    BuildContext context,
    ParentDashboardState state,
    bool isDark,
  ) {
    if (state.goalSummaries.isEmpty) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isDark ? LummyColors.slate800 : Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isDark ? LummyColors.slate700 : LummyColors.slate200,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.06),
              blurRadius: 16,
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
                    color: _orange.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.flag_rounded, color: _orange, size: 22),
                ),
                const SizedBox(width: 12),
                Text(
                  'Metas dos Filhos',
                  style: LummyFonts.body(
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white : LummyColors.slate800,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            ...state.goalSummaries.map((summary) {
              final progress = (summary.averageProgress * 100).clamp(0, 100);
              final progressColor = progress >= 75
                  ? _green
                  : progress >= 50
                  ? _orange
                  : _blue;

              return Padding(
                padding: const EdgeInsets.only(bottom: 20),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isDark
                        ? LummyColors.slate800
                        : LummyColors.slate50,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isDark
                          ? LummyColors.slate700
                          : LummyColors.slate200,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  progressColor,
                                  progressColor.withValues(alpha: 0.7),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(
                              Icons.person_rounded,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  summary.childName,
                                  style: LummyFonts.body(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                    color: isDark
                                        ? Colors.white
                                        : LummyColors.slate800,
                                  ),
                                ),
                                Text(
                                  '${summary.completedGoals}/${summary.totalGoals} metas concluídas',
                                  style: LummyFonts.body(
                                    fontSize: 12,
                                    color: isDark
                                        ? LummyColors.slate400
                                        : LummyColors.slate500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: progressColor.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              '${progress.toStringAsFixed(0)}%',
                              style: LummyFonts.body(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: progressColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      Stack(
                        children: [
                          Container(
                            height: 10,
                            decoration: BoxDecoration(
                              color: progressColor.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(5),
                            ),
                          ),
                          FractionallySizedBox(
                            widthFactor: progress / 100,
                            child: Container(
                              height: 10,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    progressColor,
                                    progressColor.withValues(alpha: 0.7),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(5),
                                boxShadow: [
                                  BoxShadow(
                                    color: progressColor.withValues(alpha: 0.3),
                                    blurRadius: 6,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildInsightNotes(
    BuildContext context,
    ParentDashboardState state,
    bool isDark,
  ) {
    final balance = state.monthIncomeTotal - state.monthExpenseTotal;
    final isPositive = balance >= 0;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Insights',
            style: LummyFonts.body(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: isDark ? Colors.white : LummyColors.slate800,
            ),
          ),
          const SizedBox(height: 16),
          _InsightCard(
            icon: isPositive ? Icons.thumb_up_rounded : Icons.warning_rounded,
            title: isPositive ? 'Finanças Saudáveis' : 'Atenção Necessária',
            description: isPositive
                ? 'Parabéns! As receitas superaram as despesas em ${AppFormatters.formatCurrency(balance)} este mês.'
                : 'As despesas superaram as receitas em ${AppFormatters.formatCurrency(-balance)}. Revise os gastos.',
            color: isPositive ? _green : _orange,
            isDark: isDark,
          ),
          const SizedBox(height: 12),
          _InsightCard(
            icon: Icons.lightbulb_rounded,
            title: 'Dica do Mês',
            description:
                'Incentive seus filhos a poupar definindo metas de economia com recompensas especiais.',
            color: _purple,
            isDark: isDark,
          ),
        ],
      ),
    );
  }

  String _getCategoryEmoji(String category) {
    const emojis = {
      'Alimentação': '🍔',
      'Transporte': '🚗',
      'Lazer': '🎮',
      'Educação': '📚',
      'Saúde': '💊',
      'Roupas': '👕',
      'Tecnologia': '📱',
      'Jogos': '🎲',
      'Outros': '📦',
    };
    return emojis[category] ?? '📦';
  }
}

class _HeaderStatItem extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _HeaderStatItem({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 16),
            const SizedBox(width: 6),
            Text(
              label,
              style: LummyFonts.body(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: Colors.white.withValues(alpha: 0.8),
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            value,
            style: LummyFonts.body(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
        ),
      ],
    );
  }
}

class _QuickStatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  final bool isDark;

  const _QuickStatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? LummyColors.slate800 : Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isDark ? LummyColors.slate700 : LummyColors.slate200,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.15 : 0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
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
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: color, size: 18),
              ),
              const Spacer(),
              Icon(
                color == LummyColors.emerald500 ||
                        color == LummyColors.blue500
                    ? Icons.arrow_upward_rounded
                    : Icons.arrow_downward_rounded,
                color: color,
                size: 16,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            label,
            style: LummyFonts.body(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: isDark ? LummyColors.slate400 : LummyColors.slate500,
            ),
          ),
          const SizedBox(height: 4),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              value,
              style: LummyFonts.body(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: isDark ? Colors.white : LummyColors.slate800,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ChartLegendItem extends StatelessWidget {
  final String label;
  final Color color;

  const _ChartLegendItem({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: LummyFonts.body(
            fontSize: 11,
            fontWeight: FontWeight.w500,
            color: LummyColors.slate500,
          ),
        ),
      ],
    );
  }
}

class _InsightCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final Color color;
  final bool isDark;

  const _InsightCard({
    required this.icon,
    required this.title,
    required this.description,
    required this.color,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            color.withValues(alpha: isDark ? 0.15 : 0.1),
            color.withValues(alpha: isDark ? 0.08 : 0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: color.withValues(alpha: isDark ? 0.25 : 0.2)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: LummyFonts.body(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white : LummyColors.slate800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: LummyFonts.body(
                    fontSize: 13,
                    color: isDark
                        ? LummyColors.slate400
                        : LummyColors.slate500,
                    height: 1.4,
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
