import 'package:flutter/material.dart';
import '../../../domain/usecases/login_usecase.dart';

class LoginViewModel extends ChangeNotifier {
  final LoginUseCase loginUseCase;

  LoginViewModel(this.loginUseCase);

  bool loading = false;
  Map<String, dynamic>? userData;
  String? error;

  Future<void> login(String usuario, String clave) async {
    loading = true;
    notifyListeners();

    try {
      final response = await loginUseCase.execute(usuario, clave);
      userData = response;
      error = null;
    } catch (e) {
      error = e.toString();
    } finally {
      loading = false;
      notifyListeners();
    }
  }
}