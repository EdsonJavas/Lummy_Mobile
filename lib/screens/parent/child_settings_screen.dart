import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:lummy_login/domain/entities/user_entity.dart';

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

  // Cores
  static const _purple = Color(0xFF8B5CF6);
  static const _blue = Color(0xFF3B82F6);
  static const _green = Color(0xFF10B981);
  static const _orange = Color(0xFFF59E0B);
  static const _red = Color(0xFFEF4444);
  static const _pink = Color(0xFFEC4899);

  // Categorias disponíveis
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

    // Se não houver categorias permitidas, permitir todas
    if (_allowedCategories.isEmpty) {
      _allowedCategories = _categories.map((c) => c['id'] as String).toList();
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
          // Content
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Aprovação de Transações
                  _buildApprovalSection(isDark),
                  const SizedBox(height: 24),
                  // Mesada
                  _buildAllowanceSection(isDark),
                  const SizedBox(height: 24),
                  // Categorias Permitidas
                  _buildCategoriesSection(isDark),
                  const SizedBox(height: 24),
                  // Limites por Categoria
                  _buildLimitsSection(isDark),
                  const SizedBox(height: 24),
                  // Botões de Ação
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
                  _blue.withOpacity(0.3),
                ]
              : [_blue, const Color(0xFF2563EB), const Color(0xFF1D4ED8)],
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(32),
          bottomRight: Radius.circular(32),
        ),
      ),
      child: Row(
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
                    color: Colors.white.withOpacity(0.8),
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              Icons.settings_rounded,
              color: Colors.white,
              size: 24,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildApprovalSection(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: _green.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.verified_user_rounded,
                  color: _green,
                  size: 22,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Aprovação de Transações',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: isDark ? Colors.white : const Color(0xFF1E293B),
                      ),
                    ),
                    Text(
                      'Exigir sua aprovação para gastos',
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
              Switch(
                value: _requiresApproval,
                onChanged: (value) => setState(() => _requiresApproval = value),
                activeThumbColor: _green,
                activeTrackColor: _green.withValues(alpha: 0.3),
              ),
            ],
          ),
          if (_requiresApproval) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: _green.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: _green.withOpacity(0.2)),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.info_outline_rounded,
                    color: _green,
                    size: 18,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Você receberá notificações para aprovar ou rejeitar transações.',
                      style: GoogleFonts.poppins(fontSize: 12, color: _green),
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

  Widget _buildAllowanceSection(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: _orange.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.account_balance_wallet_rounded,
                  color: _orange,
                  size: 22,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  'Mesada Mensal',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white : const Color(0xFF1E293B),
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: _orange.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
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
            ],
          ),
          const SizedBox(height: 20),
          SliderTheme(
            data: SliderThemeData(
              activeTrackColor: _orange,
              inactiveTrackColor: _orange.withOpacity(0.2),
              thumbColor: _orange,
              overlayColor: _orange.withOpacity(0.2),
              trackHeight: 8,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 12),
            ),
            child: Slider(
              value: _allowance,
              min: 0,
              max: 500,
              divisions: 100,
              onChanged: (value) => setState(() => _allowance = value),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'R\$ 0',
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: isDark
                      ? const Color(0xFF64748B)
                      : const Color(0xFF94A3B8),
                ),
              ),
              Text(
                'R\$ 500',
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: isDark
                      ? const Color(0xFF64748B)
                      : const Color(0xFF94A3B8),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCategoriesSection(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: _purple.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.category_rounded,
                  color: _purple,
                  size: 22,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Categorias Permitidas',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: isDark ? Colors.white : const Color(0xFF1E293B),
                      ),
                    ),
                    Text(
                      '${_allowedCategories.length} de ${_categories.length} ativas',
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
            ],
          ),
          const SizedBox(height: 20),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: _categories.map((category) {
              final isEnabled = _allowedCategories.contains(category['id']);
              final color = category['color'] as Color;

              return GestureDetector(
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
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: isEnabled
                        ? color.withOpacity(0.15)
                        : (isDark
                              ? const Color(0xFF1E293B)
                              : const Color(0xFFF1F5F9)),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: isEnabled
                          ? color
                          : (isDark
                                ? const Color(0xFF334155)
                                : const Color(0xFFE2E8F0)),
                      width: isEnabled ? 2 : 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        category['emoji'] as String,
                        style: const TextStyle(fontSize: 18),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        category['name'] as String,
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          fontWeight: isEnabled
                              ? FontWeight.w600
                              : FontWeight.w500,
                          color: isEnabled
                              ? color
                              : (isDark
                                    ? const Color(0xFF94A3B8)
                                    : const Color(0xFF64748B)),
                        ),
                      ),
                      if (isEnabled) ...[
                        const SizedBox(width: 6),
                        Icon(
                          Icons.check_circle_rounded,
                          color: color,
                          size: 18,
                        ),
                      ],
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildLimitsSection(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: _red.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.speed_rounded, color: _red, size: 22),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Limites de Gastos',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: isDark ? Colors.white : const Color(0xFF1E293B),
                      ),
                    ),
                    Text(
                      'Defina limites mensais por categoria',
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
            ],
          ),
          const SizedBox(height: 20),
          ..._categories.where((c) => _allowedCategories.contains(c['id'])).map(
            (category) {
              final categoryId = category['id'] as String;
              final limit = _limits[categoryId] ?? 0.0;
              final color = category['color'] as Color;

              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          category['emoji'] as String,
                          style: const TextStyle(fontSize: 18),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            category['name'] as String,
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: isDark
                                  ? Colors.white
                                  : const Color(0xFF1E293B),
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: color.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            limit > 0
                                ? 'R\$ ${limit.toStringAsFixed(0)}'
                                : 'Sem limite',
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: color,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    SliderTheme(
                      data: SliderThemeData(
                        activeTrackColor: color,
                        inactiveTrackColor: color.withOpacity(0.2),
                        thumbColor: color,
                        overlayColor: color.withOpacity(0.2),
                        trackHeight: 6,
                        thumbShape: const RoundSliderThumbShape(
                          enabledThumbRadius: 10,
                        ),
                      ),
                      child: Slider(
                        value: limit,
                        min: 0,
                        max: 200,
                        divisions: 40,
                        onChanged: (value) {
                          setState(() {
                            _limits[categoryId] = value;
                          });
                        },
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

  Widget _buildActionButtons(bool isDark) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _isSaving ? null : _saveSettings,
            style: ElevatedButton.styleFrom(
              backgroundColor: _green,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 0,
            ),
            child: _isSaving
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.save_rounded, size: 22),
                      const SizedBox(width: 10),
                      Text(
                        'Salvar Configurações',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            onPressed: _resetToDefaults,
            style: OutlinedButton.styleFrom(
              foregroundColor: isDark
                  ? const Color(0xFF94A3B8)
                  : const Color(0xFF64748B),
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              side: BorderSide(
                color: isDark
                    ? const Color(0xFF334155)
                    : const Color(0xFFE2E8F0),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.refresh_rounded, size: 22),
                const SizedBox(width: 10),
                Text(
                  'Restaurar Padrões',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

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
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Configurações salvas com sucesso!',
              style: GoogleFonts.poppins(),
            ),
            backgroundColor: _green,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      debugPrint('Erro ao salvar configurações: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao salvar: $e', style: GoogleFonts.poppins()),
            backgroundColor: _red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
        );
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
  }
}
