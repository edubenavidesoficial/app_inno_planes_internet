import '../../data/models/ticket_model.dart';
import 'base_api_service.dart';

class TicketService extends BaseApiService {
  Future<List<Map<String, dynamic>>> getTicketsPorUsuario({
    required String token,
    required int usuGen,
    int? idEstado,
    DateTime? fechaInicio,
    DateTime? fechaFin,
    String? ruc,
  }) async {
    final body = {
      "estado": idEstado,
      "fechaInicio": fechaInicio?.toIso8601String(),
      "fechaFin": fechaFin?.toIso8601String(),
      "busqueda": ruc, // RUC dinámico
      "usuGen": usuGen,
    };

    final headers = {'Authorization': 'Bearer $token'};

    final response = await post('crm/tickets/buscar', body, headers: headers);
    return List<Map<String, dynamic>>.from(response);
  }

  Future<List<Map<String, dynamic>>> getEstadosCrm({
    required String token,
  }) async {
    final response = await get(
      'crm/estados',
      headers: {'Authorization': 'Bearer $token'},
    );
    return List<Map<String, dynamic>>.from(response);
  }

  Future<TicketModel> getTicketPorId(int id, {required String token}) async {
    final data = {"id": id};
    final response = await post(
      'crm/tickets/detalles',
      data,
      headers: {"Authorization": "Bearer $token"},
    );

    return TicketModel.fromJson(response);
  }

  Future<Map<String, dynamic>> aprobarContrato(
    Map<String, String> contrato,
  ) async {
    return await postForm('KxCrmContratoTmpControl', contrato);
  }

  Future<Map<String, dynamic>> enviarSolicitudFirma(
    Map<String, String> contrato,
  ) async {
    return await postForm('KxSgnValidarRucControl', contrato);
  }

  Future<Map<String, dynamic>> accionesSolicitudFirma(
    Map<String, String> contrato,
  ) async {
    return await postForm('KxCrmContratoTmpAccionControl', contrato);
  }
}
