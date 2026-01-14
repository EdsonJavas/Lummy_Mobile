import 'package:lummy_login/core/result.dart';
import 'package:lummy_login/data/datasources/in_memory_data_source.dart';
import 'package:lummy_login/domain/repositories/finance_repository.dart';
import 'package:lummy_login/models/financial_data.dart';
import 'package:lummy_login/models/goal.dart';

class InMemoryFinanceRepository implements FinanceRepository {
  final InMemoryDataSource dataSource;
  InMemoryFinanceRepository(this.dataSource);

  @override
  Future<Result<FinancialData>> getFinancialData(String userId) async {
    try {
      final data = dataSource.getOrCreateFinancial(userId);
      return Success<FinancialData>(data);
    } catch (e, st) {
      return FailureResult<FinancialData>(
        Failure('Erro ao obter dados financeiros', cause: e, stackTrace: st),
      );
    }
  }

  @override
  Future<Result<FinancialData>> addTransaction({
    required String userId,
    required String description,
    required double amount,
    required String type,
    required String category,
  }) async {
    try {
      final data = dataSource.addTransaction(
        userId: userId,
        description: description,
        amount: amount,
        type: type,
        category: category,
      );
      return Success<FinancialData>(data);
    } catch (e, st) {
      return FailureResult<FinancialData>(
        Failure('Erro ao adicionar transação', cause: e, stackTrace: st),
      );
    }
  }

  @override
  Future<Result<Goal>> setGoal({
    required String userId,
    required String name,
    required String emoji,
    required double amount,
  }) async {
    try {
      final goal = dataSource.setGoal(
        userId: userId,
        name: name,
        emoji: emoji,
        amount: amount,
      );
      return Success<Goal>(goal);
    } catch (e, st) {
      return FailureResult<Goal>(
        Failure('Erro ao definir meta', cause: e, stackTrace: st),
      );
    }
  }
}
