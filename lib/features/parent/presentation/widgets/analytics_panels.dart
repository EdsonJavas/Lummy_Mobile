import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/utils/formatters.dart';
import '../../presentation/bloc/parent_dashboard_state.dart';
import '../../../../shared/widgets/custom_card.dart';

class ParentAnalyticsPanels extends StatelessWidget {
  final List<MonthlySpendingPoint> monthlyTrend;
  final double monthExpenseTotal;
  final double monthIncomeTotal;
  final List<CategorySpendingData> categoryBreakdown;
  final List<ChildGoalSummary> goalSummaries;

  const ParentAnalyticsPanels({
    super.key,
    required this.monthlyTrend,
    required this.monthExpenseTotal,
    required this.monthIncomeTotal,
    required this.categoryBreakdown,
    required this.goalSummaries,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth > 900;
        const spacing = AppConstants.spacingLarge;
        final trendCard = _buildTrendCard(context, compact: !isWide);
        final categoryCard = _buildCategoryCard(context);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (isWide)
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: trendCard),
                  const SizedBox(width: AppConstants.spacingMedium),
                  Expanded(child: categoryCard),
                ],
              )
            else ...[
              trendCard,
              const SizedBox(height: spacing),
              categoryCard,
            ],
            const SizedBox(height: spacing),
            _buildGoalsCard(context),
          ],
        );
      },
    );
  }

  Widget _buildTrendCard(BuildContext context, {required bool compact}) {
    final colorScheme = Theme.of(context).colorScheme;
    final chartHeight = compact ? 260.0 : 320.0;

    return CustomCard(
      padding: EdgeInsets.all(compact ? 16 : 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Flexible(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Fluxo mensal',
                      style: GoogleFonts.poppins(
                        fontSize: compact ? 18 : 20,
                        fontWeight: FontWeight.w600,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Comparativo de receitas e despesas dos últimos meses',
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        fontWeight: FontWeight.w400,
                        color: colorScheme.onSurface.withOpacity(0.7),
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 2,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppConstants.spacingMedium),
              Flexible(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildChip(
                      context,
                      label:
                          'Receitas: ${AppFormatters.formatCurrency(monthIncomeTotal)}',
                      color: colorScheme.tertiary,
                    ),
                    const SizedBox(height: 8),
                    _buildChip(
                      context,
                      label:
                          'Despesas: ${AppFormatters.formatCurrency(monthExpenseTotal)}',
                      color: colorScheme.error,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppConstants.spacingLarge),
          SizedBox(
            height: chartHeight,
            child: LineChart(
              LineChartData(
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  getDrawingHorizontalLine: (value) => FlLine(
                    color: colorScheme.onSurface.withOpacity(0.08),
                    strokeWidth: 1,
                  ),
                ),
                titlesData: FlTitlesData(
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        final index = value.toInt();
                        if (index < 0 || index >= monthlyTrend.length) {
                          return const SizedBox.shrink();
                        }
                        return Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(
                            monthlyTrend[index].monthLabel,
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              color: colorScheme.onSurface.withOpacity(0.7),
                            ),
                          ),
                        );
                      },
                      interval: 1,
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 44,
                      getTitlesWidget: (value, meta) => Text(
                        AppFormatters.formatLargeNumber(value),
                        style: GoogleFonts.poppins(
                          fontSize: 11,
                          color: colorScheme.onSurface.withOpacity(0.5),
                        ),
                      ),
                    ),
                  ),
                ),
                borderData: FlBorderData(
                  show: true,
                  border: Border(
                    bottom: BorderSide(
                      color: colorScheme.onSurface.withOpacity(0.12),
                    ),
                    left: BorderSide(
                      color: colorScheme.onSurface.withOpacity(0.12),
                    ),
                    right: const BorderSide(color: Colors.transparent),
                    top: const BorderSide(color: Colors.transparent),
                  ),
                ),
                lineTouchData: LineTouchData(
                  touchTooltipData: LineTouchTooltipData(
                    tooltipBorderRadius: BorderRadius.circular(
                      AppConstants.radiusMedium,
                    ),
                    tooltipPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    getTooltipItems: (spots) => spots.map((spot) {
                      final index = spot.x.toInt();
                      if (index < 0 || index >= monthlyTrend.length) {
                        return LineTooltipItem(
                          AppFormatters.formatCurrency(spot.y),
                          GoogleFonts.poppins(
                            color: colorScheme.onSurface,
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
                        );
                      }
                      return LineTooltipItem(
                        '${monthlyTrend[index].month} \n${AppFormatters.formatCurrency(spot.y)}',
                        GoogleFonts.poppins(
                          color: colorScheme.onSurface,
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      );
                    }).toList(),
                  ),
                ),
                minX: 0,
                maxX: monthlyTrend.isEmpty
                    ? 0
                    : (monthlyTrend.length - 1).toDouble(),
                lineBarsData: [
                  _buildLine(
                    monthlyTrend,
                    (point) => point.expense,
                    colorScheme.error,
                  ),
                  _buildLine(
                    monthlyTrend,
                    (point) => point.income,
                    colorScheme.tertiary,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryCard(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return CustomCard(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Categorias de gasto',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: AppConstants.spacingMedium),
          SizedBox(
            height: 200,
            child: PieChart(
              PieChartData(
                sectionsSpace: 2,
                centerSpaceRadius: 50,
                sections: categoryBreakdown
                    .map(
                      (item) => PieChartSectionData(
                        color: item.color,
                        value: item.value,
                        title: '${item.percentage.toStringAsFixed(0)}%',
                        radius: 70,
                        titleStyle: GoogleFonts.poppins(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                      ),
                    )
                    .toList(),
              ),
            ),
          ),
          const SizedBox(height: AppConstants.spacingMedium),
          ...categoryBreakdown.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                children: [
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: item.color,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      item.category,
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        color: colorScheme.onSurface.withOpacity(0.7),
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      AppFormatters.formatCurrency(item.value),
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: colorScheme.onSurface,
                      ),
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.end,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGoalsCard(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return CustomCard(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Progresso das metas',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: AppConstants.spacingMedium),
          ...goalSummaries.map(
            (summary) => Padding(
              padding: const EdgeInsets.only(
                bottom: AppConstants.spacingMedium,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        summary.childName,
                        style: GoogleFonts.poppins(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: colorScheme.onSurface,
                        ),
                      ),
                      Text(
                        '${summary.completedGoals}/${summary.totalGoals} concluídas',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: colorScheme.onSurface.withOpacity(0.7),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(
                      AppConstants.radiusSmall,
                    ),
                    child: LinearProgressIndicator(
                      value: summary.averageProgress.clamp(0.0, 1.0),
                      minHeight: 8,
                      backgroundColor: colorScheme.primary.withOpacity(0.08),
                      valueColor: AlwaysStoppedAnimation<Color>(
                        colorScheme.primary,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Avanço médio',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: colorScheme.onSurface.withOpacity(0.6),
                        ),
                      ),
                      Text(
                        AppFormatters.formatPercentage(summary.averageProgress),
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  LineChartBarData _buildLine(
    List<MonthlySpendingPoint> data,
    double Function(MonthlySpendingPoint) selector,
    Color color,
  ) {
    return LineChartBarData(
      isCurved: true,
      color: color,
      barWidth: 3,
      dotData: const FlDotData(show: false),
      spots: List.generate(
        data.length,
        (index) => FlSpot(index.toDouble(), selector(data[index])),
      ),
      belowBarData: BarAreaData(
        show: true,
        gradient: LinearGradient(
          colors: [color.withOpacity(0.15), color.withOpacity(0.02)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
    );
  }

  Widget _buildChip(
    BuildContext context, {
    required String label,
    required Color color,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppConstants.radiusSmall),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Text(
        label,
        style: GoogleFonts.poppins(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: colorScheme.onSurface,
        ),
        overflow: TextOverflow.ellipsis,
        maxLines: 1,
      ),
    );
  }
}
