import '../repositories/auth_repository.dart';

class LoginUseCase {
  final AuthRepository repository;

  LoginUseCase(this.repository);

  Future<Map<String, dynamic>> execute(String usuario, String clave) {
    return repository.login(usuario, clave);
  }
}
