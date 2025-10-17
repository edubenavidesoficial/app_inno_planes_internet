import 'base_api_service.dart';

class ApiService extends BaseApiService {
  Future<dynamic> login(String username, String password) {
    return post('auth/login', {'username': username, 'password': password});
  }
}
