import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:klaxcrm/core/services/checklist_service.dart';
import 'package:klaxcrm/data/models/checklist_model.dart';
import 'package:klaxcrm/data/models/ticket_model.dart';

class ChecklistViewModel extends ChangeNotifier {
  final ChecklistService _checklistService = ChecklistService();

  final List<ChecklistModel> _checklist = [];
  String? _token;
  bool _isLoading = false;
  String? _errorMessage;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  List<ChecklistModel> get checklist => List.unmodifiable(_checklist);

  ChecklistViewModel(TicketModel ticket, {String? token}) {
    _token = token;
    _loadChecklistFromTicket(ticket);
  }

  void setToken(String? token) {
    _token = token;
  }

  void _loadChecklistFromTicket(TicketModel ticket) {
    _checklist.clear();
    _checklist.addAll(ticket.checklist);
    notifyListeners();
  }

  /// Subir archivo usando la API V2 oficial
  Future<void> subirArchivo({
    required ChecklistModel item,
    required File archivo,
    required int idTicket,
  }) async {
    if (_token == null || _token!.isEmpty) {
      _errorMessage = "Token no disponible";
      notifyListeners();
      return;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final resp = await _checklistService.subirArchivoChecklist(
        idCrmTicketFk: idTicket,
        idCrmChecklistTipFk: item.idCrmChecklistTip,
        idCrmEstadoFk: 1,
        usu: 1,
        observacion: "Documento firmado",
        archivo: archivo,
        token: _token!,
      );

      final int codigo = resp['codigo'] ?? -1;
      if (codigo == 1) {
        // Actualiza el checklist localmente
        final idx = _checklist.indexWhere(
              (e) => e.idCrmChecklistTip == item.idCrmChecklistTip,
        );
        if (idx != -1) {
          _checklist[idx] = _checklist[idx].copyWith(
            idCrmChecklistTicket: resp['id'], // actualiza ID
            nombreDocumento: archivo.path.split("/").last,
            estado: "CARGADO",
          );
          notifyListeners();
        }
      } else {
        _errorMessage = resp['mensaje'] ?? 'Error desconocido al subir archivo';
      }
    } catch (e) {
      _errorMessage = "Error al subir archivo: $e";
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Descargar archivo usando la API V2 oficial
  Future<Uint8List?> descargarArchivo(int? idRegistroArchivo) async {
    if (_token == null || _token!.isEmpty || idRegistroArchivo == null) {
      _errorMessage = "Token o ID inválido para descargar";
      notifyListeners();
      return null;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final bytes = await _checklistService.descargarArchivoChecklist(
        idRegistroArchivo: idRegistroArchivo,
        token: _token!,
      );
      return bytes;
    } catch (e) {
      _errorMessage = "Error al descargar archivo: $e";
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void limpiarError() {
    _errorMessage = null;
    notifyListeners();
  }
}
