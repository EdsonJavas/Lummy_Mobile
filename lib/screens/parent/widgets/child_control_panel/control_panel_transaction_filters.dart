import 'package:flutter/material.dart';

import 'package:lummy/core/theme/design_tokens.dart';
import 'package:lummy/screens/parent/widgets/child_control_panel/control_panel_filter_chip.dart';

/// Filtros (período, tipo e categoria) da aba Transações.
class ControlPanelTransactionFilters extends StatelessWidget {
  final List<Map<String, dynamic>> recentTransactions;
  final String filterPeriod;
  final String filterType;
  final String filterCategory;
  final ValueChanged<String> onPeriodChanged;
  final ValueChanged<String> onTypeChanged;
  final ValueChanged<String> onCategoryChanged;
  final bool isDark;

  const ControlPanelTransactionFilters({
    super.key,
    required this.recentTransactions,
    required this.filterPeriod,
    required this.filterType,
    required this.filterCategory,
    required this.onPeriodChanged,
    required this.onTypeChanged,
    required this.onCategoryChanged,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final categories = recentTransactions
        .map((t) => t['category'] as String?)
        .whereType<String>()
        .toSet()
        .toList()
      ..sort();
    categories.insert(0, 'Todas');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Filtros',
          style: LummyFonts.body(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: isDark ? Colors.white : LummyColors.slate800,
          ),
        ),
        const SizedBox(height: 8),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              ControlPanelFilterChip(label: 'Todas', selected: filterPeriod == 'Todas', onTap: () => onPeriodChanged('Todas')),
              const SizedBox(width: 8),
              ControlPanelFilterChip(label: 'Este mês', selected: filterPeriod == 'Este mês', onTap: () => onPeriodChanged('Este mês')),
              const SizedBox(width: 8),
              ControlPanelFilterChip(label: 'Última semana', selected: filterPeriod == 'Última semana', onTap: () => onPeriodChanged('Última semana')),
              const SizedBox(width: 8),
              ControlPanelFilterChip(label: '3 meses', selected: filterPeriod == 'Últimos 3 meses', onTap: () => onPeriodChanged('Últimos 3 meses')),
            ],
          ),
        ),
        const SizedBox(height: 10),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              ControlPanelFilterChip(label: 'Todas', selected: filterType == 'Todas', onTap: () => onTypeChanged('Todas')),
              const SizedBox(width: 8),
              ControlPanelFilterChip(label: 'Entradas', selected: filterType == 'income', onTap: () => onTypeChanged('income')),
              const SizedBox(width: 8),
              ControlPanelFilterChip(label: 'Gastos', selected: filterType == 'expense', onTap: () => onTypeChanged('expense')),
            ],
          ),
        ),
        if (categories.length > 1) ...[
          const SizedBox(height: 10),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: categories.map((c) {
                final sel = filterCategory == c;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ControlPanelFilterChip(label: c, selected: sel, onTap: () => onCategoryChanged(c)),
                );
              }).toList(),
            ),
          ),
        ],
      ],
    );
  }
}
