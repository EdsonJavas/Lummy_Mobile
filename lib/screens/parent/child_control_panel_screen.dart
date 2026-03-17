import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:lummy_login/core/utils/formatters.dart';
import 'package:lummy_login/domain/entities/user_entity.dart';
import 'package:lummy_login/shared/widgets/widgets.dart';
import 'package:lummy_login/screens/parent/child_missions_manager_screen.dart';
import 'package:lummy_login/screens/parent/child_achievements_screen.dart';
import 'package:lummy_login/screens/parent/child_settings_screen.dart';

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
  static const _purple = Color(0xFF8B5CF6);
  static const _blue = Color(0xFF3B82F6);
  static const _pink = Color(0xFFEC4899);
  static const _green = Color(0xFF10B981);
  static const _orange = Color(0xFFF59E0B);
  static const _red = Color(0xFFEF4444);

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
        debugPrint('Erro ao carregar metas: $e');
        _goals = [];
      }
    } catch (e) {
      debugPrint('Erro ao carregar dados do filho: $e');
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
          ? const Color(0xFF121212)
          : const Color(0xFFF8FAFC),
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
                  const Color(0xFF1E293B),
                  const Color(0xFF0F172A),
                  cardColor.withOpacity(0.3),
                ]
              : [
                  cardColor,
                  cardColor.withOpacity(0.85),
                  cardColor.withOpacity(0.7),
                ],
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(32),
          bottomRight: Radius.circular(32),
        ),
        boxShadow: [
          BoxShadow(
            color: cardColor.withOpacity(isDark ? 0.2 : 0.3),
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
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.arrow_back_ios_new_rounded,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),
              const Spacer(),
              GestureDetector(
                onTap: () => _navigateToSettings(context),
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.settings_rounded,
                    color: Colors.white,
                    size: 20,
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
                      color: Colors.black.withOpacity(0.2),
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
                      style: GoogleFonts.poppins(
                        fontSize: 26,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        _buildInfoChip(
                          '${widget.child.age} anos',
                          Icons.cake_rounded,
                        ),
                        const SizedBox(width: 8),
                        _buildInfoChip('Nível $_level', Icons.star_rounded),
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
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white.withOpacity(0.2)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Saldo Atual',
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: Colors.white.withOpacity(0.8),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      AppFormatters.formatCurrency(widget.child.balance),
                      style: GoogleFonts.poppins(
                        fontSize: 28,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.stars_rounded,
                        color: Colors.amber,
                        size: 20,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '$_totalPoints pts',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
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

  Widget _buildInfoChip(String text, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 14),
          const SizedBox(width: 4),
          Text(
            text,
            style: GoogleFonts.poppins(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Colors.white,
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
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: color.withOpacity(isDark ? 0.3 : 0.15),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(isDark ? 0.1 : 0.08),
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
              color: color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: isDark ? Colors.white : const Color(0xFF1E293B),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
            ),
            textAlign: TextAlign.center,
          ),
          if (progress != null) ...[
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: progress,
                backgroundColor: color.withOpacity(0.2),
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
          Row(
            children: [
              Expanded(
                child: _buildActionButton(
                  'Enviar Dinheiro',
                  Icons.send_rounded,
                  _green,
                  isDark,
                  () => _showSendMoneyDialog(context, isDark),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildActionButton(
                  'Configurações',
                  Icons.tune_rounded,
                  _blue,
                  isDark,
                  () => _navigateToSettings(context),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title, bool isDark) {
    return ShaderMask(
      shaderCallback: (bounds) => LinearGradient(
        colors: isDark
            ? [const Color(0xFF3B82F6), const Color(0xFF8B5CF6)]
            : [const Color(0xFF1E293B), const Color(0xFF1E293B)],
      ).createShader(bounds),
      child: Text(
        title,
        style: GoogleFonts.poppins(
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
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [color, color.withOpacity(0.8)],
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.4),
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
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabBar(BuildContext context, bool isDark) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0),
          borderRadius: BorderRadius.circular(16),
        ),
        child: TabBar(
          controller: _tabController,
          indicator: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF3B82F6), Color(0xFF8B5CF6)],
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          indicatorSize: TabBarIndicatorSize.tab,
          dividerColor: Colors.transparent,
          labelColor: Colors.white,
          unselectedLabelColor: isDark
              ? const Color(0xFF94A3B8)
              : const Color(0xFF64748B),
          labelStyle: GoogleFonts.poppins(
            fontSize: 11,
            fontWeight: FontWeight.w600,
          ),
          unselectedLabelStyle: GoogleFonts.poppins(
            fontSize: 11,
            fontWeight: FontWeight.w500,
          ),
          labelPadding: const EdgeInsets.symmetric(horizontal: 4),
          tabs: const [
            Tab(text: 'Resumo', height: 36),
            Tab(text: 'Missões', height: 36),
            Tab(text: 'Transações', height: 36),
            Tab(text: 'Metas', height: 36),
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
          // Progresso Semanal
          _buildProgressCard(isDark),
          const SizedBox(height: 20),
          // Missões Recentes
          _buildRecentMissionsCard(isDark),
          const SizedBox(height: 20),
          // Últimas Conquistas
          _buildRecentAchievementsCard(isDark),
          const SizedBox(height: 100),
        ],
      ),
    );
  }

  Widget _buildProgressCard(bool isDark) {
    final progressPercent = _totalMissions > 0
        ? (_completedMissions / _totalMissions * 100).toInt()
        : 0;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [const Color(0xFF334155), const Color(0xFF1E293B)]
              : [Colors.white, const Color(0xFFF8FAFC)],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
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
              Text(
                'Progresso de Hoje',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.white : const Color(0xFF1E293B),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: _green.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '$progressPercent%',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: _green,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: _totalMissions > 0
                  ? _completedMissions / _totalMissions
                  : 0,
              backgroundColor: _green.withOpacity(0.2),
              valueColor: const AlwaysStoppedAnimation(_green),
              minHeight: 12,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            '$_completedMissions de $_totalMissions missões completadas',
            style: GoogleFonts.poppins(
              fontSize: 13,
              color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentMissionsCard(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
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
              Text(
                'Missões de Hoje',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.white : const Color(0xFF1E293B),
                ),
              ),
              TextButton(
                onPressed: () => _navigateToMissions(context),
                child: Text(
                  'Ver todas',
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: _blue,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (_activeMissions.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Icon(
                      Icons.assignment_outlined,
                      size: 48,
                      color: isDark
                          ? const Color(0xFF64748B)
                          : const Color(0xFF94A3B8),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Nenhuma missão hoje',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: isDark
                            ? const Color(0xFF94A3B8)
                            : const Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            ...(_activeMissions.take(3).map((mission) {
              final missionData = mission['missions'] as Map<String, dynamic>?;
              final isCompleted = mission['is_completed'] == true;

              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _buildMissionItem(
                  missionData?['title'] ?? 'Missão',
                  missionData?['emoji'] ?? '🎯',
                  missionData?['points'] ?? 0,
                  isCompleted,
                  isDark,
                ),
              );
            })),
        ],
      ),
    );
  }

  Widget _buildMissionItem(
    String title,
    String emoji,
    int points,
    bool isCompleted,
    bool isDark,
  ) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isCompleted
              ? _green.withOpacity(0.3)
              : (isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: (isCompleted ? _green : _blue).withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(emoji, style: const TextStyle(fontSize: 22)),
            ),
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
                    color: isDark ? Colors.white : const Color(0xFF1E293B),
                    decoration: isCompleted ? TextDecoration.lineThrough : null,
                  ),
                ),
                Text(
                  '+$points pontos',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: isCompleted ? _green : _orange,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          Icon(
            isCompleted ? Icons.check_circle_rounded : Icons.circle_outlined,
            color: isCompleted ? _green : const Color(0xFF94A3B8),
            size: 24,
          ),
        ],
      ),
    );
  }

  Widget _buildRecentAchievementsCard(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
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
              Text(
                'Conquistas Recentes',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.white : const Color(0xFF1E293B),
                ),
              ),
              TextButton(
                onPressed: () => _navigateToAchievements(context),
                child: Text(
                  'Ver todas',
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: _orange,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (_achievements.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Icon(
                      Icons.emoji_events_outlined,
                      size: 48,
                      color: isDark
                          ? const Color(0xFF64748B)
                          : const Color(0xFF94A3B8),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Nenhuma conquista ainda',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: isDark
                            ? const Color(0xFF94A3B8)
                            : const Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: _achievements.take(6).map((achievement) {
                final achievementData =
                    achievement['achievements'] as Map<String, dynamic>?;
                return _buildAchievementBadge(
                  achievementData?['emoji'] ?? '🏆',
                  achievementData?['name'] ?? 'Conquista',
                  isDark,
                );
              }).toList(),
            ),
        ],
      ),
    );
  }

  Widget _buildAchievementBadge(String emoji, String name, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [_orange.withOpacity(0.15), _orange.withOpacity(0.08)],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _orange.withOpacity(0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 18)),
          const SizedBox(width: 6),
          Text(
            name,
            style: GoogleFonts.poppins(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: isDark ? Colors.white : const Color(0xFF1E293B),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMissionsTab(bool isDark) {
    if (_isLoading) {
      return const Center(child: BrandedLoader());
    }

    return ListView.builder(
      padding: const EdgeInsets.all(20),
      physics: const BouncingScrollPhysics(),
      itemCount: _activeMissions.length,
      itemBuilder: (context, index) {
        final mission = _activeMissions[index];
        final missionData = mission['missions'] as Map<String, dynamic>?;
        final isCompleted = mission['is_completed'] == true;

        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: _buildMissionItem(
            missionData?['title'] ?? 'Missão',
            missionData?['emoji'] ?? '🎯',
            missionData?['points'] ?? 0,
            isCompleted,
            isDark,
          ),
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
    if (_isLoading) {
      return const Center(child: BrandedLoader());
    }

    final filtered = _filteredTransactions;

    if (_recentTransactions.isEmpty) {
      return Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.receipt_long_outlined,
                size: 56,
                color: isDark
                    ? const Color(0xFF64748B)
                    : const Color(0xFF94A3B8),
              ),
              const SizedBox(height: 12),
              Text(
                'Nenhuma transação',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.white : const Color(0xFF1E293B),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'As transações aparecerão aqui',
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
      );
    }

    return ListView(
      padding: const EdgeInsets.all(20),
      physics: const BouncingScrollPhysics(),
      children: [
        _buildTransactionFilters(isDark),
        const SizedBox(height: 16),
        ...List.generate(filtered.length, (index) {
          final transaction = filtered[index];
          final isIncome = transaction['type'] == 'income';
          final amount = (transaction['amount'] as num).toDouble();
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E293B) : Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isDark
                      ? const Color(0xFF334155)
                      : const Color(0xFFE2E8F0),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: (isIncome ? _green : _red).withOpacity(0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      isIncome
                          ? Icons.arrow_downward_rounded
                          : Icons.arrow_upward_rounded,
                      color: isIncome ? _green : _red,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          transaction['description'] ?? 'Transação',
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: isDark
                                ? Colors.white
                                : const Color(0xFF1E293B),
                          ),
                        ),
                        Text(
                          transaction['category'] ?? 'Outros',
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: isDark
                                ? const Color(0xFF94A3B8)
                                : const Color(0xFF64748B),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    '${isIncome ? '+' : '-'}${AppFormatters.formatCurrency(amount)}',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: isIncome ? _green : _red,
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
          style: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: isDark ? Colors.white : const Color(0xFF1E293B),
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
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: selected
              ? _blue
              : (isDark ? const Color(0xFF1E293B) : Colors.white),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected ? _blue : (isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
          ),
        ),
        child: Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: selected ? Colors.white : (isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B)),
          ),
        ),
      ),
    );
  }

  Widget _buildGoalsTab(bool isDark) {
    if (_isLoading) {
      return const Center(child: BrandedLoader());
    }

    // Separar metas em andamento e concluídas
    final activeGoals = _goals
        .where((g) => g['status'] != 'completed' && g['status'] != 'cancelled')
        .toList();
    final completedGoals = _goals
        .where((g) => g['status'] == 'completed')
        .toList();

    if (_goals.isEmpty) {
      return Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: _purple.withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.savings_rounded,
                  size: 40,
                  color: _purple,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Nenhuma meta',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.white : const Color(0xFF1E293B),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Seu filho ainda não criou metas de economia',
                textAlign: TextAlign.center,
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
      );
    }

    return ListView(
      padding: const EdgeInsets.all(20),
      physics: const BouncingScrollPhysics(),
      children: [
        // Metas em andamento
        if (activeGoals.isNotEmpty) ...[
          _buildGoalsSectionHeader(
            'Em Andamento',
            '${activeGoals.length}',
            _orange,
            Icons.trending_up_rounded,
            isDark,
          ),
          const SizedBox(height: 12),
          ...activeGoals.map((goal) => _buildGoalCard(goal, isDark)),
          const SizedBox(height: 24),
        ],

        // Metas concluídas
        if (completedGoals.isNotEmpty) ...[
          _buildGoalsSectionHeader(
            'Concluídas',
            '${completedGoals.length}',
            _green,
            Icons.check_circle_rounded,
            isDark,
          ),
          const SizedBox(height: 12),
          ...completedGoals.map(
            (goal) => _buildGoalCard(goal, isDark, isCompleted: true),
          ),
        ],

        const SizedBox(height: 80),
      ],
    );
  }

  Widget _buildGoalsSectionHeader(
    String title,
    String count,
    Color color,
    IconData icon,
    bool isDark,
  ) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.15),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: color, size: 18),
        ),
        const SizedBox(width: 10),
        Text(
          title,
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: isDark ? Colors.white : const Color(0xFF1E293B),
          ),
        ),
        const Spacer(),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: color.withOpacity(0.15),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            count,
            style: GoogleFonts.poppins(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildGoalCard(
    Map<String, dynamic> goal,
    bool isDark, {
    bool isCompleted = false,
  }) {
    final name = goal['name'] ?? 'Meta';
    final emoji = goal['emoji'] ?? '🎯';
    final targetAmount = (goal['target_amount'] as num?)?.toDouble() ?? 0.0;
    final currentAmount = (goal['current_amount'] as num?)?.toDouble() ?? 0.0;
    final progress = targetAmount > 0
        ? (currentAmount / targetAmount).clamp(0.0, 1.0)
        : 0.0;
    final progressPercent = (progress * 100).toInt();

    final cardColor = isCompleted ? _green : _purple;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: cardColor.withOpacity(isDark ? 0.2 : 0.15)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.2 : 0.05),
            blurRadius: 10,
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
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: cardColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(emoji, style: const TextStyle(fontSize: 22)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: GoogleFonts.poppins(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: isDark ? Colors.white : const Color(0xFF1E293B),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Meta: ${AppFormatters.formatCurrency(targetAmount)}',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: isDark
                            ? const Color(0xFF94A3B8)
                            : const Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
              ),
              if (isCompleted)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: _green.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.check_rounded, color: _green, size: 14),
                      const SizedBox(width: 4),
                      Text(
                        'Concluída',
                        style: GoogleFonts.poppins(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: _green,
                        ),
                      ),
                    ],
                  ),
                )
              else
                Text(
                  '$progressPercent%',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: cardColor,
                  ),
                ),
            ],
          ),
          if (!isCompleted) ...[
            const SizedBox(height: 14),
            // Progress bar
            Stack(
              children: [
                Container(
                  height: 8,
                  decoration: BoxDecoration(
                    color: cardColor.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                FractionallySizedBox(
                  widthFactor: progress,
                  child: Container(
                    height: 8,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [cardColor, cardColor.withOpacity(0.7)],
                      ),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Economizado: ${AppFormatters.formatCurrency(currentAmount)}',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: cardColor,
                  ),
                ),
                Text(
                  'Falta: ${AppFormatters.formatCurrency(targetAmount - currentAmount)}',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: isDark
                        ? const Color(0xFF94A3B8)
                        : const Color(0xFF64748B),
                  ),
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

  void _showSendMoneyDialog(BuildContext context, bool isDark) {
    final amountController = TextEditingController();
    final descriptionController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: EdgeInsets.fromLTRB(
          20,
          20,
          20,
          MediaQuery.of(context).viewInsets.bottom + 20,
        ),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E293B) : Colors.white,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: isDark
                      ? const Color(0xFF64748B)
                      : const Color(0xFFCBD5E1),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Enviar para ${widget.child.name}',
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: isDark ? Colors.white : const Color(0xFF1E293B),
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: amountController,
              keyboardType: TextInputType.number,
              style: GoogleFonts.poppins(
                color: isDark ? Colors.white : const Color(0xFF1E293B),
              ),
              decoration: InputDecoration(
                labelText: 'Valor',
                prefixText: 'R\$ ',
                labelStyle: GoogleFonts.poppins(
                  color: isDark
                      ? const Color(0xFF94A3B8)
                      : const Color(0xFF64748B),
                ),
                filled: true,
                fillColor: isDark
                    ? const Color(0xFF1E293B)
                    : const Color(0xFFF8FAFC),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: descriptionController,
              style: GoogleFonts.poppins(
                color: isDark ? Colors.white : const Color(0xFF1E293B),
              ),
              decoration: InputDecoration(
                labelText: 'Descrição (opcional)',
                labelStyle: GoogleFonts.poppins(
                  color: isDark
                      ? const Color(0xFF94A3B8)
                      : const Color(0xFF64748B),
                ),
                filled: true,
                fillColor: isDark
                    ? const Color(0xFF1E293B)
                    : const Color(0xFFF8FAFC),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  final amount = double.tryParse(
                    amountController.text.replaceAll(',', '.'),
                  );
                  if (amount != null && amount > 0) {
                    await _sendMoney(amount, descriptionController.text);
                    if (context.mounted) Navigator.pop(context);
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: _green,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  'Enviar',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _sendMoney(double amount, String description) async {
    try {
      final supabase = Supabase.instance.client;

      // Validar entrada
      if (amount <= 0) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Valor deve ser maior que zero',
                style: GoogleFonts.poppins(),
              ),
              backgroundColor: _red,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
          );
        }
        return;
      }

      // Buscar ID do responsável atual
      final currentUser = supabase.auth.currentUser;
      if (currentUser == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Usuário não autenticado',
                style: GoogleFonts.poppins(),
              ),
              backgroundColor: _red,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
          );
        }
        return;
      }

      // Criar transação no banco
      await supabase.from('transactions').insert({
        'child_id': widget.child.id,
        'parent_id': currentUser.id,
        'amount': amount,
        'type': 'income',
        'description': description.isEmpty
            ? 'Envio do responsável'
            : description,
        'category': 'Mesada',
        'status': 'approved',
        'date': DateTime.now().toIso8601String(),
      });

      // O trigger update_child_balance vai atualizar o saldo automaticamente
      // Não é necessário chamar RPC ou atualizar manualmente

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'R\$ ${amount.toStringAsFixed(2)} enviado com sucesso!',
              style: GoogleFonts.poppins(),
            ),
            backgroundColor: _green,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
        );
        _loadChildData();
      }
    } catch (e) {
      debugPrint('Erro ao enviar dinheiro: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao enviar: $e', style: GoogleFonts.poppins()),
            backgroundColor: _red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
        );
      }
    }
  }
}
