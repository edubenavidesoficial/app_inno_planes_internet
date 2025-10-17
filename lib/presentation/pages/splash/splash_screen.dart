import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:local_auth/local_auth.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final storage = const FlutterSecureStorage();
  final LocalAuthentication auth = LocalAuthentication();

  @override
  void initState() {
    super.initState();
    _checkStoredToken();
  }

  Future<void> _checkStoredToken() async {
    final token = await storage.read(key: 'token');
    final userName = await storage.read(key: 'username');
    final usuGen = await storage.read(key: 'usuGen');

    if (token != null && userName != null && usuGen != null) {
      bool didAuth = true;

      // Intentar biometría si está disponible
      if (await auth.canCheckBiometrics) {
        try {
          didAuth = await auth.authenticate(
            localizedReason: 'Autentíquese para acceder al CRM',
            options: const AuthenticationOptions(
              biometricOnly: true,
              stickyAuth: true,
            ),
          );
        } catch (e) {
          debugPrint('Error autenticación biométrica: $e');
          didAuth = false;
        }
      }

      if (didAuth && mounted) {
        Navigator.pushReplacementNamed(
          context,
          '/dashboard',
          arguments: {
            'token': token,
            'userName': userName,
            'usuGen': int.tryParse(usuGen),
          },
        );
        return;
      }
    }

    // Si no hay token o biometría falla → login
    if (mounted) {
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}
