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
        return _smoothRoute(const LoginScreen(), settings);

      case AppRoutes.register:
        return _smoothRoute(const RegisterScreen(), settings);

      case AppRoutes.childDashboard:
        return _smoothRoute(const MainNavigation(), settings);

      case AppRoutes.parentDashboard:
        final args = ParentDashboardArgs.fromMap(settings.arguments);
        if (args != null) {
          return _smoothRoute(
            ParentMainNavigation(
              parentId: args.parentId,
              parentName: args.parentName,
            ),
            settings,
          );
        }
        return _smoothRoute(const LoginScreen(), settings);

      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(child: Text('Rota não encontrada: ${settings.name}')),
          ),
        );
    }
  }

  static Route<dynamic> _smoothRoute(Widget page, RouteSettings settings) {
    return PageRouteBuilder(
      settings: settings,
      transitionDuration: const Duration(milliseconds: 350),
      reverseTransitionDuration: const Duration(milliseconds: 250),
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        final fadeIn = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOut,
        );
        final slideIn = Tween<Offset>(
          begin: const Offset(0.05, 0),
          end: Offset.zero,
        ).animate(CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutCubic,
        ));
        return FadeTransition(
          opacity: fadeIn,
          child: SlideTransition(position: slideIn, child: child),
        );
      },
    );
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
