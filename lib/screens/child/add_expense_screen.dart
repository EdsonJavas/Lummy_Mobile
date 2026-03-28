import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lummy_login/shared/widgets/money_text_field.dart';
import 'package:lummy_login/shared/widgets/widgets.dart';

class AddExpenseScreen extends StatefulWidget {
  const AddExpenseScreen({super.key, required this.expenseCategories});

  final List<Map<String, dynamic>> expenseCategories;

  @override
  State<AddExpenseScreen> createState() => _AddExpenseScreenState();
}

class _AddExpenseScreenState extends State<AddExpenseScreen> {
  final _formKey = GlobalKey<FormState>();
  final _descriptionController = TextEditingController();
  final _amountController = TextEditingController();
  double? _currentAmount;

  String _selectedType = 'expense';
  String? _selectedExpenseCategoryId;

  final List<String> _incomeCategories = ['Mesada', 'Presente', 'Trabalho', 'Outros'];
  String _selectedIncomeCategory = 'Mesada';

  static const _red = Color(0xFFEF4444);
  static const _green = Color(0xFF10B981);
  // ignore: unused_field
  static const _blue = Color(0xFF3B82F6);

  static const _categoryEmojis = {
    'games': '🎮', 'food': '🍔', 'education': '📚', 'clothes': '👕',
    'entertainment': '🎬', 'toys': '🧸', 'sports': '⚽', 'other': '📦',
  };
  static const _incomeCategoryEmojis = {
    'Mesada': '💰', 'Presente': '🎁', 'Trabalho': '💼', 'Outros': '📦',
  };

  bool get _isExpense => _selectedType == 'expense';
  Color get _accentColor => _isExpense ? _red : _green;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final topPadding = MediaQuery.of(context).padding.top;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
      body: Column(
        children: [
          _buildHeader(context, isDark, topPadding),
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 40),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildTypeSelector(isDark),
                    const SizedBox(height: 24),
                    _buildAmountSection(isDark),
                    const SizedBox(height: 24),
                    _buildDescriptionSection(isDark),
                    const SizedBox(height: 24),
                    _buildCategorySection(isDark),
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

  // ─────────── Header ───────────

  Widget _buildHeader(BuildContext context, bool isDark, double topPadding) {
    return Container(
      padding: EdgeInsets.fromLTRB(20, topPadding + 16, 20, 24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [const Color(0xFF1E1B4B), _accentColor.withValues(alpha: 0.4)]
              : [_accentColor, _accentColor.withValues(alpha: 0.85)],
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(32),
          bottomRight: Radius.circular(32),
        ),
        boxShadow: [
          BoxShadow(
            color: _accentColor.withValues(alpha: isDark ? 0.15 : 0.3),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
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
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _isExpense ? 'Registrar Gasto' : 'Adicionar Ganho',
                  style: GoogleFonts.poppins(
                    fontSize: 22, fontWeight: FontWeight.w700, color: Colors.white,
                  ),
                ),
                Text(
                  _isExpense ? 'Controle seus gastos' : 'Registre suas entradas',
                  style: GoogleFonts.poppins(
                    fontSize: 13, color: Colors.white.withValues(alpha: 0.8),
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              _isExpense ? Icons.shopping_bag_rounded : Icons.savings_rounded,
              color: Colors.white, size: 24,
            ),
          ),
        ],
      ),
    );
  }

  // ─────────── Type selector ───────────

  Widget _buildTypeSelector(bool isDark) {
    return Row(
      children: [
        Expanded(child: _typeChip('expense', 'Gasto', Icons.arrow_upward_rounded, _red, isDark)),
        const SizedBox(width: 12),
        Expanded(child: _typeChip('income', 'Ganho', Icons.arrow_downward_rounded, _green, isDark)),
      ],
    );
  }

