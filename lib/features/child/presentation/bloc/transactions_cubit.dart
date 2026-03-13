import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../domain/entities/transaction_entity.dart';
import 'transactions_state.dart';

class TransactionsCubit extends Cubit<TransactionsState> {
  TransactionsCubit() : super(const TransactionsState());

  final _supabase = Supabase.instance.client;

  // Carregar transações
  Future<void> loadTransactions(String userId) async {
    emit(state.copyWith(isLoading: true, error: null));

    try {
      // Validar entrada
      if (userId.isEmpty) {
        emit(state.copyWith(
          isLoading: false,
          error: 'ID do usuário inválido',
        ));
        return;
      }

      // Buscar transações do banco
      final response = await _supabase
          .from('transactions')
          .select('*')
          .eq('child_id', userId)
          .order('date', ascending: false)
          .order('created_at', ascending: false);

      final transactions = response.map<TransactionEntity>((row) {
        return TransactionEntity(
          id: row['id'] as String,
          userId: row['child_id'] as String,
          parentId: row['parent_id'] as String?,
          description: row['description'] as String,
          amount: (row['amount'] as num).toDouble(),
          type: _mapTransactionType(row['type'] as String),
          status: _mapTransactionStatus(row['status'] as String),
          category: row['category'] as String,
          date: _parseDate(row['date']),
          createdAt: _parseDate(row['created_at']),
          rejectionReason: row['rejection_reason'] as String?,
          metadata: row['metadata'] as Map<String, dynamic>?,
        );
      }).toList();

      emit(
        state.copyWith(
          isLoading: false,
          transactions: transactions,
          filteredTransactions: transactions,
          error: null,
        ),
      );
    } catch (e) {
      debugPrint('❌ Erro ao carregar transações: $e');
      emit(state.copyWith(
        isLoading: false,
        error: 'Erro ao carregar transações: ${e.toString()}',
      ));
    }
  }

  // Adicionar transação
  Future<void> addTransaction(TransactionEntity transaction) async {
    try {
      // Validar entrada
      if (transaction.userId.isEmpty) {
        emit(state.copyWith(error: 'ID do usuário inválido'));
        return;
      }

      if (transaction.amount <= 0) {
        emit(state.copyWith(error: 'Valor deve ser maior que zero'));
        return;
      }

      if (transaction.description.trim().isEmpty) {
        emit(state.copyWith(error: 'Descrição é obrigatória'));
        return;
      }

      if (transaction.category.trim().isEmpty) {
        emit(state.copyWith(error: 'Categoria é obrigatória'));
        return;
      }

      // Verificar se é despesa e se há saldo suficiente
      if (transaction.type == TransactionType.expense) {
        final childData = await _supabase
            .from('children')
            .select('balance, requires_approval, limits, allowed_categories')
            .eq('id', transaction.userId)
            .maybeSingle();

        if (childData != null) {
          final balance = (childData['balance'] as num?)?.toDouble() ?? 0.0;
          final requiresApproval =
              childData['requires_approval'] as bool? ?? true;
          final limits = _parseLimits(childData['limits']);
          final allowedCategories =
              _parseAllowedCategories(childData['allowed_categories']);

          final categoryKey = transaction.category.trim();

          // Verificar se a categoria é permitida
          if (allowedCategories.isNotEmpty &&
              !allowedCategories.contains(categoryKey)) {
            emit(
              state.copyWith(
                error:
                    'Esta categoria não está permitida pelas configurações dos responsáveis.',
              ),
            );
            return;
          }

          // Verificar limite mensal por categoria (se existir)
          final withinLimit = await _isWithinCategoryLimit(
            transaction.userId,
            categoryKey,
            transaction.amount,
            limits,
          );

          if (!withinLimit) {
            emit(
              state.copyWith(
                error:
                    'Limite mensal de gastos para esta categoria já foi atingido.',
              ),
            );
            return;
          }

          if (balance < transaction.amount) {
            emit(state.copyWith(error: 'Saldo insuficiente'));
            return;
          }

          // Definir status baseado em requires_approval
          final status = requiresApproval ? 'pending' : 'approved';

          // Inserir no banco
          await _supabase.from('transactions').insert({
            'child_id': transaction.userId,
            'parent_id': transaction.parentId,
            'amount': transaction.amount,
            'type': _mapTransactionTypeToString(transaction.type),
            'description': transaction.description.trim(),
            'category': categoryKey,
            'status': status,
            'date': transaction.date.toIso8601String(),
            'metadata': transaction.metadata,
          });

          // Se não precisa aprovação, o trigger já atualiza o saldo
          // Recarregar transações
          await loadTransactions(transaction.userId);
        } else {
          emit(state.copyWith(error: 'Usuário não encontrado'));
        }
      } else {
        // Para receitas, sempre inserir
        await _supabase.from('transactions').insert({
          'child_id': transaction.userId,
          'parent_id': transaction.parentId,
          'amount': transaction.amount,
          'type': _mapTransactionTypeToString(transaction.type),
          'description': transaction.description.trim(),
          'category': transaction.category.trim(),
          'status': 'approved',
          'date': transaction.date.toIso8601String(),
          'metadata': transaction.metadata,
        });

        // Recarregar transações
        await loadTransactions(transaction.userId);
      }
    } catch (e) {
      debugPrint('❌ Erro ao adicionar transação: $e');
      emit(state.copyWith(error: 'Erro ao adicionar transação: ${e.toString()}'));
    }
  }

