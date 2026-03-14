import 'package:flutter/material.dart';
import 'package:lummy_login/screens/app/splash_screen.dart';
import 'package:lummy_login/domain/entities/user_entity.dart';
import 'package:lummy_login/screens/parent/parent_main_navigation.dart';
import 'package:lummy_login/screens/auth/login_screen.dart';
import 'package:lummy_login/screens/child/main_navigation.dart';
import 'package:lummy_login/screens/auth/register_screen.dart';

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

/// Argumentos opcionais para rotas que precisam de dados (ex: parent dashboard).
class ParentDashboardArgs {
  final String parentId;
  final String parentName;

  const ParentDashboardArgs({
    required this.parentId,
    required this.parentName,
  });

  static ParentDashboardArgs? fromMap(dynamic args) {
    if (args is! Map) return null;
    final id = args['parentId'] as String?;
    final name = args['parentName'] as String?;
    if (id == null || name == null) return null;
    return ParentDashboardArgs(parentId: id, parentName: name);
  }
}

class AppRouter {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case AppRoutes.splash:
        return MaterialPageRoute(
          builder: (_) => const SplashScreen(),
        );

      case AppRoutes.login:
        return MaterialPageRoute(
          builder: (_) => const LoginScreen(),
        );

      case AppRoutes.register:
        return MaterialPageRoute(
          builder: (_) => const RegisterScreen(),
        );

      case AppRoutes.childDashboard:
        return MaterialPageRoute(
          builder: (_) => const MainNavigation(),
        );

      case AppRoutes.parentDashboard:
        final args = ParentDashboardArgs.fromMap(settings.arguments);
        if (args != null) {
          return MaterialPageRoute(
            builder: (_) => ParentMainNavigation(
              parentId: args.parentId,
              parentName: args.parentName,
            ),
          );
        }
        return MaterialPageRoute(
          builder: (_) => const LoginScreen(),
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
    String? parentId,
    String? parentName,
  }) {
    final args = (parentId != null && parentName != null)
        ? {'parentId': parentId, 'parentName': parentName}
        : null;
    if (replace) {
      Navigator.pushReplacementNamed(
        context,
        AppRoutes.parentDashboard,
        arguments: args,
      );
    } else {
      Navigator.pushNamed(
        context,
        AppRoutes.parentDashboard,
        arguments: args,
      );
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
