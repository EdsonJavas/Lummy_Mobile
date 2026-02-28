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
  // Paleta de cores vibrantes - consistente com versão infantil
  static const _primaryBlue = Color(0xFF3B82F6);
  static const _deepBlue = Color(0xFF1E40AF);
  static const _purple = Color(0xFF8B5CF6);
  static const _orange = Color(0xFFF59E0B);
  static const _green = Color(0xFF10B981);
  static const _red = Color(0xFFEF4444);

  // Extrai o primeiro nome do usuário
  String _getFirstName(String? fullName) {
    if (fullName == null || fullName.isEmpty) {
      return 'Responsável';
    }
    final parts = fullName.trim().split(' ');
    return parts.first;
  }

  Future<void> _refresh(BuildContext context) async {
    await context.read<ParentDashboardCubit>().refresh();
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
                        _buildHeroSection(context, state, isDark),
                        Transform(
                          transform: Matrix4.translationValues(0, -36, 0),
                          child: Container(
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: theme.scaffoldBackgroundColor,
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(32),
                                topRight: Radius.circular(32),
                              ),
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
                                28,
                                AppConstants.spacingLarge,
                                AppConstants.spacingLarge,
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _buildSectionTitle(
                                    context,
                                    title: 'Visão Geral',
                                    subtitle: 'Resumo financeiro da família',
                                    isDark: isDark,
                                  ),
                                  const SizedBox(height: 16),
                                  _buildBalanceCard(context, state, isDark),
                                  const SizedBox(height: 20),
                                  _buildOverviewGrid(context, state, isDark),
                                  const SizedBox(height: 24),
                                  _buildQuickActions(context, state, isDark),
                                  const SizedBox(height: 24),
                                  _buildInsightsPreview(
                                    context,
                                    state,
                                    widget.parentId,
                                    isDark,
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
                      color: (isDark ? const Color(0xFF0A0A1A) : Colors.white)
                          .withOpacity(0.85),
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

  Widget _buildHeroSection(
    BuildContext context,
    ParentDashboardState state,
    bool isDark,
  ) {
    final topInset = MediaQuery.of(context).padding.top;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(20, topInset + 16, 20, 60),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? const [Color(0xFF1E293B), Color(0xFF0F172A), Color(0xFF312E81)]
              : const [Color(0xFF3B82F6), Color(0xFF1E40AF), Color(0xFF7C3AED)],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header com saudação e avatar
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Olá, ',
                            style: GoogleFonts.poppins(
                              fontSize: 26,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                          ShaderMask(
                            shaderCallback: (bounds) => const LinearGradient(
                              colors: [Color(0xFFFBBF24), Color(0xFFF59E0B)],
                            ).createShader(bounds),
                            child: Text(
                              _getFirstName(state.parentName),
                              style: GoogleFonts.poppins(
                                fontSize: 26,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Gerencie as finanças da família',
                      style: GoogleFonts.poppins(
                        fontSize: 15,
                        fontWeight: FontWeight.w400,
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
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white.withOpacity(0.5),
                      width: 2.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const ClipOval(
                    child: CachedAvatar(
                      imageUrl:
                          'https://hebbkx1anhila5yf.public.blob.vercel-storage.com/Lum%202-0CkW5uvZjaDxIjCSextrqE198N99r7.png',
                      size: 52,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 28),
          // Card de saldo principal - SALDO TOTAL DOS FILHOS
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.white.withOpacity(isDark ? 0.12 : 0.2),
                  Colors.white.withOpacity(isDark ? 0.06 : 0.1),
                ],
              ),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: Colors.white.withOpacity(0.3),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 24,
                  offset: const Offset(0, 12),
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
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.savings_rounded,
                        color: Colors.white,
                        size: 18,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Saldo Total dos Filhos',
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: Colors.white.withOpacity(0.9),
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        '${state.children.length} ${state.children.length == 1 ? 'filho' : 'filhos'}',
                        style: GoogleFonts.poppins(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: Colors.white.withOpacity(0.9),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                // Saldo com FittedBox - NUNCA quebra
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    AppFormatters.formatCurrency(state.walletBalance),
                    style: GoogleFonts.poppins(
                      fontSize: 38,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      letterSpacing: -1,
                      height: 1.1,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Soma do saldo de todas as contas infantis',
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    fontWeight: FontWeight.w400,
                    color: Colors.white.withOpacity(0.7),
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
    required bool isDark,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ShaderMask(
          shaderCallback: (bounds) => LinearGradient(
            colors: isDark
                ? [_primaryBlue, _purple]
                : [_deepBlue, _primaryBlue],
          ).createShader(bounds),
          child: Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 22,
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
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
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
    bool isDark,
  ) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? [_purple.withOpacity(0.15), _primaryBlue.withOpacity(0.1)]
              : [_purple.withOpacity(0.08), _primaryBlue.withOpacity(0.05)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isDark ? _purple.withOpacity(0.3) : _purple.withOpacity(0.2),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: _purple.withOpacity(isDark ? 0.1 : 0.05),
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
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      _purple.withOpacity(0.2),
                      _primaryBlue.withOpacity(0.15),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: _purple.withOpacity(0.3)),
                ),
                child: const Icon(
                  Icons.insights_rounded,
                  color: Color(0xFF8B5CF6),
                  size: 24,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Insights e Desempenho',
                      style: GoogleFonts.poppins(
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                        color: isDark ? Colors.white : const Color(0xFF1E293B),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Gráficos detalhados de receitas e gastos',
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        color: isDark
                            ? const Color(0xFF94A3B8)
                            : const Color(0xFF64748B),
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
                  icon: Icons.pie_chart_rounded,
                  color: _green,
                  isDark: isDark,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _InsightPreviewChip(
                  label: 'Metas ativas',
                  value: '${state.goalSummaries.length}',
                  icon: Icons.flag_rounded,
                  color: _purple,
                  isDark: isDark,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: Container(
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [_purple, Color(0xFF7C3AED)],
                ),
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: _purple.withOpacity(0.35),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 14,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 0,
                  shadowColor: Colors.transparent,
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
                icon: const Icon(Icons.trending_up_rounded, size: 20),
                label: Text(
                  'Ver Insights Completos',
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
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
    bool isDark,
  ) {
    final childrenCount = state.children.isEmpty ? 1 : state.children.length;
    final averagePerChild = state.walletBalance / childrenCount;

    // Resumo rápido - sem redundância de saldo
    return Row(
      children: [
        // Card de média por filho
        Expanded(
          child: _CompactInfoCard(
            icon: Icons.child_care_rounded,
            label: 'Média/Filho',
            value: AppFormatters.formatCurrency(averagePerChild),
            color: _primaryBlue,
            isDark: isDark,
          ),
        ),
        const SizedBox(width: 12),
        // Card de aprovações pendentes
        Expanded(
          child: _CompactInfoCard(
            icon: Icons.pending_actions_rounded,
            label: 'Aprovações',
            value: '${state.pendingApprovalsCount}',
            subtitle: state.pendingApprovalsCount > 0 ? 'pendentes' : 'nenhuma',
            color: state.pendingApprovalsCount > 0 ? _orange : _green,
            isDark: isDark,
            showBadge: state.pendingApprovalsCount > 0,
          ),
        ),
      ],
    );
  }

  Widget _buildOverviewGrid(
    BuildContext context,
    ParentDashboardState state,
    bool isDark,
  ) {
    final stats = [
      _OverviewStatData(
        title: 'Receitas',
        value: AppFormatters.formatCurrency(state.monthIncomeTotal),
        subtitle: 'Este mês',
        icon: Icons.trending_up_rounded,
        color: _green,
      ),
      _OverviewStatData(
        title: 'Despesas',
        value: AppFormatters.formatCurrency(state.monthExpenseTotal),
        subtitle: 'Este mês',
        icon: Icons.trending_down_rounded,
        color: _red,
      ),
      _OverviewStatData(
        title: 'Filhos',
        value: '${state.children.length}',
        subtitle: 'Cadastrados',
        icon: Icons.family_restroom_rounded,
        color: _primaryBlue,
      ),
      _OverviewStatData(
        title: 'Média/Filho',
        value: state.children.isEmpty
            ? '—'
            : AppFormatters.formatCurrency(
                state.monthExpenseTotal / state.children.length,
              ),
        subtitle: 'Gasto mensal',
        icon: Icons.analytics_rounded,
        color: _orange,
      ),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: stats.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.5,
      ),
      itemBuilder: (context, index) {
        return _OverviewStatCard(data: stats[index], isDark: isDark);
      },
    );
  }

  Widget _buildQuickActions(
    BuildContext context,
    ParentDashboardState state,
    bool isDark,
  ) {
    final quickActions = [
      _QuickActionData(
        title: 'Meus Filhos',
        subtitle: state.children.isEmpty
            ? 'Adicione seu primeiro filho'
            : '${state.children.length} cadastrados',
        icon: Icons.family_restroom_rounded,
        color: _purple,
        onTap: () => widget.onNavigateToTab?.call(1),
      ),
      _QuickActionData(
        title: 'Enviar Dinheiro',
        subtitle: 'Distribua recursos',
        icon: Icons.send_rounded,
        color: _orange,
        onTap: () => widget.onNavigateToTab?.call(2),
      ),
      _QuickActionData(
        title: 'Aprovações',
        subtitle: state.pendingApprovalsCount > 0
            ? '${state.pendingApprovalsCount} pendentes'
            : 'Nenhuma pendente',
        icon: Icons.verified_user_rounded,
        color: _green,
        onTap: () => widget.onNavigateToTab?.call(3),
        badgeCount: state.pendingApprovalsCount,
      ),
      _QuickActionData(
        title: 'Relatórios',
        subtitle: 'Análise detalhada',
        icon: Icons.bar_chart_rounded,
        color: _primaryBlue,
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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(
          context,
          title: 'Ações Rápidas',
          subtitle: 'Gerencie tudo em um só lugar',
          isDark: isDark,
        ),
        const SizedBox(height: 16),
        // Primeira linha de ações
        Row(
          children: [
            Expanded(child: _buildActionCard(quickActions[0], isDark)),
            const SizedBox(width: 16),
            Expanded(child: _buildActionCard(quickActions[1], isDark)),
          ],
        ),
        const SizedBox(height: 16),
        // Segunda linha de ações
        Row(
          children: [
            Expanded(child: _buildActionCard(quickActions[2], isDark)),
            const SizedBox(width: 16),
            Expanded(child: _buildActionCard(quickActions[3], isDark)),
          ],
        ),
      ],
    );
  }

  Widget _buildActionCard(_QuickActionData data, bool isDark) {
    return GestureDetector(
      onTap: data.onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E293B) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: data.color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(data.icon, color: data.color, size: 22),
                ),
                if (data.badgeCount > 0) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: data.color,
                      borderRadius: BorderRadius.circular(10),
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
            const SizedBox(height: 16),
            Text(
              data.title,
              style: GoogleFonts.poppins(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white : const Color(0xFF1E293B),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              data.subtitle,
              style: GoogleFonts.poppins(
                fontSize: 12,
                fontWeight: FontWeight.w400,
                color: isDark
                    ? const Color(0xFF94A3B8)
                    : const Color(0xFF64748B),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ignore: unused_element
  Widget _buildChildrenList(
    BuildContext context,
    ParentDashboardState state, {
    EdgeInsetsGeometry? margin,
  }) {
    return Container(
      margin:
          margin ??
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
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.onSurface.withOpacity(0.65),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Container(
                                  width: 3,
                                  height: 3,
                                  decoration: BoxDecoration(
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.onSurface.withOpacity(0.25),
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
                                      color: const Color(
                                        AppConstants.successGreen,
                                      ),
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
                              color: Theme.of(
                                context,
                              ).colorScheme.onSurface.withOpacity(0.6),
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
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurface.withOpacity(0.4),
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

// Card compacto para resumo rápido
class _CompactInfoCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final String? subtitle;
  final Color color;
  final bool isDark;
  final bool showBadge;

  const _CompactInfoCard({
    required this.icon,
    required this.label,
    required this.value,
    this.subtitle,
    required this.color,
    required this.isDark,
    this.showBadge = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.15 : 0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Icon(icon, color: color, size: 18),
                    if (showBadge)
                      Positioned(
                        top: -3,
                        right: -3,
                        child: Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: color,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: isDark
                                  ? const Color(0xFF1E293B)
                                  : Colors.white,
                              width: 1.5,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  label,
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: isDark
                        ? const Color(0xFF94A3B8)
                        : const Color(0xFF64748B),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          // Valor com FittedBox - NUNCA quebra
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              value,
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: isDark ? Colors.white : const Color(0xFF1E293B),
              ),
            ),
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 2),
            Text(
              subtitle!,
              style: GoogleFonts.poppins(
                fontSize: 10,
                fontWeight: FontWeight.w500,
                color: color,
              ),
            ),
          ],
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

class _OverviewStatCard extends StatelessWidget {
  final _OverviewStatData data;
  final bool isDark;

  const _OverviewStatCard({required this.data, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.15 : 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      data.color.withOpacity(0.2),
                      data.color.withOpacity(0.1),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(data.icon, color: data.color, size: 16),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    data.title,
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: isDark
                          ? const Color(0xFF94A3B8)
                          : const Color(0xFF64748B),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              data.value,
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: isDark ? Colors.white : const Color(0xFF1E293B),
              ),
            ),
          ),
          if (data.subtitle != null) ...[
            const SizedBox(height: 2),
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(
                data.subtitle!,
                style: GoogleFonts.poppins(
                  fontSize: 10,
                  fontWeight: FontWeight.w400,
                  color: isDark
                      ? const Color(0xFF64748B)
                      : const Color(0xFF94A3B8),
                ),
              ),
            ),
          ],
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
  final bool isDark;

  const _InsightPreviewChip({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            color.withOpacity(isDark ? 0.15 : 0.1),
            color.withOpacity(isDark ? 0.08 : 0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: color.withOpacity(isDark ? 0.3 : 0.2),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: isDark
                        ? const Color(0xFF94A3B8)
                        : const Color(0xFF64748B),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: color,
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
