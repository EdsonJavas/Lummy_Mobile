import 'package:lummy_login/core/result.dart';
import 'package:lummy_login/di/locator.dart';
import 'package:lummy_login/domain/usecases/add_transaction_use_case.dart';
import 'package:lummy_login/domain/usecases/get_financial_data_use_case.dart';
import 'package:lummy_login/domain/usecases/login_use_case.dart';
import 'package:lummy_login/domain/usecases/set_goal_use_case.dart';
import 'package:lummy_login/models/financial_data.dart';
import 'package:lummy_login/models/goal.dart';

/// Application Facade to expose use cases to UI without coupling to implementations.
class AppFacade {
  AppFacade._();

  static final AppFacade instance = AppFacade._();

  final LoginUseCase _login = locator<LoginUseCase>();
  final AddTransactionUseCase _addTransaction = locator<AddTransactionUseCase>();
  final SetGoalUseCase _setGoal = locator<SetGoalUseCase>();
  final GetFinancialDataUseCase _getFinancial = locator<GetFinancialDataUseCase>();

  Future<Result<String>> login(String email, String password) {
    return _login(email: email, password: password);
  }

  Future<Result<FinancialData>> getFinancialData(String userId) {
    return _getFinancial(userId);
  }

  Future<Result<FinancialData>> addTransaction({
    required String userId,
    required String description,
    required double amount,
    required String type,
    required String category,
  }) {
    return _addTransaction(
      userId: userId,
      description: description,
      amount: amount,
      type: type,
      category: category,
    );
  }

  Future<Result<Goal>> setGoal({
    required String userId,
    required String name,
    required String emoji,
    required double amount,
  }) {
    return _setGoal(
      userId: userId,
      name: name,
      emoji: emoji,
      amount: amount,
    );
  }
}


