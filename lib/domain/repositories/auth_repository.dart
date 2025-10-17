abstract class AuthRepository {
  Future<Map<String, dynamic>> login(String usuario, String clave);
}
