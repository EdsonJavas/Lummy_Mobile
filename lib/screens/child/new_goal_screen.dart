import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lummy_login/shared/widgets/money_text_field.dart';
import 'package:lummy_login/shared/widgets/widgets.dart';

class NewGoalScreen extends StatefulWidget {
  const NewGoalScreen({super.key});

  @override
  State<NewGoalScreen> createState() => _NewGoalScreenState();
}

class _NewGoalScreenState extends State<NewGoalScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _amountController = TextEditingController();
  double? _currentAmount;
  String _selectedEmoji = '🚲';

  static const _purple = Color(0xFF8B5CF6);
  static const _purpleDark = Color(0xFF6D28D9);
  // ignore: unused_field
  static const _green = Color(0xFF10B981);

  final List<String> _goalEmojis = [
    '🚲', '🎮', '📱', '👟', '🎸', '📚', '🏀', '🎨',
    '🧸', '🎯', '💻', '🎧', '⚽', '🛴', '🎪', '🎭',
    '🎹', '📷', '🎒', '🏆',
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final topPadding = MediaQuery.of(context).padding.top;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
      body: Column(
        children: [
          _buildHeader(isDark, topPadding),
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 40),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildEmojiSection(isDark),
                    const SizedBox(height: 28),
                    _buildNameSection(isDark),
                    const SizedBox(height: 24),
                    _buildAmountSection(isDark),
                    const SizedBox(height: 36),
                    _buildSaveButton(isDark),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─────────── Header with live preview ───────────

  Widget _buildHeader(bool isDark, double topPadding) {
    final hasName = _nameController.text.isNotEmpty;
    final hasAmount = _currentAmount != null && _currentAmount! > 0;

    return Container(
      padding: EdgeInsets.fromLTRB(20, topPadding + 16, 20, 28),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [const Color(0xFF1E1B4B), _purple.withValues(alpha: 0.5)]
              : [_purple, _purpleDark],
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(32),
          bottomRight: Radius.circular(32),
        ),
        boxShadow: [
          BoxShadow(
            color: _purple.withValues(alpha: isDark ? 0.2 : 0.35),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
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
                    child: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Text(
                'Nova Meta',
                style: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.w700, color: Colors.white),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
            ),
            child: Row(
              children: [
                Container(
                  width: 60, height: 60,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.18),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  alignment: Alignment.center,
                  child: Text(_selectedEmoji, style: const TextStyle(fontSize: 32)),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        hasName ? _nameController.text : 'Nome da meta',
                        style: GoogleFonts.poppins(
                          fontSize: 17,
                          fontWeight: FontWeight.w600,
                          color: Colors.white.withValues(alpha: hasName ? 1.0 : 0.5),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        hasAmount ? 'R\$ ${_currentAmount!.toStringAsFixed(2)}' : 'R\$ 0,00',
                        style: GoogleFonts.poppins(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: Colors.white.withValues(alpha: hasAmount ? 1.0 : 0.4),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─────────── Emoji selector ───────────

  Widget _buildEmojiSection(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionLabel('Ícone da meta', isDark),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E293B) : Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.1 : 0.04),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _goalEmojis.map((emoji) {
              final isSelected = emoji == _selectedEmoji;
              return Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: () => setState(() => _selectedEmoji = emoji),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 44, height: 44,
                    decoration: BoxDecoration(
                      gradient: isSelected
                          ? LinearGradient(colors: [_purple.withValues(alpha: 0.2), _purple.withValues(alpha: 0.08)])
                          : null,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected ? _purple : Colors.transparent,
                        width: isSelected ? 2 : 1,
                      ),
                    ),
                    alignment: Alignment.center,
                    child: Text(emoji, style: const TextStyle(fontSize: 22)),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  // ─────────── Name field ───────────

  Widget _buildNameSection(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionLabel('Nome da meta', isDark),
        const SizedBox(height: 10),
        TextFormField(
          controller: _nameController,
          onChanged: (_) => setState(() {}),
          style: GoogleFonts.poppins(
            color: isDark ? Colors.white : const Color(0xFF1E293B),
            fontSize: 15, fontWeight: FontWeight.w500,
          ),
          decoration: InputDecoration(
            hintText: 'Ex: Bicicleta Nova',
            hintStyle: GoogleFonts.poppins(
              color: isDark ? const Color(0xFF475569) : const Color(0xFFCBD5E1), fontSize: 14,
            ),
            prefixIcon: Padding(
              padding: const EdgeInsets.only(left: 14, right: 8),
              child: Icon(Icons.flag_rounded, color: _purple.withValues(alpha: 0.6), size: 22),
            ),
            prefixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
            filled: true,
            fillColor: isDark ? const Color(0xFF1E293B) : Colors.white,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: _purple, width: 2),
            ),
          ),
          validator: (v) => (v == null || v.isEmpty) ? 'Dê um nome para sua meta' : null,
        ),
      ],
    );
  }

  // ─────────── Amount field ───────────

  Widget _buildAmountSection(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionLabel('Quanto precisa?', isDark),
        const SizedBox(height: 10),
        Container(
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E293B) : Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: _purple.withValues(alpha: 0.2)),
            boxShadow: [
              BoxShadow(
                color: _purple.withValues(alpha: 0.06),
                blurRadius: 16, offset: const Offset(0, 4),
              ),
            ],
          ),
          child: MoneyTextField(
            controller: _amountController,
            onChanged: (v) => setState(() => _currentAmount = v),
            isSmallScreen: false,
            fontSize: 24, fontWeight: FontWeight.w700,
            textAlign: TextAlign.start,
            prefixColor: _purple,
          ),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [10, 25, 50, 100, 200].map((val) {
            return Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(10),
                onTap: () {
                  setState(() {
                    _currentAmount = val.toDouble();
                    _amountController.text = val.toStringAsFixed(2).replaceAll('.', ',');
                  });
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF1E293B) : Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: _currentAmount == val.toDouble()
                          ? _purple
                          : (isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
                      width: _currentAmount == val.toDouble() ? 2 : 1,
                    ),
                  ),
                  child: Text(
                    'R\$ $val',
                    style: GoogleFonts.poppins(
                      fontSize: 12, fontWeight: FontWeight.w600,
                      color: _currentAmount == val.toDouble()
                          ? _purple
                          : (isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B)),
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  // ─────────── Save button ───────────

  Widget _buildSaveButton(bool isDark) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: _saveGoal,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 18),
          decoration: BoxDecoration(
            gradient: const LinearGradient(colors: [_purple, _purpleDark]),
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: _purple.withValues(alpha: 0.4),
                blurRadius: 16, offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.rocket_launch_rounded, color: Colors.white, size: 22),
              const SizedBox(width: 10),
              Text(
                'Criar Meta',
                style: GoogleFonts.poppins(fontSize: 17, fontWeight: FontWeight.w600, color: Colors.white),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ─────────── Helpers ───────────

  Widget _sectionLabel(String text, bool isDark) {
    return Text(
      text,
      style: GoogleFonts.poppins(
        fontSize: 15, fontWeight: FontWeight.w600,
        color: isDark ? const Color(0xFFCBD5E1) : const Color(0xFF334155),
      ),
    );
  }

  void _saveGoal() {
    if (!_formKey.currentState!.validate()) return;

    if (_currentAmount == null || _currentAmount! <= 0) {
      LummyFeedback.warning(context, 'Informe o valor da meta');
      return;
    }

    Navigator.pop(context, {
      'name': _nameController.text,
      'emoji': _selectedEmoji,
      'amount': _currentAmount!,
    });
  }
}
