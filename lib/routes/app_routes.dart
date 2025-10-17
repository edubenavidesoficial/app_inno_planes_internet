import 'package:flutter/material.dart';
import '../presentation/pages/login/login_page.dart';
import '../presentation/pages/dashboard/dashboard_page.dart';
import '../presentation/pages/prospecto/prospecto_page.dart';
import '../presentation/pages/prospecto/formulario_page.dart';
import '../presentation/pages/tickets/tickets_page.dart';
import '../presentation/pages/splash/splash_screen.dart';

class AppRoutes {
  static const splash = '/splash';
  static const String login = '/login';
  static const String dashboard = '/dashboard';
  static const String formulario = '/formulario';
  static const String tickets = '/tickets';
  static const String prospecto = '/prospectos';

  static final Map<String, WidgetBuilder> routes = {
    splash: (_) => const SplashScreen(),
    login: (_) => const LoginPage(),
  };

  static Route<dynamic>? onGenerateRoute(RouteSettings settings) {
    print('RUTA: ${settings.name}');
    print('ARGUMENTOS: ${settings.arguments}');

    switch (settings.name) {
      case dashboard:
        final args = settings.arguments as Map<String, dynamic>?;
        if (args == null ||
            !args.containsKey('token') ||
            !args.containsKey('userName') ||
            !args.containsKey('usuGen')) {
          return MaterialPageRoute(builder: (_) => const LoginPage());
        }
        return MaterialPageRoute(
          builder: (_) => DashboardPage(
            token: args['token'] as String,
            userName: args['userName'] as String,
            usuGen: args['usuGen'] as int,
          ),
        );

      case formulario:
        final args = settings.arguments as Map<String, dynamic>?;
        if (args == null || !args.containsKey('token')) {
          return MaterialPageRoute(builder: (_) => const LoginPage());
        }
        return MaterialPageRoute(
          builder: (_) => FormularioPage(token: args['token'] as String),
        );

      case tickets:
        final args = settings.arguments as Map<String, dynamic>?;
        if (args == null ||
            !args.containsKey('token') ||
            !args.containsKey('usuGen')) {
          return MaterialPageRoute(builder: (_) => const LoginPage());
        }
        return MaterialPageRoute(
          builder: (_) => TicketsPage(
            token: args['token'] as String,
            userName: args['userName'] as String,
            usuGen: args['usuGen'] as int,
          ),
        );

      case prospecto:
        final args = settings.arguments as Map<String, dynamic>?;
        if (args == null || !args.containsKey('token')) {
          return MaterialPageRoute(builder: (_) => const LoginPage());
        }
        return MaterialPageRoute(
          builder: (_) => ProspectoPage(
            token: args['token'] as String,
            id_ticket: args['id_ticket'] as int,
          ),
        );

      default:
        return null;
    }
  }
}