  TransactionType _mapTransactionType(String value) {
    switch (value.toLowerCase()) {
      case 'income':
        return TransactionType.income;
      case 'expense':
        return TransactionType.expense;
      case 'allowance':
        return TransactionType.allowance;
      case 'reward':
        return TransactionType.reward;
      default:
        return TransactionType.expense;
    }
  }

  String _mapTransactionTypeToString(TransactionType type) {
    switch (type) {
      case TransactionType.income:
        return 'income';
      case TransactionType.expense:
        return 'expense';
      case TransactionType.allowance:
        return 'allowance';
      case TransactionType.reward:
        return 'reward';
    }
  }

  TransactionStatus _mapTransactionStatus(String value) {
    switch (value.toLowerCase()) {
      case 'pending':
        return TransactionStatus.pending;
      case 'approved':
        return TransactionStatus.approved;
      case 'rejected':
        return TransactionStatus.rejected;
      case 'completed':
        return TransactionStatus.completed;
      default:
        return TransactionStatus.pending;
    }
  }

  DateTime _parseDate(dynamic raw) {
    if (raw is DateTime) return raw;
    if (raw is String && raw.isNotEmpty) {
      return DateTime.tryParse(raw) ?? DateTime.now();
    }
    return DateTime.now();
  }

  Map<String, double> _parseLimits(dynamic raw) {
    if (raw == null) return const {};
    if (raw is Map) {
      return raw.map((key, value) {
        final numeric = value is num ? value.toDouble() : 0.0;
        return MapEntry(key.toString(), numeric);
      });
    }
    return const {};
  }

  List<String> _parseAllowedCategories(dynamic raw) {
    if (raw == null) return const [];
    if (raw is List) {
      return raw.map((e) => e.toString()).toList();
    }
    return const [];
  }

  Future<bool> _isWithinCategoryLimit(
    String childId,
    String category,
    double amount,
    Map<String, double> limits,
  ) async {
    final limit = limits[category];
    if (limit == null || limit <= 0) return true;

    final now = DateTime.now();
    final monthStart = DateTime(now.year, now.month, 1);

    var query = _supabase
        .from('transactions')
        .select('amount')
        .eq('child_id', childId)
        .eq('type', 'expense')
        .eq('category', category)
        .gte('date', monthStart.toIso8601String());

    // Considerar apenas despesas já aprovadas/concluídas
    query = query.or('status.eq.approved,status.eq.completed');

    final response = await query;

    double spent = 0.0;
    for (final row in response) {
      spent += (row['amount'] as num).toDouble();
    }

    return spent + amount <= limit;
  }

  // Filtrar por categoria
  void filterByCategory(String? category) {
    emit(
      state.copyWith(
        selectedCategory: category,
        filteredTransactions: _filterTransactions(
          state.transactions,
          category,
          state.selectedType,
        ),
      ),
    );
  }

  // Filtrar por tipo
  void filterByType(TransactionType? type) {
    emit(
      state.copyWith(
        selectedType: type,
        filteredTransactions: _filterTransactions(
          state.transactions,
          state.selectedCategory,
          type,
        ),
      ),
    );
  }

  // Limpar filtros
  void clearFilters() {
    emit(
      state.copyWith(
        selectedCategory: null,
        selectedType: null,
        filteredTransactions: state.transactions,
      ),
    );
  }

  // Filtrar transações
  List<TransactionEntity> _filterTransactions(
    List<TransactionEntity> transactions,
    String? category,
    TransactionType? type,
  ) {
    var filtered = transactions;

    if (category != null) {
      filtered = filtered.where((t) => t.category == category).toList();
    }

    if (type != null) {
      filtered = filtered.where((t) => t.type == type).toList();
    }

    return filtered;
  }

}