  Widget _typeChip(String type, String label, IconData icon, Color color, bool isDark) {
    final isActive = _selectedType == type;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          setState(() {
            _selectedType = type;
            if (type == 'expense' && widget.expenseCategories.isNotEmpty) {
              _selectedExpenseCategoryId = widget.expenseCategories.first['id'] as String;
            } else if (type == 'income') {
              _selectedIncomeCategory = _incomeCategories.first;
            }
          });
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          padding: const EdgeInsets.symmetric(vertical: 18),
          decoration: BoxDecoration(
            gradient: isActive
                ? LinearGradient(colors: [color, color.withValues(alpha: 0.8)])
                : null,
            color: isActive ? null : (isDark ? const Color(0xFF1E293B) : Colors.white),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isActive ? color : (isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
              width: isActive ? 2 : 1,
            ),
            boxShadow: isActive
                ? [BoxShadow(color: color.withValues(alpha: 0.35), blurRadius: 12, offset: const Offset(0, 4))]
                : null,
          ),
          child: Column(
            children: [
              Icon(icon, color: isActive ? Colors.white : color, size: 28),
              const SizedBox(height: 6),
              Text(
                label,
                style: GoogleFonts.poppins(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: isActive
                      ? Colors.white
                      : (isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ─────────── Amount ───────────

  Widget _buildAmountSection(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionLabel('Valor', isDark),
        const SizedBox(height: 10),
        Container(
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E293B) : Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: _accentColor.withValues(alpha: 0.2),
            ),
            boxShadow: [
              BoxShadow(
                color: _accentColor.withValues(alpha: 0.06),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: MoneyTextField(
            controller: _amountController,
            onChanged: (v) => setState(() => _currentAmount = v),
            isSmallScreen: false,
            fontSize: 24,
            fontWeight: FontWeight.w700,
            textAlign: TextAlign.start,
            prefixColor: _accentColor,
          ),
        ),
        if (_currentAmount != null && _currentAmount! > 0) ...[
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerRight,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: _accentColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                _isExpense ? '- R\$ ${_currentAmount!.toStringAsFixed(2)}' : '+ R\$ ${_currentAmount!.toStringAsFixed(2)}',
                style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w600, color: _accentColor),
              ),
            ),
          ),
        ],
      ],
    );
  }

  // ─────────── Description ───────────

