import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:lummy/screens/child/add_expense_screen.dart';
import 'package:lummy/screens/child/widgets/expenses/expenses_chart_card.dart';
import 'package:lummy/screens/child/widgets/expenses/expenses_filters_section.dart';
import 'package:lummy/screens/child/widgets/expenses/expenses_hero.dart';
import 'package:lummy/screens/child/widgets/expenses/expenses_load_error.dart';
import 'package:lummy/screens/child/widgets/expenses/expenses_section_header.dart';
import 'package:lummy/screens/child/widgets/expenses/expenses_skeleton_loader.dart';
import 'package:lummy/screens/child/widgets/expenses/expenses_total_card.dart';
import 'package:lummy/screens/child/widgets/expenses/expenses_transactions_card.dart';
import 'package:lummy/shared/widgets/widgets.dart';
import 'package:lummy/core/utils/app_log.dart';
import 'package:lummy/core/theme/design_tokens.dart';

class ExpensesScreen extends StatefulWidget {
  const ExpensesScreen({super.key});

  @override
  State<ExpensesScreen> createState() => _ExpensesScreenState();
}

class _ExpensesScreenState extends State<ExpensesScreen> {
  String selectedPeriod = 'Este mês';
  String selectedCategory = 'Todas'; // 'Todas' ou id da categoria
  bool _isLoading = true;
  String? _loadError;

  final _supabase = Supabase.instance.client;

  // Categorias base (devem bater com as ids usadas nas configurações do responsável)
  // id: usado no banco; name: exibido na UI; color: usado em gráficos/listas
  final List<Map<String, dynamic>> _baseCategories = [
    {
      'id': 'games',
      'name': 'Jogos',
      'color': LummyColors.violet500,
    },
    {
      'id': 'food',
      'name': 'Alimentação',
      'color': LummyColors.amber500,
    },
    {
      'id': 'education',
      'name': 'Educação',
      'color': LummyColors.blue500,
    },
    {
      'id': 'clothes',
      'name': 'Roupas',
      'color': LummyColors.pink500,
    },
    {
      'id': 'entertainment',
      'name': 'Entretenimento',
      'color': LummyColors.red500,
    },
    {
      'id': 'toys',
      'name': 'Brinquedos',
      'color': LummyColors.emerald500,
    },
    {
      'id': 'sports',
      'name': 'Esportes',
      'color': LummyColors.cyan500,
    },
    {
      'id': 'other',
      'name': 'Outros',
      'color': LummyColors.slate500,
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
      _loadError = null;
    });

    try {
      final user = _supabase.auth.currentUser;
      if (user == null) {
        setState(() {
          _isLoading = false;
          _loadError = 'Sessão não encontrada. Entre de novo no app.';
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
            'color': LummyColors.slate500,
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
        _loadError = null;
      });
    } catch (e, st) {
      appLog('❌ expenses_screen _loadData: $e\n$st');
      setState(() {
        _isLoading = false;
        _loadError =
            'Não foi possível carregar seus gastos. Verifique a internet e tente de novo.';
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
        body: const SafeArea(child: ExpensesSkeletonLoader()),
      );
    }

    if (_loadError != null) {
      return Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: SafeArea(
          child: ExpensesLoadError(
            message: _loadError!,
            onRetry: _loadData,
          ),
        ),
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
                child: ExpensesHero(
                  isSmallScreen: isSmallScreen,
                  isDark: isDark,
                  topPadding: topPadding,
                  selectedPeriod: selectedPeriod,
                  transactionCount: _visibleTransactions.length,
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 24)),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: ExpensesTotalCard(
                    isSmallScreen: isSmallScreen,
                    currentBalance: _currentBalance,
                    totalSpent: _totalSpent,
                    selectedPeriod: selectedPeriod,
                    selectedCategory: selectedCategory,
                  ),
                )
                    .animate()
                    .fadeIn(duration: 350.ms)
                    .slideY(begin: 0.06, end: 0, curve: Curves.easeOutCubic),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 24)),
              SliverToBoxAdapter(
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: ExpensesSectionHeader(
                    title: 'Gastos por Categoria',
                    icon: Icons.pie_chart_rounded,
                    accentColor: LummyColors.amber500,
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
                  child: ExpensesChartCard(
                    categorySpending: _categorySpending,
                    baseCategories: _baseCategories,
                  ),
                )
                    .animate()
                    .fadeIn(delay: 120.ms, duration: 320.ms)
                    .slideY(begin: 0.05, end: 0, curve: Curves.easeOutCubic),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 24)),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: ExpensesSectionHeader(
                    title: 'Filtros',
                    icon: Icons.tune_rounded,
                    accentColor: Theme.of(context).colorScheme.primary,
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
                  child: ExpensesFiltersSection(
                    selectedPeriod: selectedPeriod,
                    selectedCategory: selectedCategory,
                    allowedCategories: _allowedCategories,
                    onPeriodSelected: (period) => setState(() {
                      selectedPeriod = period;
                      _applyFilters();
                    }),
                    onCategorySelected: (id) => setState(() {
                      selectedCategory = id;
                      _applyFilters();
                    }),
                  ),
                )
                    .animate()
                    .fadeIn(delay: 200.ms, duration: 320.ms)
                    .slideY(begin: 0.04, end: 0, curve: Curves.easeOutCubic),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 24)),
              SliverToBoxAdapter(
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: ExpensesSectionHeader(
                    title: 'Transações Recentes',
                    icon: Icons.receipt_long_rounded,
                    accentColor: LummyColors.emerald500,
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
                  child: ExpensesTransactionsCard(
                    visibleTransactions: _visibleTransactions,
                  ),
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
            if (!ok && context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Saldo insuficiente ou erro ao registrar. Tente novamente.',
                    style: LummyFonts.body(),
                  ),
                  backgroundColor: LummyColors.red500,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            }
          }
        },
        backgroundColor: LummyColors.amber500,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_rounded, size: 24),
        label: Text(
          'Registrar gasto',
          style: LummyFonts.body(fontWeight: FontWeight.w700, fontSize: 15),
        ),
        elevation: 4,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}
