import '../../../core/services/api_service.dart';

class AuthRemoteDataSource {
  final ApiService apiService;

  AuthRemoteDataSource(this.apiService);

  Future<Map<String, dynamic>> login(String usuario, String clave) async {
    final response = await apiService.post('auth/login', {
      'usuario': usuario,
      'clave': clave,
    });
    return response;
  }
}
