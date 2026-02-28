import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';
import 'add_expense_screen.dart';
import 'core/constants/app_constants.dart';
import 'shared/widgets/widgets.dart';

class ExpensesScreen extends StatefulWidget {
  const ExpensesScreen({super.key});

  @override
  State<ExpensesScreen> createState() => _ExpensesScreenState();
}

class _ExpensesScreenState extends State<ExpensesScreen> {
  String selectedPeriod = 'Este mês';
  String selectedCategory = 'Todas';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });

    // Simular carregamento de dados do banco
    await Future.delayed(const Duration(milliseconds: 800));

    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _refreshData() async {
    await _loadData();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: SafeArea(child: _buildSkeletonLoader()),
      );
    }

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final result = await Navigator.push<Map<String, dynamic>>(
            context,
            MaterialPageRoute(
              builder: (context) => const AddExpenseScreen(),
            ),
          );
          if (result != null && mounted) _loadData();
        },
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_rounded),
        label: Text(
          'Registrar',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 15),
        ),
      ),
      body: SafeArea(
        child: BrandedRefreshIndicator(
          onRefresh: _refreshData,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(
              parent: BouncingScrollPhysics(),
            ),
            padding: const EdgeInsets.fromLTRB(
              AppConstants.spacingMedium,
              AppConstants.spacingMedium,
              AppConstants.spacingMedium,
              80,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Meus Gastos',
                      style: GoogleFonts.poppins(
                        fontSize: 26,
                        fontWeight: FontWeight.w700,
                        color: Theme.of(context).textTheme.titleLarge?.color,
                        letterSpacing: -0.5,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ).animate().fadeIn(duration: 200.ms).slideX(begin: -0.05, end: 0, curve: Curves.easeOut),
                    const Gap(6),
                    Text(
                      'Acompanhe onde você gastou e registre novos gastos',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Theme.of(context).textTheme.bodyMedium?.color,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ).animate().fadeIn(delay: 80.ms, duration: 200.ms),
                  ],
                ),
                const Gap(24),

                // Resumo dos gastos
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(AppConstants.spacingLarge),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Theme.of(context).colorScheme.primary,
                        Theme.of(context).colorScheme.primary.withValues(alpha: 0.85),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(AppConstants.radiusLarge),
                    boxShadow: [
                      BoxShadow(
                        color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.25),
                        blurRadius: 14,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.pie_chart_rounded, color: Colors.white.withValues(alpha: 0.95), size: 22),
                          const Gap(10),
                          Text(
                            'Total Gasto',
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.white.withValues(alpha: 0.95),
                            ),
                          ),
                        ],
                      ),
                      const Gap(10),
                      Text(
                        'R\$ 1.247,50',
                        style: GoogleFonts.poppins(
                          fontSize: 28,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const Gap(6),
                      Text(
                        'de R\$ 2.000,00 disponíveis',
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          color: Colors.white.withValues(alpha: 0.85),
                        ),
                      ),
                    ],
                  ),
                ),
                const Gap(20),

                // Gráfico de gastos
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(AppConstants.spacingLarge),
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardTheme.color,
                    borderRadius: BorderRadius.circular(AppConstants.radiusLarge),
                    border: Theme.of(context).brightness == Brightness.dark
                        ? Border.all(color: Theme.of(context).dividerColor)
                        : null,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.06),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Gastos por Categoria',
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Theme.of(context).textTheme.titleLarge?.color,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          // Gráfico estilizado
                          SizedBox(
                            width: 140,
                            height: 140,
                            child: PieChart(
                              PieChartData(
                                startDegreeOffset: -90,
                                sectionsSpace: 2,
                                centerSpaceRadius: 48,
                                borderData: FlBorderData(show: false),
                                sections: [
                                  PieChartSectionData(
                                    color: const Color(0xFF8B5CF6),
                                    value: 35,
                                    title: '',
                                    radius: 32,
                                  ),
                                  PieChartSectionData(
                                    color: const Color(0xFF3B82F6),
                                    value: 25,
                                    title: '',
                                    radius: 32,
                                  ),
                                  PieChartSectionData(
                                    color: const Color(0xFF10B981),
                                    value: 20,
                                    title: '',
                                    radius: 32,
                                  ),
                                  PieChartSectionData(
                                    color: const Color(0xFFF59E0B),
                                    value: 15,
                                    title: '',
                                    radius: 32,
                                  ),
                                  PieChartSectionData(
                                    color: const Color(0xFFE5E7EB),
                                    value: 5,
                                    title: '',
                                    radius: 32,
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 20),
                          // Legenda
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildLegendItem(
                                  'Metas',
                                  const Color(0xFF8B5CF6),
                                  'R\$ 436,63',
                                ),
                                _buildLegendItem(
                                  'Transporte',
                                  const Color(0xFF3B82F6),
                                  'R\$ 311,88',
                                ),
                                _buildLegendItem(
                                  'Jogos e Brinquedos',
                                  const Color(0xFF10B981),
                                  'R\$ 249,50',
                                ),
                                _buildLegendItem(
                                  'Alimentação',
                                  const Color(0xFFF59E0B),
                                  'R\$ 187,13',
                                ),
                                _buildLegendItem(
                                  'Outros',
                                  const Color(0xFFE5E7EB),
                                  'R\$ 62,36',
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const Gap(24),

                // Filtros com Chips
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Filtros',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).textTheme.titleLarge?.color,
                      ),
                    ),
                    const Gap(16),

                    // Filtro de Período
                    Text(
                      'Período',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
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
                            () => setState(() => selectedPeriod = 'Este mês'),
                          ),
                          const SizedBox(width: 8),
                          _buildFilterChip(
                            'Última semana',
                            selectedPeriod == 'Última semana',
                            () => setState(
                              () => selectedPeriod = 'Última semana',
                            ),
                          ),
                          const SizedBox(width: 8),
                          _buildFilterChip(
                            'Últimos 3 meses',
                            selectedPeriod == 'Últimos 3 meses',
                            () => setState(
                              () => selectedPeriod = 'Últimos 3 meses',
                            ),
                          ),
                        ],
                      ),
                    ),

                    const Gap(20),

                    // Filtro de Categoria
                    Text(
                      'Categoria',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Theme.of(context).textTheme.bodyMedium?.color,
                      ),
                    ),
                    const SizedBox(height: 8),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          _buildFilterChip(
                            'Todas',
                            selectedCategory == 'Todas',
                            () => setState(() => selectedCategory = 'Todas'),
                          ),
                          const SizedBox(width: 8),
                          _buildFilterChip(
                            'Metas',
                            selectedCategory == 'Metas',
                            () => setState(() => selectedCategory = 'Metas'),
                          ),
                          const SizedBox(width: 8),
                          _buildFilterChip(
                            'Transporte',
                            selectedCategory == 'Transporte',
                            () =>
                                setState(() => selectedCategory = 'Transporte'),
                          ),
                          const SizedBox(width: 8),
                          _buildFilterChip(
                            'Alimentação',
                            selectedCategory == 'Alimentação',
                            () => setState(
                              () => selectedCategory = 'Alimentação',
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const Gap(24),

                // Lista de transações
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardTheme.color,
                    borderRadius: BorderRadius.circular(16),
                    border: Theme.of(context).brightness == Brightness.dark
                        ? Border.all(color: Theme.of(context).dividerColor)
                        : null,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Transações Recentes',
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Theme.of(context).textTheme.titleLarge?.color,
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildTransactionItem(
                        'Lanche na escola',
                        'Alimentação',
                        'R\$ 15,50',
                        const Color(0xFFF59E0B),
                        0,
                      ),
                      _buildTransactionItem(
                        'Ônibus',
                        'Transporte',
                        'R\$ 4,50',
                        const Color(0xFF3B82F6),
                        1,
                      ),
                      _buildTransactionItem(
                        'Jogo novo',
                        'Jogos e Brinquedos',
                        'R\$ 29,90',
                        const Color(0xFF10B981),
                        2,
                      ),
                      _buildTransactionItem(
                        'Mesada guardada',
                        'Metas',
                        'R\$ 50,00',
                        const Color(0xFF8B5CF6),
                        3,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
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
                    : const Color(AppConstants.borderLight),
            width: 1.5,
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
                    color: Colors.black.withValues(alpha: 0.05),
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
