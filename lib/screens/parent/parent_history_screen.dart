import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import 'package:lummy_login/core/constants/app_constants.dart';
import 'package:lummy_login/core/utils/formatters.dart';
import 'package:lummy_login/domain/entities/transaction_entity.dart';
import 'package:lummy_login/features/parent/presentation/bloc/parent_dashboard_cubit.dart';
import 'package:lummy_login/features/parent/presentation/bloc/parent_dashboard_state.dart';
import 'package:lummy_login/shared/widgets/widgets.dart';

class ParentHistoryScreen extends StatefulWidget {
  const ParentHistoryScreen({super.key});

  @override
  State<ParentHistoryScreen> createState() => _ParentHistoryScreenState();
}

class _ParentHistoryScreenState extends State<ParentHistoryScreen> {
  String _filterType = 'all';
  String _filterStatus = 'all';

  static const _blue = Color(0xFF3B82F6);
  static const _green = Color(0xFF10B981);
  static const _red = Color(0xFFEF4444);
  static const _orange = Color(0xFFF59E0B);
  static const _purple = Color(0xFF8B5CF6);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? const Color(0xFF0F0F0F) : const Color(0xFFF1F5F9);
    final cardBg = isDark ? const Color(0xFF1A1A2E) : Colors.white;
    final titleColor = isDark ? Colors.white : const Color(0xFF0F172A);
    final subtitleColor =
        isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);
    final borderColor =
        isDark ? const Color(0xFF2D2D2D) : const Color(0xFFE2E8F0);

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        title: Text(
          'Histórico',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        backgroundColor: Colors.transparent,
        foregroundColor: titleColor,
        elevation: 0,
      ),
      body: BlocBuilder<ParentDashboardCubit, ParentDashboardState>(
        builder: (context, state) {
          final allTransactions = _getAllTransactions(state);
          final filtered = _applyFilters(allTransactions);

          return Column(
            children: [
              _buildFilterChips(isDark),
              Expanded(
                child: filtered.isEmpty
                    ? const EmptyState(
                        emoji: '📋',
                        title: 'Sem transações',
                        message:
                            'As transações aparecerão aqui à medida que movimentações forem realizadas.',
                        icon: Icons.receipt_long_rounded,
                        iconColor: Color(0xFF3B82F6),
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                        itemCount: filtered.length,
                        separatorBuilder: (_, __) =>
                            const SizedBox(height: 8),
                        itemBuilder: (_, i) => _buildTransactionTile(
                          filtered[i],
                          cardBg,
                          titleColor,
                          subtitleColor,
                          borderColor,
                          isDark,
                        ),
                      ),
              ),
            ],
          );
        },
      ),
    );
  }

  List<TransactionEntity> _getAllTransactions(ParentDashboardState state) {
    return [...state.pendingApprovals];
  }

  List<TransactionEntity> _applyFilters(List<TransactionEntity> txs) {
    var result = txs;
    if (_filterType != 'all') {
      result = result.where((t) => t.type.name == _filterType).toList();
    }
    if (_filterStatus != 'all') {
      result = result.where((t) => t.status.name == _filterStatus).toList();
    }
    result.sort((a, b) => b.date.compareTo(a.date));
    return result;
  }

  Widget _buildFilterChips(bool isDark) {
    final chipBg = isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0);
    final activeBg = _blue;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          _chip('Todos', 'all', _filterType, chipBg, activeBg, (v) {
            setState(() => _filterType = v);
          }),
          const SizedBox(width: 8),
          _chip('Entradas', 'income', _filterType, chipBg, activeBg, (v) {
            setState(() => _filterType = v);
          }),
          const SizedBox(width: 8),
          _chip('Gastos', 'expense', _filterType, chipBg, activeBg, (v) {
            setState(() => _filterType = v);
          }),
          const SizedBox(width: 8),
          _chip('Mesada', 'allowance', _filterType, chipBg, activeBg, (v) {
            setState(() => _filterType = v);
          }),
          const SizedBox(width: 16),
          _chip('Pendentes', 'pending', _filterStatus, chipBg, _orange, (v) {
            setState(() => _filterStatus = _filterStatus == v ? 'all' : v);
          }),
          const SizedBox(width: 8),
          _chip('Aprovados', 'approved', _filterStatus, chipBg, _green, (v) {
            setState(() => _filterStatus = _filterStatus == v ? 'all' : v);
          }),
        ],
      ),
    );
  }

  Widget _chip(
    String label,
    String value,
    String current,
    Color chipBg,
    Color activeBg,
    ValueChanged<String> onTap,
  ) {
    final isActive = current == value;
    return GestureDetector(
      onTap: () => onTap(value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? activeBg : chipBg,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: isActive ? Colors.white : null,
          ),
        ),
      ),
    );
  }

  Widget _buildTransactionTile(
    TransactionEntity tx,
    Color cardBg,
    Color titleColor,
    Color subtitleColor,
    Color borderColor,
    bool isDark,
  ) {
    final isIncome = tx.isIncome;
    final color = isIncome ? _green : _red;
    final statusColor = switch (tx.status) {
      TransactionStatus.pending => _orange,
      TransactionStatus.approved => _green,
      TransactionStatus.rejected => _red,
      TransactionStatus.completed => _blue,
    };
    final statusLabel = switch (tx.status) {
      TransactionStatus.pending => 'Pendente',
      TransactionStatus.approved => 'Aprovado',
      TransactionStatus.rejected => 'Rejeitado',
      TransactionStatus.completed => 'Concluído',
    };
    final categoryEmoji =
        AppConstants.categoryEmojis[tx.category] ?? '📦';

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            alignment: Alignment.center,
            child: Text(categoryEmoji, style: const TextStyle(fontSize: 20)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  tx.description,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: titleColor,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Text(
                      DateFormat('dd/MM HH:mm').format(tx.date),
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: subtitleColor,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: statusColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        statusLabel,
                        style: GoogleFonts.poppins(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: statusColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Text(
            '${isIncome ? '+' : '-'} ${AppFormatters.formatCurrency(tx.amount)}',
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
