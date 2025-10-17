import 'dart:convert';
import '../../core/services/base_api_service.dart';
import '../../data/models/log_model.dart';
import '../../data/models/ticket_model.dart';

class AccionesService {
  final String token;
  final BaseApiService _api = BaseApiService();

  AccionesService(this.token);

  // Método genérico para enviar cualquier acción/observación
  Future<Map<String, dynamic>> _postAccion({
    required int ticketId,
    required String idCrmDice,
    String? observacion,
    String? fechaAgendaIso,
  }) async {
    print("Token usado: $token");
    final body = {
      "idCrmTicket": ticketId,
      "idCrmDice": idCrmDice,
      "observacion": observacion ?? "",
      if (fechaAgendaIso != null) "fechaAgendaIso": fechaAgendaIso,
      // se agrega solo si no es null
    };

    return await _api.post(
      "crm/tickets/agendar-observaciones",
      body,
      headers: {"Authorization": "Bearer $token"},
    );
  }

  // Para agendar con fecha y hora específica
  Future<void> agendar({
    required int ticketId,
    required String idCrmDice,
    required String fechaAgendaIso,
    String? observacion,
  }) async {
    final resp = await _postAccion(
      ticketId: ticketId,
      idCrmDice: idCrmDice,
      fechaAgendaIso: fechaAgendaIso,
      observacion: observacion,
    );
    if (resp["codigo"] != 0) throw Exception(resp["mensaje"]);
  }

  // Para agregar solo una observación sin fecha
  Future<void> agregarObservacion({
    required int ticketId,
    required String idCrmDice,
    required String observacion,
  }) async {
    final resp = await _postAccion(
      ticketId: ticketId,
      idCrmDice: idCrmDice,
      observacion: observacion,
    );
    if (resp["codigo"] != 0) throw Exception(resp["mensaje"]);
  }

  Future<void> enviarSolicitud({required int ticketId}) async {
    final body = {"idCrmTicket": ticketId};

    // Debug: mostrar token usado
    print("Token usado: $token");

    final resp = await _api.post(
      "crm/tickets/enviar-solicitud",
      body,
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json", // asegúrate de incluirlo
      },
    );

    // Validar respuesta según la documentación
    if (resp["codigo"] != 0) {
      throw Exception(resp["mensaje"]);
    } else {
      print("Solicitud enviada correctamente: ${resp["mensaje"]}");
    }
  }

  // Obtener logs usando tu endpoint POST
  Future<List<LogModel>> getLogs(int ticketId) async {
    final body = {"id": ticketId};
    final resp = await _api.post(
      "crm/log/buscar-logs",
      body,
      headers: {"Authorization": "Bearer $token"},
    );

    if (resp is List) {
      return resp.map((e) => LogModel.fromJson(e)).toList();
    }
    return [];
  }

  Future<TicketModel> getTicketPorId(int id) async {
    final data = {"id": id};
    final response = await _api.post(
      'crm/tickets/detalles',
      data,
      headers: {"Authorization": "Bearer $token"},
    );

    return TicketModel.fromJson(response);
  }


}
