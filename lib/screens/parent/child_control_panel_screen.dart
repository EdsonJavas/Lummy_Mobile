import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:lummy/domain/entities/user_entity.dart';
import 'package:lummy/shared/widgets/widgets.dart';
import 'package:lummy/screens/parent/child_missions_manager_screen.dart';
import 'package:lummy/screens/parent/child_achievements_screen.dart';
import 'package:lummy/screens/parent/child_settings_screen.dart';
import 'package:lummy/core/utils/app_log.dart';
import 'package:lummy/core/theme/design_tokens.dart';
import 'package:lummy/screens/parent/widgets/child_control_panel/control_panel_goals_tab.dart';
import 'package:lummy/screens/parent/widgets/child_control_panel/control_panel_header.dart';
import 'package:lummy/screens/parent/widgets/child_control_panel/control_panel_inline_empty.dart';
import 'package:lummy/screens/parent/widgets/child_control_panel/control_panel_missions_tab.dart';
import 'package:lummy/screens/parent/widgets/child_control_panel/control_panel_progress_card.dart';
import 'package:lummy/screens/parent/widgets/child_control_panel/control_panel_quick_actions.dart';
import 'package:lummy/screens/parent/widgets/child_control_panel/control_panel_recent_achievements_card.dart';
import 'package:lummy/screens/parent/widgets/child_control_panel/control_panel_recent_goals_card.dart';
import 'package:lummy/screens/parent/widgets/child_control_panel/control_panel_recent_missions_card.dart';
import 'package:lummy/screens/parent/widgets/child_control_panel/control_panel_stats_grid.dart';
import 'package:lummy/screens/parent/widgets/child_control_panel/control_panel_tab_bar.dart';
import 'package:lummy/screens/parent/widgets/child_control_panel/control_panel_transaction_filters.dart';
import 'package:lummy/screens/parent/widgets/child_control_panel/control_panel_transaction_tile.dart';

class ChildControlPanelScreen extends StatefulWidget {
  final ChildEntity child;

  const ChildControlPanelScreen({super.key, required this.child});

  @override
  State<ChildControlPanelScreen> createState() =>
      _ChildControlPanelScreenState();
}

