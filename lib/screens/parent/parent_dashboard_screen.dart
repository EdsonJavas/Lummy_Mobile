import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lummy/core/constants/app_constants.dart';
import 'package:lummy/shared/widgets/widgets.dart';
import 'package:lummy/features/parent/presentation/bloc/parent_dashboard_cubit.dart';
import 'package:lummy/features/parent/presentation/bloc/parent_dashboard_state.dart';
import 'package:lummy/features/parent/presentation/widgets/parent_dashboard_skeleton.dart';
import 'package:lummy/screens/parent/parent_profile_screen.dart';
import 'package:lummy/screens/parent/parent_insights_screen.dart';
import 'package:lummy/core/theme/design_tokens.dart';
import 'package:lummy/screens/parent/widgets/dashboard/dashboard_balance_card.dart';
import 'package:lummy/screens/parent/widgets/dashboard/dashboard_form_top_clipper.dart';
import 'package:lummy/screens/parent/widgets/dashboard/dashboard_goals_summary.dart';
import 'package:lummy/screens/parent/widgets/dashboard/dashboard_hero_section.dart';
import 'package:lummy/screens/parent/widgets/dashboard/dashboard_insights_preview.dart';
import 'package:lummy/screens/parent/widgets/dashboard/dashboard_overview_grid.dart';
import 'package:lummy/screens/parent/widgets/dashboard/dashboard_quick_actions.dart';
import 'package:lummy/screens/parent/widgets/dashboard/dashboard_section_title.dart';

class ParentDashboardScreen extends StatefulWidget {
  final String parentId;
  final ValueChanged<int>? onNavigateToTab;
  /// Padding à esquerda no hero (usado quando o ícone do drawer não está no hero).
  final double heroLeftPadding;
  /// Abre o drawer; quando não null, o ícone hambúrguer é exibido no header (rola com a tela).
  final VoidCallback? onOpenDrawer;

  const ParentDashboardScreen({
    super.key,
    required this.parentId,
    this.onNavigateToTab,
    this.heroLeftPadding = 0,
    this.onOpenDrawer,
  });

  @override
  State<ParentDashboardScreen> createState() => _ParentDashboardScreenState();
}

class _ParentDashboardScreenState extends State<ParentDashboardScreen> {
  /// Oculta/mostra o saldo no card principal (hero) — UX de privacidade.
  bool _balanceVisible = true;

  Future<void> _refresh(BuildContext context) async {
    await context.read<ParentDashboardCubit>().refresh();
  }

  void _openProfile(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const ParentProfileScreen(),
      ),
    );
  }

  void _openInsights(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => BlocProvider.value(
          value: context.read<ParentDashboardCubit>(),
          child: ParentInsightsScreen(parentId: widget.parentId),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
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
                  color: theme.colorScheme.primary,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(
                      parent: BouncingScrollPhysics(),
                    ),
                    child: Column(
                      children: [
                        DashboardHeroSection(
                          state: state,
                          isDark: isDark,
                          balanceVisible: _balanceVisible,
                          onToggleBalanceVisibility: () {
                            setState(() => _balanceVisible = !_balanceVisible);
                          },
                          onOpenDrawer: widget.onOpenDrawer,
                          heroLeftPadding: widget.heroLeftPadding,
                          onOpenProfile: () => _openProfile(context),
                        ),
                        Transform(
                          transform: Matrix4.translationValues(0, -64, 0),
                          child: ClipPath(
                            clipper: DashboardFormTopClipper(),
                            child: Container(
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: theme.scaffoldBackgroundColor,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(
                                      alpha: isDark ? 0.3 : 0.08,
                                    ),
                                    blurRadius: 30,
                                    offset: const Offset(0, -15),
                                  ),
                                ],
                              ),
                              child: Padding(
                                padding: const EdgeInsets.fromLTRB(
                                  AppConstants.spacingLarge,
                                  92,
                                  AppConstants.spacingLarge,
                                  AppConstants.spacingLarge,
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    DashboardSectionTitle(
                                      title: 'Visão Geral',
                                      subtitle: 'Resumo do saldo do responsável',
                                      isDark: isDark,
                                    ),
                                    const SizedBox(height: 16),
                                    DashboardBalanceCard(
                                      state: state,
                                      isDark: isDark,
                                    ),
                                    const SizedBox(height: 20),
                                    DashboardOverviewGrid(
                                      state: state,
                                      isDark: isDark,
                                    ),
                                    const SizedBox(height: 24),
                                    DashboardQuickActions(
                                      state: state,
                                      isDark: isDark,
                                      onNavigateToTab: (index) =>
                                          widget.onNavigateToTab?.call(index),
                                      onOpenReports: () =>
                                          _openInsights(context),
                                    ),
                                    const SizedBox(height: 24),
                                    DashboardInsightsPreview(
                                      state: state,
                                      isDark: isDark,
                                      onOpenInsights: () =>
                                          _openInsights(context),
                                    ),
                                    if (state.goalSummaries.isNotEmpty) ...[
                                      const SizedBox(height: 24),
                                      DashboardGoalsSummary(
                                        state: state,
                                        isDark: isDark,
                                      ),
                                    ],
                                  ],
                                ),
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
                      color: (isDark ? LummyColors.darkMaterial : Colors.white)
                          .withValues(alpha: 0.85),
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
    );
  }
}
