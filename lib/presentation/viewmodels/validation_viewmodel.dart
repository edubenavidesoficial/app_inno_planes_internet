import 'package:flutter/material.dart';
import '/domain/usecases/id_usecases.dart';

class ValidationViewModel extends ChangeNotifier {
  final AuthenticateUserUseCase authenticateUserUseCase;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _isAuthenticationSuccessful = false;
  bool get isAuthenticationSuccessful => _isAuthenticationSuccessful;

  ValidationViewModel(this.authenticateUserUseCase);

  Future<void> authenticate(String username, String password) async {
    _isLoading = true;
    notifyListeners();

    try {
      final idToken = await authenticateUserUseCase.call(username, password);
      // Guardar el token para usarlo en los siguientes pasos
      _isAuthenticationSuccessful = true;
    } catch (e) {
      _isAuthenticationSuccessful = false;
      // Manejar errores
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

// Métodos para los demás pasos de la validación
}