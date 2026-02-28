import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import 'core/constants/app_constants.dart';

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
}

/// Lista de aulas com vídeos genéricos do YouTube (educação financeira).
final List<LessonItem> _allLessons = [
  const LessonItem(
    id: '1',
    title: 'O que é dinheiro?',
    description: 'Aprenda de onde vem e para que serve o dinheiro.',
    youtubeVideoId: 'xG0XBHsdBZU',
    duration: '5 min',
    watched: false,
  ),
  const LessonItem(
    id: '2',
    title: 'Mesada e poupança',
    description: 'Como guardar e planejar com a mesada.',
    youtubeVideoId: '2VZ3ri_ebc0',
    duration: '6 min',
    watched: false,
  ),
  const LessonItem(
    id: '3',
    title: 'Diferença entre querer e precisar',
    description: 'Decidir no que gastar de forma inteligente.',
    youtubeVideoId: '5p4qM6n8r2s',
    duration: '4 min',
    watched: false,
  ),
  const LessonItem(
    id: '4',
    title: 'Como economizar para uma meta',
    description: 'Passo a passo para juntar dinheiro e realizar um sonho.',
    youtubeVideoId: '7YyX5z9K2pQ',
    duration: '7 min',
    watched: false,
  ),
  const LessonItem(
    id: '5',
    title: 'Gastar com consciência',
    description: 'Dicas para não gastar mais do que você tem.',
    youtubeVideoId: '9VqRohP1YcE',
    duration: '5 min',
    watched: true,
  ),
  const LessonItem(
    id: '6',
    title: 'Juntando dinheiro com Leo',
    description: 'História de um amigo que aprendeu a poupar.',
    youtubeVideoId: 'AbC1DeF2GhI',
    duration: '8 min',
    watched: true,
  ),
];

class LessonsScreen extends StatefulWidget {
  const LessonsScreen({super.key});

  @override
  State<LessonsScreen> createState() => _LessonsScreenState();
}

class _LessonsScreenState extends State<LessonsScreen> {
  bool _showWatchedLessons = false;
  final List<LessonItem> _lessons = List.from(_allLessons);

  List<LessonItem> get _filteredLessons => _showWatchedLessons
      ? _lessons.where((l) => l.watched).toList()
      : _lessons.where((l) => !l.watched).toList();

  LessonItem? get _continueWatching =>
      _lessons.where((l) => !l.watched).isNotEmpty ? _lessons.firstWhere((l) => !l.watched) : null;

