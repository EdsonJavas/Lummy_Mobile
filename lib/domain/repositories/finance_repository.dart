import 'package:lummy_login/core/result.dart';
import 'package:lummy_login/models/financial_data.dart';
import 'package:lummy_login/models/goal.dart';

abstract class FinanceRepository {
  Future<Result<FinancialData>> getFinancialData(String userId);
  Future<Result<FinancialData>> addTransaction({
    required String userId,
    required String description,
    required double amount,
    required String type, // 'income' | 'expense'
    required String category,
  });
  Future<Result<Goal>> setGoal({
    required String userId,
    required String name,
    required String emoji,
    required double amount,
  });
}


