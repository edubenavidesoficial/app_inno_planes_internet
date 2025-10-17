import 'package:flutter/material.dart';
import '../../core/services/acciones_service.dart';
import '../../data/models/log_model.dart';
import '../../data/models/ticket_model.dart';

class AccionesViewModel extends ChangeNotifier {
  final AccionesService service;
  final int ticketId;

  bool cargando = false;
  bool bloqueando = false;
  List<LogModel> logs = [];

  AccionesViewModel(String token, this.ticketId)
    : service = AccionesService(token) {
    obtenerLogs();
  }

  void setBloqueo(bool valor) {
    bloqueando = valor;
    notifyListeners();
  }

  Future<void> obtenerLogs() async {
    try {
      cargando = true;
      notifyListeners();
      logs = await service.getLogs(ticketId);
    } catch (e) {
      debugPrint("Error al obtener logs: $e");
    } finally {
      cargando = false;
      notifyListeners();
    }
  }

  Future<void> agendar({
    required String idCrmDice,
    required String fechaIso,
    String? observacion,
  }) async {
    try {
      await service.agendar(
        ticketId: ticketId,
        idCrmDice: idCrmDice,
        fechaAgendaIso: fechaIso,
        observacion: observacion,
      );
      await obtenerLogs();
    } catch (e) {
      debugPrint("Error al agendar: $e");
      rethrow;
    }
  }

  Future<void> agregarObservacion({
    required String idCrmDice,
    required String observacion,
  }) async {
    try {
      await service.agregarObservacion(
        ticketId: ticketId,
        idCrmDice: idCrmDice,
        observacion: observacion,
      );
      await obtenerLogs();
    } catch (e) {
      debugPrint("Error al agregar observación: $e");
      rethrow;
    }
  }

  // ✨ Aquí se ajusta para la nueva API
  Future<void> enviarSolicitud() async {
    try {
      await service.enviarSolicitud(ticketId: ticketId);
      await obtenerLogs();
    } catch (e) {
      debugPrint("Error al enviar solicitud: $e");
      rethrow;
    }
  }

  Future<TicketModel> validarTicket() async {
    try {
      return await service.getTicketPorId(ticketId);
    } catch (e) {
      debugPrint("Error al enviar solicitud: $e");
      rethrow;
    }
  }
}
