import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:lummy/domain/entities/user_entity.dart';
import 'package:lummy/shared/widgets/widgets.dart';
import 'package:lummy/core/utils/app_log.dart';
import 'package:lummy/core/theme/design_tokens.dart';
import 'package:lummy/screens/parent/widgets/achievements/achievements_create_sheet.dart';
import 'package:lummy/screens/parent/widgets/achievements/achievements_fab.dart';
import 'package:lummy/screens/parent/widgets/achievements/achievements_grid_card.dart';
import 'package:lummy/screens/parent/widgets/achievements/achievements_header.dart';
import 'package:lummy/screens/parent/widgets/achievements/achievements_recent_card.dart';
import 'package:lummy/screens/parent/widgets/achievements/achievements_section_title.dart';
import 'package:lummy/screens/parent/widgets/achievements/achievements_stats_section.dart';

class ChildAchievementsScreen extends StatefulWidget {
  final ChildEntity child;

  const ChildAchievementsScreen({super.key, required this.child});

  @override
  State<ChildAchievementsScreen> createState() =>
      _ChildAchievementsScreenState();
}

class _ChildAchievementsScreenState extends State<ChildAchievementsScreen> {
  List<Map<String, dynamic>> _unlockedAchievements = [];
  List<Map<String, dynamic>> _allAchievements = [];
  bool _isLoading = true;

  static const _gold = LummyColors.amber600;

  @override
  void initState() {
    super.initState();
    _loadAchievements();
  }

  Future<void> _loadAchievements() async {
    setState(() => _isLoading = true);
    try {
      final supabase = Supabase.instance.client;

      final allAchievementsData = await supabase
          .from('achievements')
          .select('*')
          .order('points_required');

      _allAchievements = List<Map<String, dynamic>>.from(allAchievementsData);

      final unlockedData = await supabase
          .from('child_achievements')
          .select('*, achievements(*)')
          .eq('child_id', widget.child.id)
          .order('unlocked_at', ascending: false);

      _unlockedAchievements = List<Map<String, dynamic>>.from(unlockedData);
    } catch (e) {
      appLog('Erro ao carregar conquistas: $e');
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

    final unlockedIds = _unlockedAchievements
        .map((a) => a['achievement_id'] as String?)
        .whereType<String>()
        .toSet();

    return Scaffold(
      backgroundColor:
          isDark ? LummyColors.slate900 : LummyColors.slate50,
      body: BrandedRefreshIndicator(
        onRefresh: _loadAchievements,
        color: _gold,
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(
              child: AchievementsHeader(
                isDark: isDark,
                topPadding: topPadding,
                childName: widget.child.name,
                onBack: () => Navigator.pop(context),
              ),
            ),
            SliverToBoxAdapter(
              child: AchievementsStatsSection(
                isDark: isDark,
                totalAchievements: _allAchievements.length,
                unlockedCount: _unlockedAchievements.length,
              ),
            ),
            if (_unlockedAchievements.isNotEmpty) ...[
              const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(20, 24, 20, 12),
                  child: AchievementsSectionTitle(title: 'Conquistas Recentes'),
                ),
              ),
              SliverToBoxAdapter(
                child: SizedBox(
                  height: 150,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    itemCount: _unlockedAchievements.take(5).length,
                    itemBuilder: (context, index) {
                      final achievement = _unlockedAchievements[index];
                      final achievementData =
                          achievement['achievements'] as Map<String, dynamic>?;
                      return Padding(
                        padding: const EdgeInsets.only(right: 12),
                        child: AchievementsRecentCard(
                          name: achievementData?['name'] ?? 'Conquista',
                          emoji: achievementData?['emoji'] ?? '🏆',
                          description: achievementData?['description'] ?? '',
                          color: _hexToColor(
                            achievementData?['color_hex'] ?? '#F59E0B',
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(20, 24, 20, 12),
                child: AchievementsSectionTitle(title: 'Todas as Conquistas'),
              ),
            ),
            if (_isLoading)
              const SliverFillRemaining(child: Center(child: BrandedLoader()))
            else if (_allAchievements.isEmpty)
              SliverFillRemaining(
                child: EmptyState(
                  emoji: '🏆',
                  title: 'Nenhuma conquista disponível',
                  message: 'Crie conquistas para motivar ${widget.child.name}!',
                  icon: Icons.emoji_events_outlined,
                  iconColor: _gold,
                  buttonText: 'Criar Conquista',
                  onButtonPressed: () => _showCreateAchievementDialog(context, isDark),
                ),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
                sliver: SliverGrid(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                    childAspectRatio: 0.82,
                  ),
                  delegate: SliverChildBuilderDelegate((context, index) {
                    final achievement = _allAchievements[index];
                    final isUnlocked = unlockedIds.contains(achievement['id']);
                    return AchievementsGridCard(
                      name: achievement['name'] ?? 'Conquista',
                      emoji: achievement['emoji'] ?? '🏆',
                      pointsRequired: achievement['points_required'] ?? 0,
                      color: _hexToColor(achievement['color_hex'] ?? '#F59E0B'),
                      isUnlocked: isUnlocked,
                      isDark: isDark,
                    );
                  }, childCount: _allAchievements.length),
                ),
              ),
          ],
        ),
      ),
      floatingActionButton: AchievementsFab(
        onTap: () => _showCreateAchievementDialog(context, isDark),
      ),
    );
  }

  // ──────────────────────── Helpers ────────────────────────

  Color _hexToColor(String hex) {
    hex = hex.replaceAll('#', '');
    if (hex.length == 6) hex = 'FF$hex';
    return Color(int.parse(hex, radix: 16));
  }

  // ──────────────────────── Create Dialog ────────────────────────

  void _showCreateAchievementDialog(BuildContext context, bool isDark) {
    final nameController = TextEditingController();
    final descriptionController = TextEditingController();
    final pointsController = TextEditingController(text: '100');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AchievementsCreateSheet(
        isDark: isDark,
        nameController: nameController,
        descriptionController: descriptionController,
        pointsController: pointsController,
        onCreate: _createAchievement,
      ),
    );
  }

  // ──────────────────────── Create Achievement ────────────────────────

  Future<void> _createAchievement(
    String name,
    String description,
    String emoji,
    int pointsRequired,
    Color color,
  ) async {
    try {
      final supabase = Supabase.instance.client;
      final colorHex =
          '#${color.toARGB32().toRadixString(16).substring(2).toUpperCase()}';

      await supabase.from('achievements').insert({
        'name': name,
        'description': description,
        'emoji': emoji,
        'points_required': pointsRequired,
        'color_hex': colorHex,
        'created_at': DateTime.now().toIso8601String(),
      });

      _loadAchievements();

      if (mounted) {
        LummyFeedback.success(context, 'Conquista "$name" criada!');
      }
    } catch (e) {
      appLog('Erro ao criar conquista: $e');
      if (mounted) {
        LummyFeedback.error(context, 'Erro ao criar conquista');
      }
    }
  }
}
