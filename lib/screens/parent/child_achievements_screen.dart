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

  // Cores
  static const _purple = Color(0xFF8B5CF6);
  static const _blue = Color(0xFF3B82F6);
  static const _green = Color(0xFF10B981);
  static const _orange = Color(0xFFF59E0B);
  static const _red = Color(0xFFEF4444);
  static const _pink = Color(0xFFEC4899);
  static const _gold = Color(0xFFD97706);

  @override
  void initState() {
    super.initState();
    _loadAchievements();
  }

  Future<void> _loadAchievements() async {
    setState(() => _isLoading = true);
    try {
      final supabase = Supabase.instance.client;

      // Carregar todas as conquistas disponíveis
      final allAchievementsData = await supabase
          .from('achievements')
          .select('*')
          .order('points_required');

      _allAchievements = List<Map<String, dynamic>>.from(allAchievementsData);

      // Carregar conquistas desbloqueadas pelo filho
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
      backgroundColor: isDark
          ? const Color(0xFF121212)
          : const Color(0xFFF8FAFC),
      body: BrandedRefreshIndicator(
        onRefresh: _loadAchievements,
        color: _gold,
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // Header
            SliverToBoxAdapter(
              child: _buildHeader(context, isDark, topPadding),
            ),
            // Stats
            SliverToBoxAdapter(child: _buildStatsSection(isDark)),
            // Seção de conquistas recentes
            if (_unlockedAchievements.isNotEmpty) ...[
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
                  child: _buildSectionTitle('Conquistas Recentes', isDark),
                ),
              ),
              SliverToBoxAdapter(
                child: SizedBox(
                  height: 140,
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
            // Todas as conquistas
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
                child: _buildSectionTitle('Todas as Conquistas', isDark),
              ),
            ),
            if (_isLoading)
              const SliverFillRemaining(child: Center(child: BrandedLoader()))
            else if (_allAchievements.isEmpty)
              SliverFillRemaining(child: _buildEmptyState(isDark))
            else
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 100),
                sliver: SliverGrid(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                    childAspectRatio: 0.85,
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
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showCreateAchievementDialog(context, isDark),
        backgroundColor: _gold,
        icon: const Icon(Icons.add_rounded, color: Colors.white),
        label: Text(
          'Nova Conquista',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, bool isDark, double topPadding) {
    return Container(
      padding: EdgeInsets.fromLTRB(20, topPadding + 16, 20, 24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [
                  const Color(0xFF334155),
                  const Color(0xFF1E293B),
                  _gold.withOpacity(0.3),
                ]
              : [_gold, _orange, const Color(0xFFEA580C)],
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(32),
          bottomRight: Radius.circular(32),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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
                        color: Colors.white.withOpacity(0.8),
                      ),
                    ),
                  ],
                ),
              ),
              // Trophy icon
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
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

  Widget _buildStatsSection(bool isDark) {
    final totalAchievements = _allAchievements.length;
    final unlockedCount = _unlockedAchievements.length;
    final progress = totalAchievements > 0
        ? unlockedCount / totalAchievements
        : 0.0;

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Container(
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
              color: _gold.withOpacity(isDark ? 0.1 : 0.08),
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
                  width: 1,
                  height: 50,
                  color: isDark
                      ? const Color(0xFF334155)
                      : const Color(0xFFE2E8F0),
                ),
                _buildStatItem(
                  '${totalAchievements - unlockedCount}',
                  'Restantes',
                  Icons.lock_rounded,
                  _purple,
                  isDark,
                ),
                Container(
                  width: 1,
                  height: 50,
                  color: isDark
                      ? const Color(0xFF334155)
                      : const Color(0xFFE2E8F0),
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
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: progress,
                backgroundColor: _gold.withOpacity(0.2),
                valueColor: const AlwaysStoppedAnimation(_gold),
                minHeight: 10,
              ),
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
        Icon(icon, color: color, size: 24),
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
          colors: [color, color.withOpacity(0.8)],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.4),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
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
        ],
      ),
    );
  }

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
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isUnlocked
              ? color.withOpacity(0.5)
              : (isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
          width: isUnlocked ? 2 : 1,
        ),
        boxShadow: isUnlocked
            ? [
                BoxShadow(
                  color: color.withOpacity(0.2),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ]
            : null,
      ),
      child: Column(
        children: [
          // Badge
          Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: isUnlocked
                      ? color.withOpacity(0.15)
                      : (isDark
                            ? const Color(0xFF1E293B)
                            : const Color(0xFFF1F5F9)),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isUnlocked
                        ? color.withOpacity(0.3)
                        : (isDark
                              ? const Color(0xFF334155)
                              : const Color(0xFFE2E8F0)),
                    width: 2,
                  ),
                ),
                child: Center(
                  child: Text(
                    emoji,
                    style: TextStyle(
                      fontSize: 28,
                      color: isUnlocked ? null : Colors.grey,
                    ),
                  ),
                ),
              ),
              if (!isUnlocked)
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: (isDark ? Colors.black : Colors.white).withOpacity(
                      0.5,
                    ),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.lock_rounded,
                    color: isDark
                        ? const Color(0xFF64748B)
                        : const Color(0xFF94A3B8),
                    size: 24,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          // Name
          Text(
            name,
            style: GoogleFonts.poppins(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: isUnlocked
                  ? (isDark ? Colors.white : const Color(0xFF1E293B))
                  : (isDark
                        ? const Color(0xFF64748B)
                        : const Color(0xFF94A3B8)),
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          // Points required
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: (isUnlocked ? _green : _purple).withOpacity(0.15),
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

  Widget _buildEmptyState(bool isDark) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: _gold.withOpacity(0.15),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.emoji_events_outlined,
                size: 48,
                color: _gold,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Nenhuma conquista disponível',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white : const Color(0xFF1E293B),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Crie conquistas para motivar ${widget.child.name}!',
              textAlign: TextAlign.center,
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
    );
  }

  Color _hexToColor(String hex) {
    hex = hex.replaceAll('#', '');
    if (hex.length == 6) hex = 'FF$hex';
    return Color(int.parse(hex, radix: 16));
  }

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
          child: SingleChildScrollView(
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
                  'Criar Nova Conquista',
                  style: GoogleFonts.poppins(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: isDark ? Colors.white : const Color(0xFF1E293B),
                  ),
                ),
                const SizedBox(height: 20),
                // Emoji selector
                Text(
                  'Escolha um emoji',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: isDark
                        ? const Color(0xFF94A3B8)
                        : const Color(0xFF64748B),
                  ),
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 10,
                  children: emojis.map((emoji) {
                    final isSelected = emoji == selectedEmoji;
                    return GestureDetector(
                      onTap: () => setModalState(() => selectedEmoji = emoji),
                      child: Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: isSelected
                              ? selectedColor.withOpacity(0.2)
                              : (isDark
                                    ? const Color(0xFF1E293B)
                                    : const Color(0xFFF8FAFC)),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isSelected
                                ? selectedColor
                                : Colors.transparent,
                            width: 2,
                          ),
                        ),
                        child: Center(
                          child: Text(
                            emoji,
                            style: const TextStyle(fontSize: 24),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16),
                // Color selector
                Text(
                  'Escolha uma cor',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: isDark
                        ? const Color(0xFF94A3B8)
                        : const Color(0xFF64748B),
                  ),
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 10,
                  children: colors.map((color) {
                    final isSelected = color == selectedColor;
                    return GestureDetector(
                      onTap: () => setModalState(() => selectedColor = color),
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: color,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isSelected
                                ? Colors.white
                                : Colors.transparent,
                            width: 3,
                          ),
                          boxShadow: isSelected
                              ? [
                                  BoxShadow(
                                    color: color.withOpacity(0.5),
                                    blurRadius: 8,
                                    spreadRadius: 2,
                                  ),
                                ]
                              : null,
                        ),
                        child: isSelected
                            ? const Icon(
                                Icons.check_rounded,
                                color: Colors.white,
                                size: 20,
                              )
                            : null,
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: nameController,
                  style: GoogleFonts.poppins(
                    color: isDark ? Colors.white : const Color(0xFF1E293B),
                  ),
                  decoration: InputDecoration(
                    labelText: 'Nome da Conquista',
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
                  maxLines: 2,
                  decoration: InputDecoration(
                    labelText: 'Descrição',
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
                  controller: pointsController,
                  keyboardType: TextInputType.number,
                  style: GoogleFonts.poppins(
                    color: isDark ? Colors.white : const Color(0xFF1E293B),
                  ),
                  decoration: InputDecoration(
                    labelText: 'Pontos Necessários',
                    suffixText: 'pts',
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
                      if (nameController.text.isNotEmpty) {
                        await _createAchievement(
                          nameController.text,
                          descriptionController.text,
                          selectedEmoji,
                          int.tryParse(pointsController.text) ?? 100,
                          selectedColor,
                        );
                        if (context.mounted) Navigator.pop(context);
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: selectedColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      'Criar Conquista',
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
        ),
      ),
    );
  }

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
          '#${color.value.toRadixString(16).substring(2).toUpperCase()}';

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
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Conquista criada com sucesso!',
              style: GoogleFonts.poppins(),
            ),
            backgroundColor: _green,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
        );
      }
    } catch (e) {
      debugPrint('Erro ao criar conquista: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Erro ao criar conquista: $e',
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
    }
  }
}
