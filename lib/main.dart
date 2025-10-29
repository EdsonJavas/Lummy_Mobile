import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'core/theme/app_theme.dart';
import 'core/providers/theme_provider.dart';
import 'di/locator.dart';
import 'features/auth/presentation/bloc/auth_cubit.dart';
import 'shared/navigation/app_router.dart';
import 'splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializar formatação de data em português
  await initializeDateFormatting('pt_BR', null);

  // Inicializar injeção de dependências
  setupLocator();

  runApp(const LummyApp());
}

class LummyApp extends StatelessWidget {
  const LummyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // Theme Provider
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        // Auth Cubit global
        BlocProvider(create: (context) => AuthCubit()),
        // Outros providers globais podem ser adicionados aqui
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, _) {
          return MaterialApp(
            title: 'Lummy - Educação Financeira',
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeProvider.themeMode,
            home: const SplashScreen(),
            onGenerateRoute: AppRouter.generateRoute,
            debugShowCheckedModeBanner: false,
            builder: (context, child) {
              return MediaQuery(
                data: MediaQuery.of(
                  context,
                ).copyWith(textScaler: const TextScaler.linear(1.0)),
                child: child!,
              );
            },
          );
        },
      ),
    );
  }
}
