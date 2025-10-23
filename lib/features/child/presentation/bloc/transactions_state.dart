import 'package:equatable/equatable.dart';
import '../../../../domain/entities/transaction_entity.dart';

class TransactionsState extends Equatable {
  final bool isLoading;
  final List<TransactionEntity> transactions;
  final List<TransactionEntity> filteredTransactions;
  final String? selectedCategory;
  final TransactionType? selectedType;
  final String? error;

  const TransactionsState({
    this.isLoading = false,
    this.transactions = const [],
    this.filteredTransactions = const [],
    this.selectedCategory,
    this.selectedType,
    this.error,
  });

  TransactionsState copyWith({
    bool? isLoading,
    List<TransactionEntity>? transactions,
    List<TransactionEntity>? filteredTransactions,
    String? selectedCategory,
    TransactionType? selectedType,
    String? error,
  }) {
    return TransactionsState(
      isLoading: isLoading ?? this.isLoading,
      transactions: transactions ?? this.transactions,
      filteredTransactions: filteredTransactions ?? this.filteredTransactions,
      selectedCategory: selectedCategory,
      selectedType: selectedType,
      error: error,
    );
  }

  @override
  List<Object?> get props => [
    isLoading,
    transactions,
    filteredTransactions,
    selectedCategory,
    selectedType,
    error,
  ];
}
