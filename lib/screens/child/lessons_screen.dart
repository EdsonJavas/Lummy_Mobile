import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:lummy_login/shared/widgets/widgets.dart';

class LessonItem {
  final String id;
  final String title;
  final String description;
  final String youtubeVideoId;
  final String duration;
  final bool watched;

  const LessonItem({
    required this.id,
    required this.title,
    required this.description,
    required this.youtubeVideoId,
    required this.duration,
    this.watched = false,
  });

  String get youtubeUrl => 'https://www.youtube.com/watch?v=$youtubeVideoId';
  String get thumbnailUrl => 'https://img.youtube.com/vi/$youtubeVideoId/mqdefault.jpg';
}

final List<LessonItem> _allLessons = [
  const LessonItem(
    id: '1',
    title: 'O que é dinheiro?',
    description: 'Aprenda de onde vem e para que serve o dinheiro no nosso dia a dia.',
    youtubeVideoId: 'CyFI8cN-KtY',
    duration: '5 min',
  ),
  const LessonItem(
    id: '2',
    title: 'Mesada e poupança',
    description: 'Descubra como guardar e planejar melhor com a sua mesada.',
    youtubeVideoId: 'fYP-3q22too',
    duration: '6 min',
  ),
  const LessonItem(
    id: '3',
    title: 'Diferença entre querer e precisar',
    description: 'Aprenda a decidir no que gastar de forma inteligente e consciente.',
    youtubeVideoId: 'MEmU-VGM62M',
    duration: '4 min',
  ),
  const LessonItem(
    id: '4',
    title: 'Como economizar para uma meta',
    description: 'Passo a passo para juntar dinheiro e realizar um sonho especial.',
    youtubeVideoId: '2lmVPBeVoWU',
    duration: '7 min',
  ),
  const LessonItem(
    id: '5',
    title: 'Gastar com consciência',
    description: 'Dicas para não gastar mais do que você tem e evitar surpresas.',
    youtubeVideoId: 'dirZ-28qnXg',
    duration: '5 min',
    watched: true,
  ),
  const LessonItem(
    id: '6',
    title: 'Juntando dinheiro com Leo',
    description: 'A história de um amigo que aprendeu a poupar desde cedo.',
    youtubeVideoId: 'l4WNrvVjiTw',
    duration: '8 min',
    watched: true,
  ),
];

const Color _accent = Color(0xFF8B5CF6);
const Color _accentDark = Color(0xFF7C3AED);
const Color _green = Color(0xFF10B981);

class LessonsScreen extends StatefulWidget {
  const LessonsScreen({super.key});

  @override
  State<LessonsScreen> createState() => _LessonsScreenState();
}

class _LessonsScreenState extends State<LessonsScreen> {
  final List<LessonItem> _lessons = List.from(_allLessons);
  final Set<String> _watchLater = {};

  List<LessonItem> get _unwatched => _lessons.where((l) => !l.watched).toList();
  List<LessonItem> get _watched => _lessons.where((l) => l.watched).toList();

  Future<void> _openVideo(String url) async {
    final uri = Uri.parse(url);
    try {
      final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (!launched && mounted) _showVideoError();
    } catch (_) {
      if (mounted) _showVideoError();
    }
  }

  void _showVideoError() {
    LummyFeedback.error(context, 'Não foi possível abrir o vídeo');
  }

  void _toggleWatchLater(String id) {
    setState(() {
      if (_watchLater.contains(id)) {
        _watchLater.remove(id);
        LummyFeedback.info(context, 'Removido de Assistir Depois');
      } else {
        _watchLater.add(id);
        LummyFeedback.success(context, 'Adicionado a Assistir Depois');
      }
    });
  }

