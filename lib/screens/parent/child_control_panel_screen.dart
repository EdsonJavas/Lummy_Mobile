import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:lummy/core/utils/formatters.dart';
import 'package:lummy/domain/entities/user_entity.dart';
import 'package:lummy/shared/widgets/widgets.dart';
import 'package:lummy/screens/parent/child_missions_manager_screen.dart';
import 'package:lummy/screens/parent/child_achievements_screen.dart';
import 'package:lummy/screens/parent/child_settings_screen.dart';
import 'package:lummy/core/utils/app_log.dart';
import 'package:lummy/core/theme/design_tokens.dart';

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
  static const _purple = LummyColors.violet500;
  static const _blue = LummyColors.blue500;
  static const _pink = LummyColors.pink500;
  static const _green = LummyColors.emerald500;
  static const _orange = LummyColors.amber500;
  static const _red = LummyColors.red500;

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
              child: _buildHeader(context, isDark, topPadding),
            ),
            // Stats Cards
            SliverToBoxAdapter(child: _buildStatsGrid(context, isDark)),
            // Quick Actions
            SliverToBoxAdapter(child: _buildQuickActions(context, isDark)),
            // Tabs
            SliverToBoxAdapter(child: _buildTabBar(context, isDark)),
            // Tab Content
            SliverFillRemaining(child: _buildTabContent(context, isDark)),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, bool isDark, double topPadding) {
    final colors = [_blue, _purple, _pink, _green, _orange];
    final cardColor = colors[widget.child.name.hashCode % colors.length];

    return Container(
      padding: EdgeInsets.fromLTRB(20, topPadding + 16, 20, 24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [
                  LummyColors.slate800,
                  LummyColors.slate900,
                  cardColor.withValues(alpha: 0.3),
                ]
              : [
                  cardColor,
                  cardColor.withValues(alpha: 0.85),
                  cardColor.withValues(alpha: 0.7),
                ],
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(32),
          bottomRight: Radius.circular(32),
        ),
        boxShadow: [
          BoxShadow(
            color: cardColor.withValues(alpha: isDark ? 0.2 : 0.3),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          // Top bar
          Row(
            children: [
              Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.arrow_back_ios_new_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),
              ),
              const Spacer(),
              Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: () => _navigateToSettings(context),
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.settings_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          // Avatar e Info
          Row(
            children: [
              // Avatar grande
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.2),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Icon(
                  widget.child.gender == Gender.male
                      ? Icons.face_rounded
                      : Icons.face_3_rounded,
                  color: cardColor,
                  size: 48,
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.child.name,
                      style: LummyFonts.body(
                        fontSize: 26,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        // Level tag (highlighted)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [LummyColors.gold, LummyColors.orangeWeb],
                            ),
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: [
                              BoxShadow(
                                color: LummyColors.gold.withValues(alpha: 0.4),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.bolt_rounded, color: Colors.white, size: 14),
                              const SizedBox(width: 3),
                              Text(
                                'Nível $_level',
                                style: LummyFonts.body(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        // Age chip
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.18),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.cake_rounded, color: Colors.white, size: 13),
                              const SizedBox(width: 4),
                              Text(
                                '${widget.child.age} anos',
                                style: LummyFonts.body(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          // Balance Card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Saldo Atual',
                      style: LummyFonts.body(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: Colors.white.withValues(alpha: 0.8),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      AppFormatters.formatCurrency(widget.child.balance),
                      style: LummyFonts.body(
                        fontSize: 28,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        LummyColors.gold.withValues(alpha: 0.25),
                        LummyColors.orangeWeb.withValues(alpha: 0.15),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: LummyColors.gold.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.stars_rounded, color: LummyColors.gold, size: 18),
                      const SizedBox(width: 6),
                      Text(
                        '$_totalPoints',
                        style: LummyFonts.body(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: LummyColors.gold,
                        ),
                      ),
                      const SizedBox(width: 3),
                      Text(
                        'pts',
                        style: LummyFonts.body(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: Colors.white.withValues(alpha: 0.7),
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


  Widget _buildStatsGrid(BuildContext context, bool isDark) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Expanded(
            child: _buildStatCard(
              'Missões Hoje',
              '$_completedMissions/$_totalMissions',
              Icons.flag_rounded,
              _blue,
              isDark,
              progress: _totalMissions > 0
                  ? _completedMissions / _totalMissions
                  : 0,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildStatCard(
              'Conquistas',
              '$_totalAchievements',
              Icons.emoji_events_rounded,
              _orange,
              isDark,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildStatCard(
              'Transações',
              '${_recentTransactions.length}',
              Icons.receipt_long_rounded,
              _green,
              isDark,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
    String label,
    String value,
    IconData icon,
    Color color,
    bool isDark, {
    double? progress,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? LummyColors.slate800 : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: color.withValues(alpha: isDark ? 0.3 : 0.15),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: isDark ? 0.1 : 0.08),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: LummyFonts.body(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: isDark ? Colors.white : LummyColors.slate800,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: LummyFonts.body(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: isDark ? LummyColors.slate400 : LummyColors.slate500,
            ),
            textAlign: TextAlign.center,
          ),
          if (progress != null) ...[
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: progress,
                backgroundColor: color.withValues(alpha: 0.2),
                valueColor: AlwaysStoppedAnimation(color),
                minHeight: 4,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('Ações Rápidas', isDark),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildActionButton(
                  'Gerenciar Missões',
                  Icons.assignment_rounded,
                  _purple,
                  isDark,
                  () => _navigateToMissions(context),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildActionButton(
                  'Conquistas',
                  Icons.emoji_events_rounded,
                  _orange,
                  isDark,
                  () => _navigateToAchievements(context),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildActionButton(
            'Configurações',
            Icons.tune_rounded,
            _blue,
            isDark,
            () => _navigateToSettings(context),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title, bool isDark) {
    return ShaderMask(
      shaderCallback: (bounds) => LinearGradient(
        colors: isDark
            ? [LummyColors.blue500, LummyColors.violet500]
            : [LummyColors.slate800, LummyColors.slate800],
      ).createShader(bounds),
      child: Text(
        title,
        style: LummyFonts.body(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildActionButton(
    String label,
    IconData icon,
    Color color,
    bool isDark,
    VoidCallback onTap,
  ) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [color, color.withValues(alpha: 0.8)],
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: 0.4),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Icon(icon, color: Colors.white, size: 22),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  label,
                  style: LummyFonts.body(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
              Icon(Icons.arrow_forward_ios_rounded, color: Colors.white.withValues(alpha: 0.6), size: 14),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTabBar(BuildContext context, bool isDark) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
      child: Container(
        padding: const EdgeInsets.all(5),
        decoration: BoxDecoration(
          color: isDark ? LummyColors.slate800 : LummyColors.slate200,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.15 : 0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: TabBar(
          controller: _tabController,
          indicator: BoxDecoration(
            gradient: const LinearGradient(
              colors: [LummyColors.blue500, LummyColors.violet500],
            ),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: _blue.withValues(alpha: 0.3),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          indicatorSize: TabBarIndicatorSize.tab,
          dividerColor: Colors.transparent,
          labelColor: Colors.white,
          unselectedLabelColor: isDark
              ? LummyColors.slate500
              : LummyColors.slate400,
          labelStyle: LummyFonts.body(
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
          unselectedLabelStyle: LummyFonts.body(
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
          labelPadding: const EdgeInsets.symmetric(horizontal: 4),
          tabs: const [
            Tab(text: 'Resumo', height: 38),
            Tab(text: 'Missões', height: 38),
            Tab(text: 'Transações', height: 38),
            Tab(text: 'Metas', height: 38),
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
        _buildMissionsTab(isDark),
        _buildTransactionsTab(isDark),
        _buildGoalsTab(isDark),
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
          _buildProgressCard(isDark),
          const SizedBox(height: 20),
          _buildRecentMissionsCard(isDark),
          const SizedBox(height: 20),
          _buildRecentAchievementsCard(isDark),
          const SizedBox(height: 20),
          _buildRecentGoalsCard(isDark),
          const SizedBox(height: 100),
        ],
      ),
    );
  }

  Widget _summaryCard({
    required bool isDark,
    required Widget child,
    Color? accent,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? LummyColors.slate800 : Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: accent != null
              ? accent.withValues(alpha: isDark ? 0.15 : 0.1)
              : (isDark ? LummyColors.slate700 : LummyColors.slate200),
        ),
        boxShadow: [
          BoxShadow(
            color: (accent ?? Colors.black).withValues(alpha: isDark ? 0.08 : 0.05),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _summaryHeader(String title, IconData icon, Color color, bool isDark, {VoidCallback? onSeeAll}) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: [color.withValues(alpha: 0.2), color.withValues(alpha: 0.08)]),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: color, size: 18),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            title,
            style: LummyFonts.body(
              fontSize: 16, fontWeight: FontWeight.w600,
              color: isDark ? Colors.white : LummyColors.slate800,
            ),
          ),
        ),
        if (onSeeAll != null)
          Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(8),
              onTap: onSeeAll,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: Text(
                  'Ver todas',
                  style: LummyFonts.body(fontSize: 12, fontWeight: FontWeight.w600, color: color),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildProgressCard(bool isDark) {
    final progress = _totalMissions > 0 ? _completedMissions / _totalMissions : 0.0;
    final progressPercent = (progress * 100).toInt();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [LummyColors.emerald900, _green.withValues(alpha: 0.3)]
              : [_green, LummyColors.emerald600],
        ),
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: _green.withValues(alpha: isDark ? 0.15 : 0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.trending_up_rounded, color: Colors.white, size: 18),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Progresso de Hoje',
                    style: LummyFonts.body(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '$progressPercent%',
                  style: LummyFonts.body(fontSize: 15, fontWeight: FontWeight.w700, color: Colors.white),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Stack(
            children: [
              Container(
                height: 12,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
              FractionallySizedBox(
                widthFactor: progress.clamp(0.0, 1.0),
                child: Container(
                  height: 12,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(6),
                    boxShadow: [BoxShadow(color: Colors.white.withValues(alpha: 0.4), blurRadius: 6)],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            '$_completedMissions de $_totalMissions missões completadas',
            style: LummyFonts.body(fontSize: 13, color: Colors.white.withValues(alpha: 0.8)),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentMissionsCard(bool isDark) {
    return _summaryCard(
      isDark: isDark,
      accent: _blue,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _summaryHeader('Missões de Hoje', Icons.flag_rounded, _blue, isDark,
              onSeeAll: () => _navigateToMissions(context)),
          const SizedBox(height: 16),
          if (_activeMissions.isEmpty)
            _miniEmpty('🎯', 'Nenhuma missão hoje', isDark)
          else
            ...(_activeMissions.take(3).map((mission) {
              final d = mission['missions'] as Map<String, dynamic>?;
              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: _missionRow(d?['title'] ?? 'Missão', d?['emoji'] ?? '🎯',
                    d?['points'] ?? 0, mission['is_completed'] == true, isDark),
              );
            })),
        ],
      ),
    );
  }

  Widget _missionRow(String title, String emoji, int pts, bool done, bool isDark) {
    final color = done ? _green : _blue;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        gradient: done
            ? LinearGradient(colors: [_green.withValues(alpha: 0.08), _green.withValues(alpha: 0.03)])
            : null,
        color: done ? null : (isDark ? LummyColors.slate900 : LummyColors.slate50),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: done ? _green.withValues(alpha: 0.25) : (isDark ? LummyColors.slate800 : LummyColors.slate100),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 42, height: 42,
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [color.withValues(alpha: 0.2), color.withValues(alpha: 0.08)]),
              borderRadius: BorderRadius.circular(12),
            ),
            alignment: Alignment.center,
            child: Text(emoji, style: const TextStyle(fontSize: 20)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: LummyFonts.body(
                    fontSize: 14, fontWeight: FontWeight.w600,
                    color: done
                        ? _green
                        : (isDark ? Colors.white : LummyColors.slate800),
                    decoration: done ? TextDecoration.lineThrough : null,
                  ),
                ),
                Text(
                  '+$pts pontos',
                  style: LummyFonts.body(fontSize: 11, fontWeight: FontWeight.w500, color: done ? _green : _orange),
                ),
              ],
            ),
          ),
          Container(
            width: 28, height: 28,
            decoration: BoxDecoration(
              gradient: done ? const LinearGradient(colors: [_green, LummyColors.emerald600]) : null,
              color: done ? null : (isDark ? LummyColors.slate800 : LummyColors.slate200),
              shape: BoxShape.circle,
            ),
            child: Icon(
              done ? Icons.check_rounded : Icons.circle_outlined,
              color: done ? Colors.white : LummyColors.slate400,
              size: done ? 16 : 20,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentAchievementsCard(bool isDark) {
    return _summaryCard(
      isDark: isDark,
      accent: _orange,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _summaryHeader('Conquistas Recentes', Icons.emoji_events_rounded, _orange, isDark,
              onSeeAll: () => _navigateToAchievements(context)),
          const SizedBox(height: 16),
          if (_achievements.isEmpty)
            _miniEmpty('🏆', 'Nenhuma conquista ainda', isDark)
          else
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: _achievements.take(6).map((a) {
                final d = a['achievements'] as Map<String, dynamic>?;
                return _achieveBadge(d?['emoji'] ?? '🏆', d?['name'] ?? 'Conquista', isDark);
              }).toList(),
            ),
        ],
      ),
    );
  }

  Widget _achieveBadge(String emoji, String name, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [_orange.withValues(alpha: 0.15), _orange.withValues(alpha: 0.06)]),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _orange.withValues(alpha: 0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 18)),
          const SizedBox(width: 6),
          Text(
            name,
            style: LummyFonts.body(
              fontSize: 12, fontWeight: FontWeight.w600,
              color: isDark ? Colors.white : LummyColors.slate800,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentGoalsCard(bool isDark) {
    final active = _goals.where((g) => g['status'] != 'completed' && g['status'] != 'cancelled').take(2).toList();
    final completed = _goals.where((g) => g['status'] == 'completed').take(2).toList();

    return _summaryCard(
      isDark: isDark,
      accent: _purple,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _summaryHeader('Metas', Icons.savings_rounded, _purple, isDark,
              onSeeAll: () => _tabController.animateTo(3)),
          const SizedBox(height: 16),
          if (_goals.isEmpty)
            _miniEmpty('🎯', 'Nenhuma meta criada', isDark)
          else ...[
            ...active.map((g) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _miniGoalRow(g, false, isDark),
            )),
            ...completed.map((g) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _miniGoalRow(g, true, isDark),
            )),
          ],
        ],
      ),
    );
  }

  Widget _miniGoalRow(Map<String, dynamic> goal, bool done, bool isDark) {
    final emoji = goal['emoji'] ?? '🎯';
    final name = goal['name'] ?? 'Meta';
    final target = (goal['target_amount'] as num?)?.toDouble() ?? 0.0;
    final current = (goal['current_amount'] as num?)?.toDouble() ?? 0.0;
    final progress = target > 0 ? (current / target).clamp(0.0, 1.0) : 0.0;
    final color = done ? _green : _purple;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        gradient: done
            ? LinearGradient(colors: [_green.withValues(alpha: 0.08), _green.withValues(alpha: 0.03)])
            : null,
        color: done ? null : (isDark ? LummyColors.slate900 : LummyColors.slate50),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: done ? _green.withValues(alpha: 0.2) : (isDark ? LummyColors.slate800 : LummyColors.slate100),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 40, height: 40,
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [color.withValues(alpha: 0.2), color.withValues(alpha: 0.08)]),
              borderRadius: BorderRadius.circular(11),
            ),
            alignment: Alignment.center,
            child: Text(emoji, style: const TextStyle(fontSize: 18)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: LummyFonts.body(fontSize: 13, fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white : LummyColors.slate800)),
                const SizedBox(height: 4),
                if (!done)
                  Stack(
                    children: [
                      Container(height: 5, decoration: BoxDecoration(
                        color: _purple.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(3))),
                      FractionallySizedBox(widthFactor: progress, child: Container(height: 5,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(colors: [_purple, LummyColors.violet600]),
                          borderRadius: BorderRadius.circular(3),
                        ),
                      )),
                    ],
                  )
                else
                  Text('Concluída!', style: LummyFonts.body(fontSize: 11, fontWeight: FontWeight.w600, color: _green)),
              ],
            ),
          ),
          const SizedBox(width: 8),
          if (done)
            Container(
              padding: const EdgeInsets.all(4),
              decoration: const BoxDecoration(gradient: LinearGradient(colors: [_green, LummyColors.emerald600]), shape: BoxShape.circle),
              child: const Icon(Icons.check_rounded, color: Colors.white, size: 14),
            )
          else
            Text('${(progress * 100).toInt()}%', style: LummyFonts.body(fontSize: 13, fontWeight: FontWeight.w700, color: _purple)),
        ],
      ),
    );
  }

  Widget _miniEmpty(String emoji, String text, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 14),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 20)),
          const SizedBox(width: 8),
          Text(text, style: LummyFonts.body(
            fontSize: 13, fontWeight: FontWeight.w500,
            color: isDark ? LummyColors.slate400 : LummyColors.slate500,
          )),
        ],
      ),
    );
  }

  Widget _inlineEmpty(IconData icon, String text, bool isDark) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 60, horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 52, height: 52,
              decoration: BoxDecoration(
                color: isDark
                    ? LummyColors.violet500.withValues(alpha: 0.1)
                    : LummyColors.violet500.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(14),
              ),
              alignment: Alignment.center,
              child: Icon(icon, size: 26, color: isDark ? LummyColors.violet600 : LummyColors.violet500),
            ),
            const SizedBox(height: 14),
            Text(
              text,
              textAlign: TextAlign.center,
              style: LummyFonts.body(
                fontSize: 14, fontWeight: FontWeight.w600,
                color: isDark ? LummyColors.slate400 : LummyColors.slate500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ──────────────────────── Missions Tab ────────────────────────

  Widget _buildMissionsTab(bool isDark) {
    if (_isLoading) return const Center(child: BrandedLoader());

    if (_activeMissions.isEmpty) {
      return _inlineEmpty(Icons.assignment_outlined, 'Nenhuma missão hoje', isDark);
    }

    return ListView.builder(
      padding: const EdgeInsets.all(20),
      physics: const BouncingScrollPhysics(),
      itemCount: _activeMissions.length,
      itemBuilder: (context, index) {
        final mission = _activeMissions[index];
        final d = mission['missions'] as Map<String, dynamic>?;
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: _missionRow(d?['title'] ?? 'Missão', d?['emoji'] ?? '🎯',
              d?['points'] ?? 0, mission['is_completed'] == true, isDark),
        );
      },
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
      return _inlineEmpty(Icons.receipt_long_outlined, 'Nenhuma transação recente', isDark);
    }

    return ListView(
      padding: const EdgeInsets.all(20),
      physics: const BouncingScrollPhysics(),
      children: [
        _buildTransactionFilters(isDark),
        const SizedBox(height: 16),
        ...List.generate(filtered.length, (index) {
          final tx = filtered[index];
          final isIncome = tx['type'] == 'income';
          final amount = (tx['amount'] as num).toDouble();
          final color = isIncome ? _green : _red;

          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: isDark ? LummyColors.slate800 : Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: color.withValues(alpha: isDark ? 0.12 : 0.08),
                ),
                boxShadow: [
                  BoxShadow(
                    color: color.withValues(alpha: isDark ? 0.06 : 0.04),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    width: 44, height: 44,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [color.withValues(alpha: 0.2), color.withValues(alpha: 0.08)],
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      isIncome ? Icons.arrow_downward_rounded : Icons.arrow_upward_rounded,
                      color: color, size: 22,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          tx['description'] ?? 'Transação',
                          style: LummyFonts.body(
                            fontSize: 14, fontWeight: FontWeight.w600,
                            color: isDark ? Colors.white : LummyColors.slate800,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: isDark ? LummyColors.slate900 : LummyColors.slate100,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            tx['category'] ?? 'Outros',
                            style: LummyFonts.body(
                              fontSize: 10, fontWeight: FontWeight.w500,
                              color: isDark ? LummyColors.slate400 : LummyColors.slate500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [color.withValues(alpha: 0.15), color.withValues(alpha: 0.06)],
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      '${isIncome ? '+' : '-'}${AppFormatters.formatCurrency(amount)}',
                      style: LummyFonts.body(fontSize: 14, fontWeight: FontWeight.w700, color: color),
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
        const SizedBox(height: 80),
      ],
    );
  }

  Widget _buildTransactionFilters(bool isDark) {
    final categories = _recentTransactions
        .map((t) => t['category'] as String?)
        .whereType<String>()
        .toSet()
        .toList()
      ..sort();
    categories.insert(0, 'Todas');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Filtros',
          style: LummyFonts.body(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: isDark ? Colors.white : LummyColors.slate800,
          ),
        ),
        const SizedBox(height: 8),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _buildFilterChip('Todas', _filterPeriod == 'Todas', () => setState(() => _filterPeriod = 'Todas')),
              const SizedBox(width: 8),
              _buildFilterChip('Este mês', _filterPeriod == 'Este mês', () => setState(() => _filterPeriod = 'Este mês')),
              const SizedBox(width: 8),
              _buildFilterChip('Última semana', _filterPeriod == 'Última semana', () => setState(() => _filterPeriod = 'Última semana')),
              const SizedBox(width: 8),
              _buildFilterChip('3 meses', _filterPeriod == 'Últimos 3 meses', () => setState(() => _filterPeriod = 'Últimos 3 meses')),
            ],
          ),
        ),
        const SizedBox(height: 10),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _buildFilterChip('Todas', _filterType == 'Todas', () => setState(() => _filterType = 'Todas')),
              const SizedBox(width: 8),
              _buildFilterChip('Entradas', _filterType == 'income', () => setState(() => _filterType = 'income')),
              const SizedBox(width: 8),
              _buildFilterChip('Gastos', _filterType == 'expense', () => setState(() => _filterType = 'expense')),
            ],
          ),
        ),
        if (categories.length > 1) ...[
          const SizedBox(height: 10),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: categories.map((c) {
                final sel = _filterCategory == c;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: _buildFilterChip(c, sel, () => setState(() => _filterCategory = c)),
                );
              }).toList(),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildFilterChip(String label, bool selected, VoidCallback onTap) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            gradient: selected
                ? const LinearGradient(colors: [_blue, LummyColors.blue600])
                : null,
            color: selected
                ? null
                : (isDark ? LummyColors.slate800 : Colors.white),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: selected ? _blue : (isDark ? LummyColors.slate700 : LummyColors.slate200),
            ),
            boxShadow: selected
                ? [BoxShadow(color: _blue.withValues(alpha: 0.3), blurRadius: 8, offset: const Offset(0, 2))]
                : null,
          ),
          child: Text(
            label,
            style: LummyFonts.body(
              fontSize: 13,
              fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
              color: selected ? Colors.white : (isDark ? LummyColors.slate400 : LummyColors.slate500),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGoalsTab(bool isDark) {
    if (_isLoading) return const Center(child: BrandedLoader());

    final activeGoals = _goals
        .where((g) => g['status'] != 'completed' && g['status'] != 'cancelled')
        .toList();
    final completedGoals = _goals
        .where((g) => g['status'] == 'completed')
        .toList();

    if (_goals.isEmpty) {
      return _inlineEmpty(Icons.savings_outlined, 'Nenhuma meta criada ainda', isDark);
    }

    final hasOnlyCompleted = activeGoals.isEmpty && completedGoals.isNotEmpty;

    return ListView(
      padding: const EdgeInsets.all(20),
      physics: const BouncingScrollPhysics(),
      children: [
        if (activeGoals.isNotEmpty) ...[
          _goalSectionHeader('Em Andamento', '${activeGoals.length}', _orange, Icons.trending_up_rounded, isDark),
          const SizedBox(height: 12),
          ...activeGoals.map((g) => _goalCard(g, isDark)),
          const SizedBox(height: 24),
        ],
        if (hasOnlyCompleted) ...[
          _goalsCelebrationBanner(isDark, completedGoals.length),
          const SizedBox(height: 20),
        ],
        if (completedGoals.isNotEmpty) ...[
          _goalSectionHeader(
            hasOnlyCompleted ? 'Todas Concluídas' : 'Concluídas',
            '${completedGoals.length}',
            _green,
            Icons.check_circle_rounded,
            isDark,
          ),
          const SizedBox(height: 12),
          ...completedGoals.map((g) => _goalCard(g, isDark, isCompleted: true)),
        ],
        const SizedBox(height: 80),
      ],
    );
  }

  Widget _goalsCelebrationBanner(bool isDark, int count) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [LummyColors.emerald900, _green.withValues(alpha: 0.25)]
              : [_green, LummyColors.emerald600],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: _green.withValues(alpha: isDark ? 0.15 : 0.3),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 52, height: 52,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(14),
            ),
            alignment: Alignment.center,
            child: const Text('🏆', style: TextStyle(fontSize: 28)),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Parabéns!',
                  style: LummyFonts.body(fontSize: 18, fontWeight: FontWeight.w700, color: Colors.white),
                ),
                Text(
                  '$count ${count == 1 ? 'meta concluída' : 'metas concluídas'} com sucesso',
                  style: LummyFonts.body(fontSize: 13, color: Colors.white.withValues(alpha: 0.85)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _goalSectionHeader(String title, String count, Color color, IconData icon, bool isDark) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: [color.withValues(alpha: 0.2), color.withValues(alpha: 0.08)]),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: color, size: 18),
        ),
        const SizedBox(width: 10),
        Text(title, style: LummyFonts.body(
          fontSize: 16, fontWeight: FontWeight.w600,
          color: isDark ? Colors.white : LummyColors.slate800,
        )),
        const Spacer(),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: [color.withValues(alpha: 0.18), color.withValues(alpha: 0.08)]),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(count, style: LummyFonts.body(fontSize: 13, fontWeight: FontWeight.w700, color: color)),
        ),
      ],
    );
  }

  Widget _goalCard(Map<String, dynamic> goal, bool isDark, {bool isCompleted = false}) {
    final name = goal['name'] ?? 'Meta';
    final emoji = goal['emoji'] ?? '🎯';
    final target = (goal['target_amount'] as num?)?.toDouble() ?? 0.0;
    final current = (goal['current_amount'] as num?)?.toDouble() ?? 0.0;
    final progress = target > 0 ? (current / target).clamp(0.0, 1.0) : 0.0;
    final pct = (progress * 100).toInt();
    final color = isCompleted ? _green : _purple;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: isCompleted
            ? LinearGradient(
                colors: isDark
                    ? [LummyColors.slate800, _green.withValues(alpha: 0.1)]
                    : [Colors.white, _green.withValues(alpha: 0.04)],
              )
            : null,
        color: isCompleted ? null : (isDark ? LummyColors.slate800 : Colors.white),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: isDark ? 0.2 : 0.12)),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: isDark ? 0.08 : 0.06),
            blurRadius: 14,
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
                width: 48, height: 48,
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: [color.withValues(alpha: 0.2), color.withValues(alpha: 0.08)]),
                  borderRadius: BorderRadius.circular(14),
                ),
                alignment: Alignment.center,
                child: Text(emoji, style: const TextStyle(fontSize: 24)),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(name, style: LummyFonts.body(
                      fontSize: 15, fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white : LummyColors.slate800,
                    ), maxLines: 1, overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 2),
                    Text(
                      'Meta: ${AppFormatters.formatCurrency(target)}',
                      style: LummyFonts.body(fontSize: 12,
                          color: isDark ? LummyColors.slate400 : LummyColors.slate500),
                    ),
                  ],
                ),
              ),
              if (isCompleted)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(colors: [_green, LummyColors.emerald600]),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [BoxShadow(color: _green.withValues(alpha: 0.3), blurRadius: 8, offset: const Offset(0, 2))],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.check_rounded, color: Colors.white, size: 14),
                      const SizedBox(width: 4),
                      Text('Concluída', style: LummyFonts.body(
                        fontSize: 11, fontWeight: FontWeight.w700, color: Colors.white,
                      )),
                    ],
                  ),
                )
              else
                Text('$pct%', style: LummyFonts.body(fontSize: 18, fontWeight: FontWeight.w700, color: color)),
            ],
          ),
          if (!isCompleted) ...[
            const SizedBox(height: 16),
            Stack(
              children: [
                Container(height: 10, decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(5))),
                FractionallySizedBox(
                  widthFactor: progress,
                  child: Container(height: 10, decoration: BoxDecoration(
                    gradient: LinearGradient(colors: [color, color.withValues(alpha: 0.7)]),
                    borderRadius: BorderRadius.circular(5),
                    boxShadow: [BoxShadow(color: color.withValues(alpha: 0.3), blurRadius: 6, offset: const Offset(0, 2))],
                  )),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      width: 8, height: 8,
                      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      AppFormatters.formatCurrency(current),
                      style: LummyFonts.body(fontSize: 12, fontWeight: FontWeight.w600, color: color),
                    ),
                  ],
                ),
                Text(
                  'Falta ${AppFormatters.formatCurrency(target - current)}',
                  style: LummyFonts.body(fontSize: 12,
                      color: isDark ? LummyColors.slate400 : LummyColors.slate500),
                ),
              ],
            ),
          ],
        ],
      ),
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
