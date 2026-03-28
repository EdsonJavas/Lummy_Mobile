import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:lummy_login/domain/entities/user_entity.dart';
import 'package:lummy_login/shared/widgets/widgets.dart';

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

  static const _purple = Color(0xFF8B5CF6);
  static const _blue = Color(0xFF3B82F6);
  static const _green = Color(0xFF10B981);
  static const _orange = Color(0xFFF59E0B);
  // ignore: unused_field
  static const _red = Color(0xFFEF4444);
  static const _pink = Color(0xFFEC4899);
  static const _gold = Color(0xFFD97706);
  static const _goldLight = Color(0xFFF59E0B);

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
      debugPrint('Erro ao carregar conquistas: $e');
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
          isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
      body: BrandedRefreshIndicator(
        onRefresh: _loadAchievements,
        color: _gold,
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(
              child: _buildHeader(context, isDark, topPadding),
            ),
            SliverToBoxAdapter(child: _buildStatsSection(isDark)),
            if (_unlockedAchievements.isNotEmpty) ...[
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
                  child: _buildSectionTitle('Conquistas Recentes', isDark),
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
                        child: _buildRecentAchievementCard(
                          achievementData?['name'] ?? 'Conquista',
                          achievementData?['emoji'] ?? '🏆',
                          achievementData?['description'] ?? '',
                          _hexToColor(
                            achievementData?['color_hex'] ?? '#F59E0B',
                          ),
                          isDark,
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
                child: _buildSectionTitle('Todas as Conquistas', isDark),
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
                    return _buildAchievementCard(
                      achievement['name'] ?? 'Conquista',
                      achievement['emoji'] ?? '🏆',
                      achievement['description'] ?? '',
                      achievement['points_required'] ?? 0,
                      _hexToColor(achievement['color_hex'] ?? '#F59E0B'),
                      isUnlocked,
                      isDark,
                    );
                  }, childCount: _allAchievements.length),
                ),
              ),
          ],
        ),
      ),
      floatingActionButton: _buildFab(isDark),
    );
  }

  // ──────────────────────── FAB ────────────────────────

  Widget _buildFab(bool isDark) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: () => _showCreateAchievementDialog(context, isDark),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          decoration: BoxDecoration(
            gradient: const LinearGradient(colors: [_gold, _goldLight]),
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: _gold.withValues(alpha: 0.45),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.add_rounded, color: Colors.white, size: 22),
              const SizedBox(width: 8),
              Text(
                'Nova Conquista',
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ──────────────────────── Header ────────────────────────

  Widget _buildHeader(BuildContext context, bool isDark, double topPadding) {
    return Container(
      padding: EdgeInsets.fromLTRB(20, topPadding + 16, 20, 28),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [const Color(0xFF1C1917), _gold.withValues(alpha: 0.4)]
              : [_gold, _orange, const Color(0xFFEA580C)],
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(32),
          bottomRight: Radius.circular(32),
        ),
        boxShadow: [
          BoxShadow(
            color: _gold.withValues(alpha: isDark ? 0.15 : 0.3),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Conquistas',
                      style: GoogleFonts.poppins(
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      'Medalhas de ${widget.child.name}',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: Colors.white.withValues(alpha: 0.8),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Text('🏆', style: TextStyle(fontSize: 28)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ──────────────────────── Stats ────────────────────────

  Widget _buildStatsSection(bool isDark) {
    final totalAchievements = _allAchievements.length;
    final unlockedCount = _unlockedAchievements.length;
    final progress =
        totalAchievements > 0 ? unlockedCount / totalAchievements : 0.0;

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDark
                ? [const Color(0xFF1E293B), const Color(0xFF0F172A)]
                : [Colors.white, const Color(0xFFFFFBEB)],
          ),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: _gold.withValues(alpha: isDark ? 0.15 : 0.12),
          ),
          boxShadow: [
            BoxShadow(
              color: _gold.withValues(alpha: isDark ? 0.08 : 0.1),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem(
                  '$unlockedCount',
                  'Desbloqueadas',
                  Icons.emoji_events_rounded,
                  _gold,
                  isDark,
                ),
                Container(
                  width: 1, height: 50,
                  color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                ),
                _buildStatItem(
                  '${totalAchievements - unlockedCount}',
                  'Restantes',
                  Icons.lock_rounded,
                  _purple,
                  isDark,
                ),
                Container(
                  width: 1, height: 50,
                  color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                ),
                _buildStatItem(
                  '${(progress * 100).toInt()}%',
                  'Progresso',
                  Icons.pie_chart_rounded,
                  _green,
                  isDark,
                ),
              ],
            ),
            const SizedBox(height: 20),
            Stack(
              children: [
                Container(
                  height: 12,
                  decoration: BoxDecoration(
                    color: _gold.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
                FractionallySizedBox(
                  widthFactor: progress.clamp(0.0, 1.0),
                  child: Container(
                    height: 12,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(colors: [_gold, _goldLight]),
                      borderRadius: BorderRadius.circular(6),
                      boxShadow: [
                        BoxShadow(
                          color: _gold.withValues(alpha: 0.4),
                          blurRadius: 8,
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
  }

  Widget _buildStatItem(
    String value,
    String label,
    IconData icon,
    Color color,
    bool isDark,
  ) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: GoogleFonts.poppins(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: isDark ? Colors.white : const Color(0xFF1E293B),
          ),
        ),
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 11,
            color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
          ),
        ),
      ],
    );
  }

  // ──────────────────────── Section title ────────────────────────

  Widget _buildSectionTitle(String title, bool isDark) {
    return ShaderMask(
      shaderCallback: (bounds) =>
          const LinearGradient(colors: [_gold, _orange]).createShader(bounds),
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

  // ──────────────────────── Recent card ────────────────────────

  Widget _buildRecentAchievementCard(
    String name,
    String emoji,
    String description,
    Color color,
    bool isDark,
  ) {
    return Container(
      width: 160,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [color, color.withValues(alpha: 0.75)],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.4),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 48, height: 48,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.white.withValues(alpha: 0.3), Colors.white.withValues(alpha: 0.1)],
              ),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Center(
              child: Text(emoji, style: const TextStyle(fontSize: 26)),
            ),
          ),
          const Spacer(),
          Text(
            name,
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          if (description.isNotEmpty) ...[
            const SizedBox(height: 2),
            Text(
              description,
              style: GoogleFonts.poppins(
                fontSize: 10,
                color: Colors.white.withValues(alpha: 0.7),
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ],
      ),
    );
  }

  // ──────────────────────── Achievement grid card ────────────────────────

  Widget _buildAchievementCard(
    String name,
    String emoji,
    String description,
    int pointsRequired,
    Color color,
    bool isUnlocked,
    bool isDark,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: isUnlocked
            ? LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: isDark
                    ? [const Color(0xFF1E293B), color.withValues(alpha: 0.12)]
                    : [Colors.white, color.withValues(alpha: 0.06)],
              )
            : null,
        color: isUnlocked ? null : (isDark ? const Color(0xFF1E293B) : Colors.white),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isUnlocked
              ? color.withValues(alpha: 0.4)
              : (isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
          width: isUnlocked ? 2 : 1,
        ),
        boxShadow: isUnlocked
            ? [
                BoxShadow(
                  color: color.withValues(alpha: 0.2),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ]
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: isDark ? 0.1 : 0.04),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: 64, height: 64,
                decoration: BoxDecoration(
                  gradient: isUnlocked
                      ? LinearGradient(
                          colors: [color.withValues(alpha: 0.2), color.withValues(alpha: 0.08)],
                        )
                      : null,
                  color: isUnlocked
                      ? null
                      : (isDark ? const Color(0xFF0F172A) : const Color(0xFFF1F5F9)),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isUnlocked
                        ? color.withValues(alpha: 0.3)
                        : (isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
                    width: 2,
                  ),
                ),
                child: Center(
                  child: Text(emoji, style: const TextStyle(fontSize: 28)),
                ),
              ),
              if (!isUnlocked)
                Container(
                  width: 64, height: 64,
                  decoration: BoxDecoration(
                    color: (isDark ? const Color(0xFF0F172A) : Colors.white)
                        .withValues(alpha: 0.6),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.lock_rounded,
                    color: isDark ? const Color(0xFF475569) : const Color(0xFFCBD5E1),
                    size: 24,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            name,
            style: GoogleFonts.poppins(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: isUnlocked
                  ? (isDark ? Colors.white : const Color(0xFF1E293B))
                  : (isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8)),
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              gradient: isUnlocked
                  ? LinearGradient(colors: [_green.withValues(alpha: 0.2), _green.withValues(alpha: 0.1)])
                  : null,
              color: isUnlocked ? null : _purple.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              isUnlocked ? '✓ Desbloqueada' : '$pointsRequired pts',
              style: GoogleFonts.poppins(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: isUnlocked ? _green : _purple,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ──────────────────────── Helpers ────────────────────────

  Color _hexToColor(String hex) {
    hex = hex.replaceAll('#', '');
    if (hex.length == 6) hex = 'FF$hex';
    return Color(int.parse(hex, radix: 16));
  }

  InputDecoration _achieveFieldDecor(String hint, bool isDark, {Widget? prefixIcon, String? suffixText}) {
    final fillColor = isDark ? const Color(0xFF0F172A) : const Color(0xFFF1F5F9);
    return InputDecoration(
      hintText: hint,
      hintStyle: GoogleFonts.poppins(
        color: isDark ? const Color(0xFF475569) : const Color(0xFFCBD5E1),
        fontSize: 14,
      ),
      prefixIcon: prefixIcon,
      suffixText: suffixText,
      suffixStyle: GoogleFonts.poppins(
        color: isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8),
        fontWeight: FontWeight.w500,
      ),
      filled: true,
      fillColor: fillColor,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(
          color: isDark ? const Color(0xFF2D2D2D) : const Color(0xFFE2E8F0),
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: _gold, width: 2),
      ),
    );
  }

  Widget _dialogSectionLabel(String text, bool isDark) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        text,
        style: GoogleFonts.poppins(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
        ),
      ),
    );
  }

  // ──────────────────────── Create Dialog ────────────────────────

  void _showCreateAchievementDialog(BuildContext context, bool isDark) {
    final nameController = TextEditingController();
    final descriptionController = TextEditingController();
    final pointsController = TextEditingController(text: '100');
    String selectedEmoji = '🏆';
    Color selectedColor = _gold;

    final emojis = ['🏆', '⭐', '🥇', '🎖️', '🏅', '💎', '👑', '🚀', '💪', '🎯'];
    final colors = [_gold, _orange, _purple, _blue, _green, _pink];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Container(
          padding: EdgeInsets.fromLTRB(
            20, 0, 20,
            MediaQuery.of(context).viewInsets.bottom + 20,
          ),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E293B) : Colors.white,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(28),
              topRight: Radius.circular(28),
            ),
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 12),
                Container(
                  width: 40, height: 4,
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF475569) : const Color(0xFFCBD5E1),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 16),
                // Live preview header
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [selectedColor, selectedColor.withValues(alpha: 0.75)],
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: selectedColor.withValues(alpha: 0.35),
                        blurRadius: 16,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 56, height: 56,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        alignment: Alignment.center,
                        child: Text(selectedEmoji, style: const TextStyle(fontSize: 30)),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Nova Conquista',
                              style: GoogleFonts.poppins(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                            Text(
                              'Pré-visualização',
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                color: Colors.white.withValues(alpha: 0.7),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                // Emoji selector
                _dialogSectionLabel('Escolha um emoji', isDark),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: emojis.map((emoji) {
                    final isSelected = emoji == selectedEmoji;
                    return Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(12),
                        onTap: () => setModalState(() => selectedEmoji = emoji),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          width: 48, height: 48,
                          decoration: BoxDecoration(
                            gradient: isSelected
                                ? LinearGradient(colors: [selectedColor.withValues(alpha: 0.25), selectedColor.withValues(alpha: 0.1)])
                                : null,
                            color: isSelected
                                ? null
                                : (isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC)),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isSelected ? selectedColor : Colors.transparent,
                              width: 2,
                            ),
                            boxShadow: isSelected
                                ? [BoxShadow(color: selectedColor.withValues(alpha: 0.2), blurRadius: 8)]
                                : null,
                          ),
                          child: Center(
                            child: Text(emoji, style: const TextStyle(fontSize: 24)),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16),
                // Color selector
                _dialogSectionLabel('Escolha uma cor', isDark),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 12,
                  children: colors.map((color) {
                    final isSelected = color == selectedColor;
                    return Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(20),
                        onTap: () => setModalState(() => selectedColor = color),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          width: 40, height: 40,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [color, color.withValues(alpha: 0.8)],
                            ),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: isSelected ? Colors.white : Colors.transparent,
                              width: 3,
                            ),
                            boxShadow: isSelected
                                ? [BoxShadow(color: color.withValues(alpha: 0.5), blurRadius: 10, spreadRadius: 2)]
                                : null,
                          ),
                          child: isSelected
                              ? const Icon(Icons.check_rounded, color: Colors.white, size: 20)
                              : null,
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 20),
                // Fields
                _dialogSectionLabel('Nome da Conquista', isDark),
                const SizedBox(height: 8),
                TextField(
                  controller: nameController,
                  style: GoogleFonts.poppins(
                    color: isDark ? Colors.white : const Color(0xFF1E293B),
                  ),
                  decoration: _achieveFieldDecor('Ex: Super Economista', isDark),
                ),
                const SizedBox(height: 12),
                _dialogSectionLabel('Descrição', isDark),
                const SizedBox(height: 8),
                TextField(
                  controller: descriptionController,
                  style: GoogleFonts.poppins(
                    color: isDark ? Colors.white : const Color(0xFF1E293B),
                  ),
                  maxLines: 2,
                  decoration: _achieveFieldDecor('Descreva a conquista...', isDark),
                ),
                const SizedBox(height: 12),
                _dialogSectionLabel('Pontos Necessários', isDark),
                const SizedBox(height: 8),
                TextField(
                  controller: pointsController,
                  keyboardType: TextInputType.number,
                  style: GoogleFonts.poppins(
                    color: isDark ? Colors.white : const Color(0xFF1E293B),
                  ),
                  decoration: _achieveFieldDecor(
                    '100',
                    isDark,
                    prefixIcon: const Padding(
                      padding: EdgeInsets.only(left: 12, right: 4),
                      child: Icon(Icons.star_rounded, color: _gold, size: 20),
                    ),
                    suffixText: 'pontos',
                  ),
                ),
                const SizedBox(height: 24),
                // Create button
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: () async {
                      if (nameController.text.trim().isEmpty) {
                        LummyFeedback.warning(context, 'Dê um nome à conquista');
                        return;
                      }
                      await _createAchievement(
                        nameController.text.trim(),
                        descriptionController.text.trim(),
                        selectedEmoji,
                        int.tryParse(pointsController.text) ?? 100,
                        selectedColor,
                      );
                      if (context.mounted) Navigator.pop(context);
                    },
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [selectedColor, selectedColor.withValues(alpha: 0.8)],
                        ),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: selectedColor.withValues(alpha: 0.4),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      alignment: Alignment.center,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.emoji_events_rounded, color: Colors.white, size: 20),
                          const SizedBox(width: 10),
                          Text(
                            'Criar Conquista',
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
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
      debugPrint('Erro ao criar conquista: $e');
      if (mounted) {
        LummyFeedback.error(context, 'Erro ao criar conquista');
      }
    }
  }
}
