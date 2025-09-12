class FinancialData {
  double currentBalance;
  double savingsGoal;
  String goalName;
  String goalEmoji;
  List<Transaction> transactions;
  List<Achievement> achievements;

  FinancialData({
    this.currentBalance = 127.50,
    this.savingsGoal = 200.00,
    this.goalName = "Bicicleta Nova",
    this.goalEmoji = "🚲",
    this.transactions = const [],
    this.achievements = const [],
  });
}

class Transaction {
  final String id;
  final String description;
  final double amount;
  final DateTime date;
  final TransactionType type;
  final String category;

  Transaction({
    required this.id,
    required this.description,
    required this.amount,
    required this.date,
    required this.type,
    required this.category,
  });
}

enum TransactionType { income, expense }

class Achievement {
  final String id;
  final String title;
  final String description;
  final String emoji;
  final bool isCompleted;
  final DateTime? completedDate;

  Achievement({
    required this.id,
    required this.title,
    required this.description,
    required this.emoji,
    this.isCompleted = false,
    this.completedDate,
  });
}
