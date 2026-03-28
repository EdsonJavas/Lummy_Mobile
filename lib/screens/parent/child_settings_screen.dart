import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:lummy_login/domain/entities/user_entity.dart';
import 'package:lummy_login/shared/widgets/widgets.dart';

class ChildSettingsScreen extends StatefulWidget {
  final ChildEntity child;

  const ChildSettingsScreen({super.key, required this.child});

  @override
  State<ChildSettingsScreen> createState() => _ChildSettingsScreenState();
}

class _ChildSettingsScreenState extends State<ChildSettingsScreen> {
  late bool _requiresApproval;
  late double _allowance;
  late Map<String, double> _limits;
  late List<String> _allowedCategories;
  bool _isSaving = false;

  static const _purple = Color(0xFF8B5CF6);
  static const _blue = Color(0xFF3B82F6);
  static const _green = Color(0xFF10B981);
  static const _orange = Color(0xFFF59E0B);
  static const _red = Color(0xFFEF4444);
  static const _pink = Color(0xFFEC4899);
  static const _blueDark = Color(0xFF1D4ED8);

  final List<Map<String, dynamic>> _categories = [
    {'id': 'games', 'name': 'Jogos', 'emoji': '🎮', 'color': _purple},
    {'id': 'food', 'name': 'Alimentação', 'emoji': '🍔', 'color': _orange},
    {'id': 'education', 'name': 'Educação', 'emoji': '📚', 'color': _blue},
    {'id': 'clothes', 'name': 'Roupas', 'emoji': '👕', 'color': _pink},
    {
      'id': 'entertainment',
      'name': 'Entretenimento',
      'emoji': '🎬',
      'color': _red,
    },
    {'id': 'toys', 'name': 'Brinquedos', 'emoji': '🧸', 'color': _green},
    {
      'id': 'sports',
      'name': 'Esportes',
      'emoji': '⚽',
      'color': const Color(0xFF06B6D4),
    },
    {
      'id': 'other',
      'name': 'Outros',
      'emoji': '📦',
      'color': const Color(0xFF64748B),
    },
  ];

