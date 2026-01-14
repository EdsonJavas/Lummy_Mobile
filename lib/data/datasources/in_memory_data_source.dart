import 'package:lummy_login/models/financial_data.dart';
import 'package:lummy_login/models/goal.dart';

class InMemoryDataSource {
  final Map<String, FinancialData> _userFinancialData = {};

  FinancialData getOrCreateFinancial(String userId) {
    return _userFinancialData.putIfAbsent(
      userId,
      () => FinancialData(
        transactions: [],
        achievements: [
          Achievement(
            id: 'first_saving',
            title: 'Primeira Economia',
            description: 'Você guardou seu primeiro dinheiro!',
            emoji: '🥇',
            isCompleted: true,
          ),
          Achievement(
            id: 'expense_control',
            title: 'Controle de Gastos',
            description: 'Anotou gastos por 7 dias seguidos',
            emoji: '📊',
            isCompleted: true,
          ),
          Achievement(
            id: 'goal_reached',
            title: 'Meta Alcançada',
            description: 'Complete sua primeira meta de economia',
            emoji: '🎯',
            isCompleted: false,
          ),
        ],
      ),
    );
  }

  FinancialData addTransaction({
    required String userId,
    required String description,
    required double amount,
    required String type,
    required String category,
  }) {
    final data = getOrCreateFinancial(userId);
    final newTransaction = Transaction(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      description: description,
      amount: amount,
      date: DateTime.now(),
      type: type == 'expense'
          ? TransactionType.expense
          : TransactionType.income,
      category: category,
    );
    data.transactions = List<Transaction>.from(data.transactions)
      ..add(newTransaction);
    if (newTransaction.type == TransactionType.expense) {
      data.currentBalance -= amount;
    } else {
      data.currentBalance += amount;
    }

    // Check goal achievement
    if (data.currentBalance >= data.savingsGoal) {
      data.achievements = data.achievements.map((a) {
        if (a.id == 'goal_reached') {
          return Achievement(
            id: a.id,
            title: a.title,
            description: a.description,
            emoji: a.emoji,
            isCompleted: true,
            completedDate: DateTime.now(),
          );
        }
        return a;
      }).toList();
    }
    return data;
  }

  Goal setGoal({
    required String userId,
    required String name,
    required String emoji,
    required double amount,
  }) {
    final data = getOrCreateFinancial(userId);
    data.goalName = name;
    data.goalEmoji = emoji;
    data.savingsGoal = amount;
    return Goal(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      emoji: emoji,
      targetAmount: amount,
      currentAmount: data.currentBalance,
      createdDate: DateTime.now(),
      description: '',
    );
  }
}
