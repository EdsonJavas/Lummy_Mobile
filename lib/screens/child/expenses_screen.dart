import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:lummy_login/screens/child/add_expense_screen.dart';
import 'package:lummy_login/core/constants/app_constants.dart';
import 'package:lummy_login/core/utils/formatters.dart';
import 'package:lummy_login/shared/widgets/widgets.dart';

class ExpensesScreen extends StatefulWidget {
  const ExpensesScreen({super.key});

  @override
  State<ExpensesScreen> createState() => _ExpensesScreenState();
}

class _ExpensesScreenState extends State<ExpensesScreen> {
  String selectedPeriod = 'Este mês';
  String selectedCategory = 'Todas'; // 'Todas' ou id da categoria
  bool _isLoading = true;

  final _supabase = Supabase.instance.client;

  // Categorias base (devem bater com as ids usadas nas configurações do responsável)
  // id: usado no banco; name: exibido na UI; color: usado em gráficos/listas
  final List<Map<String, dynamic>> _baseCategories = [
    {
      'id': 'games',
      'name': 'Jogos',
      'color': const Color(0xFF8B5CF6),
    },
    {
      'id': 'food',
      'name': 'Alimentação',
      'color': const Color(0xFFF59E0B),
    },
    {
      'id': 'education',
      'name': 'Educação',
      'color': const Color(0xFF3B82F6),
    },
    {
      'id': 'clothes',
      'name': 'Roupas',
      'color': const Color(0xFFEC4899),
    },
    {
      'id': 'entertainment',
      'name': 'Entretenimento',
      'color': const Color(0xFFEF4444),
    },
    {
      'id': 'toys',
      'name': 'Brinquedos',
      'color': const Color(0xFF10B981),
    },
    {
      'id': 'sports',
      'name': 'Esportes',
      'color': const Color(0xFF06B6D4),
    },
    {
      'id': 'other',
      'name': 'Outros',
      'color': const Color(0xFF64748B),
    },
  ];

  // Categorias permitidas para este filho (filtradas de _baseCategories)
  List<Map<String, dynamic>> _allowedCategories = [];

  // Transações carregadas do banco (apenas despesas)
  // Cada item: { description, amount, categoryId, categoryName, color, date }
  List<Map<String, dynamic>> _allTransactions = [];
  List<Map<String, dynamic>> _visibleTransactions = [];

  // Totais para UI
  double _totalSpent = 0.0;
  double _currentBalance = 0.0;
  Map<String, double> _categorySpending = {};

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final user = _supabase.auth.currentUser;
      if (user == null) {
        setState(() {
          _isLoading = false;
        });
        return;
      }

      final childId = user.id;

      // 1) Carregar configurações do filho (categorias permitidas + saldo)
      final childRow = await _supabase
          .from('children')
          .select('allowed_categories, balance')
          .eq('id', childId)
          .maybeSingle();

      final rawAllowed =
          (childRow?['allowed_categories'] as List<dynamic>?) ?? [];
      final allowedIds =
          rawAllowed.map((e) => e.toString()).toList(growable: false);

      _currentBalance =
          (childRow?['balance'] as num?)?.toDouble() ?? _currentBalance;

      // Se não houver categorias configuradas, permite todas as base
      if (allowedIds.isEmpty) {
        _allowedCategories = List<Map<String, dynamic>>.from(_baseCategories);
      } else {
        _allowedCategories = _baseCategories
            .where((c) => allowedIds.contains(c['id'] as String))
            .toList();

        if (_allowedCategories.isEmpty) {
          _allowedCategories =
              List<Map<String, dynamic>>.from(_baseCategories);
        }
      }

      // 2) Carregar transações de despesa do banco
      final rows = await _supabase
          .from('transactions')
          .select('description, amount, category, date')
          .eq('child_id', childId)
          .eq('type', 'expense')
          .order('date', ascending: false);

