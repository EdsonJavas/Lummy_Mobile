import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'core/services/connectivity_service.dart';
import 'core/theme/app_theme.dart';
import 'core/providers/theme_provider.dart';
import 'package:lummy_login/auth/bloc/auth_cubit.dart';
import 'package:lummy_login/screens/app/splash_screen.dart';
import 'package:lummy_login/shared/navigation/app_router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializar formatação de data em português
  await initializeDateFormatting('pt_BR', null); 

  // NÃO inicializar locator aqui - será feito no SplashScreen após inicializar Supabase
  // setupLocator() precisa que o Supabase já esteja inicializado

  runApp(const LummyApp());
}

class LummyApp extends StatelessWidget {
  const LummyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => ConnectivityService()),
        BlocProvider(create: (context) => AuthCubit()),
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
          );
        },
      ),
    );
  }
}
