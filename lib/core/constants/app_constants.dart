// Constantes do aplicativo Lummy

class AppConstants {
  AppConstants._();

  // Cores ficam em LummyColors (lib/core/theme/design_tokens.dart).

  // Limites de tela
  static const smallScreenHeight = 650.0;
  static const mediumScreenHeight = 700.0;

  // Espaçamentos
  static const spacingXSmall = 4.0;
  static const spacingSmall = 8.0;
  static const spacingMedium = 16.0;
  static const spacingLarge = 24.0;
  static const spacingXLarge = 32.0;

  // Border radius
  static const radiusSmall = 8.0;
  static const radiusMedium = 12.0;
  static const radiusLarge = 16.0;
  static const radiusXLarge = 20.0;
  static const radiusFull = 100.0;

  // Categorias de gastos
  static const List<String> expenseCategories = [
    'Alimentação',
    'Doces',
    'Brinquedos',
    'Jogos',
    'Livros',
    'Roupas',
    'Transporte',
    'Lazer',
    'Educação',
    'Outros',
  ];

  // Emojis de categorias
  static const Map<String, String> categoryEmojis = {
    'Pedido': '💵',
    'Mesada': '💰',
    'Alimentação': '🍔',
    'Doces': '🍭',
    'Brinquedos': '🧸',
    'Jogos': '🎮',
    'Livros': '📚',
    'Roupas': '👕',
    'Transporte': '🚌',
    'Lazer': '🎉',
    'Educação': '✏️',
    'Outros': '📦',
  };

  // Ícones de metas comuns
  static const List<Map<String, String>> goalIcons = [
    {'emoji': '🚲', 'name': 'Bicicleta'},
    {'emoji': '🎮', 'name': 'Videogame'},
    {'emoji': '📱', 'name': 'Celular'},
    {'emoji': '💻', 'name': 'Computador'},
    {'emoji': '🎸', 'name': 'Instrumento'},
    {'emoji': '⚽', 'name': 'Esporte'},
    {'emoji': '🎨', 'name': 'Arte'},
    {'emoji': '📚', 'name': 'Livros'},
    {'emoji': '🧸', 'name': 'Brinquedo'},
    {'emoji': '👟', 'name': 'Tênis'},
    {'emoji': '🎒', 'name': 'Mochila'},
    {'emoji': '🎧', 'name': 'Fone'},
  ];

  // Tipos de transação
  static const String transactionTypeIncome = 'income';
  static const String transactionTypeExpense = 'expense';
  static const String transactionTypeAllowance = 'allowance';
  static const String transactionTypeReward = 'reward';

  // Status de transação
  static const String transactionStatusPending = 'pending';
  static const String transactionStatusApproved = 'approved';
  static const String transactionStatusRejected = 'rejected';
  static const String transactionStatusCompleted = 'completed';

  // Roles de usuário
  static const String roleParent = 'parent';
  static const String roleChild = 'child';

  // Mensagens padrão
  static const String errorGeneric = 'Ocorreu um erro. Tente novamente.';
  static const String errorNetwork = 'Erro de conexão. Verifique sua internet.';
  static const String errorAuth = 'Erro de autenticação. Faça login novamente.';

  /// Plano **Lummy For You**: máximo de dependentes. Acima disso, o indicado é **Lummy Pro** (ilimitado).
  static const int lummyForYouMaxChildren = 3;

  // Validações
  static const int minPasswordLength = 6;
  static const int minNameLength = 2;
  static const int minAge = 1;
  static const int maxAge = 17;
}
