import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

/// Uma aula com link para vídeo no YouTube.
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

/// Vídeos infantis reais do YouTube (placeholders até os vídeos de educação financeira).
/// Thumbnails e links funcionam; tema infantil combina com a estética do app.
final List<LessonItem> _allLessons = [
  const LessonItem(
    id: '1',
    title: 'O que é dinheiro?',
    description: 'Aprenda de onde vem e para que serve o dinheiro.',
    youtubeVideoId: 'CyFI8cN-KtY', // Galinha Pintadinha - DVD 1
    duration: '5 min',
    watched: false,
  ),
  const LessonItem(
    id: '2',
    title: 'Mesada e poupança',
    description: 'Como guardar e planejar com a mesada.',
    youtubeVideoId: 'fYP-3q22too', // Super Simple Songs - If You're Happy + More
    duration: '6 min',
    watched: false,
  ),
  const LessonItem(
    id: '3',
    title: 'Diferença entre querer e precisar',
    description: 'Decidir no que gastar de forma inteligente.',
    youtubeVideoId: 'MEmU-VGM62M', // Turma da Mônica - episódios
    duration: '4 min',
    watched: false,
  ),
  const LessonItem(
    id: '4',
    title: 'Como economizar para uma meta',
    description: 'Passo a passo para juntar dinheiro e realizar um sonho.',
    youtubeVideoId: '2lmVPBeVoWU', // Super Simple Songs - Animal Songs
    duration: '7 min',
    watched: false,
  ),
  const LessonItem(
    id: '5',
    title: 'Gastar com consciência',
    description: 'Dicas para não gastar mais do que você tem.',
    youtubeVideoId: 'dirZ-28qnXg', // Turma da Mônica - Maratona Mônica
    duration: '5 min',
    watched: true,
  ),
  const LessonItem(
    id: '6',
    title: 'Juntando dinheiro com Leo',
    description: 'História de um amigo que aprendeu a poupar.',
    youtubeVideoId: 'l4WNrvVjiTw', // Super Simple Songs - If You're Happy
    duration: '8 min',
    watched: true,
  ),
];

/// Cor de destaque da tela de Aulas (roxo da paleta Lummy, não vermelho tipo YouTube).
const Color _kLessonsAccent = Color(0xFF8B5CF6);
const Color _kLessonsAccentDark = Color(0xFF7C3AED);

/// Tela de Aulas com layout inspirado no YouTube: uma única página
/// com seções bem definidas e conteúdo rico (horizontal scrolls, cards tipo thumbnail).
class LessonsScreen extends StatefulWidget {
  const LessonsScreen({super.key});

  @override
  State<LessonsScreen> createState() => _LessonsScreenState();
}

class _LessonsScreenState extends State<LessonsScreen> {
  final List<LessonItem> _lessons = List.from(_allLessons);

  List<LessonItem> get _unwatched => _lessons.where((l) => !l.watched).toList();
  List<LessonItem> get _watched => _lessons.where((l) => l.watched).toList();
  LessonItem? get _continueWatching =>
      _unwatched.isNotEmpty ? _unwatched.first : null;

