import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:lummy/shared/widgets/widgets.dart';
import 'package:lummy/features/parent/presentation/bloc/parent_dashboard_cubit.dart';
import 'package:lummy/features/parent/presentation/bloc/parent_dashboard_state.dart';
import 'package:lummy/features/parent/presentation/widgets/parent_dashboard_skeleton.dart';
import 'package:lummy/core/theme/design_tokens.dart';
import 'package:lummy/screens/parent/widgets/insights/insights_category_breakdown.dart';
import 'package:lummy/screens/parent/widgets/insights/insights_goals_progress.dart';
import 'package:lummy/screens/parent/widgets/insights/insights_header.dart';
import 'package:lummy/screens/parent/widgets/insights/insights_monthly_chart.dart';
import 'package:lummy/screens/parent/widgets/insights/insights_notes.dart';
import 'package:lummy/screens/parent/widgets/insights/insights_quick_stats.dart';
import 'package:lummy/screens/parent/widgets/insights/insights_report_by_child.dart';

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
                SliverToBoxAdapter(
                  child: InsightsHeader(
                    state: state,
                    isDark: isDark,
                    onBack: () => Navigator.pop(context),
                  ),
                ),
                SliverToBoxAdapter(
                  child: InsightsQuickStats(state: state, isDark: isDark),
                ),
                SliverToBoxAdapter(
                  child: InsightsReportByChild(state: state, isDark: isDark),
                ),
                SliverToBoxAdapter(
                  child: InsightsMonthlyChart(state: state, isDark: isDark),
                ),
                SliverToBoxAdapter(
                  child: InsightsCategoryBreakdown(state: state, isDark: isDark),
                ),
                SliverToBoxAdapter(
                  child: InsightsGoalsProgress(state: state, isDark: isDark),
                ),
                SliverToBoxAdapter(
                  child: InsightsNotes(state: state, isDark: isDark),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 100)),
              ],
            );
          },
        ),
      ),
    );
  }
}