class _ChildControlPanelScreenState extends State<ChildControlPanelScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Stats do filho
  int _totalMissions = 0;
  int _completedMissions = 0;
  int _totalAchievements = 0;
  int _totalPoints = 0;
  int _level = 1;
  List<Map<String, dynamic>> _recentTransactions = [];
  String _filterPeriod = 'Todas';
  String _filterType = 'Todas';
  String _filterCategory = 'Todas';
  List<Map<String, dynamic>> _activeMissions = [];
  List<Map<String, dynamic>> _achievements = [];
  List<Map<String, dynamic>> _goals = [];
  bool _isLoading = true;

  // Paleta de cores
  static const _blue = LummyColors.blue500;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadChildData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadChildData() async {
    setState(() => _isLoading = true);
    try {
      final supabase = Supabase.instance.client;
      final today = DateTime.now().toIso8601String().split('T')[0];

      // Carregar dados do filho
      final childData = await supabase
          .from('children')
          .select('total_points, level')
          .eq('id', widget.child.id)
          .maybeSingle();

      if (childData != null) {
        _totalPoints = childData['total_points'] ?? 0;
        _level = childData['level'] ?? 1;
      }

      // Carregar missões diárias
      final dailyMissions = await supabase
          .from('daily_missions')
          .select('*, missions(*)')
          .eq('child_id', widget.child.id)
          .eq('selected_date', today);

      _activeMissions = List<Map<String, dynamic>>.from(dailyMissions);
      _totalMissions = _activeMissions.length;
      _completedMissions = _activeMissions
          .where((m) => m['is_completed'] == true)
          .length;

      // Carregar conquistas
      final achievementsData = await supabase
          .from('child_achievements')
          .select('*, achievements(*)')
          .eq('child_id', widget.child.id)
          .order('unlocked_at', ascending: false)
          .limit(10);

      _achievements = List<Map<String, dynamic>>.from(achievementsData);
      _totalAchievements = _achievements.length;

      // Carregar transações (mais para permitir filtros)
      final transactionsData = await supabase
          .from('transactions')
          .select('*')
          .eq('child_id', widget.child.id)
          .order('created_at', ascending: false)
          .limit(100);

      _recentTransactions = List<Map<String, dynamic>>.from(transactionsData);

      // Carregar metas do filho
      try {
        final goalsData = await supabase
            .from('goals')
            .select('*')
            .eq('child_id', widget.child.id)
            .order('created_at', ascending: false);

        _goals = List<Map<String, dynamic>>.from(goalsData);
      } catch (e) {
        appLog('Erro ao carregar metas: $e');
        _goals = [];
      }
    } catch (e) {
      appLog('Erro ao carregar dados do filho: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final topPadding = MediaQuery.of(context).padding.top;

    return Scaffold(
      backgroundColor: isDark
          ? LummyColors.darkMaterial
          : LummyColors.slate50,
      body: BrandedRefreshIndicator(
        onRefresh: _loadChildData,
        color: _blue,
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // Header com informações do filho
            SliverToBoxAdapter(
              child: ControlPanelHeader(
                isDark: isDark,
                topPadding: topPadding,
                level: _level,
                totalPoints: _totalPoints,
                onBack: () => Navigator.pop(context),
                onOpenSettings: () => _navigateToSettings(context),
                child: widget.child,
              ),
            ),
            // Stats Cards
            SliverToBoxAdapter(
              child: ControlPanelStatsGrid(
                completedMissions: _completedMissions,
                totalMissions: _totalMissions,
                totalAchievements: _totalAchievements,
                recentTransactions: _recentTransactions,
                isDark: isDark,
              ),
            ),
            // Quick Actions
            SliverToBoxAdapter(
              child: ControlPanelQuickActions(
                isDark: isDark,
                onOpenMissions: () => _navigateToMissions(context),
                onOpenAchievements: () => _navigateToAchievements(context),
                onOpenSettings: () => _navigateToSettings(context),
              ),
            ),
            // Tabs
            SliverToBoxAdapter(
              child: ControlPanelTabBar(
                tabController: _tabController,
                isDark: isDark,
              ),
            ),
            // Tab Content
            SliverFillRemaining(child: _buildTabContent(context, isDark)),
          ],
        ),
      ),
    );
  }

  Widget _buildTabContent(BuildContext context, bool isDark) {
    return TabBarView(
      controller: _tabController,
      children: [
        _buildSummaryTab(isDark),
        ControlPanelMissionsTab(
          isLoading: _isLoading,
          activeMissions: _activeMissions,
          isDark: isDark,
        ),
        _buildTransactionsTab(isDark),
        ControlPanelGoalsTab(
          isLoading: _isLoading,
          goals: _goals,
          isDark: isDark,
        ),
      ],
    );
  }

  Widget _buildSummaryTab(bool isDark) {
    if (_isLoading) {
      return const Center(child: BrandedLoader());
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ControlPanelProgressCard(
            completedMissions: _completedMissions,
            totalMissions: _totalMissions,
            isDark: isDark,
          ),
          const SizedBox(height: 20),
          ControlPanelRecentMissionsCard(
            activeMissions: _activeMissions,
            isDark: isDark,
            onSeeAll: () => _navigateToMissions(context),
          ),
          const SizedBox(height: 20),
          ControlPanelRecentAchievementsCard(
            achievements: _achievements,
            isDark: isDark,
            onSeeAll: () => _navigateToAchievements(context),
          ),
          const SizedBox(height: 20),
          ControlPanelRecentGoalsCard(
            goals: _goals,
            isDark: isDark,
            onSeeAll: () => _tabController.animateTo(3),
          ),
          const SizedBox(height: 100),
        ],
      ),
    );
  }

  List<Map<String, dynamic>> get _filteredTransactions {
    var list = _recentTransactions;

    // Filtro por período
    if (_filterPeriod != 'Todas') {
      final now = DateTime.now();
      DateTime startDate;
      switch (_filterPeriod) {
        case 'Este mês':
          startDate = DateTime(now.year, now.month, 1);
          break;
        case 'Última semana':
          startDate = now.subtract(const Duration(days: 7));
          break;
        case 'Últimos 3 meses':
          startDate = now.subtract(const Duration(days: 90));
          break;
        default:
          return list;
      }
      list = list.where((t) {
        final d = t['date'];
        if (d == null) return false;
        final dt = d is String ? DateTime.tryParse(d) : (d is DateTime ? d : null);
        return dt != null && dt.isAfter(startDate);
      }).toList();
    }

    // Filtro por tipo
    if (_filterType != 'Todas') {
      list = list.where((t) => t['type'] == _filterType).toList();
    }

    // Filtro por categoria
    if (_filterCategory != 'Todas') {
      list = list.where((t) => (t['category'] ?? '') == _filterCategory).toList();
    }

    return list;
  }

  Widget _buildTransactionsTab(bool isDark) {
    if (_isLoading) return const Center(child: BrandedLoader());

    final filtered = _filteredTransactions;

    if (_recentTransactions.isEmpty) {
      return ControlPanelInlineEmpty(
        icon: Icons.receipt_long_outlined,
        text: 'Nenhuma transação recente',
        isDark: isDark,
      );
    }

    return ListView(
      padding: const EdgeInsets.all(20),
      physics: const BouncingScrollPhysics(),
      children: [
        ControlPanelTransactionFilters(
          recentTransactions: _recentTransactions,
          filterPeriod: _filterPeriod,
          filterType: _filterType,
          filterCategory: _filterCategory,
          onPeriodChanged: (value) => setState(() => _filterPeriod = value),
          onTypeChanged: (value) => setState(() => _filterType = value),
          onCategoryChanged: (value) =>
              setState(() => _filterCategory = value),
          isDark: isDark,
        ),
        const SizedBox(height: 16),
        ...List.generate(filtered.length, (index) {
          final tx = filtered[index];
          return ControlPanelTransactionTile(tx: tx, isDark: isDark);
        }),
        const SizedBox(height: 80),
      ],
    );
  }

  void _navigateToMissions(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChildMissionsManagerScreen(child: widget.child),
      ),
    );
  }

  void _navigateToAchievements(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChildAchievementsScreen(child: widget.child),
      ),
    );
  }

  void _navigateToSettings(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChildSettingsScreen(child: widget.child),
      ),
    );
  }

}
