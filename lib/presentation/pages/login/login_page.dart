import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:local_auth/local_auth.dart';

import '../../../core/services/api_service.dart';
import '../../../data/datasources/auth_remote_datasource.dart';
import '../../../data/repositories_impl/auth_repository_impl.dart';
import '../../../domain/usecases/login_usecase.dart';
import '../../viewmodels/login_viewmodel.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final usuarioController = TextEditingController();
  final claveController = TextEditingController();
  final storage = const FlutterSecureStorage();
  final LocalAuthentication auth = LocalAuthentication();
  bool _rememberMe = false;

  @override
  void initState() {
    super.initState();
    _checkStoredToken();
  }

  Future<void> _checkStoredToken() async {
    final token = await storage.read(key: 'token');
    final userName = await storage.read(key: 'username');

    if (token != null && userName != null) {
      final didAuth = await _authenticateUser();
      if (didAuth) {
        if (!mounted) return;
        Navigator.pushReplacementNamed(
          context,
          '/dashboard',
          arguments: {'token': token, 'userName': userName},
        );
      }
    }
  }

  Future<bool> _authenticateUser() async {
    final canCheck = await auth.canCheckBiometrics;
    if (!canCheck) return false;

    try {
      return await auth.authenticate(
        localizedReason: 'Autentíquese para acceder al CRM',
        options: const AuthenticationOptions(
          biometricOnly: true,
          stickyAuth: true,
        ),
      );
    } catch (e) {
      debugPrint('Error autenticación biométrica: $e');
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => LoginViewModel(
        LoginUseCase(
          AuthRepositoryImpl(AuthRemoteDataSource(ApiService())),
        ),
      ),
      child: Scaffold(
        body: LayoutBuilder(
          builder: (context, constraints) {
            final isMobile = constraints.maxWidth < 600;

            return Row(
              children: [
                if (!isMobile)
                  Expanded(
                    flex: 2,
                    child: Container(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Color(0xFF3A0DFF), Color(0xFF1E1EFF)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                      child: const Padding(
                        padding: EdgeInsets.all(40.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "*",
                              style: TextStyle(
                                fontSize: 40,
                                color: Colors.white,
                              ),
                            ),
                            SizedBox(height: 20),
                            Text(
                              "Klaxcrm 👋",
                              style: TextStyle(
                                fontSize: 36,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 20),
                            Text(
                              "CRM 2026",
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.white70,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                Expanded(
                  flex: 3,
                  child: Center(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(24),
                      child: Consumer<LoginViewModel>(
                        builder: (context, viewModel, child) {
                          return Card(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            elevation: isMobile ? 4 : 0,
                            child: Padding(
                              padding: const EdgeInsets.all(24.0),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Text(
                                    "CRM",
                                    style: TextStyle(
                                        fontSize: 28,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    "¡Bienvenido de nuevo!",
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleMedium
                                        ?.copyWith(color: Colors.grey[700]),
                                  ),
                                  const SizedBox(height: 24),
                                  TextField(
                                    controller: usuarioController,
                                    decoration: InputDecoration(
                                      labelText: "Usuario",
                                      prefixIcon: const Icon(Icons.person),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  TextField(
                                    controller: claveController,
                                    obscureText: true,
                                    decoration: InputDecoration(
                                      labelText: "Clave",
                                      prefixIcon: const Icon(Icons.lock),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Checkbox(
                                        value: _rememberMe,
                                        onChanged: (bool? value) {
                                          setState(() {
                                            _rememberMe = value ?? false;
                                          });
                                        },
                                      ),
                                      const Text("Guardar sesión"),
                                    ],
                                  ),
                                  const SizedBox(height: 24),
                                  SizedBox(
                                    width: double.infinity,
                                    child: ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 14),
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                          BorderRadius.circular(12),
                                        ),
                                      ),
                                      onPressed: viewModel.loading
                                          ? null
                                          : () async {
                                        // 🚀 Limpiamos espacios en blanco
                                        final usuario = usuarioController.text.trim();
                                        final clave = claveController.text.trim();

                                        await viewModel.login(usuario, clave);

                                        if (viewModel.userData != null) {
                                          final token = viewModel.userData!['token'];
                                          final usuario = viewModel.userData!['usuario']['usuario'];
                                          final usuGen = viewModel.userData!['usuario']['id_seg_usuario'];

                                          if (_rememberMe) {
                                            await storage.write(key: 'token', value: token);
                                            await storage.write(key: 'username', value: usuario);
                                            await storage.write(key: 'usuGen', value: usuGen.toString());
                                          } else {
                                            await storage.deleteAll();
                                          }

                                          if (!mounted) return;
                                          Navigator.pushReplacementNamed(
                                            context,
                                            '/dashboard',
                                            arguments: {
                                              'token': token ?? '',
                                              'userName': usuario ?? '',
                                              'usuGen': usuGen, // PASA EL ID AQUÍ COMO ENTERO
                                            },
                                          );
                                        } else {
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(
                                              content:
                                              Text(viewModel.error ?? 'Error al iniciar sesión'),
                                            ),
                                          );
                                        }
                                      },
                                      child: viewModel.loading
                                          ? const SizedBox(
                                        width: 20,
                                        height: 20,
                                        child:
                                        CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: Colors.white,
                                        ),
                                      )
                                          : const Text("Iniciar sesión"),
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  TextButton(
                                    onPressed: () {},
                                    child: const Text(
                                      "¿Olvidó su contraseña?",
                                      style: TextStyle(fontSize: 14),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
