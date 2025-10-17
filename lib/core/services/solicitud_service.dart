import '../../data/models/solicitud_model.dart';
import 'base_api_service.dart';

class SolicitudService {
  final BaseApiService _apiService = BaseApiService();
  final String endpoint = 'crm/solicitudes';

  Future<Map<String, dynamic>> guardarSolicitud(
    Map<String, dynamic> solicitud, {
    required String token,
  }) async {
    return await _apiService.post(
      endpoint,
      solicitud,
      headers: {"Authorization": "Bearer $token"},
    );
  }

  Future<Map<String, dynamic>> consultarTaxDni(
    Map<String, dynamic> ruc, {
    required String token,
  }) async {
    return await _apiService.post(
      'crm/clientes/crear-o-traer',
      ruc,
      headers: {"Authorization": "Bearer $token"},
    );
  }

  Future<Map<String, dynamic>> conectarTarjeta(
    Map<String, String> tarjeta,
  ) async {
    return await _apiService.putForm('KxCrmSolicitudTarjetaControl', tarjeta);
  }
}
