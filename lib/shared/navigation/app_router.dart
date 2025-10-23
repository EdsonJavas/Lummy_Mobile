import 'package:flutter/material.dart';
import '../../domain/entities/user_entity.dart';

// Nomes de rotas
class AppRoutes {
  static const String splash = '/';
  static const String login = '/login';
  static const String register = '/register';
  static const String registerChildren = '/register/children';

  // Rotas da criança
  static const String childDashboard = '/child/dashboard';
  static const String childTransactions = '/child/transactions';
  static const String childGoals = '/child/goals';
  static const String childAchievements = '/child/achievements';
  static const String childLessons = '/child/lessons';
  static const String childProfile = '/child/profile';
  static const String addTransaction = '/child/add-transaction';
  static const String addGoal = '/child/add-goal';

  // Rotas do responsável
  static const String parentDashboard = '/parent/dashboard';
  static const String parentChildren = '/parent/children';
  static const String parentApprovals = '/parent/approvals';
  static const String parentReports = '/parent/reports';
  static const String parentSettings = '/parent/settings';
  static const String parentNotifications = '/parent/notifications';
  static const String childDetails = '/parent/child-details';
}

class AppRouter {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case AppRoutes.splash:
        // Importar splash_screen quando necessário
        return MaterialPageRoute(
          builder: (_) => const Placeholder(), // TODO: Implementar
        );

      case AppRoutes.login:
        // Importar login_page quando necessário
        return MaterialPageRoute(
          builder: (_) => const Placeholder(), // TODO: Implementar
        );

      case AppRoutes.register:
        return MaterialPageRoute(
          builder: (_) => const Placeholder(), // TODO: Implementar
        );

      case AppRoutes.childDashboard:
        return MaterialPageRoute(
          builder: (_) => const Placeholder(), // TODO: Implementar
        );

      case AppRoutes.parentDashboard:
        return MaterialPageRoute(
          builder: (_) => const Placeholder(), // TODO: Implementar
        );

      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(child: Text('Rota não encontrada: ${settings.name}')),
          ),
        );
    }
  }

  // Navegação helper methods
  static void navigateToChildDashboard(
    BuildContext context, {
    bool replace = false,
  }) {
    if (replace) {
      Navigator.pushReplacementNamed(context, AppRoutes.childDashboard);
    } else {
      Navigator.pushNamed(context, AppRoutes.childDashboard);
    }
  }

  static void navigateToParentDashboard(
    BuildContext context, {
    bool replace = false,
  }) {
    if (replace) {
      Navigator.pushReplacementNamed(context, AppRoutes.parentDashboard);
    } else {
      Navigator.pushNamed(context, AppRoutes.parentDashboard);
    }
  }

  static void navigateBasedOnRole(
    BuildContext context,
    UserRole role, {
    bool replace = false,
  }) {
    if (role == UserRole.child) {
      navigateToChildDashboard(context, replace: replace);
    } else {
      navigateToParentDashboard(context, replace: replace);
    }
  }

  static void navigateToLogin(BuildContext context, {bool replace = false}) {
    if (replace) {
      Navigator.pushReplacementNamed(context, AppRoutes.login);
    } else {
      Navigator.pushNamed(context, AppRoutes.login);
    }
  }
}
