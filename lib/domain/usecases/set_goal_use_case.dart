import 'package:lummy_login/core/result.dart';
import 'package:lummy_login/models/goal.dart';
import 'package:lummy_login/domain/repositories/finance_repository.dart';

class SetGoalUseCase {
  final FinanceRepository financeRepository;
  const SetGoalUseCase(this.financeRepository);

  Future<Result<Goal>> call({
    required String userId,
    required String name,
    required String emoji,
    required double amount,
  }) {
    return financeRepository.setGoal(
      userId: userId,
      name: name,
      emoji: emoji,
      amount: amount,
    );
  }
}
