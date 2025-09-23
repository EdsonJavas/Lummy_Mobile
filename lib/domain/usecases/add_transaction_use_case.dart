import 'package:lummy_login/core/result.dart';
import 'package:lummy_login/models/financial_data.dart';
import 'package:lummy_login/domain/repositories/finance_repository.dart';

class AddTransactionUseCase {
  final FinanceRepository financeRepository;
  const AddTransactionUseCase(this.financeRepository);

  Future<Result<FinancialData>> call({
    required String userId,
    required String description,
    required double amount,
    required String type,
    required String category,
  }) {
    return financeRepository.addTransaction(
      userId: userId,
      description: description,
      amount: amount,
      type: type,
      category: category,
    );
  }
}


