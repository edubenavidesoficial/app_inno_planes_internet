import 'dart:convert';
import '../../data/models/buro_model.dart';
import 'base_api_service.dart';

class BuroService {
  final BaseApiService _apiService = BaseApiService();
  final String endpoint = 'crm/buro';

  Future<BuroResponse> consultarBuro(String tipoDoc, String ruc,
      String token) async {
    try {
      final body = {
        "tipoDoc": tipoDoc,
        "ruc": ruc,
      };

      final headers = {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      };

      print("Endpoint: $endpoint");
      print("Body: ${jsonEncode(body)}");
      print("Headers: $headers");

      final response = await _apiService.post(
        endpoint,
        body,
        headers: headers,
      );

      if (response != null) {
        print("Respuesta recibida del Buró: $response");
        return BuroResponse.fromJson(response);
      } else {
        throw Exception("Respuesta vacía del servicio Buró");
      }
    } catch (e) {
      print("Error al consultar Buró: $e");
      throw Exception("Error al consultar Buró: $e");
    }
  }
}