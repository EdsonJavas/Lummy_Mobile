import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../shared/widgets/widgets.dart';
import '../bloc/parent_dashboard_cubit.dart';
import '../bloc/parent_dashboard_state.dart';
import '../widgets/parent_dashboard_skeleton.dart';
import '../widgets/analytics_panels.dart';

class ParentInsightsScreen extends StatelessWidget {
  final String parentId;

  const ParentInsightsScreen({super.key, required this.parentId});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final gradientColors = theme.brightness == Brightness.dark
        ? const [Color(0xFF0F172A), Color(0xFF312E81)]
        : const [Color(0xFF8B5CF6), Color(0xFF4C1D95)];

    return Scaffold(
      body: BrandedRefreshIndicator(
        onRefresh: () =>
            context.read<ParentDashboardCubit>().loadDashboard(parentId),
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverAppBar(
              pinned: true,
              expandedHeight: 200,
              flexibleSpace: FlexibleSpaceBar(
                title: const Text('Insights e desempenho'),
                background: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: gradientColors,
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: Align(
                    alignment: Alignment.bottomLeft,
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Text(
                        'Visualize gráficos e tendências completos das finanças familiares.',
                        style: GoogleFonts.poppins(
                          color: Colors.white.withOpacity(0.85),
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: BlocBuilder<ParentDashboardCubit, ParentDashboardState>(
                  builder: (context, state) {
                    if (state.isLoading && state.monthlyTrend.isEmpty) {
                      return const ParentDashboardSkeleton();
                    }

                    if (state.error != null) {
                      return EmptyState(
                        emoji: '📉',
                        title: 'Não foi possível carregar os insights',
                        message: 'Puxe para atualizar e tentar novamente.',
                        buttonText: 'Atualizar',
                        onButtonPressed: () =>
                            context.read<ParentDashboardCubit>().loadDashboard(parentId),
                      );
                    }

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _InsightSection(
                          title: 'Visão do mês',
                          child: CustomCard(
                            padding: const EdgeInsets.all(20),
                            child: ParentAnalyticsPanels(
                              monthlyTrend: state.monthlyTrend,
                              monthExpenseTotal: state.monthExpenseTotal,
                              monthIncomeTotal: state.monthIncomeTotal,
                              categoryBreakdown: state.categoryBreakdown,
                              goalSummaries: state.goalSummaries,
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        _InsightSection(
                          title: 'Notas rápidas',
                          child: Column(
                            children: [
                              _InsightNote(
                                icon: Icons.trending_up_rounded,
                                color: Colors.green,
                                title: 'Receitas em alta',
                                description:
                                    'Suas receitas superaram as despesas em ${state.monthIncomeTotal > 0 ? ((1 - (state.monthExpenseTotal / state.monthIncomeTotal)) * 100).clamp(0, 999).toStringAsFixed(0) : '0'}% este mês.',
                              ),
                              const SizedBox(height: 12),
                              const _InsightNote(
                                icon: Icons.pie_chart_outline,
                                color: Colors.indigo,
                                title: 'Categorias equilibradas',
                                description:
                                    'As categorias de gastos estão bem distribuídas. Revise metas para reforçar comportamentos positivos.',
                              ),
                            ],
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InsightSection extends StatelessWidget {
  final String title;
  final Widget child;

  const _InsightSection({
    required this.title,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
        const SizedBox(height: 12),
        child,
      ],
    );
  }
}

class _InsightNote extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final String description;

  const _InsightNote({
    required this.icon,
    required this.color,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return CustomCard(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: color),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: GoogleFonts.poppins(fontSize: 13),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

