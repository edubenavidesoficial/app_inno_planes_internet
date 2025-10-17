import 'dart:convert';
import '../../data/models/equifax_pdf_response.dart';
import 'base_api_service.dart';

class EquifaxService {
  final BaseApiService _apiService = BaseApiService();
  final String endpoint = 'equifax/generar-pdf';
  final String endpointbuscar = 'crm/buro';

  Future<EquifaxPdfResponse> generarPdf(String ruc, String token) async {
    try {
      final body = {"ruc": ruc};

      final response = await _apiService.post(
        endpoint,
        body,
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
      );
      if (response != null) {
        return EquifaxPdfResponse.fromJson(response);
      } else {
        throw Exception("Respuesta vacía del servicio Equifax PDF");
      }
    } catch (e) {
      throw Exception("Error al generar PDF de Equifax: $e");
    }
  }

  Future<int> consultarEquifax(String ruc, String token) async {
    final body = {
      "ruc": ruc,
      "tipoDoc": ruc.length == 10 ? 'C' : (ruc.length == 13 ? 'R' : 'P'),
    };
    final response = await _apiService.post(
      endpointbuscar,
      body,
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      },
    );
    if (response.isNotEmpty) {
      final id = response["id"] ?? 0;
      return id;
    }
    return 0;
  }
}
