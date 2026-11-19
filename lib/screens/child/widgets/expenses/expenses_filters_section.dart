import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:lummy/core/constants/app_constants.dart';
import 'package:lummy/core/theme/design_tokens.dart';

/// Filtros de período e categoria da tela de gastos.
class ExpensesFiltersSection extends StatelessWidget {
  final String selectedPeriod;
  final String selectedCategory;
  final List<Map<String, dynamic>> allowedCategories;
  final ValueChanged<String> onPeriodSelected;
  final ValueChanged<String> onCategorySelected;

  const ExpensesFiltersSection({
    super.key,
    required this.selectedPeriod,
    required this.selectedCategory,
    required this.allowedCategories,
    required this.onPeriodSelected,
    required this.onCategorySelected,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Período',
          style: LummyFonts.body(
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
                context,
                'Este mês',
                selectedPeriod == 'Este mês',
                () => onPeriodSelected('Este mês'),
              ),
              const SizedBox(width: 8),
              _buildFilterChip(
                context,
                'Última semana',
                selectedPeriod == 'Última semana',
                () => onPeriodSelected('Última semana'),
              ),
              const SizedBox(width: 8),
              _buildFilterChip(
                context,
                'Últimos 3 meses',
                selectedPeriod == 'Últimos 3 meses',
                () => onPeriodSelected('Últimos 3 meses'),
              ),
            ],
          ),
        ),
        const Gap(18),
        Text(
          'Categoria',
          style: LummyFonts.body(
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
                context,
                'Todas',
                selectedCategory == 'Todas',
                () => onCategorySelected('Todas'),
              ),
              const SizedBox(width: 8),
              ...allowedCategories.map((category) {
                final id = category['id'] as String;
                final name = category['name'] as String;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: _buildFilterChip(
                    context,
                    name,
                    selectedCategory == id,
                    () => onCategorySelected(id),
                  ),
                );
              }),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFilterChip(
    BuildContext context,
    String label,
    bool isSelected,
    VoidCallback onTap,
  ) {
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
                    : LummyColors.slate300,
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
          style: LummyFonts.body(
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
}
