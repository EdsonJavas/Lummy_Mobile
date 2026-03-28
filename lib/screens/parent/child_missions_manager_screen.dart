import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:lummy_login/domain/entities/user_entity.dart';
import 'package:lummy_login/shared/widgets/widgets.dart';

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

  static const _purple = Color(0xFF8B5CF6);
  static const _purpleDark = Color(0xFF6D28D9);
  static const _blue = Color(0xFF3B82F6);
  static const _green = Color(0xFF10B981);
  static const _orange = Color(0xFFF59E0B);
  static const _red = Color(0xFFEF4444);
  static const _pink = Color(0xFFEC4899);

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
      debugPrint('Erro ao carregar missões: $e');
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
    final bg = isDark ? const Color(0xFF0F0F0F) : const Color(0xFFF8FAFC);

    return Scaffold(
      backgroundColor: bg,
      body: Column(
        children: [
          _buildHeader(context, isDark),
          _buildTabBar(isDark),
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
      floatingActionButton: _buildFab(),
    );
  }

  // ---------------------------------------------------------------------------
  // Header
  // ---------------------------------------------------------------------------

  Widget _buildHeader(BuildContext context, bool isDark) {
    final topPadding = MediaQuery.of(context).padding.top;
    final completedToday = _childDailyMissions
        .where((m) => m['is_completed'] == true)
        .length;
    final totalToday = _childDailyMissions.length;

    return Container(
      padding: EdgeInsets.fromLTRB(20, topPadding + 12, 20, 24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [const Color(0xFF1E1B4B), _purpleDark.withValues(alpha: 0.7)]
              : [_purple, _purpleDark],
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(28),
          bottomRight: Radius.circular(28),
        ),
        boxShadow: [
          BoxShadow(
            color: _purple.withValues(alpha: isDark ? 0.15 : 0.25),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top row: back + title
          Row(
            children: [
              _headerBackButton(context),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Missões',
                      style: GoogleFonts.poppins(
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      widget.child.name,
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        color: Colors.white.withValues(alpha: 0.8),
                      ),
                    ),
                  ],
                ),
              ),
              // Mini avatar
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(14),
                ),
                alignment: Alignment.center,
                child: const Icon(
                  Icons.rocket_launch_rounded,
                  color: Colors.white,
                  size: 22,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          // Stats row
          Row(
            children: [
              _buildHeaderStat(
                '$completedToday/$totalToday',
                'Concluídas hoje',
                Icons.check_circle_outline_rounded,
              ),
              const SizedBox(width: 12),
              _buildHeaderStat(
                '${_customMissions.length}',
                'Personalizadas',
                Icons.auto_awesome_rounded,
              ),
              const SizedBox(width: 12),
              _buildHeaderStat(
                '${_allMissions.length}',
                'Disponíveis',
                Icons.list_alt_rounded,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _headerBackButton(BuildContext context) {
    return Material(
      color: Colors.white.withValues(alpha: 0.15),
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: () => Navigator.pop(context),
        borderRadius: BorderRadius.circular(12),
        child: const SizedBox(
          width: 44,
          height: 44,
          child: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Colors.white,
            size: 18,
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderStat(String value, String label, IconData icon) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.1),
          ),
        ),
        child: Column(
          children: [
            Icon(icon, color: Colors.white, size: 18),
            const SizedBox(height: 4),
            Text(
              value,
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 10,
                fontWeight: FontWeight.w400,
                color: Colors.white.withValues(alpha: 0.75),
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Tab bar
  // ---------------------------------------------------------------------------

  Widget _buildTabBar(bool isDark) {
    final trackColor =
        isDark ? const Color(0xFF1E293B) : const Color(0xFFEDE9FE);
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 4),
      child: Container(
        height: 48,
        decoration: BoxDecoration(
          color: trackColor,
          borderRadius: BorderRadius.circular(14),
        ),
        child: TabBar(
          controller: _tabController,
          dividerHeight: 0,
          indicatorSize: TabBarIndicatorSize.tab,
          indicator: BoxDecoration(
            gradient: const LinearGradient(colors: [_purple, _purpleDark]),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: _purple.withValues(alpha: 0.3),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          labelColor: Colors.white,
          unselectedLabelColor:
              isDark ? const Color(0xFF94A3B8) : const Color(0xFF7C3AED),
          labelStyle:
              GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w600),
          unselectedLabelStyle:
              GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w500),
          padding: const EdgeInsets.all(3),
          tabs: const [
            Tab(text: 'Hoje'),
            Tab(text: 'Criadas'),
            Tab(text: 'Catálogo'),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // FAB
  // ---------------------------------------------------------------------------

  Widget _buildFab() {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [_purple, _purpleDark]),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: _purple.withValues(alpha: 0.4),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: () => _showCreateMissionDialog(
            context,
            Theme.of(context).brightness == Brightness.dark,
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.add_rounded, color: Colors.white, size: 22),
                const SizedBox(width: 8),
                Text(
                  'Nova Missão',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
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
            child: _MissionCard(
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
            child: _MissionCard(
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
            child: _MissionCard(
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
    String selectedEmoji = '⭐';
    Color selectedColor = _purple;

    const emojis = [
      '⭐', '🎯', '📚', '🧹', '🍎', '💪', '🎨', '🎮', '🏃', '💰',
      '🎵', '🧠',
    ];
    const colors = [_purple, _blue, _green, _orange, _pink, _red];

    final cardBg = isDark ? const Color(0xFF1A1A2E) : Colors.white;
    final fieldBg = isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC);
    final titleColor = isDark ? Colors.white : const Color(0xFF0F172A);
    final labelColor =
        isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModal) {
          return Container(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(ctx).size.height * 0.88,
            ),
            padding: EdgeInsets.fromLTRB(
              24,
              16,
              24,
              MediaQuery.of(ctx).viewInsets.bottom + 24,
            ),
            decoration: BoxDecoration(
              color: cardBg,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(28),
              ),
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Handle
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      margin: const EdgeInsets.only(bottom: 20),
                      decoration: BoxDecoration(
                        color: isDark
                            ? const Color(0xFF334155)
                            : const Color(0xFFCBD5E1),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),

                  // Title
                  Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              selectedColor,
                              selectedColor.withValues(alpha: 0.7),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          selectedEmoji,
                          style: const TextStyle(fontSize: 20),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Nova Missão',
                          style: GoogleFonts.poppins(
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                            color: titleColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Emoji selector
                  _sectionLabel('Emoji', labelColor),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: emojis.map((e) {
                      final sel = e == selectedEmoji;
                      return GestureDetector(
                        onTap: () => setModal(() => selectedEmoji = e),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: sel
                                ? selectedColor.withValues(alpha: 0.15)
                                : fieldBg,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: sel
                                  ? selectedColor
                                  : Colors.transparent,
                              width: 2,
                            ),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            e,
                            style: const TextStyle(fontSize: 22),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 20),

                  // Color selector
                  _sectionLabel('Cor', labelColor),
                  const SizedBox(height: 8),
                  Row(
                    children: colors.map((c) {
                      final sel = c == selectedColor;
                      return Padding(
                        padding: const EdgeInsets.only(right: 10),
                        child: GestureDetector(
                          onTap: () => setModal(() => selectedColor = c),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: c,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color:
                                    sel ? Colors.white : Colors.transparent,
                                width: 3,
                              ),
                              boxShadow: sel
                                  ? [
                                      BoxShadow(
                                        color: c.withValues(alpha: 0.5),
                                        blurRadius: 10,
                                        spreadRadius: 1,
                                      ),
                                    ]
                                  : null,
                            ),
                            alignment: Alignment.center,
                            child: sel
                                ? const Icon(
                                    Icons.check_rounded,
                                    color: Colors.white,
                                    size: 20,
                                  )
                                : null,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 20),

                  // Title field
                  _sectionLabel('Título', labelColor),
                  const SizedBox(height: 6),
                  TextField(
                    controller: titleCtl,
                    style: GoogleFonts.poppins(color: titleColor),
                    decoration: _fieldDecor(
                      'Ex: Arrumar o quarto',
                      fieldBg,
                      isDark,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Description field
                  _sectionLabel('Descrição (opcional)', labelColor),
                  const SizedBox(height: 6),
                  TextField(
                    controller: descCtl,
                    style: GoogleFonts.poppins(color: titleColor),
                    maxLines: 2,
                    decoration: _fieldDecor(
                      'Detalhe o que precisa ser feito...',
                      fieldBg,
                      isDark,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Points field
                  _sectionLabel('Recompensa', labelColor),
                  const SizedBox(height: 6),
                  TextField(
                    controller: pointsCtl,
                    keyboardType: TextInputType.number,
                    style: GoogleFonts.poppins(color: titleColor),
                    decoration: _fieldDecor(
                      '50',
                      fieldBg,
                      isDark,
                    ).copyWith(
                      suffixText: 'pontos',
                      suffixStyle: GoogleFonts.poppins(
                        color: labelColor,
                        fontWeight: FontWeight.w500,
                      ),
                      prefixIcon: Icon(
                        Icons.star_rounded,
                        color: selectedColor,
                        size: 20,
                      ),
                    ),
                  ),
                  const SizedBox(height: 28),

                  // Create button
                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            selectedColor,
                            selectedColor.withValues(alpha: 0.8),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: selectedColor.withValues(alpha: 0.35),
                            blurRadius: 14,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(16),
                          onTap: () async {
                            if (titleCtl.text.trim().isEmpty) {
                              LummyFeedback.warning(
                                ctx,
                                'Dê um título para a missão.',
                              );
                              return;
                            }
                            await _createCustomMission(
                              titleCtl.text.trim(),
                              descCtl.text.trim(),
                              selectedEmoji,
                              int.tryParse(pointsCtl.text) ?? 50,
                              selectedColor,
                            );
                            if (ctx.mounted) Navigator.pop(ctx);
                          },
                          child: Center(
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.add_rounded,
                                  color: Colors.white,
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Criar Missão',
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
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _sectionLabel(String text, Color color) {
    return Text(
      text,
      style: GoogleFonts.poppins(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: color,
      ),
    );
  }

  InputDecoration _fieldDecor(String hint, Color fillColor, bool isDark) {
    return InputDecoration(
      hintText: hint,
      hintStyle: GoogleFonts.poppins(
        color: isDark ? const Color(0xFF475569) : const Color(0xFFCBD5E1),
        fontSize: 14,
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
        borderSide: const BorderSide(color: _purple, width: 2),
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
      debugPrint('Erro ao criar missão: $e');
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
      debugPrint('Erro ao deletar missão: $e');
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
      debugPrint('Erro ao atribuir missão: $e');
      if (mounted) LummyFeedback.error(context, 'Erro ao atribuir missão.');
    }
  }
}

// =============================================================================
// Mission Card (extracted for readability)
// =============================================================================

class _MissionCard extends StatelessWidget {
  final String title;
  final String description;
  final String emoji;
  final int points;
  final bool isCompleted;
  final Color color;
  final bool isDark;
  final String? badge;
  final Color? badgeColor;
  final String? actionLabel;
  final VoidCallback? onAction;
  final VoidCallback? onDelete;

  const _MissionCard({
    required this.title,
    required this.description,
    required this.emoji,
    required this.points,
    required this.isCompleted,
    required this.color,
    required this.isDark,
    this.badge,
    this.badgeColor,
    this.actionLabel,
    this.onAction,
    this.onDelete,
  });

  static const _green = Color(0xFF10B981);
  static const _red = Color(0xFFEF4444);

  @override
  Widget build(BuildContext context) {
    final cardBg = isDark ? const Color(0xFF1A1A2E) : Colors.white;
    final borderColor = isCompleted
        ? _green.withValues(alpha: 0.3)
        : (isDark ? const Color(0xFF2D2D2D) : color.withValues(alpha: 0.15));
    final titleColor = isDark ? Colors.white : const Color(0xFF0F172A);
    final subtitleColor =
        isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: borderColor, width: 1.5),
        boxShadow: [
          if (!isDark)
            BoxShadow(
              color: color.withValues(alpha: 0.06),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top row: emoji + title + badge
          Row(
            children: [
              // Emoji container with subtle gradient
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      color.withValues(alpha: 0.15),
                      color.withValues(alpha: 0.06),
                    ],
                  ),
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
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            title,
                            style: GoogleFonts.poppins(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: titleColor,
                              decoration: isCompleted
                                  ? TextDecoration.lineThrough
                                  : null,
                              decorationColor: _green,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (badge != null) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: (badgeColor ?? color)
                                  .withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              badge!,
                              style: GoogleFonts.poppins(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: badgeColor ?? color,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    if (description.isNotEmpty) ...[
                      const SizedBox(height: 3),
                      Text(
                        description,
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: subtitleColor,
                          height: 1.3,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Bottom row: points + status / actions
          Row(
            children: [
              // Points chip
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.star_rounded, color: color, size: 16),
                    const SizedBox(width: 4),
                    Text(
                      '+$points pts',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: color,
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),

              // Status / Action buttons
              if (isCompleted)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: _green.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.check_circle_rounded,
                        color: _green,
                        size: 16,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Concluída',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: _green,
                        ),
                      ),
                    ],
                  ),
                ),
              if (actionLabel != null && onAction != null)
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: onAction,
                    borderRadius: BorderRadius.circular(10),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 7,
                      ),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [color, color.withValues(alpha: 0.8)],
                        ),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        actionLabel!,
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              if (onDelete != null) ...[
                const SizedBox(width: 8),
                Material(
                  color: _red.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                  child: InkWell(
                    onTap: onDelete,
                    borderRadius: BorderRadius.circular(10),
                    child: const Padding(
                      padding: EdgeInsets.all(8),
                      child: Icon(
                        Icons.delete_outline_rounded,
                        color: _red,
                        size: 18,
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