  Future<void> _openYouTubeVideo(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Não foi possível abrir o vídeo.',
              style: GoogleFonts.poppins(fontSize: 14),
            ),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      body: Stack(
        children: [
          // Header com imagem de fundo (como era antes)
          Container(
            height: MediaQuery.of(context).size.height * 0.34,
            width: double.infinity,
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: NetworkImage(
                  'https://hebbkx1anhila5yf.public.blob.vercel-storage.com/4DB5FF%20FFA42E%2077D88F%20FF8FC2%20BBA8F9%20FEE440%20%281%29%201-6GbuJScbV9th96qhg9CZLt9VZ4YLhW.png',
                ),
                fit: BoxFit.cover,
              ),
            ),
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(0.20),
                    Colors.black.withOpacity(0.35),
                  ],
                ),
              ),
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 8),
                      const Text(
                        'Aulas',
                        style: TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Aprenda brincando e acompanhe seu progresso',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.white.withOpacity(0.9),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: _SegmentButton(
                              label: 'Novas Aulas',
                              selected: !_showWatchedLessons,
                              onTap: () => setState(() => _showWatchedLessons = false),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _SegmentButton(
                              label: 'Aulas Assistidas',
                              selected: _showWatchedLessons,
                              onTap: () => setState(() => _showWatchedLessons = true),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          DraggableScrollableSheet(
            initialChildSize: 0.65,
            minChildSize: 0.65,
            maxChildSize: 0.95,
            builder: (context, scrollController) {
              return Container(
                decoration: BoxDecoration(
                  color: theme.scaffoldBackgroundColor,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
                  ),
                ),
                child: Column(
                  children: [
                    Container(
                      margin: const EdgeInsets.only(top: 12),
                      height: 4,
                      width: 40,
                      decoration: BoxDecoration(
                        color: theme.dividerColor,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    Expanded(
                      child: ListView(
                        controller: scrollController,
                        padding: const EdgeInsets.all(20),
                        children: [
                          if (!_showWatchedLessons && _continueWatching != null)
                            _ContinueWatchingCard(
                              lesson: _continueWatching!,
                              onTap: () => _openYouTubeVideo(_continueWatching!.youtubeUrl),
                              isDark: isDark,
                            ),
                          if (!_showWatchedLessons && _continueWatching != null)
                            const SizedBox(height: 20),
                          ..._filteredLessons
                              .where((l) => l.id != _continueWatching?.id)
                              .map(
                                (lesson) => Padding(
                                  padding: const EdgeInsets.only(bottom: 16),
                                  child: _LessonCard(
                                    lesson: lesson,
                                    onTap: () => _openYouTubeVideo(lesson.youtubeUrl),
                                    isDark: isDark,
                                    showWatched: _showWatchedLessons,
                                  ),
                                ),
                              ),
                          if (_filteredLessons.isEmpty)
                            Padding(
                              padding: const EdgeInsets.only(top: 40),
                              child: Center(
                                child: Column(
                                  children: [
                                    Icon(
                                      Icons.play_circle_outline_rounded,
                                      size: 64,
                                      color: theme.disabledColor,
                                    ),
                                    const SizedBox(height: 16),
                                    Text(
                                      _showWatchedLessons
                                          ? 'Nenhuma aula assistida ainda'
                                          : 'Nenhuma aula nova no momento',
                                      style: GoogleFonts.poppins(
                                        fontSize: 16,
                                        color: theme.textTheme.bodyMedium?.color,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _SegmentButton extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _SegmentButton({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onTap,
      style: ElevatedButton.styleFrom(
        backgroundColor: selected ? const Color(0xFF62C370) : Colors.white.withOpacity(0.28),
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(25),
        ),
        elevation: 0,
      ),
      child: Text(
        label,
        style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600),
      ),
    );
  }
}

class _ContinueWatchingCard extends StatelessWidget {
  final LessonItem lesson;
  final VoidCallback onTap;
  final bool isDark;

  const _ContinueWatchingCard({
    required this.lesson,
    required this.onTap,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppConstants.radiusLarge),
        child: Container(
          padding: const EdgeInsets.all(AppConstants.spacingMedium),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF4A90E2),
                Color(0xFF10B981),
              ],
            ),
            borderRadius: BorderRadius.circular(AppConstants.radiusLarge),
            boxShadow: [
              BoxShadow(
                color: const Color(AppConstants.primaryBlue).withValues(alpha: 0.35),
                blurRadius: 16,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
                child: Container(
                  width: 110,
                  height: 84,
                  color: Colors.black.withValues(alpha: 0.25),
                  child: const Center(
                    child: Icon(Icons.play_circle_fill, color: Colors.white, size: 40),
                  ),
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
                            'Continue assistindo',
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(
                            '60%',
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      lesson.title,
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      height: 6,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(3),
                        child: LinearProgressIndicator(
                          value: 0.6,
                          backgroundColor: Colors.white.withValues(alpha: 0.25),
                          valueColor: const AlwaysStoppedAnimation<Color>(Color(AppConstants.accentOrange)),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        FilledButton.tonal(
                          onPressed: onTap,
                          style: FilledButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: const Color(AppConstants.textPrimary),
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                            minimumSize: const Size(0, 0),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: Text('Continuar', style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 13)),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Vídeo • ${lesson.duration}',
                          style: GoogleFonts.poppins(
                            color: Colors.white.withValues(alpha: 0.9),
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
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

class _LessonCard extends StatelessWidget {
  final LessonItem lesson;
  final VoidCallback onTap;
  final bool isDark;
  final bool showWatched;

  const _LessonCard({
    required this.lesson,
    required this.onTap,
    required this.isDark,
    required this.showWatched,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cardColor = theme.cardTheme.color ?? theme.colorScheme.surface;
    final borderColor = theme.dividerColor;
    final titleColor = showWatched
        ? (theme.textTheme.titleLarge?.color ?? theme.colorScheme.onSurface)
        : Colors.white;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppConstants.radiusLarge),
        child: Container(
          padding: const EdgeInsets.all(AppConstants.spacingMedium),
          decoration: BoxDecoration(
            gradient: showWatched
                ? null
                : const LinearGradient(
                    colors: [
                      Color(0xFF60A5FA),
                      Color(0xFF8B5CF6),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
            color: showWatched ? cardColor : null,
            borderRadius: BorderRadius.circular(AppConstants.radiusLarge),
            border: showWatched ? Border.all(color: borderColor, width: 1) : null,
            boxShadow: showWatched
                ? [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.06),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : null,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            lesson.title,
                            style: GoogleFonts.poppins(
                              color: titleColor,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (showWatched)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: const Color(AppConstants.successGreen).withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(999),
                              border: Border.all(
                                color: const Color(AppConstants.successGreen).withValues(alpha: 0.35),
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.check_circle, size: 12, color: Color(AppConstants.successGreen)),
                                const SizedBox(width: 4),
                                Text(
                                  'Assistida',
                                  style: GoogleFonts.poppins(
                                    color: const Color(AppConstants.successGreen),
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      lesson.description,
                      style: GoogleFonts.poppins(
                        color: showWatched
                            ? (theme.textTheme.bodyMedium?.color ?? theme.colorScheme.onSurfaceVariant)
                            : Colors.white.withValues(alpha: 0.9),
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
                child: Container(
                  width: 100,
                  height: 76,
                  color: isDark ? Colors.white.withValues(alpha: 0.1) : Colors.black.withValues(alpha: 0.2),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      const Icon(Icons.play_circle_fill, color: Colors.white, size: 36),
                      Positioned(
                        bottom: 6,
                        right: 6,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: showWatched
                                ? const Color(AppConstants.successGreen)
                                : const Color(AppConstants.primaryBlue),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            showWatched ? 'Assistida' : 'Novo',
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
