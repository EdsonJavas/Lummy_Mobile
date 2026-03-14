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

class _ChildMissionsManagerScreenState extends State<ChildMissionsManagerScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  List<Map<String, dynamic>> _allMissions = [];
  List<Map<String, dynamic>> _childDailyMissions = [];
  List<Map<String, dynamic>> _customMissions = [];
  bool _isLoading = true;

  // Cores
  static const _purple = Color(0xFF8B5CF6);
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

      // Carregar todas as missões disponíveis
      final allMissionsData = await supabase
          .from('missions')
          .select('*')
          .eq('is_active', true)
          .order('created_at');

      _allMissions = List<Map<String, dynamic>>.from(allMissionsData);

      // Carregar missões diárias do filho
      final dailyMissionsData = await supabase
          .from('daily_missions')
          .select('*, missions(*)')
          .eq('child_id', widget.child.id)
          .eq('selected_date', today);

      _childDailyMissions = List<Map<String, dynamic>>.from(dailyMissionsData);

      // Carregar missões personalizadas criadas pelo responsável
      final customMissionsData = await supabase
          .from('custom_missions')
          .select('*')
          .eq('child_id', widget.child.id)
          .order('created_at', ascending: false);

      _customMissions = List<Map<String, dynamic>>.from(customMissionsData);
    } catch (e) {
      debugPrint('Erro ao carregar missões: $e');
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
      body: Column(
        children: [
          // Header
          _buildHeader(context, isDark, topPadding),
          // Tab Bar
          _buildTabBar(isDark),
          // Content
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
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showCreateMissionDialog(context, isDark),
        backgroundColor: _purple,
        icon: const Icon(Icons.add_rounded, color: Colors.white),
        label: Text(
          'Nova Missão',
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
                  _purple.withOpacity(0.3),
                ]
              : [_purple, _purple.withOpacity(0.85), const Color(0xFF7C3AED)],
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
                      'Missões',
                      style: GoogleFonts.poppins(
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      'Gerenciar missões de ${widget.child.name}',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: Colors.white.withOpacity(0.8),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          // Stats
          Row(
            children: [
              _buildStatChip(
                '${_childDailyMissions.where((m) => m['is_completed'] == true).length}/${_childDailyMissions.length}',
                'Hoje',
                Icons.today_rounded,
              ),
              const SizedBox(width: 12),
              _buildStatChip(
                '${_customMissions.length}',
                'Personalizadas',
                Icons.star_rounded,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatChip(String value, String label, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 18),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
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
                  fontSize: 11,
                  color: Colors.white.withOpacity(0.8),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar(bool isDark) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0),
          borderRadius: BorderRadius.circular(14),
        ),
        child: TabBar(
          controller: _tabController,
          indicator: BoxDecoration(
            gradient: const LinearGradient(
              colors: [_purple, Color(0xFF7C3AED)],
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          labelColor: Colors.white,
          unselectedLabelColor: isDark
              ? const Color(0xFF94A3B8)
              : const Color(0xFF64748B),
          labelStyle: GoogleFonts.poppins(
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
          unselectedLabelStyle: GoogleFonts.poppins(
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
          tabs: const [
            Tab(text: 'Hoje'),
            Tab(text: 'Personalizadas'),
            Tab(text: 'Todas'),
          ],
        ),
      ),
    );
  }

  Widget _buildDailyMissionsTab(bool isDark) {
    if (_childDailyMissions.isEmpty) {
      return _buildEmptyState(
        'Nenhuma missão hoje',
        'As missões diárias aparecerão aqui.',
        Icons.assignment_outlined,
        isDark,
      );
    }

    return BrandedRefreshIndicator(
      onRefresh: _loadMissions,
      color: _purple,
      child: ListView.builder(
        padding: const EdgeInsets.all(20),
        physics: const AlwaysScrollableScrollPhysics(
          parent: BouncingScrollPhysics(),
        ),
        itemCount: _childDailyMissions.length,
        itemBuilder: (context, index) {
          final mission = _childDailyMissions[index];
          final missionData = mission['missions'] as Map<String, dynamic>?;
          final isCompleted = mission['is_completed'] == true;

          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _buildMissionCard(
              missionData?['title'] ?? 'Missão',
              missionData?['description'] ?? '',
              missionData?['emoji'] ?? '🎯',
              missionData?['points'] ?? 0,
              isCompleted,
              _hexToColor(missionData?['color_hex'] ?? '#8B5CF6'),
              isDark,
            ),
          );
        },
      ),
    );
  }

  Widget _buildCustomMissionsTab(bool isDark) {
    if (_customMissions.isEmpty) {
      return _buildEmptyState(
        'Nenhuma missão personalizada',
        'Crie missões especiais para ${widget.child.name}!',
        Icons.star_outline_rounded,
        isDark,
      );
    }

    return BrandedRefreshIndicator(
      onRefresh: _loadMissions,
      color: _purple,
      child: ListView.builder(
        padding: const EdgeInsets.all(20),
        physics: const AlwaysScrollableScrollPhysics(
          parent: BouncingScrollPhysics(),
        ),
        itemCount: _customMissions.length,
        itemBuilder: (context, index) {
          final mission = _customMissions[index];
          final isCompleted = mission['is_completed'] == true;

          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _buildMissionCard(
              mission['title'] ?? 'Missão',
              mission['description'] ?? '',
              mission['emoji'] ?? '⭐',
              mission['reward_points'] ?? 0,
              isCompleted,
              _hexToColor(mission['color_hex'] ?? '#F59E0B'),
              isDark,
              isCustom: true,
              onDelete: () => _deleteCustomMission(mission['id']),
            ),
          );
        },
      ),
    );
  }

  Widget _buildAllMissionsTab(bool isDark) {
    if (_allMissions.isEmpty) {
      return _buildEmptyState(
        'Nenhuma missão disponível',
        'Missões do sistema aparecerão aqui.',
        Icons.list_alt_rounded,
        isDark,
      );
    }

    return BrandedRefreshIndicator(
      onRefresh: _loadMissions,
      color: _purple,
      child: ListView.builder(
        padding: const EdgeInsets.all(20),
        physics: const AlwaysScrollableScrollPhysics(
          parent: BouncingScrollPhysics(),
        ),
        itemCount: _allMissions.length,
        itemBuilder: (context, index) {
          final mission = _allMissions[index];

          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _buildMissionCard(
              mission['title'] ?? 'Missão',
              mission['description'] ?? '',
              mission['emoji'] ?? '🎯',
              mission['points'] ?? 0,
              false,
              _hexToColor(mission['color_hex'] ?? '#3B82F6'),
              isDark,
              showAssignButton: true,
              onAssign: () => _assignMission(mission),
            ),
          );
        },
      ),
    );
  }

  Widget _buildMissionCard(
    String title,
    String description,
    String emoji,
    int points,
    bool isCompleted,
    Color color,
    bool isDark, {
    bool isCustom = false,
    bool showAssignButton = false,
    VoidCallback? onDelete,
    VoidCallback? onAssign,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isCompleted
              ? _green.withOpacity(0.3)
              : color.withOpacity(isDark ? 0.3 : 0.15),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Center(
                  child: Text(emoji, style: const TextStyle(fontSize: 26)),
                ),
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
                              color: isDark
                                  ? Colors.white
                                  : const Color(0xFF1E293B),
                              decoration: isCompleted
                                  ? TextDecoration.lineThrough
                                  : null,
                            ),
                          ),
                        ),
                        if (isCustom)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: _orange.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              'Personalizada',
                              style: GoogleFonts.poppins(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: _orange,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: isDark
                            ? const Color(0xFF94A3B8)
                            : const Color(0xFF64748B),
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.star_rounded,
                      color: Colors.amber,
                      size: 16,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '+$points pts',
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: color,
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              if (isCompleted)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: _green.withOpacity(0.15),
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
              if (showAssignButton && onAssign != null)
                GestureDetector(
                  onTap: onAssign,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [color, color.withOpacity(0.8)],
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      'Atribuir',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              if (isCustom && onDelete != null)
                GestureDetector(
                  onTap: onDelete,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: _red.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.delete_outline_rounded,
                      color: _red,
                      size: 20,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(
    String title,
    String subtitle,
    IconData icon,
    bool isDark,
  ) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: _purple.withOpacity(0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 48, color: _purple),
            ),
            const SizedBox(height: 20),
            Text(
              title,
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white : const Color(0xFF1E293B),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
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

  void _showCreateMissionDialog(BuildContext context, bool isDark) {
    final titleController = TextEditingController();
    final descriptionController = TextEditingController();
    final pointsController = TextEditingController(text: '50');
    String selectedEmoji = '⭐';
    Color selectedColor = _purple;

    final emojis = ['⭐', '🎯', '📚', '🧹', '🍎', '💪', '🎨', '🎮', '🏃', '💰'];
    final colors = [_purple, _blue, _green, _orange, _pink, _red];

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
                  'Criar Missão Personalizada',
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
                  controller: titleController,
                  style: GoogleFonts.poppins(
                    color: isDark ? Colors.white : const Color(0xFF1E293B),
                  ),
                  decoration: InputDecoration(
                    labelText: 'Título da Missão',
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
                    labelText: 'Pontos de Recompensa',
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
                      if (titleController.text.isNotEmpty) {
                        await _createCustomMission(
                          titleController.text,
                          descriptionController.text,
                          selectedEmoji,
                          int.tryParse(pointsController.text) ?? 50,
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
                      'Criar Missão',
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
          '#${color.value.toRadixString(16).substring(2).toUpperCase()}';

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

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Missão criada com sucesso!',
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
      debugPrint('Erro ao criar missão: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Erro ao criar missão: $e',
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

  Future<void> _deleteCustomMission(String missionId) async {
    try {
      final supabase = Supabase.instance.client;
      await supabase.from('custom_missions').delete().eq('id', missionId);
      _loadMissions();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Missão removida!', style: GoogleFonts.poppins()),
            backgroundColor: _orange,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
        );
      }
    } catch (e) {
      debugPrint('Erro ao deletar missão: $e');
    }
  }

  Future<void> _assignMission(Map<String, dynamic> mission) async {
    try {
      final supabase = Supabase.instance.client;
      final today = DateTime.now().toIso8601String().split('T')[0];

      // Verificar se a missão já foi atribuída hoje
      final existing = await supabase
          .from('daily_missions')
          .select('id')
          .eq('child_id', widget.child.id)
          .eq('mission_id', mission['id'])
          .eq('selected_date', today)
          .maybeSingle();

      if (existing != null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Esta missão já foi atribuída hoje!',
                style: GoogleFonts.poppins(),
              ),
              backgroundColor: _orange,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
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

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Missão atribuída com sucesso!',
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
      debugPrint('Erro ao atribuir missão: $e');
    }
  }
}