  Future<void> _openVideo(String url) async {
    final uri = Uri.parse(url);
    try {
      // Tenta abrir direto (não usar canLaunchUrl — pode dar false indevidamente no Android)
      final launched = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );
      if (!launched && mounted) _showVideoError();
    } catch (_) {
      if (mounted) _showVideoError();
    }
  }

  void _showVideoError() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Não foi possível abrir o vídeo.', style: GoogleFonts.poppins(fontSize: 14)),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final topPadding = MediaQuery.of(context).padding.top;
    final isSmallScreen = MediaQuery.of(context).size.height < 700;
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(
              child: _buildLessonsHero(context, isSmallScreen, isDark, topPadding),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 24)),
            if (_continueWatching != null) ...[
              _sectionTitle('Continuar assistindo', theme),
              _buildContinueWatchingFullWidth(context, _continueWatching!, isDark),
            ],
            _sectionTitle('Novas aulas', theme),
            _horizontalLessons(
              context,
              _unwatched.where((l) => l.id != _continueWatching?.id).toList(),
              isDark: isDark,
            ),
            if (_watched.isNotEmpty) ...[
              _sectionTitle('Assistidas', theme),
              _horizontalLessons(
                context,
                _watched,
                showWatchedBadge: true,
                isDark: isDark,
              ),
            ],
            _sectionTitle('Por tema', theme),
            _buildThemesRow(theme, isDark),
            const SliverToBoxAdapter(child: SizedBox(height: 32)),
          ],
        ),
      ),
    );
  }

  Widget _buildLessonsHero(
    BuildContext context,
    bool isSmallScreen,
    bool isDark,
    double topPadding,
  ) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(20, topPadding + 12, 20, 28),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [
                  const Color(0xFF5B21B6),
                  const Color(0xFF7C3AED),
                  const Color(0xFF6366F1),
                ]
              : [
                  const Color(0xFF8B5CF6),
                  const Color(0xFF7C3AED),
                  const Color(0xFF6366F1),
                ],
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(28),
          bottomRight: Radius.circular(28),
        ),
        boxShadow: [
          BoxShadow(
            color: _kLessonsAccentDark.withValues(alpha: 0.35),
            blurRadius: 20,
            offset: const Offset(0, 10),
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
                child: const Icon(
                  Icons.video_library_rounded,
                  color: Colors.white,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Aulas',
                      style: GoogleFonts.poppins(
                        fontSize: isSmallScreen ? 24 : 28,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Educação financeira para você',
                      style: GoogleFonts.poppins(
                        fontSize: isSmallScreen ? 13 : 15,
                        fontWeight: FontWeight.w500,
                        color: Colors.white.withValues(alpha: 0.9),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              _buildHeroStatChip(
                Icons.play_circle_outline_rounded,
                '${_unwatched.length} novas',
                isSmallScreen,
              ),
              const SizedBox(width: 10),
              _buildHeroStatChip(
                Icons.check_circle_outline_rounded,
                '${_watched.length} assistidas',
                isSmallScreen,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHeroStatChip(IconData icon, String label, bool isSmallScreen) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.22),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.35),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: isSmallScreen ? 16 : 18),
          const SizedBox(width: 6),
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: isSmallScreen ? 11 : 12,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContinueWatchingFullWidth(
    BuildContext context,
    LessonItem lesson,
    bool isDark,
  ) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: _LessonThumbnailCard(
          lesson: lesson,
          onTap: () => _openVideo(lesson.youtubeUrl),
          isContinueWatching: true,
          showWatchedBadge: false,
          isDark: isDark,
          fullWidth: true,
        ),
      )
          .animate()
          .fadeIn(duration: 320.ms)
          .slideY(begin: 0.05, end: 0, curve: Curves.easeOutCubic),
    );
  }

  Widget _sectionTitle(String title, ThemeData theme) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 24, 16, 12),
        child: Row(
          children: [
            Text(
              title,
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: theme.textTheme.titleLarge?.color ?? theme.colorScheme.onSurface,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _horizontalLessons(
    BuildContext context,
    List<LessonItem> items, {
    bool isContinueWatching = false,
    bool showWatchedBadge = false,
    bool isDark = false,
  }) {
    final theme = Theme.of(context);
    if (items.isEmpty) {
      return SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
          child: Text(
            isContinueWatching ? 'Nada em andamento' : 'Nenhuma aula aqui',
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.6),
            ),
          ),
        ),
      );
    }

    return SliverToBoxAdapter(
      child: SizedBox(
        height: isContinueWatching ? 200 : 188,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          itemCount: items.length,
          itemBuilder: (context, index) {
            final lesson = items[index];
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: _LessonThumbnailCard(
                lesson: lesson,
                onTap: () => _openVideo(lesson.youtubeUrl),
                isContinueWatching: isContinueWatching && index == 0,
                showWatchedBadge: showWatchedBadge,
                isDark: isDark,
              ),
            )
                .animate()
                .fadeIn(delay: (80 + index * 50).ms, duration: 280.ms)
                .slideX(begin: 0.08, end: 0, curve: Curves.easeOutCubic);
          },
        ),
      ),
    );
  }

  Widget _buildThemesRow(ThemeData theme, bool isDark) {
    final surface = theme.cardTheme.color ?? theme.colorScheme.surface;
    final fg = theme.textTheme.titleMedium?.color ?? theme.colorScheme.onSurface;
    final themes = [
      ('Dinheiro', Icons.payments_rounded),
      ('Mesada', Icons.savings_rounded),
      ('Metas', Icons.flag_rounded),
      ('Gastos', Icons.shopping_bag_rounded),
    ];
    return SliverToBoxAdapter(
      child: SizedBox(
        height: 100,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          itemCount: themes.length,
          itemBuilder: (context, index) {
            final (label, icon) = themes[index];
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {},
                  borderRadius: BorderRadius.circular(16),
                  splashColor: _kLessonsAccent.withValues(alpha: 0.2),
                  highlightColor: _kLessonsAccent.withValues(alpha: 0.1),
                  child: Container(
                    width: 100,
                    decoration: BoxDecoration(
                      color: surface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: _kLessonsAccent.withValues(alpha: isDark ? 0.2 : 0.4),
                        width: isDark ? 1 : 1.5,
                      ),
                      boxShadow: isDark
                          ? null
                          : [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.06),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(icon, color: _kLessonsAccent, size: 28),
                        const SizedBox(height: 8),
                        Text(
                          label,
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: fg,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            )
                .animate()
                .fadeIn(delay: (120 + index * 40).ms, duration: 260.ms)
                .scale(begin: const Offset(0.92, 0.92), end: const Offset(1, 1), curve: Curves.easeOut);
          },
        ),
      ),
    );
  }
}

