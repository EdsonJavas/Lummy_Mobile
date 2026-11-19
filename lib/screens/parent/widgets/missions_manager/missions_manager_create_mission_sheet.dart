import 'package:flutter/material.dart';

import 'package:lummy/shared/widgets/widgets.dart';
import 'package:lummy/core/theme/design_tokens.dart';

/// Bottom sheet content for creating a custom mission.
///
/// The text controllers are owned by the caller; [onCreate] performs the
/// insert and the sheet closes itself afterwards.
class MissionsManagerCreateMissionSheet extends StatefulWidget {
  final bool isDark;
  final TextEditingController titleCtl;
  final TextEditingController descCtl;
  final TextEditingController pointsCtl;
  final Future<void> Function(
    String title,
    String description,
    String emoji,
    int points,
    Color color,
  ) onCreate;

  const MissionsManagerCreateMissionSheet({
    super.key,
    required this.isDark,
    required this.titleCtl,
    required this.descCtl,
    required this.pointsCtl,
    required this.onCreate,
  });

  @override
  State<MissionsManagerCreateMissionSheet> createState() =>
      _MissionsManagerCreateMissionSheetState();
}

class _MissionsManagerCreateMissionSheetState
    extends State<MissionsManagerCreateMissionSheet> {
  static const _purple = LummyColors.violet500;
  static const _blue = LummyColors.blue500;
  static const _green = LummyColors.emerald500;
  static const _orange = LummyColors.amber500;
  static const _red = LummyColors.red500;
  static const _pink = LummyColors.pink500;

  String selectedEmoji = '⭐';
  Color selectedColor = _purple;

  @override
  Widget build(BuildContext context) {
    final isDark = widget.isDark;
    final titleCtl = widget.titleCtl;
    final descCtl = widget.descCtl;
    final pointsCtl = widget.pointsCtl;

    const emojis = [
      '⭐', '🎯', '📚', '🧹', '🍎', '💪', '🎨', '🎮', '🏃', '💰',
      '🎵', '🧠',
    ];
    const colors = [_purple, _blue, _green, _orange, _pink, _red];

    final cardBg = isDark ? LummyColors.darkNavy : Colors.white;
    final fieldBg = isDark ? LummyColors.slate900 : LummyColors.slate50;
    final titleColor = isDark ? Colors.white : LummyColors.slate900;
    final labelColor =
        isDark ? LummyColors.slate400 : LummyColors.slate500;

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.88,
      ),
      padding: EdgeInsets.fromLTRB(
        24,
        16,
        24,
        MediaQuery.of(context).viewInsets.bottom + 24,
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
                      ? LummyColors.slate700
                      : LummyColors.slate300,
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
                    style: LummyFonts.body(
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
                  onTap: () => setState(() => selectedEmoji = e),
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
                    onTap: () => setState(() => selectedColor = c),
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
              style: LummyFonts.body(color: titleColor),
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
              style: LummyFonts.body(color: titleColor),
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
              style: LummyFonts.body(color: titleColor),
              decoration: _fieldDecor(
                '50',
                fieldBg,
                isDark,
              ).copyWith(
                suffixText: 'pontos',
                suffixStyle: LummyFonts.body(
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
                          context,
                          'Dê um título para a missão.',
                        );
                        return;
                      }
                      await widget.onCreate(
                        titleCtl.text.trim(),
                        descCtl.text.trim(),
                        selectedEmoji,
                        int.tryParse(pointsCtl.text) ?? 50,
                        selectedColor,
                      );
                      if (context.mounted) Navigator.pop(context);
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
                            style: LummyFonts.body(
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
  }

  Widget _sectionLabel(String text, Color color) {
    return Text(
      text,
      style: LummyFonts.body(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: color,
      ),
    );
  }

  InputDecoration _fieldDecor(String hint, Color fillColor, bool isDark) {
    return InputDecoration(
      hintText: hint,
      hintStyle: LummyFonts.body(
        color: isDark ? LummyColors.slate600 : LummyColors.slate300,
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
          color: isDark ? LummyColors.darkSurfaceHigh : LummyColors.slate200,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: _purple, width: 2),
      ),
    );
  }
}
