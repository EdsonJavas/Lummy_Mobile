import 'package:flutter/material.dart';

import 'package:lummy/shared/widgets/widgets.dart';
import 'package:lummy/core/theme/design_tokens.dart';

/// Bottom sheet content for creating an achievement.
///
/// The text controllers are owned by the caller; [onCreate] performs the
/// insert and the sheet closes itself afterwards.
class AchievementsCreateSheet extends StatefulWidget {
  final bool isDark;
  final TextEditingController nameController;
  final TextEditingController descriptionController;
  final TextEditingController pointsController;
  final Future<void> Function(
    String name,
    String description,
    String emoji,
    int pointsRequired,
    Color color,
  ) onCreate;

  const AchievementsCreateSheet({
    super.key,
    required this.isDark,
    required this.nameController,
    required this.descriptionController,
    required this.pointsController,
    required this.onCreate,
  });

  @override
  State<AchievementsCreateSheet> createState() =>
      _AchievementsCreateSheetState();
}

class _AchievementsCreateSheetState extends State<AchievementsCreateSheet> {
  static const _purple = LummyColors.violet500;
  static const _blue = LummyColors.blue500;
  static const _green = LummyColors.emerald500;
  static const _orange = LummyColors.amber500;
  static const _pink = LummyColors.pink500;
  static const _gold = LummyColors.amber600;

  String selectedEmoji = '🏆';
  Color selectedColor = _gold;

  @override
  Widget build(BuildContext context) {
    final isDark = widget.isDark;
    final nameController = widget.nameController;
    final descriptionController = widget.descriptionController;
    final pointsController = widget.pointsController;

    final emojis = ['🏆', '⭐', '🥇', '🎖️', '🏅', '💎', '👑', '🚀', '💪', '🎯'];
    final colors = [_gold, _orange, _purple, _blue, _green, _pink];

    return Container(
      padding: EdgeInsets.fromLTRB(
        20, 0, 20,
        MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      decoration: BoxDecoration(
        color: isDark ? LummyColors.slate800 : Colors.white,
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
                color: isDark ? LummyColors.slate600 : LummyColors.slate300,
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
                          style: LummyFonts.body(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          'Pré-visualização',
                          style: LummyFonts.body(
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
                    onTap: () => setState(() => selectedEmoji = emoji),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: 48, height: 48,
                      decoration: BoxDecoration(
                        gradient: isSelected
                            ? LinearGradient(colors: [selectedColor.withValues(alpha: 0.25), selectedColor.withValues(alpha: 0.1)])
                            : null,
                        color: isSelected
                            ? null
                            : (isDark ? LummyColors.slate900 : LummyColors.slate50),
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
                    onTap: () => setState(() => selectedColor = color),
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
              style: LummyFonts.body(
                color: isDark ? Colors.white : LummyColors.slate800,
              ),
              decoration: _achieveFieldDecor('Ex: Super Economista', isDark),
            ),
            const SizedBox(height: 12),
            _dialogSectionLabel('Descrição', isDark),
            const SizedBox(height: 8),
            TextField(
              controller: descriptionController,
              style: LummyFonts.body(
                color: isDark ? Colors.white : LummyColors.slate800,
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
              style: LummyFonts.body(
                color: isDark ? Colors.white : LummyColors.slate800,
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
                  await widget.onCreate(
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
          ],
        ),
      ),
    );
  }

  InputDecoration _achieveFieldDecor(String hint, bool isDark, {Widget? prefixIcon, String? suffixText}) {
    final fillColor = isDark ? LummyColors.slate900 : LummyColors.slate100;
    return InputDecoration(
      hintText: hint,
      hintStyle: LummyFonts.body(
        color: isDark ? LummyColors.slate600 : LummyColors.slate300,
        fontSize: 14,
      ),
      prefixIcon: prefixIcon,
      suffixText: suffixText,
      suffixStyle: LummyFonts.body(
        color: isDark ? LummyColors.slate500 : LummyColors.slate400,
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
          color: isDark ? LummyColors.darkSurfaceHigh : LummyColors.slate200,
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
        style: LummyFonts.body(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: isDark ? LummyColors.slate400 : LummyColors.slate500,
        ),
      ),
    );
  }
}