  Widget _buildDescriptionSection(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionLabel('Descrição', isDark),
        const SizedBox(height: 10),
        TextFormField(
          controller: _descriptionController,
          style: GoogleFonts.poppins(
            color: isDark ? Colors.white : const Color(0xFF1E293B),
            fontSize: 15,
          ),
          decoration: InputDecoration(
            hintText: _isExpense ? 'Ex: Lanche na escola' : 'Ex: Mesada da semana',
            hintStyle: GoogleFonts.poppins(
              color: isDark ? const Color(0xFF475569) : const Color(0xFFCBD5E1),
              fontSize: 14,
            ),
            prefixIcon: Padding(
              padding: const EdgeInsets.only(left: 14, right: 8),
              child: Icon(
                Icons.edit_note_rounded,
                color: isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8),
                size: 22,
              ),
            ),
            prefixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
            filled: true,
            fillColor: isDark ? const Color(0xFF1E293B) : Colors.white,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(
                color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: _accentColor, width: 2),
            ),
          ),
          validator: (v) => (v == null || v.isEmpty) ? 'Informe uma descrição' : null,
        ),
      ],
    );
  }

  // ─────────── Category ───────────

  Widget _buildCategorySection(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionLabel('Categoria', isDark),
        const SizedBox(height: 12),
        if (_isExpense) _buildExpenseCategoryChips(isDark) else _buildIncomeCategoryChips(isDark),
      ],
    );
  }

  Widget _buildExpenseCategoryChips(bool isDark) {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: widget.expenseCategories.map((cat) {
        final id = cat['id'] as String;
        final name = cat['name'] as String;
        final emoji = _categoryEmojis[id] ?? '📦';
        final isActive = _selectedExpenseCategoryId == id;

        return Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(14),
            onTap: () => setState(() => _selectedExpenseCategoryId = id),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                gradient: isActive
                    ? LinearGradient(colors: [_red.withValues(alpha: 0.18), _red.withValues(alpha: 0.08)])
                    : null,
                color: isActive ? null : (isDark ? const Color(0xFF1E293B) : Colors.white),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: isActive ? _red : (isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
                  width: isActive ? 2 : 1,
                ),
                boxShadow: isActive
                    ? [BoxShadow(color: _red.withValues(alpha: 0.15), blurRadius: 8, offset: const Offset(0, 2))]
                    : null,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(emoji, style: const TextStyle(fontSize: 18)),
                  const SizedBox(width: 8),
                  Text(
                    name,
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                      color: isActive ? _red : (isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B)),
                    ),
                  ),
                  if (isActive) ...[
                    const SizedBox(width: 6),
                    const Icon(Icons.check_circle_rounded, color: _red, size: 16),
                  ],
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildIncomeCategoryChips(bool isDark) {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: _incomeCategories.map((cat) {
        final emoji = _incomeCategoryEmojis[cat] ?? '📦';
        final isActive = _selectedIncomeCategory == cat;

        return Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(14),
            onTap: () => setState(() => _selectedIncomeCategory = cat),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                gradient: isActive
                    ? LinearGradient(colors: [_green.withValues(alpha: 0.18), _green.withValues(alpha: 0.08)])
                    : null,
                color: isActive ? null : (isDark ? const Color(0xFF1E293B) : Colors.white),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: isActive ? _green : (isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
                  width: isActive ? 2 : 1,
                ),
                boxShadow: isActive
                    ? [BoxShadow(color: _green.withValues(alpha: 0.15), blurRadius: 8, offset: const Offset(0, 2))]
                    : null,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(emoji, style: const TextStyle(fontSize: 18)),
                  const SizedBox(width: 8),
                  Text(
                    cat,
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                      color: isActive ? _green : (isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B)),
                    ),
                  ),
                  if (isActive) ...[
                    const SizedBox(width: 6),
                    const Icon(Icons.check_circle_rounded, color: _green, size: 16),
                  ],
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  // ─────────── Save ───────────

  Widget _buildSaveButton(bool isDark) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: _saveTransaction,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 18),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [_accentColor, _accentColor.withValues(alpha: 0.8)],
            ),
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: _accentColor.withValues(alpha: 0.4),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(_isExpense ? Icons.remove_circle_rounded : Icons.add_circle_rounded, color: Colors.white, size: 22),
              const SizedBox(width: 10),
              Text(
                _isExpense ? 'Registrar Gasto' : 'Adicionar Ganho',
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
        fontSize: 15,
        fontWeight: FontWeight.w600,
        color: isDark ? const Color(0xFFCBD5E1) : const Color(0xFF334155),
      ),
    );
  }

  void _saveTransaction() {
    if (!_formKey.currentState!.validate()) return;

    final amount = _currentAmount ?? 0.0;
    if (amount <= 0) {
      LummyFeedback.warning(context, 'Informe um valor válido');
      return;
    }

    if (_isExpense && (_selectedExpenseCategoryId == null || _selectedExpenseCategoryId!.isEmpty)) {
      LummyFeedback.warning(context, 'Selecione uma categoria');
      return;
    }

    String categoryId;
    String categoryName;

    if (_isExpense) {
      categoryId = _selectedExpenseCategoryId!;
      final category = widget.expenseCategories.firstWhere(
        (c) => c['id'] == categoryId,
        orElse: () => {'id': categoryId, 'name': categoryId},
      );
      categoryName = category['name'] as String;
    } else {
      categoryId = _selectedIncomeCategory;
      categoryName = _selectedIncomeCategory;
    }

    Navigator.pop(context, {
      'description': _descriptionController.text,
      'amount': amount,
      'type': _selectedType,
      'categoryId': categoryId,
      'categoryName': categoryName,
    });
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _amountController.dispose();
    super.dispose();
  }
}
