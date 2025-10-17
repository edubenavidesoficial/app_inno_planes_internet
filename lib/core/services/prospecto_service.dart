import '../../../core/services/base_api_service.dart';

class ProspectoService extends BaseApiService {
  /// Buscar prospecto por RUC
  Future<Map<String, dynamic>> buscarProspecto(String token, String ruc) async {
    final data = {"ruc": ruc, "nombre": ""};
    return await post(
      'crm/info/prospecto',
      data,
      headers: {"Authorization": "Bearer $token"},
    );
  }

  /// Verifica si un prospecto existe por RUC
  Future<int> existeProspecto(String token, String ruc) async {
    final response = await buscarProspecto(token, ruc);
    if (response.isNotEmpty) {
      final idCrmTicket = response["idCrmTicket"] ?? 0;
      return idCrmTicket;
    }
    return 0;
  }

  /// Guardar o actualizar prospecto
  Future<Map<String, dynamic>> guardarProspecto(
    String token,
    Map<String, dynamic> data,
  ) async {
    return await post(
      'crm/info/guardar-prospecto',
      data,
      headers: {"Authorization": "Bearer $token"},
    );
  }
}