      _allTransactions = rows.map<Map<String, dynamic>>((row) {
        final catId = (row['category'] ?? 'other').toString();
        final categoryConfig = _baseCategories.firstWhere(
          (c) => c['id'] == catId,
          orElse: () => {
            'id': catId,
            'name': catId,
            'color': const Color(0xFF64748B),
          },
        );

        final dateRaw = row['date'];
        final date = dateRaw is String
            ? DateTime.tryParse(dateRaw) ?? DateTime.now()
            : (dateRaw is DateTime ? dateRaw : DateTime.now());

        return {
          'description': (row['description'] ?? '') as String,
          'amount': (row['amount'] as num?)?.toDouble() ?? 0.0,
          'categoryId': categoryConfig['id'] as String,
          'categoryName': categoryConfig['name'] as String,
          'color': categoryConfig['color'] as Color,
          'date': date,
        };
      }).toList();

      _applyFilters();

      setState(() {
        _isLoading = false;
      });
    } catch (_) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _refreshData() async {
    await _loadData();
  }

  /// Retorna true se salvou com sucesso; false se saldo insuficiente ou erro.
  Future<bool> _saveTransactionToDatabase(
    Map<String, dynamic> data,
  ) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) return false;

      final amount = (data['amount'] as num?)?.toDouble() ?? 0.0;
      if (amount <= 0) return false;

      final type = (data['type'] ?? 'expense').toString();
      final categoryId = (data['categoryId'] ?? 'other').toString();
      final description =
          (data['description'] as String?)?.trim() ?? 'Transação';

      final status = type == 'expense' ? 'pending' : 'approved';

      if (type == 'expense' && status == 'pending') {
        final childRow = await _supabase
            .from('children')
            .select('balance')
            .eq('id', user.id)
            .maybeSingle();
        final balance = (childRow?['balance'] as num?)?.toDouble() ?? 0.0;
        if (balance < amount) return false;
        // Descontar primeiro; se o insert falhar, devolvemos o valor
        await _deductChildBalance(user.id, amount);
      }

      await _supabase.from('transactions').insert({
        'child_id': user.id,
        'amount': amount,
        'type': type,
        'description': description,
        'category': categoryId,
        'status': status,
        'date': DateTime.now().toIso8601String(),
      });
      return true;
    } catch (_) {
      // Rollback: se era despesa pendente, já descontamos — devolver o valor
      final user = _supabase.auth.currentUser;
      final amount = (data['amount'] as num?)?.toDouble() ?? 0.0;
      final type = (data['type'] ?? 'expense').toString();
      final status = type == 'expense' ? 'pending' : 'approved';
      if (user != null && amount > 0 && type == 'expense' && status == 'pending') {
        try {
          await _creditChildBalance(user.id, amount);
        } catch (_) {}
      }
      return false;
    }
  }

  Future<void> _deductChildBalance(String childId, double amount) async {
    if (childId.isEmpty || amount <= 0) return;
    final row = await _supabase
        .from('children')
        .select('balance')
        .eq('id', childId)
        .maybeSingle();
    final current = (row?['balance'] as num?)?.toDouble() ?? 0.0;
    final updated = double.parse((current - amount).toStringAsFixed(2));
    await _supabase
        .from('children')
        .update({'balance': updated})
        .eq('id', childId);
  }

  Future<void> _creditChildBalance(String childId, double amount) async {
    if (childId.isEmpty || amount <= 0) return;
    final row = await _supabase
        .from('children')
        .select('balance')
        .eq('id', childId)
        .maybeSingle();
    final current = (row?['balance'] as num?)?.toDouble() ?? 0.0;
    final updated = double.parse((current + amount).toStringAsFixed(2));
    await _supabase
        .from('children')
        .update({'balance': updated})
        .eq('id', childId);
  }

  void _applyFilters() {
    final now = DateTime.now();
    DateTime? startDate;

    switch (selectedPeriod) {
      case 'Este mês':
        startDate = DateTime(now.year, now.month, 1);
        break;
      case 'Última semana':
        startDate = now.subtract(const Duration(days: 7));
        break;
      case 'Últimos 3 meses':
        startDate = now.subtract(const Duration(days: 90));
        break;
    }

    Iterable<Map<String, dynamic>> filtered = _allTransactions;

    if (startDate != null) {
      filtered = filtered.where(
        (t) => (t['date'] as DateTime).isAfter(startDate!),
      );
    }

    if (selectedCategory != 'Todas') {
      filtered = filtered.where(
        (t) => t['categoryId'] == selectedCategory,
      );
    }

    final list = filtered.toList();
    _visibleTransactions = list;

    _totalSpent = 0.0;
    _categorySpending = {};

    for (final t in list) {
      final amount = (t['amount'] as num).toDouble();
      _totalSpent += amount;

      final catId = t['categoryId'] as String;
      _categorySpending[catId] = (_categorySpending[catId] ?? 0.0) + amount;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final topPadding = MediaQuery.of(context).padding.top;
    final isSmallScreen = MediaQuery.of(context).size.height < 700;

    if (_isLoading) {
      return Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: SafeArea(child: _buildSkeletonLoader()),
      );
    }

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: BrandedRefreshIndicator(
          onRefresh: _refreshData,
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(
              parent: BouncingScrollPhysics(),
            ),
            slivers: [
              SliverToBoxAdapter(
                child: _buildExpensesHero(
                  context,
                  isSmallScreen,
                  isDark,
                  topPadding,
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 24)),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: _buildTotalCard(context, isSmallScreen),
                )
                    .animate()
                    .fadeIn(duration: 350.ms)
                    .slideY(begin: 0.06, end: 0, curve: Curves.easeOutCubic),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 24)),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: _buildSectionHeader(
                    context,
                    'Gastos por Categoria',
                    Icons.pie_chart_rounded,
                    const Color(0xFFF59E0B),
                  ),
                )
                    .animate()
                    .fadeIn(delay: 80.ms, duration: 300.ms)
                    .slideX(begin: -0.03, end: 0, curve: Curves.easeOut),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 12)),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: _buildChartCard(context),
                )
                    .animate()
                    .fadeIn(delay: 120.ms, duration: 320.ms)
                    .slideY(begin: 0.05, end: 0, curve: Curves.easeOutCubic),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 24)),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: _buildSectionHeader(
                    context,
                    'Filtros',
                    Icons.tune_rounded,
                    Theme.of(context).colorScheme.primary,
                  ),
                )
                    .animate()
                    .fadeIn(delay: 160.ms, duration: 300.ms)
                    .slideX(begin: -0.03, end: 0, curve: Curves.easeOut),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 12)),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: _buildFiltersSection(context),
                )
                    .animate()
                    .fadeIn(delay: 200.ms, duration: 320.ms)
                    .slideY(begin: 0.04, end: 0, curve: Curves.easeOutCubic),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 24)),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: _buildSectionHeader(
                    context,
                    'Transações Recentes',
                    Icons.receipt_long_rounded,
                    const Color(0xFF10B981),
                  ),
                )
                    .animate()
                    .fadeIn(delay: 240.ms, duration: 300.ms)
                    .slideX(begin: -0.03, end: 0, curve: Curves.easeOut),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 12)),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: _buildTransactionsCard(context),
                )
                    .animate()
                    .fadeIn(delay: 280.ms, duration: 320.ms)
                    .slideY(begin: 0.04, end: 0, curve: Curves.easeOutCubic),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 100)),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'fab_expenses',
        onPressed: () async {
          if (_allowedCategories.isEmpty) return;

          final result = await Navigator.push<Map<String, dynamic>>(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  AddExpenseScreen(expenseCategories: _allowedCategories),
            ),
          );

          if (result != null && mounted) {
            final ok = await _saveTransactionToDatabase(result);
            if (!mounted) return;
            await _loadData();
            if (!ok && mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Saldo insuficiente ou erro ao registrar. Tente novamente.',
                    style: GoogleFonts.poppins(),
                  ),
                  backgroundColor: const Color(0xFFEF4444),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            }
          }
        },
        backgroundColor: const Color(0xFFF59E0B),
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_rounded, size: 24),
        label: Text(
          'Registrar gasto',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w700, fontSize: 15),
        ),
        elevation: 4,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  Widget _buildExpensesHero(
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
                  const Color(0xFFB45309),
                  const Color(0xFFD97706),
                  const Color(0xFFF59E0B),
                ]
              : [
                  const Color(0xFFF59E0B),
                  const Color(0xFFD97706),
                  const Color(0xFFB45309),
                ],
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(28),
          bottomRight: Radius.circular(28),
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFD97706).withValues(alpha: 0.4),
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
                  color: Colors.white.withValues(alpha: 0.25),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(
                  Icons.shopping_cart_rounded,
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
                      'Meus Gastos',
                      style: GoogleFonts.poppins(
                        fontSize: isSmallScreen ? 24 : 28,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Acompanhe onde você gastou',
                      style: GoogleFonts.poppins(
                        fontSize: isSmallScreen ? 13 : 15,
                        fontWeight: FontWeight.w500,
                        color: Colors.white.withValues(alpha: 0.95),
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
                Icons.calendar_today_rounded,
                selectedPeriod,
                isSmallScreen,
              ),
              const SizedBox(width: 10),
              _buildHeroStatChip(
                Icons.receipt_rounded,
                '${_visibleTransactions.length} transações',
                isSmallScreen,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHeroStatChip(
    IconData icon,
    String label,
    bool isSmallScreen,
  ) {
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

  Widget _buildSectionHeader(
    BuildContext context,
    String title,
    IconData icon,
    Color accentColor,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: isDark
            ? accentColor.withValues(alpha: 0.08)
            : accentColor.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDark
              ? accentColor.withValues(alpha: 0.2)
              : accentColor.withValues(alpha: 0.35),
          width: isDark ? 1 : 1.5,
        ),
      ),
      child: Row(
        children: [
          Icon(icon, color: accentColor, size: 22),
          const SizedBox(width: 10),
          Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: Theme.of(context).textTheme.titleLarge?.color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTotalCard(BuildContext context, bool isSmallScreen) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final totalGasto = _totalSpent;
    final disponivel = _currentBalance <= 0
        ? totalGasto
        : _currentBalance + totalGasto; // aproximação para barra de uso
    final usado =
        disponivel > 0 ? (totalGasto / disponivel).clamp(0.0, 1.0) : 0.0;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: isSmallScreen ? 18 : 22,
        vertical: isSmallScreen ? 16 : 20,
      ),
      decoration: BoxDecoration(
        color: theme.cardTheme.color ?? theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark
              ? theme.dividerColor
              : const Color(0xFFCBD5E1),
          width: isDark ? 1 : 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.1),
            blurRadius: isDark ? 12 : 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Total gasto',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: theme.textTheme.bodyMedium?.color,
                      ),
                    ),
                    const Gap(4),
                    Text(
                      AppFormatters.formatCurrency(totalGasto),
                      style: GoogleFonts.poppins(
                        fontSize: isSmallScreen ? 20 : 22,
                        fontWeight: FontWeight.w700,
                        color: theme.textTheme.titleLarge?.color,
                        letterSpacing: -0.5,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                width: 1,
                height: 40,
                color: theme.dividerColor,
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'Disponível',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: theme.textTheme.bodyMedium?.color,
                      ),
                    ),
                    const Gap(4),
                    Text(
                      AppFormatters.formatCurrency(_currentBalance),
                      style: GoogleFonts.poppins(
                        fontSize: isSmallScreen ? 20 : 22,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF10B981),
                        letterSpacing: -0.5,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const Gap(16),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: usado.clamp(0.0, 1.0),
              minHeight: 6,
              backgroundColor: (theme.textTheme.bodyMedium?.color ?? Colors.grey).withValues(alpha: 0.15),
              valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFF59E0B)),
            ),
          ),
          const Gap(6),
          Text(
            '${(usado * 100).round()}% do limite usado',
            style: GoogleFonts.poppins(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: theme.textTheme.bodySmall?.color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChartCard(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppConstants.spacingLarge),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? Theme.of(context).dividerColor : const Color(0xFFCBD5E1),
          width: isDark ? 1 : 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.15 : 0.1),
            blurRadius: isDark ? 14 : 18,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          SizedBox(
            width: 140,
            height: 140,
            child: PieChart(
              PieChartData(
                startDegreeOffset: -90,
                sectionsSpace: 2,
                centerSpaceRadius: 48,
                borderData: FlBorderData(show: false),
                sections: _buildPieSections(),
              ),
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ..._categorySpending.entries.map((entry) {
                  final catId = entry.key;
                  final amount = entry.value;
                  final config = _baseCategories.firstWhere(
                    (c) => c['id'] == catId,
                    orElse: () => {
                      'id': catId,
                      'name': catId,
                      'color': const Color(0xFF64748B),
                    },
                  );
                  return _buildLegendItem(
                    config['name'] as String,
                    config['color'] as Color,
                    AppFormatters.formatCurrency(amount),
                  );
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFiltersSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Período',
          style: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Theme.of(context).textTheme.bodyMedium?.color,
          ),
        ),
        const Gap(8),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _buildFilterChip(
                'Este mês',
                selectedPeriod == 'Este mês',
                () => setState(() {
                  selectedPeriod = 'Este mês';
                  _applyFilters();
                }),
              ),
              const SizedBox(width: 8),
              _buildFilterChip(
                'Última semana',
                selectedPeriod == 'Última semana',
                () => setState(() {
                  selectedPeriod = 'Última semana';
                  _applyFilters();
                }),
              ),
              const SizedBox(width: 8),
              _buildFilterChip(
                'Últimos 3 meses',
                selectedPeriod == 'Últimos 3 meses',
                () => setState(() {
                  selectedPeriod = 'Últimos 3 meses';
                  _applyFilters();
                }),
              ),
            ],
          ),
        ),
        const Gap(18),
        Text(
          'Categoria',
          style: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Theme.of(context).textTheme.bodyMedium?.color,
          ),
        ),
        const Gap(8),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _buildFilterChip(
                'Todas',
                selectedCategory == 'Todas',
                () => setState(() {
                  selectedCategory = 'Todas';
                  _applyFilters();
                }),
              ),
              const SizedBox(width: 8),
              ..._allowedCategories.map((category) {
                final id = category['id'] as String;
                final name = category['name'] as String;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: _buildFilterChip(
                    name,
                    selectedCategory == id,
                    () => setState(() {
                      selectedCategory = id;
                      _applyFilters();
                    }),
                  ),
                );
              }),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTransactionsCard(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? Theme.of(context).dividerColor : const Color(0xFFCBD5E1),
          width: isDark ? 1 : 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.15 : 0.1),
            blurRadius: isDark ? 12 : 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ...List.generate(
            _visibleTransactions.length,
            (i) => _buildTransactionItem(
              _visibleTransactions[i]['description'] as String,
              _visibleTransactions[i]['categoryName'] as String,
              AppFormatters.formatCurrency(
                (_visibleTransactions[i]['amount'] as num).toDouble(),
              ),
              _visibleTransactions[i]['color'] as Color,
              i,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(String label, Color color, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: Theme.of(context).textTheme.bodyMedium?.color,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              softWrap: false,
            ),
          ),
          Flexible(
            child: Text(
              value,
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Theme.of(context).textTheme.titleMedium?.color,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.right,
              softWrap: false,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, bool isSelected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected
              ? Theme.of(context).colorScheme.primary
              : Theme.of(context).cardTheme.color,
          borderRadius: BorderRadius.circular(AppConstants.radiusFull),
          border: Border.all(
            color: isSelected
                ? Theme.of(context).colorScheme.primary
                : Theme.of(context).brightness == Brightness.dark
                    ? Theme.of(context).dividerColor
                    : const Color(0xFFCBD5E1),
            width: Theme.of(context).brightness == Brightness.dark ? 1.5 : 2,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : [
                  BoxShadow(
                    color: Colors.black.withValues(
                      alpha: Theme.of(context).brightness == Brightness.dark ? 0.05 : 0.08,
                    ),
                    blurRadius: 4,
                    offset: const Offset(0, 1),
                  ),
                ],
        ),
        child: Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: isSelected
                ? Colors.white
                : Theme.of(context).textTheme.bodyMedium?.color,
          ),
        ),
      ),
    );
  }

  Widget _buildTransactionItem(
    String title,
    String category,
    String amount,
    Color categoryColor,
    int index,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: categoryColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              _getCategoryIcon(category),
              color: categoryColor,
              size: 20,
            ),
          ),
          const Gap(14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Theme.of(context).textTheme.titleMedium?.color,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  softWrap: false,
                ),
                Text(
                  category,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: Theme.of(context).textTheme.bodySmall?.color,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  softWrap: false,
                ),
              ],
            ),
          ),
          Flexible(
            child: Text(
              amount,
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).textTheme.titleMedium?.color,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.right,
              softWrap: false,
            ),
          ),
        ],
      ),
    )
        .animate()
        .fadeIn(delay: (100 + index * 60).ms, duration: 280.ms)
        .slideX(begin: 0.03, end: 0, curve: Curves.easeOut);
  }

  List<PieChartSectionData> _buildPieSections() {
    if (_categorySpending.isEmpty) {
      return [
        PieChartSectionData(
          color: const Color(0xFFE5E7EB),
          value: 1,
          title: '',
          radius: 32,
        ),
      ];
    }

    final total = _categorySpending.values.fold<double>(
      0.0,
      (prev, v) => prev + v,
    );

    if (total == 0) {
      return [
        PieChartSectionData(
          color: const Color(0xFFE5E7EB),
          value: 1,
          title: '',
          radius: 32,
        ),
      ];
    }

    return _categorySpending.entries.map((entry) {
      final catId = entry.key;
      final amount = entry.value;
      final ratio = amount / total;

      final config = _baseCategories.firstWhere(
        (c) => c['id'] == catId,
        orElse: () => {
          'id': catId,
          'name': catId,
          'color': const Color(0xFF64748B),
        },
      );

      return PieChartSectionData(
        color: config['color'] as Color,
        value: ratio * 100,
        title: '',
        radius: 32,
      );
    }).toList();
  }

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'Alimentação':
        return Icons.restaurant;
      case 'Transporte':
        return Icons.directions_bus;
      case 'Jogos e Brinquedos':
        return Icons.sports_esports;
      case 'Metas':
        return Icons.savings;
      default:
        return Icons.category;
    }
  }

  Widget _buildSkeletonLoader() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header skeleton
          const SkeletonText(width: 150, height: 32),
          const SizedBox(height: 8),
          const SkeletonText(width: 200, height: 16),
          const SizedBox(height: 24),
          // Total card skeleton
          SkeletonLoader(
            width: double.infinity,
            height: 120,
            borderRadius: BorderRadius.circular(16),
          ),
          const SizedBox(height: 24),
          // Chart skeleton
          SkeletonLoader(
            width: double.infinity,
            height: 250,
            borderRadius: BorderRadius.circular(16),
          ),
          const SizedBox(height: 24),
          // Categories skeleton
          const SkeletonText(width: 120, height: 20),
          const SizedBox(height: 16),
          ...List.generate(
            5,
            (index) => Padding(
              padding: EdgeInsets.only(bottom: index == 4 ? 0 : 12),
              child: Row(
                children: [
                  SkeletonLoader(
                    width: 48,
                    height: 48,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SkeletonText(width: 120, height: 16),
                        SizedBox(height: 4),
                        SkeletonText(width: 80, height: 12),
                      ],
                    ),
                  ),
                  const SkeletonText(width: 60, height: 16),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