class _LessonThumbnailCard extends StatelessWidget {
  final LessonItem lesson;
  final VoidCallback onTap;
  final bool isContinueWatching;
  final bool showWatchedBadge;
  final bool isDark;
  final bool fullWidth;

  const _LessonThumbnailCard({
    required this.lesson,
    required this.onTap,
    this.isContinueWatching = false,
    this.showWatchedBadge = false,
    this.isDark = false,
    this.fullWidth = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // fullWidth: usa a largura que o pai der (evita RenderErrorBox por restrições)
    final cardWidth = fullWidth
        ? null
        : (isContinueWatching ? 320.0 : 160.0);
    final titleColor = theme.textTheme.titleMedium?.color ?? theme.colorScheme.onSurface;
    final subColor = theme.textTheme.bodySmall?.color ?? theme.colorScheme.onSurfaceVariant;
    final placeholderBg = isDark ? const Color(0xFF2D2D44) : const Color(0xFFE2E8F0);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        splashColor: _kLessonsAccent.withValues(alpha: 0.25),
        highlightColor: _kLessonsAccent.withValues(alpha: 0.12),
        child: Container(
          width: cardWidth ?? double.infinity,
          decoration: isDark
              ? null
              : BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: const Color(0xFFCBD5E1),
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.08),
                      blurRadius: 12,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
          child: SizedBox(
            width: cardWidth ?? double.infinity,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Stack(
                alignment: Alignment.center,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      lesson.thumbnailUrl,
                      width: cardWidth ?? double.infinity,
                      height: fullWidth ? 180 : (isContinueWatching ? 120 : 94),
                      fit: BoxFit.cover,
                      errorBuilder: (_, _, _) => Container(
                        width: cardWidth ?? double.infinity,
                        height: fullWidth ? 180 : (isContinueWatching ? 120 : 94),
                        color: placeholderBg,
                        child: Icon(
                          Icons.videocam_rounded,
                          color: _kLessonsAccent.withValues(alpha: 0.6),
                          size: 48,
                        ),
                      ),
                    ),
                  ),
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.black.withValues(alpha: 0.5),
                          ],
                        ),
                      ),
                    ),
                  ),
                  // Player centralizado (ícone outline)
                  Center(
                    child: Icon(
                      Icons.play_circle_outline_rounded,
                      color: _kLessonsAccent,
                      size: fullWidth || isContinueWatching ? 72 : 56,
                    ),
                  ),
                  Positioned(
                    bottom: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.75),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        lesson.duration,
                        style: GoogleFonts.poppins(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  if (showWatchedBadge)
                    Positioned(
                      top: 8,
                      left: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFF22C55E),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.check_circle_outline_rounded, color: Colors.white, size: 12),
                            const SizedBox(width: 4),
                            Text(
                              'Assistida',
                              style: GoogleFonts.poppins(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  if (isContinueWatching)
                    Positioned(
                      left: 0,
                      right: 0,
                      bottom: 0,
                      child: ClipRRect(
                        borderRadius: const BorderRadius.only(
                          bottomLeft: Radius.circular(12),
                          bottomRight: Radius.circular(12),
                        ),
                        child: LinearProgressIndicator(
                          value: 0.6,
                          minHeight: 4,
                          backgroundColor: Colors.white.withValues(alpha: 0.2),
                          valueColor: const AlwaysStoppedAnimation<Color>(_kLessonsAccent),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Text(
                  lesson.title,
                  style: GoogleFonts.poppins(
                    fontSize: isContinueWatching ? 15 : 13,
                    fontWeight: FontWeight.w600,
                    color: titleColor,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (isContinueWatching) ...[
                const SizedBox(height: 4),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Text(
                    'Continuar assistindo',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: subColor,
                    ),
                  ),
                ),
              ],
            ],
          ),  // Column
        ),    // SizedBox
        ),    // Container
      ),      // InkWell
    );        // Material
  }
}