  void _showMoreOptions(BuildContext ctx, LessonItem lesson, bool isDark) {
    showModalBottomSheet(
      context: ctx,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E293B) : Colors.white,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40, height: 4,
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF475569) : const Color(0xFFCBD5E1),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            _sheetOption(
              Icons.bookmark_add_outlined,
              _watchLater.contains(lesson.id) ? 'Remover de Assistir Depois' : 'Assistir Depois',
              isDark,
              () { Navigator.pop(ctx); _toggleWatchLater(lesson.id); },
            ),
            _sheetOption(
              Icons.share_outlined,
              'Compartilhar',
              isDark,
              () { Navigator.pop(ctx); LummyFeedback.info(context, 'Em breve!'); },
            ),
            _sheetOption(
              Icons.open_in_new_rounded,
              'Abrir no YouTube',
              isDark,
              () { Navigator.pop(ctx); _openVideo(lesson.youtubeUrl); },
            ),
            _sheetOption(
              Icons.info_outline_rounded,
              'Sobre esta aula',
              isDark,
              () {
                Navigator.pop(ctx);
                _showAbout(lesson, isDark);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _sheetOption(IconData icon, String label, bool isDark, VoidCallback onTap) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 4),
          child: Row(
            children: [
              Icon(icon, color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B), size: 22),
              const SizedBox(width: 16),
              Text(
                label,
                style: GoogleFonts.poppins(
                  fontSize: 15, fontWeight: FontWeight.w500,
                  color: isDark ? Colors.white : const Color(0xFF1E293B),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showAbout(LessonItem lesson, bool isDark) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(lesson.title, style: GoogleFonts.poppins(fontWeight: FontWeight.w600,
            color: isDark ? Colors.white : const Color(0xFF1E293B))),
        content: Text(lesson.description, style: GoogleFonts.poppins(fontSize: 14,
            color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B))),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Fechar', style: GoogleFonts.poppins(fontWeight: FontWeight.w600, color: _accent)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final topPadding = MediaQuery.of(context).padding.top;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverToBoxAdapter(child: _buildHero(isDark, topPadding)),
          const SliverToBoxAdapter(child: SizedBox(height: 8)),

          if (_unwatched.isNotEmpty) ...[
            _sectionTitle('Para você', isDark),
            _buildFeaturedCard(_unwatched.first, isDark),
            const SliverToBoxAdapter(child: SizedBox(height: 8)),
          ],

          if (_unwatched.length > 1) ...[
            _sectionTitle('Novas aulas', isDark),
            ..._unwatched.skip(1).toList().asMap().entries.map((e) =>
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                  child: _VideoCard(
                    lesson: e.value,
                    isDark: isDark,
                    isWatchLater: _watchLater.contains(e.value.id),
                    onTap: () => _openVideo(e.value.youtubeUrl),
                    onWatchLater: () => _toggleWatchLater(e.value.id),
                    onMore: () => _showMoreOptions(context, e.value, isDark),
                  ),
                ).animate()
                    .fadeIn(delay: (60 + e.key * 40).ms, duration: 280.ms)
                    .slideY(begin: 0.04, end: 0, curve: Curves.easeOutCubic),
              ),
            ),
          ],

          if (_watched.isNotEmpty) ...[
            _sectionTitle('Assistidas', isDark),
            ..._watched.asMap().entries.map((e) =>
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                  child: _VideoCard(
                    lesson: e.value,
                    isDark: isDark,
                    isWatched: true,
                    isWatchLater: _watchLater.contains(e.value.id),
                    onTap: () => _openVideo(e.value.youtubeUrl),
                    onWatchLater: () => _toggleWatchLater(e.value.id),
                    onMore: () => _showMoreOptions(context, e.value, isDark),
                  ),
                ).animate()
                    .fadeIn(delay: (60 + e.key * 40).ms, duration: 280.ms),
              ),
            ),
          ],

          _sectionTitle('Por tema', isDark),
          _buildThemesRow(isDark),
          const SliverToBoxAdapter(child: SizedBox(height: 32)),
        ],
      ),
    );
  }

  // ─────────── Hero ───────────

  Widget _buildHero(bool isDark, double topPadding) {
    return Container(
      padding: EdgeInsets.fromLTRB(20, topPadding + 16, 20, 28),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [const Color(0xFF5B21B6), _accentDark, const Color(0xFF6366F1)]
              : [_accent, _accentDark, const Color(0xFF6366F1)],
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(28),
          bottomRight: Radius.circular(28),
        ),
        boxShadow: [
          BoxShadow(
            color: _accentDark.withValues(alpha: 0.35),
            blurRadius: 20, offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(Icons.school_rounded, color: Colors.white, size: 28),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Aprender', style: GoogleFonts.poppins(
                      fontSize: 26, fontWeight: FontWeight.w800, color: Colors.white, letterSpacing: -0.5,
                    )),
                    const SizedBox(height: 2),
                    Text('Educação financeira para você', style: GoogleFonts.poppins(
                      fontSize: 13, fontWeight: FontWeight.w500, color: Colors.white.withValues(alpha: 0.85),
                    )),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              _heroChip(Icons.play_circle_outline_rounded, '${_unwatched.length} novas'),
              const SizedBox(width: 10),
              _heroChip(Icons.check_circle_outline_rounded, '${_watched.length} assistidas'),
              if (_watchLater.isNotEmpty) ...[
                const SizedBox(width: 10),
                _heroChip(Icons.bookmark_outline_rounded, '${_watchLater.length} salvas'),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _heroChip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 16),
          const SizedBox(width: 6),
          Text(label, style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.white)),
        ],
      ),
    );
  }

  // ─────────── Featured card (first unwatched) ───────────

  Widget _buildFeaturedCard(LessonItem lesson, bool isDark) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(20),
            onTap: () => _openVideo(lesson.youtubeUrl),
            child: Container(
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E293B) : Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: _accent.withValues(alpha: isDark ? 0.15 : 0.1)),
                boxShadow: [
                  BoxShadow(
                    color: _accent.withValues(alpha: isDark ? 0.08 : 0.06),
                    blurRadius: 16, offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Stack(
                    children: [
                      ClipRRect(
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(20), topRight: Radius.circular(20),
                        ),
                        child: Image.network(
                          lesson.thumbnailUrl,
                          width: double.infinity, height: 180,
                          fit: BoxFit.cover,
                      errorBuilder: (_, _, _) => Container(
                        width: double.infinity, height: 180,
                            color: isDark ? const Color(0xFF2D2D44) : const Color(0xFFE2E8F0),
                            child: Icon(Icons.play_circle_rounded, color: _accent.withValues(alpha: 0.4), size: 56),
                          ),
                        ),
                      ),
                      Positioned.fill(
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(20), topRight: Radius.circular(20),
                            ),
                            gradient: LinearGradient(
                              begin: Alignment.topCenter, end: Alignment.bottomCenter,
                              colors: [Colors.transparent, Colors.black.withValues(alpha: 0.6)],
                            ),
                          ),
                        ),
                      ),
                      Positioned(bottom: 12, left: 14, child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: _accent, borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(lesson.duration, style: GoogleFonts.poppins(
                          fontSize: 11, fontWeight: FontWeight.w600, color: Colors.white,
                        )),
                      )),
                      Positioned(top: 12, left: 14, child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(colors: [_accent, _accentDark]),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text('Em destaque', style: GoogleFonts.poppins(
                          fontSize: 10, fontWeight: FontWeight.w700, color: Colors.white,
                        )),
                      )),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                lesson.title,
                                style: GoogleFonts.poppins(
                                  fontSize: 16, fontWeight: FontWeight.w700,
                                  color: isDark ? Colors.white : const Color(0xFF1E293B),
                                ),
                                maxLines: 1, overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                lesson.description,
                                style: GoogleFonts.poppins(
                                  fontSize: 13, color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                                ),
                                maxLines: 1, overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        _actionButtons(lesson, isDark),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ).animate().fadeIn(duration: 320.ms).slideY(begin: 0.04, end: 0, curve: Curves.easeOutCubic),
    );
  }

  Widget _actionButtons(LessonItem lesson, bool isDark) {
    final isSaved = _watchLater.contains(lesson.id);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(8),
            onTap: () => _toggleWatchLater(lesson.id),
            child: Padding(
              padding: const EdgeInsets.all(6),
              child: Icon(
                isSaved ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
                size: 20,
                color: isSaved ? _accent : (isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8)),
              ),
            ),
          ),
        ),
        Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(8),
            onTap: () => _showMoreOptions(context, lesson, isDark),
            child: Padding(
              padding: const EdgeInsets.all(6),
              child: Icon(
                Icons.more_vert_rounded, size: 20,
                color: isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ─────────── Section title ───────────

  Widget _sectionTitle(String title, bool isDark) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 10),
        child: Text(
          title,
          style: GoogleFonts.poppins(
            fontSize: 18, fontWeight: FontWeight.w700,
            color: isDark ? Colors.white : const Color(0xFF1E293B),
          ),
        ),
      ),
    );
  }

  // ─────────── Themes row ───────────

  Widget _buildThemesRow(bool isDark) {
    final themes = [
      ('Dinheiro', Icons.payments_rounded, const Color(0xFF10B981)),
      ('Mesada', Icons.savings_rounded, const Color(0xFFF59E0B)),
      ('Metas', Icons.flag_rounded, _accent),
      ('Gastos', Icons.shopping_bag_rounded, const Color(0xFFEF4444)),
    ];
    return SliverToBoxAdapter(
      child: SizedBox(
        height: 90,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: themes.length,
          itemBuilder: (context, index) {
            final (label, icon, color) = themes[index];
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {},
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    width: 90,
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF1E293B) : Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: color.withValues(alpha: isDark ? 0.2 : 0.15)),
                      boxShadow: [
                        BoxShadow(
                          color: color.withValues(alpha: 0.06),
                          blurRadius: 8, offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(colors: [color.withValues(alpha: 0.2), color.withValues(alpha: 0.08)]),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(icon, color: color, size: 22),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          label,
                          style: GoogleFonts.poppins(
                            fontSize: 11, fontWeight: FontWeight.w600,
                            color: isDark ? const Color(0xFFCBD5E1) : const Color(0xFF334155),
                          ),
                          maxLines: 1, overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ).animate()
                .fadeIn(delay: (120 + index * 40).ms, duration: 260.ms)
                .scale(begin: const Offset(0.92, 0.92), end: const Offset(1, 1), curve: Curves.easeOut);
          },
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════
// Modern video card — no play button in the center
// ══════════════════════════════════════════════════════════════

class _VideoCard extends StatelessWidget {
  final LessonItem lesson;
  final bool isDark;
  final bool isWatched;
  final bool isWatchLater;
  final VoidCallback onTap;
  final VoidCallback onWatchLater;
  final VoidCallback onMore;

  const _VideoCard({
    required this.lesson,
    required this.isDark,
    this.isWatched = false,
    this.isWatchLater = false,
    required this.onTap,
    required this.onWatchLater,
    required this.onMore,
  });

  @override
  Widget build(BuildContext context) {
    final placeholderBg = isDark ? const Color(0xFF2D2D44) : const Color(0xFFE2E8F0);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E293B) : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isWatched
                  ? _green.withValues(alpha: isDark ? 0.15 : 0.1)
                  : (isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9)),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.08 : 0.04),
                blurRadius: 10, offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Thumbnail
              Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      lesson.thumbnailUrl,
                      width: 130, height: 80,
                      fit: BoxFit.cover,
                      errorBuilder: (_, _, _) => Container(
                        width: 130, height: 80,
                        decoration: BoxDecoration(
                          color: placeholderBg,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(Icons.play_circle_rounded, color: _accent.withValues(alpha: 0.3), size: 32),
                      ),
                    ),
                  ),
                  Positioned(bottom: 6, right: 6, child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.75),
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: Text(lesson.duration, style: GoogleFonts.poppins(
                      fontSize: 10, fontWeight: FontWeight.w600, color: Colors.white,
                    )),
                  )),
                  if (isWatched)
                    Positioned(top: 6, left: 6, child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                      decoration: BoxDecoration(
                        color: _green, borderRadius: BorderRadius.circular(5),
                      ),
                      child: const Icon(Icons.check_rounded, color: Colors.white, size: 10),
                    )),
                ],
              ),
              const SizedBox(width: 12),
              // Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      lesson.title,
                      style: GoogleFonts.poppins(
                        fontSize: 14, fontWeight: FontWeight.w600,
                        color: isDark ? Colors.white : const Color(0xFF1E293B),
                      ),
                      maxLines: 1, overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      lesson.description,
                      style: GoogleFonts.poppins(
                        fontSize: 12, color: isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8),
                      ),
                      maxLines: 2, overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Material(
                          color: Colors.transparent,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(6),
                            onTap: onWatchLater,
                            child: Padding(
                              padding: const EdgeInsets.only(right: 8, top: 2, bottom: 2),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    isWatchLater ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
                                    size: 15,
                                    color: isWatchLater ? _accent : (isDark ? const Color(0xFF475569) : const Color(0xFFCBD5E1)),
                                  ),
                                  const SizedBox(width: 3),
                                  Text(
                                    isWatchLater ? 'Salva' : 'Salvar',
                                    style: GoogleFonts.poppins(
                                      fontSize: 10, fontWeight: FontWeight.w600,
                                      color: isWatchLater ? _accent : (isDark ? const Color(0xFF475569) : const Color(0xFFCBD5E1)),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const Spacer(),
                        Material(
                          color: Colors.transparent,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(6),
                            onTap: onMore,
                            child: const Padding(
                              padding: EdgeInsets.all(2),
                              child: Icon(Icons.more_horiz_rounded, size: 18, color: Color(0xFF94A3B8)),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
