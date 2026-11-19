import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:lummy/domain/entities/user_entity.dart';
import 'package:lummy/shared/widgets/widgets.dart';
import 'package:lummy/core/utils/app_log.dart';
import 'package:lummy/core/theme/design_tokens.dart';
import 'package:lummy/screens/parent/widgets/missions_manager/missions_manager_card.dart';
import 'package:lummy/screens/parent/widgets/missions_manager/missions_manager_create_mission_sheet.dart';
import 'package:lummy/screens/parent/widgets/missions_manager/missions_manager_fab.dart';
import 'package:lummy/screens/parent/widgets/missions_manager/missions_manager_header.dart';
import 'package:lummy/screens/parent/widgets/missions_manager/missions_manager_tab_bar.dart';

class ChildMissionsManagerScreen extends StatefulWidget {
  final ChildEntity child;

  const ChildMissionsManagerScreen({super.key, required this.child});

  @override
  State<ChildMissionsManagerScreen> createState() =>
      _ChildMissionsManagerScreenState();
}

class _ChildMissionsManagerScreenState
    extends State<ChildMissionsManagerScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  List<Map<String, dynamic>> _allMissions = [];
  List<Map<String, dynamic>> _childDailyMissions = [];
  List<Map<String, dynamic>> _customMissions = [];
  bool _isLoading = true;

  static const _purple = LummyColors.violet500;
  static const _blue = LummyColors.blue500;
  static const _orange = LummyColors.amber500;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadMissions();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadMissions() async {
    setState(() => _isLoading = true);
    try {
      final supabase = Supabase.instance.client;
      final today = DateTime.now().toIso8601String().split('T')[0];

      final allMissionsData = await supabase
          .from('missions')
          .select('*')
          .eq('is_active', true)
          .order('created_at');

      _allMissions = List<Map<String, dynamic>>.from(allMissionsData);

      final dailyMissionsData = await supabase
          .from('daily_missions')
          .select('*, missions(*)')
          .eq('child_id', widget.child.id)
          .eq('selected_date', today);

      _childDailyMissions =
          List<Map<String, dynamic>>.from(dailyMissionsData);

      final customMissionsData = await supabase
          .from('custom_missions')
          .select('*')
          .eq('child_id', widget.child.id)
          .order('created_at', ascending: false);

      _customMissions = List<Map<String, dynamic>>.from(customMissionsData);
    } catch (e) {
      appLog('Erro ao carregar missões: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // ---------------------------------------------------------------------------
  // Build
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? LummyColors.darkBase : LummyColors.slate50;

    return Scaffold(
      backgroundColor: bg,
      body: Column(
        children: [
          MissionsManagerHeader(
            isDark: isDark,
            childName: widget.child.name,
            childDailyMissions: _childDailyMissions,
            customMissions: _customMissions,
            allMissions: _allMissions,
            onBack: () => Navigator.pop(context),
          ),
          MissionsManagerTabBar(controller: _tabController, isDark: isDark),
          Expanded(
            child: _isLoading
                ? const Center(child: BrandedLoader())
                : TabBarView(
                    controller: _tabController,
                    children: [
                      _buildDailyMissionsTab(isDark),
                      _buildCustomMissionsTab(isDark),
                      _buildAllMissionsTab(isDark),
                    ],
                  ),
          ),
        ],
      ),
      floatingActionButton: MissionsManagerFab(
        onTap: () => _showCreateMissionDialog(
          context,
          Theme.of(context).brightness == Brightness.dark,
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Tabs content
  // ---------------------------------------------------------------------------

  Widget _buildDailyMissionsTab(bool isDark) {
    if (_childDailyMissions.isEmpty) {
      return EmptyState(
        emoji: '📋',
        title: 'Nenhuma missão hoje',
        message:
            'Atribua missões do catálogo ou crie uma personalizada para ${widget.child.name}.',
        icon: Icons.assignment_outlined,
        iconColor: _purple,
        buttonText: 'Ver catálogo',
        onButtonPressed: () => _tabController.animateTo(2),
      );
    }

    return BrandedRefreshIndicator(
      onRefresh: _loadMissions,
      color: _purple,
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 100),
        physics: const AlwaysScrollableScrollPhysics(
          parent: BouncingScrollPhysics(),
        ),
        itemCount: _childDailyMissions.length,
        itemBuilder: (context, index) {
          final mission = _childDailyMissions[index];
          final data = mission['missions'] as Map<String, dynamic>?;
          final isCompleted = mission['is_completed'] == true;

          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: MissionsManagerCard(
              title: data?['title'] ?? 'Missão',
              description: data?['description'] ?? '',
              emoji: data?['emoji'] ?? '🎯',
              points: data?['points'] ?? 0,
              isCompleted: isCompleted,
              color: _hexToColor(data?['color_hex'] ?? '#8B5CF6'),
              isDark: isDark,
            ),
          );
        },
      ),
    );
  }

  Widget _buildCustomMissionsTab(bool isDark) {
    if (_customMissions.isEmpty) {
      return EmptyState(
        emoji: '⭐',
        title: 'Nenhuma missão criada',
        message:
            'Crie missões especiais e personalizadas para ${widget.child.name}!',
        icon: Icons.auto_awesome_rounded,
        iconColor: _orange,
        buttonText: 'Criar missão',
        onButtonPressed: () => _showCreateMissionDialog(context, isDark),
      );
    }

    return BrandedRefreshIndicator(
      onRefresh: _loadMissions,
      color: _purple,
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 100),
        physics: const AlwaysScrollableScrollPhysics(
          parent: BouncingScrollPhysics(),
        ),
        itemCount: _customMissions.length,
        itemBuilder: (context, index) {
          final mission = _customMissions[index];
          final isCompleted = mission['is_completed'] == true;

          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: MissionsManagerCard(
              title: mission['title'] ?? 'Missão',
              description: mission['description'] ?? '',
              emoji: mission['emoji'] ?? '⭐',
              points: mission['reward_points'] ?? 0,
              isCompleted: isCompleted,
              color: _hexToColor(mission['color_hex'] ?? '#F59E0B'),
              isDark: isDark,
              badge: 'Personalizada',
              badgeColor: _orange,
              onDelete: () => _deleteCustomMission(mission['id']),
            ),
          );
        },
      ),
    );
  }

  Widget _buildAllMissionsTab(bool isDark) {
    if (_allMissions.isEmpty) {
      return const EmptyState(
        emoji: '🎯',
        title: 'Catálogo vazio',
        message: 'As missões do sistema aparecerão aqui quando disponíveis.',
        icon: Icons.explore_outlined,
        iconColor: _blue,
      );
    }

    return BrandedRefreshIndicator(
      onRefresh: _loadMissions,
      color: _purple,
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 100),
        physics: const AlwaysScrollableScrollPhysics(
          parent: BouncingScrollPhysics(),
        ),
        itemCount: _allMissions.length,
        itemBuilder: (context, index) {
          final mission = _allMissions[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: MissionsManagerCard(
              title: mission['title'] ?? 'Missão',
              description: mission['description'] ?? '',
              emoji: mission['emoji'] ?? '🎯',
              points: mission['points'] ?? 0,
              isCompleted: false,
              color: _hexToColor(mission['color_hex'] ?? '#3B82F6'),
              isDark: isDark,
              actionLabel: 'Atribuir',
              onAction: () => _assignMission(mission),
            ),
          );
        },
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Create mission dialog
  // ---------------------------------------------------------------------------

  void _showCreateMissionDialog(BuildContext context, bool isDark) {
    final titleCtl = TextEditingController();
    final descCtl = TextEditingController();
    final pointsCtl = TextEditingController(text: '50');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => MissionsManagerCreateMissionSheet(
        isDark: isDark,
        titleCtl: titleCtl,
        descCtl: descCtl,
        pointsCtl: pointsCtl,
        onCreate: _createCustomMission,
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // CRUD operations
  // ---------------------------------------------------------------------------

  Color _hexToColor(String hex) {
    hex = hex.replaceAll('#', '');
    if (hex.length == 6) hex = 'FF$hex';
    return Color(int.parse(hex, radix: 16));
  }

  Future<void> _createCustomMission(
    String title,
    String description,
    String emoji,
    int points,
    Color color,
  ) async {
    try {
      final supabase = Supabase.instance.client;
      final colorHex =
          '#${color.toARGB32().toRadixString(16).substring(2).toUpperCase()}';

      await supabase.from('custom_missions').insert({
        'child_id': widget.child.id,
        'parent_id': supabase.auth.currentUser?.id,
        'title': title,
        'description': description,
        'emoji': emoji,
        'reward_points': points,
        'color_hex': colorHex,
        'is_completed': false,
        'created_at': DateTime.now().toIso8601String(),
      });

      _loadMissions();
      if (mounted) LummyFeedback.success(context, 'Missão criada!');
    } catch (e) {
      appLog('Erro ao criar missão: $e');
      if (mounted) LummyFeedback.error(context, 'Erro ao criar missão.');
    }
  }

  Future<void> _deleteCustomMission(String missionId) async {
    try {
      final supabase = Supabase.instance.client;
      await supabase.from('custom_missions').delete().eq('id', missionId);
      _loadMissions();
      if (mounted) LummyFeedback.success(context, 'Missão removida!');
    } catch (e) {
      appLog('Erro ao deletar missão: $e');
      if (mounted) LummyFeedback.error(context, 'Erro ao remover missão.');
    }
  }

  Future<void> _assignMission(Map<String, dynamic> mission) async {
    try {
      final supabase = Supabase.instance.client;
      final today = DateTime.now().toIso8601String().split('T')[0];

      final existing = await supabase
          .from('daily_missions')
          .select('id')
          .eq('child_id', widget.child.id)
          .eq('mission_id', mission['id'])
          .eq('selected_date', today)
          .maybeSingle();

      if (existing != null) {
        if (mounted) {
          LummyFeedback.warning(
            context,
            'Esta missão já foi atribuída hoje!',
          );
        }
        return;
      }

      await supabase.from('daily_missions').insert({
        'child_id': widget.child.id,
        'mission_id': mission['id'],
        'selected_date': today,
        'is_completed': false,
        'progress': 0,
      });

      _loadMissions();
      if (mounted) LummyFeedback.success(context, 'Missão atribuída!');
    } catch (e) {
      appLog('Erro ao atribuir missão: $e');
      if (mounted) LummyFeedback.error(context, 'Erro ao atribuir missão.');
    }
  }
}
