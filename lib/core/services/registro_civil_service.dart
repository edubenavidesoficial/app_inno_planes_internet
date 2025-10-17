import 'dart:convert';
import '../../../core/services/base_api_service.dart';
import '../../data/models/registro_civil_model.dart';

class RegistroCivilService {
  final BaseApiService _apiService = BaseApiService();
  final String endpoint = 'crm/registro-civil/cliente-por-ruc';

  Future<RegistroCivilResponse?> consultarClientePorRuc(
      String token, String ruc) async {
    final body = {"ruc": ruc};

    try {
      final response = await _apiService.post(
        endpoint,
        body,
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
      );

      if (response != null && response.isNotEmpty) {
        return RegistroCivilResponse.fromJson(response);
      } else {
        return null;
      }
    } catch (e) {
      throw Exception("Fallo al consultar Registro Civil: $e");
    }
  }
}
