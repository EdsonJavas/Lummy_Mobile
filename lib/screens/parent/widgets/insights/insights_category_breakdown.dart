import 'package:flutter/material.dart';
import 'package:lummy/core/utils/formatters.dart';
import 'package:lummy/features/parent/presentation/bloc/parent_dashboard_state.dart';
import 'package:lummy/core/theme/design_tokens.dart';

/// Gastos por categoria com barras de progresso.
class InsightsCategoryBreakdown extends StatelessWidget {
  final ParentDashboardState state;
  final bool isDark;

  const InsightsCategoryBreakdown({
    super.key,
    required this.state,
    required this.isDark,
  });

  static const _purple = LummyColors.violet500;
  static const _blue = LummyColors.blue500;
  static const _green = LummyColors.emerald500;
  static const _orange = LummyColors.amber500;
  static const _pink = LummyColors.pink500;
  static const _cyan = LummyColors.cyan500;

  @override
  Widget build(BuildContext context) {
    final colors = [_purple, _blue, _pink, _orange, _cyan, _green];

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isDark ? LummyColors.slate800 : Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isDark ? LummyColors.slate700 : LummyColors.slate200,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.06),
              blurRadius: 16,
              offset: const Offset(0, 6),
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
                    color: _pink.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.pie_chart_rounded, color: _pink, size: 22),
                ),
                const SizedBox(width: 12),
                Text(
                  'Por Categoria',
                  style: LummyFonts.body(
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white : LummyColors.slate800,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            if (state.categoryBreakdown.isEmpty)
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Text(
                    'Sem categorias registradas',
                    style: LummyFonts.body(
                      color: isDark
                          ? LummyColors.slate400
                          : LummyColors.slate500,
                    ),
                  ),
                ),
              )
            else
              ...state.categoryBreakdown.asMap().entries.map((entry) {
                final index = entry.key;
                final item = entry.value;
                final color = colors[index % colors.length];
                final percentage = item.percentage.clamp(0, 100);

                return Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              color: color.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Center(
                              child: Text(
                                _getCategoryEmoji(item.category),
                                style: const TextStyle(fontSize: 16),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              item.category,
                              style: LummyFonts.body(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: isDark
                                    ? Colors.white
                                    : LummyColors.slate800,
                              ),
                            ),
                          ),
                          FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                              AppFormatters.formatCurrency(item.value),
                              style: LummyFonts.body(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: color,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Stack(
                        children: [
                          Container(
                            height: 8,
                            decoration: BoxDecoration(
                              color: color.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                          FractionallySizedBox(
                            widthFactor: percentage / 100,
                            child: Container(
                              height: 8,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [color, color.withValues(alpha: 0.7)],
                                ),
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Align(
                        alignment: Alignment.centerRight,
                        child: Text(
                          '${percentage.toStringAsFixed(1)}%',
                          style: LummyFonts.body(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: isDark
                                ? LummyColors.slate400
                                : LummyColors.slate500,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }),
          ],
        ),
      ),
    );
  }

  String _getCategoryEmoji(String category) {
    const emojis = {
      'Alimentação': '🍔',
      'Transporte': '🚗',
      'Lazer': '🎮',
      'Educação': '📚',
      'Saúde': '💊',
      'Roupas': '👕',
      'Tecnologia': '📱',
      'Jogos': '🎲',
      'Outros': '📦',
    };
    return emojis[category] ?? '📦';
  }
}
