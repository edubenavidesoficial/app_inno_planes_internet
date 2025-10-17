import 'package:dio/dio.dart';

class IdService {
  final Dio _dio;

  IdService(this._dio);

  // Método 1: Autenticación con usuario y contraseña
  Future<Response> authenticate(String username, String password) async {
    try {
      final response = await _dio.post(
        '/api/auth/login',
        data: {
          'username': username,
          'password': password,
        },
      );
      return response;
    } on DioException catch (e) {
      throw Exception('Error al autenticar: ${e.response?.data ?? e.message}');
    }
  }

  // Método 2: Validación biométrica con RCE
  Future<Response> validateFaceWithRCE(String idToken, String photo) async {
    try {
      final response = await _dio.post(
        '/api/validate-face',
        options: Options(headers: {'Authorization': 'Bearer $idToken'}),
        data: {
          'photo': photo,
        },
      );
      return response;
    } on DioException catch (e) {
      throw Exception('Error al validar rostro con RCE: ${e.response?.data ?? e.message}');
    }
  }

  // Método 3: Validación biométrica sin RCE (subiendo una foto)
  Future<Response> validatePhotoWithoutRCE(String idToken, String photo) async {
    try {
      final response = await _dio.post(
        '/api/validate-photo',
        options: Options(headers: {'Authorization': 'Bearer $idToken'}),
        data: {
          'photo': photo,
        },
      );
      return response;
    } on DioException catch (e) {
      throw Exception('Error al validar rostro sin RCE: ${e.response?.data ?? e.message}');
    }
  }

  // Método 4: Validación de cédula frontal
  Future<Response> validateFront(String idToken, String frontPhoto) async {
    try {
      final response = await _dio.post(
        '/api/validate-front',
        options: Options(headers: {'Authorization': 'Bearer $idToken'}),
        data: {
          'front_photo': frontPhoto,
        },
      );
      return response;
    } on DioException catch (e) {
      throw Exception('Error al validar cédula frontal: ${e.response?.data ?? e.message}');
    }
  }

  // Método 5: Validación de cédula posterior
  Future<Response> validateBack(String idToken, String backPhoto) async {
    try {
      final response = await _dio.post(
        '/api/validate-back',
        options: Options(headers: {'Authorization': 'Bearer $idToken'}),
        data: {
          'back_photo': backPhoto,
        },
      );
      return response;
    } on DioException catch (e) {
      throw Exception('Error al validar cédula posterior: ${e.response?.data ?? e.message}');
    }
  }

  // Método 6: Validación de selfie con cédula
  Future<Response> validateSelfie(String idToken, String selfiePhoto) async {
    try {
      final response = await _dio.post(
        '/api/validate-selfie',
        options: Options(headers: {'Authorization': 'Bearer $idToken'}),
        data: {
          'selfie_photo': selfiePhoto,
        },
      );
      return response;
    } on DioException catch (e) {
      throw Exception('Error al validar selfie: ${e.response?.data ?? e.message}');
    }
  }

  // Método 7: Generar documento de evidencia
  Future<Response> generateEvidence(String idToken, Map<String, dynamic> data) async {
    try {
      final response = await _dio.post(
        '/api/extra-document',
        options: Options(headers: {'Authorization': 'Bearer $idToken'}),
        data: data,
      );
      return response;
    } on DioException catch (e) {
      throw Exception('Error al generar evidencia: ${e.response?.data ?? e.message}');
    }
  }
}