  @override
  void initState() {
    super.initState();
    _requiresApproval = widget.child.requiresApproval;
    _allowance = widget.child.allowance;
    _limits = Map<String, double>.from(widget.child.limits);
    _allowedCategories = List<String>.from(widget.child.allowedCategories);

    if (_allowedCategories.isEmpty) {
      _allowedCategories = _categories.map((c) => c['id'] as String).toList();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final topPadding = MediaQuery.of(context).padding.top;

    return Scaffold(
      backgroundColor:
          isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
      body: Column(
        children: [
          _buildHeader(context, isDark, topPadding),
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildApprovalSection(isDark),
                  const SizedBox(height: 20),
                  _buildAllowanceSection(isDark),
                  const SizedBox(height: 20),
                  _buildCategoriesSection(isDark),
                  const SizedBox(height: 20),
                  _buildLimitsSection(isDark),
                  const SizedBox(height: 32),
                  _buildActionButtons(isDark),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ──────────────────────── Header ────────────────────────

  Widget _buildHeader(BuildContext context, bool isDark, double topPadding) {
    return Container(
      padding: EdgeInsets.fromLTRB(20, topPadding + 16, 20, 28),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [const Color(0xFF1E1B4B), _blue.withValues(alpha: 0.5)]
              : [_blue, _blueDark],
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(32),
          bottomRight: Radius.circular(32),
        ),
        boxShadow: [
          BoxShadow(
            color: _blue.withValues(alpha: isDark ? 0.15 : 0.3),
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
                    child: const Icon(
                      Icons.arrow_back_ios_new_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Configurações',
                      style: GoogleFonts.poppins(
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      'Gerenciar ${widget.child.name}',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: Colors.white.withValues(alpha: 0.8),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(
                  Icons.tune_rounded,
                  color: Colors.white,
                  size: 24,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          // Summary row
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
            ),
            child: Row(
              children: [
                _headerChip(
                  Icons.verified_user_rounded,
                  _requiresApproval ? 'Aprovação ativa' : 'Livre',
                  _requiresApproval ? _green : _orange,
                ),
                const SizedBox(width: 12),
                Container(width: 1, height: 28, color: Colors.white.withValues(alpha: 0.2)),
                const SizedBox(width: 12),
                _headerChip(
                  Icons.account_balance_wallet_rounded,
                  'R\$ ${_allowance.toStringAsFixed(0)}/mês',
                  _orange,
                ),
                const SizedBox(width: 12),
                Container(width: 1, height: 28, color: Colors.white.withValues(alpha: 0.2)),
                const SizedBox(width: 12),
                _headerChip(
                  Icons.category_rounded,
                  '${_allowedCategories.length} cat.',
                  _purple,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _headerChip(IconData icon, String text, Color color) {
    return Expanded(
      child: Row(
        children: [
          Icon(icon, color: color, size: 16),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              text,
              style: GoogleFonts.poppins(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: Colors.white.withValues(alpha: 0.9),
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  // ──────────────────────── Section Card Wrapper ────────────────────────

  Widget _sectionCard({
    required bool isDark,
    required Widget child,
    Color? accentColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: accentColor != null
              ? accentColor.withValues(alpha: isDark ? 0.2 : 0.12)
              : (isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
        ),
        boxShadow: [
          BoxShadow(
            color: (accentColor ?? Colors.black).withValues(alpha: isDark ? 0.08 : 0.05),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _sectionHeader({
    required IconData icon,
    required Color color,
    required String title,
    String? subtitle,
    required bool isDark,
    Widget? trailing,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [color.withValues(alpha: 0.2), color.withValues(alpha: 0.1)],
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: color, size: 22),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.white : const Color(0xFF1E293B),
                ),
              ),
              if (subtitle != null)
                Text(
                  subtitle,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: isDark
                        ? const Color(0xFF94A3B8)
                        : const Color(0xFF64748B),
                  ),
                ),
            ],
          ),
        ),
        ?trailing,
      ],
    );
  }

  // ──────────────────────── Approval Section ────────────────────────

  Widget _buildApprovalSection(bool isDark) {
    return _sectionCard(
      isDark: isDark,
      accentColor: _green,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionHeader(
            icon: Icons.verified_user_rounded,
            color: _green,
            title: 'Aprovação de Transações',
            subtitle: 'Exigir sua aprovação para gastos',
            isDark: isDark,
            trailing: Switch.adaptive(
              value: _requiresApproval,
              onChanged: (value) => setState(() => _requiresApproval = value),
              activeThumbColor: _green,
              activeTrackColor: _green.withValues(alpha: 0.3),
            ),
          ),
          if (_requiresApproval) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [_green.withValues(alpha: 0.08), _green.withValues(alpha: 0.04)],
                ),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: _green.withValues(alpha: 0.15)),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: _green.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.notifications_active_rounded, color: _green, size: 16),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Você receberá notificações para aprovar ou rejeitar transações.',
                      style: GoogleFonts.poppins(fontSize: 12, color: _green, fontWeight: FontWeight.w500),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ──────────────────────── Allowance Section ────────────────────────

  Widget _buildAllowanceSection(bool isDark) {
    return _sectionCard(
      isDark: isDark,
      accentColor: _orange,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionHeader(
            icon: Icons.account_balance_wallet_rounded,
            color: _orange,
            title: 'Mesada Mensal',
            isDark: isDark,
            trailing: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [_orange.withValues(alpha: 0.2), _orange.withValues(alpha: 0.1)],
                ),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: _orange.withValues(alpha: 0.2)),
              ),
              child: Text(
                'R\$ ${_allowance.toStringAsFixed(2)}',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: _orange,
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
          // Visual amount indicator
          Center(
            child: Text(
              'R\$ ${_allowance.toStringAsFixed(0)}',
              style: GoogleFonts.poppins(
                fontSize: 36,
                fontWeight: FontWeight.w700,
                color: _orange,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Center(
            child: Text(
              'por mês',
              style: GoogleFonts.poppins(
                fontSize: 13,
                color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
              ),
            ),
          ),
          const SizedBox(height: 16),
          SliderTheme(
            data: SliderThemeData(
              activeTrackColor: _orange,
              inactiveTrackColor: _orange.withValues(alpha: 0.15),
              thumbColor: Colors.white,
              overlayColor: _orange.withValues(alpha: 0.2),
              trackHeight: 10,
              thumbShape: const RoundSliderThumbShape(
                enabledThumbRadius: 14,
                elevation: 4,
              ),
              trackShape: const RoundedRectSliderTrackShape(),
            ),
            child: Slider(
              value: _allowance,
              min: 0,
              max: 500,
              divisions: 100,
              onChanged: (value) => setState(() => _allowance = value),
            ),
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'R\$ 0',
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8),
                ),
              ),
              Text(
                'R\$ 500',
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Quick presets
          Row(
            children: [50.0, 100.0, 200.0, 300.0].map((val) {
              final isActive = (_allowance - val).abs() < 1;
              return Expanded(
                child: Padding(
                  padding: EdgeInsets.only(right: val == 300.0 ? 0 : 8),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(10),
                      onTap: () => setState(() => _allowance = val),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        decoration: BoxDecoration(
                          gradient: isActive
                              ? LinearGradient(colors: [_orange, _orange.withValues(alpha: 0.8)])
                              : null,
                          color: isActive
                              ? null
                              : (isDark ? const Color(0xFF0F172A) : const Color(0xFFF1F5F9)),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: isActive ? _orange : (isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
                          ),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          'R\$ ${val.toInt()}',
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: isActive ? Colors.white : (isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B)),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  // ──────────────────────── Categories Section ────────────────────────

  Widget _buildCategoriesSection(bool isDark) {
    return _sectionCard(
      isDark: isDark,
      accentColor: _purple,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionHeader(
            icon: Icons.category_rounded,
            color: _purple,
            title: 'Categorias Permitidas',
            subtitle: '${_allowedCategories.length} de ${_categories.length} ativas',
            isDark: isDark,
            trailing: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(8),
                onTap: () {
                  setState(() {
                    if (_allowedCategories.length == _categories.length) {
                      _allowedCategories.clear();
                    } else {
                      _allowedCategories = _categories.map((c) => c['id'] as String).toList();
                    }
                  });
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  child: Text(
                    _allowedCategories.length == _categories.length ? 'Limpar' : 'Todas',
                    style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w600, color: _purple),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: _categories.map((category) {
              final isEnabled = _allowedCategories.contains(category['id']);
              final color = category['color'] as Color;

              return Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(14),
                  onTap: () {
                    setState(() {
                      if (isEnabled) {
                        _allowedCategories.remove(category['id']);
                      } else {
                        _allowedCategories.add(category['id'] as String);
                      }
                    });
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      gradient: isEnabled
                          ? LinearGradient(colors: [color.withValues(alpha: 0.18), color.withValues(alpha: 0.08)])
                          : null,
                      color: isEnabled
                          ? null
                          : (isDark ? const Color(0xFF0F172A) : const Color(0xFFF1F5F9)),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: isEnabled
                            ? color
                            : (isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
                        width: isEnabled ? 2 : 1,
                      ),
                      boxShadow: isEnabled
                          ? [BoxShadow(color: color.withValues(alpha: 0.15), blurRadius: 8, offset: const Offset(0, 2))]
                          : null,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(category['emoji'] as String, style: const TextStyle(fontSize: 18)),
                        const SizedBox(width: 8),
                        Text(
                          category['name'] as String,
                          style: GoogleFonts.poppins(
                            fontSize: 13,
                            fontWeight: isEnabled ? FontWeight.w600 : FontWeight.w500,
                            color: isEnabled
                                ? color
                                : (isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B)),
                          ),
                        ),
                        if (isEnabled) ...[
                          const SizedBox(width: 6),
                          Icon(Icons.check_circle_rounded, color: color, size: 18),
                        ],
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  // ──────────────────────── Limits Section ────────────────────────

  Widget _buildLimitsSection(bool isDark) {
    final enabledCategories = _categories.where((c) => _allowedCategories.contains(c['id'])).toList();

    if (enabledCategories.isEmpty) {
      return _sectionCard(
        isDark: isDark,
        accentColor: _red,
        child: Column(
          children: [
            _sectionHeader(
              icon: Icons.speed_rounded,
              color: _red,
              title: 'Limites de Gastos',
              subtitle: 'Selecione categorias primeiro',
              isDark: isDark,
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.category_outlined,
                    size: 32,
                    color: isDark ? const Color(0xFF475569) : const Color(0xFFCBD5E1),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Nenhuma categoria habilitada',
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    return _sectionCard(
      isDark: isDark,
      accentColor: _red,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionHeader(
            icon: Icons.speed_rounded,
            color: _red,
            title: 'Limites de Gastos',
            subtitle: 'Defina limites mensais por categoria',
            isDark: isDark,
          ),
          const SizedBox(height: 20),
          ...enabledCategories.map((category) {
            final categoryId = category['id'] as String;
            final limit = _limits[categoryId] ?? 0.0;
            final color = category['color'] as Color;

            return Padding(
              padding: const EdgeInsets.only(bottom: 20),
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF0F172A) : const Color(0xFFFAFAFA),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: limit > 0
                        ? color.withValues(alpha: 0.25)
                        : (isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9)),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 36, height: 36,
                          decoration: BoxDecoration(
                            color: color.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          alignment: Alignment.center,
                          child: Text(category['emoji'] as String, style: const TextStyle(fontSize: 18)),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            category['name'] as String,
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: isDark ? Colors.white : const Color(0xFF1E293B),
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            gradient: limit > 0
                                ? LinearGradient(colors: [color.withValues(alpha: 0.2), color.withValues(alpha: 0.1)])
                                : null,
                            color: limit > 0
                                ? null
                                : (isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9)),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            limit > 0 ? 'R\$ ${limit.toStringAsFixed(0)}' : 'Sem limite',
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: limit > 0
                                  ? color
                                  : (isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8)),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    SliderTheme(
                      data: SliderThemeData(
                        activeTrackColor: color,
                        inactiveTrackColor: color.withValues(alpha: 0.15),
                        thumbColor: Colors.white,
                        overlayColor: color.withValues(alpha: 0.2),
                        trackHeight: 6,
                        thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 10, elevation: 3),
                      ),
                      child: Slider(
                        value: limit,
                        min: 0,
                        max: 200,
                        divisions: 40,
                        onChanged: (value) {
                          setState(() => _limits[categoryId] = value);
                        },
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  // ──────────────────────── Action Buttons ────────────────────────

  Widget _buildActionButtons(bool isDark) {
    return Column(
      children: [
        // Save button with gradient
        Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: _isSaving ? null : _saveSettings,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                gradient: _isSaving
                    ? null
                    : const LinearGradient(colors: [_green, Color(0xFF059669)]),
                color: _isSaving ? _green.withValues(alpha: 0.5) : null,
                borderRadius: BorderRadius.circular(16),
                boxShadow: _isSaving
                    ? null
                    : [
                        BoxShadow(
                          color: _green.withValues(alpha: 0.4),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
              ),
              alignment: Alignment.center,
              child: _isSaving
                  ? const SizedBox(
                      width: 24, height: 24,
                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.save_rounded, color: Colors.white, size: 22),
                        const SizedBox(width: 10),
                        Text(
                          'Salvar Configurações',
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
        const SizedBox(height: 12),
        // Reset button
        Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: _resetToDefaults,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E293B) : Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                ),
              ),
              alignment: Alignment.center,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.refresh_rounded,
                    size: 22,
                    color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    'Restaurar Padrões',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ──────────────────────── Actions ────────────────────────

  Future<void> _saveSettings() async {
    setState(() => _isSaving = true);
    try {
      final supabase = Supabase.instance.client;

      await supabase
          .from('children')
          .update({
            'requires_approval': _requiresApproval,
            'allowance': _allowance,
            'limits': _limits,
            'allowed_categories': _allowedCategories,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', widget.child.id);

      if (mounted) {
        LummyFeedback.success(context, 'Configurações salvas com sucesso!');
        Navigator.pop(context);
      }
    } catch (e) {
      debugPrint('Erro ao salvar configurações: $e');
      if (mounted) {
        LummyFeedback.error(context, 'Erro ao salvar configurações');
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  void _resetToDefaults() {
    setState(() {
      _requiresApproval = true;
      _allowance = 0;
      _limits = {};
      _allowedCategories = _categories.map((c) => c['id'] as String).toList();
    });
    LummyFeedback.info(context, 'Valores restaurados ao padrão');
  }
}
