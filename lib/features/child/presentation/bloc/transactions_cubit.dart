import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../domain/entities/transaction_entity.dart';
import 'transactions_state.dart';

class TransactionsCubit extends Cubit<TransactionsState> {
  TransactionsCubit() : super(const TransactionsState());

  // Carregar transações
  Future<void> loadTransactions(String userId) async {
    emit(state.copyWith(isLoading: true));

    try {
      // TODO: Buscar do backend
      await Future.delayed(const Duration(seconds: 1));

      final transactions = _getMockTransactions(userId);

      emit(
        state.copyWith(
          isLoading: false,
          transactions: transactions,
          filteredTransactions: transactions,
        ),
      );
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }

  // Adicionar transação
  Future<void> addTransaction(TransactionEntity transaction) async {
    final updatedTransactions = [transaction, ...state.transactions];

    emit(
      state.copyWith(
        transactions: updatedTransactions,
        filteredTransactions: _filterTransactions(
          updatedTransactions,
          state.selectedCategory,
          state.selectedType,
        ),
      ),
    );
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

  // Mock data
  List<TransactionEntity> _getMockTransactions(String userId) {
    final now = DateTime.now();

    return [
      TransactionEntity(
        id: '1',
        userId: userId,
        description: 'Mesada de Outubro',
        amount: 50.0,
        type: TransactionType.allowance,
        status: TransactionStatus.completed,
        category: 'Mesada',
        date: now.subtract(const Duration(days: 1)),
        createdAt: now.subtract(const Duration(days: 1)),
      ),
      TransactionEntity(
        id: '2',
        userId: userId,
        description: 'Sorvete na praça',
        amount: 10.0,
        type: TransactionType.expense,
        status: TransactionStatus.completed,
        category: 'Doces',
        date: now.subtract(const Duration(days: 2)),
        createdAt: now.subtract(const Duration(days: 2)),
      ),
      TransactionEntity(
        id: '3',
        userId: userId,
        description: 'Recompensa por boas notas',
        amount: 25.0,
        type: TransactionType.reward,
        status: TransactionStatus.completed,
        category: 'Recompensa',
        date: now.subtract(const Duration(days: 5)),
        createdAt: now.subtract(const Duration(days: 5)),
      ),
      TransactionEntity(
        id: '4',
        userId: userId,
        description: 'Novo jogo',
        amount: 40.0,
        type: TransactionType.expense,
        status: TransactionStatus.completed,
        category: 'Jogos',
        date: now.subtract(const Duration(days: 7)),
        createdAt: now.subtract(const Duration(days: 7)),
      ),
    ];
  }
}
