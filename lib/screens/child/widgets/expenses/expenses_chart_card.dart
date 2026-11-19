import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:lummy/core/constants/app_constants.dart';
import 'package:lummy/core/theme/design_tokens.dart';
import 'package:lummy/core/utils/formatters.dart';

/// Card com o gráfico de pizza e a legenda de gastos por categoria.
class ExpensesChartCard extends StatelessWidget {
  final Map<String, double> categorySpending;
  final List<Map<String, dynamic>> baseCategories;

  const ExpensesChartCard({
    super.key,
    required this.categorySpending,
    required this.baseCategories,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final hasData = categorySpending.isNotEmpty;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppConstants.spacingLarge),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? Theme.of(context).dividerColor : LummyColors.slate300,
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
      child: hasData
          ? Row(
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
                      ...categorySpending.entries.map((entry) {
                        final catId = entry.key;
                        final amount = entry.value;
                        final config = baseCategories.firstWhere(
                          (c) => c['id'] == catId,
                          orElse: () => {
                            'id': catId,
                            'name': catId,
                            'color': LummyColors.slate500,
                          },
                        );
                        return _buildLegendItem(
                          context,
                          config['name'] as String,
                          config['color'] as Color,
                          AppFormatters.formatCurrency(amount),
                        );
                      }),
                    ],
                  ),
                ),
              ],
            )
          : Padding(
              padding: const EdgeInsets.symmetric(vertical: 28),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 48, height: 48,
                    decoration: BoxDecoration(
                      color: isDark
                          ? LummyColors.violet500.withValues(alpha: 0.1)
                          : LummyColors.violet500.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    alignment: Alignment.center,
                    child: Icon(
                      Icons.pie_chart_outline_rounded,
                      size: 24,
                      color: isDark ? LummyColors.violet600 : LummyColors.violet500,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Nenhum gasto neste período',
                    style: LummyFonts.body(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: isDark ? LummyColors.slate400 : LummyColors.slate500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Registre um gasto para visualizar o gráfico',
                    style: LummyFonts.body(
                      fontSize: 11,
                      color: isDark ? LummyColors.slate500 : LummyColors.slate400,
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildLegendItem(
    BuildContext context,
    String label,
    Color color,
    String value,
  ) {
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
              style: LummyFonts.body(
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
              style: LummyFonts.body(
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

  List<PieChartSectionData> _buildPieSections() {
    if (categorySpending.isEmpty) {
      return [
        PieChartSectionData(
          color: LummyColors.gray200,
          value: 1,
          title: '',
          radius: 32,
        ),
      ];
    }

    final total = categorySpending.values.fold<double>(
      0.0,
      (prev, v) => prev + v,
    );

    if (total == 0) {
      return [
        PieChartSectionData(
          color: LummyColors.gray200,
          value: 1,
          title: '',
          radius: 32,
        ),
      ];
    }

    return categorySpending.entries.map((entry) {
      final catId = entry.key;
      final amount = entry.value;
      final ratio = amount / total;

      final config = baseCategories.firstWhere(
        (c) => c['id'] == catId,
        orElse: () => {
          'id': catId,
          'name': catId,
          'color': LummyColors.slate500,
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
}
