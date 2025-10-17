import 'package:flutter/material.dart';
import 'package:klaxcrm/data/models/ticket_model.dart';
import 'package:klaxcrm/data/models/solicitud_model.dart';
import 'package:klaxcrm/core/services/solicitud_service.dart';

class SolicitudViewModel extends ChangeNotifier {
  final SolicitudService _solicitudService = SolicitudService();

  bool _isLoading = false;
  String? _token;
  SolicitudModel _solicitud = SolicitudModel.empty();

  bool get isLoading => _isLoading;

  SolicitudModel get solicitud => _solicitud;

  SolicitudViewModel(TicketModel ticket, {String? token}) {
    _token = token;
    _initSolicitudTicket(ticket);
  }

  /// Permite actualizar/inyectar token si cambia la sesión
  void setToken(String? token) {
    _token = token;
  }

  void _initSolicitudTicket(TicketModel ticket) {
    if (ticket.solicitudes.isNotEmpty) {
      _solicitud = ticket.solicitudes.first.copyWith(
        idCrmTicketFk: ticket.idCrmTicket,
      );
    } else {
      // Si tu modelo tiene más campos obligatorios, ajusta aquí.
      _solicitud = SolicitudModel.empty().copyWith(
        idCrmTicketFk: ticket.idCrmTicket,
      );
    }
    notifyListeners();
  }

  /// Unifica numMegas/numMega:
  /// - Usa solo `numMegas` (double?) si tu modelo lo define así.
  void updateSolicitud({
    int? idCrmTicketFk,
    double? valorPlan,
    String? direccion,
    String? latitud,
    String? longitud,
    String? ctaNumero,
    double? valorDebitar,
    int? idConPlanFk,
    int? idConConvenioPagoFk,
    int? idConCasaFk,
    int? idConBuroFk,
    int? idCiuBarrioFk,
    int? permanenciaMinima,
    double? costoFacturar,
    // ELIMINADO: double? pagoInicial,
    int? idConFormaPagoFk,
    int? idConFormaPagoSubFk,
    int? debitoDni,
    String? debitoRuc,
    String? debitoNombre,
    int? ctaTipo,
    String? tarVence,
    int? usuVendedor,
    // ELIMINADO: double? numMega,
    int? idConDebitoFk,
    int? routerFacturado,
    int? numMesFactura,
    String? debitoIdTaxTipIdeFk, // cambia a int? si tu modelo lo requiere
    int? con,
    double? numMega,
  }) {
    _solicitud = _solicitud.copyWith(
      idCrmTicketFk: idCrmTicketFk,
      valorPlan: valorPlan,
      direccion: direccion,
      latitud: latitud,
      longitud: longitud,
      ctaNumero: ctaNumero,
      valorDebitar: valorDebitar,
      idConPlanFk: idConPlanFk,
      idConConvenioPagoFk: idConConvenioPagoFk,
      idConCasaFk: idConCasaFk,
      idConBuroFk: idConBuroFk,
      idCiuBarrioFk: idCiuBarrioFk,
      permanenciaMinima: permanenciaMinima,
      costoFacturar: costoFacturar,
      // pagoInicial: pagoInicial, // ← eliminado
      idConFormaPagoFk: idConFormaPagoFk,
      idConFormaPagoSubFk: idConFormaPagoSubFk,
      debitoDni: debitoDni,
      debitoRuc: debitoRuc,
      debitoNombre: debitoNombre,
      ctaTipo: ctaTipo,
      tarVence: tarVence,
      usuVendedor: usuVendedor,
      // numMega: numMega, // ← sustituido por numMegas
      idConDebitoFk: idConDebitoFk,
      routerFacturado: routerFacturado,
      numMesFactura: numMesFactura,
      debitoIdTaxTipIdeFk: debitoIdTaxTipIdeFk,
      con: con,
      numMega: numMega, // asegúrate que exista en tu modelo/copyWith
    );
    notifyListeners();
  }

  /// Define claramente la respuesta esperada del servicio
  /// { codigo: int, mensaje: String, id: int? }
  Future<String> guardarSolicitud() async {
    if (_token == null || _token!.isEmpty) {
      return 'Token no disponible. Inicie sesión nuevamente.';
    }

    _isLoading = true;
    notifyListeners();

    try {
      final Map<String, dynamic> resp = await _solicitudService
          .guardarSolicitud(_solicitud.toJson(), token: _token!);

      if (resp.isEmpty) {
        return 'Ha ocurrido un error, consulte con el administrador.';
      }

      final int codigo = resp['codigo'] is int ? resp['codigo'] as int : -1;
      final String mensaje = (resp['mensaje'] ?? 'Operación realizada')
          .toString();

      if (codigo == 0) {
        // Si el backend devuelve el id generado de la solicitud
        final dynamic id = resp['id'];
        if (id != null) {
          _solicitud = _solicitud.copyWith(
            idCrmSolicitud: id is int ? id : int.tryParse('$id'),
          );
          notifyListeners();
        }
      }

      return mensaje;
    } catch (e) {
      return 'Error al guardar la solicitud: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<String> consultarTaxdni() async {
    if (_token == null || _token!.isEmpty) {
      return 'Token no disponible. Inicie sesión nuevamente.';
    }
    _isLoading = true;
    notifyListeners();
    try {
      Map<String, dynamic> ruc = {"ruc": _solicitud.debitoRuc};
      final Map<String, dynamic> resp = await _solicitudService.consultarTaxDni(
        ruc,
        token: _token!,
      );
      if (resp.isEmpty) {
        return 'Ha ocurrido un error, consulte con el administrador.';
      }
      final int idTaxDni = resp['idTaxDni'] is int
          ? resp['idTaxDni'] as int
          : 0;
      if (idTaxDni > 0) {
        _solicitud = _solicitud.copyWith(
          debitoDni: idTaxDni,
          debitoNombre: resp['nombre'],
          debitoRuc: resp['ruc'],
        );
        notifyListeners();
        return '0';
      } else {
        return 'VERIFIQUE NUEVAMENTE EL NUI';
      }
    } catch (e) {
      return 'Error al guardar la solicitud: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<String> conectarTarjeta() async {
    _isLoading = true;
    notifyListeners();
    try {
      Map<String, String> tarjeta = {
        "op": "registrar",
        "id": _solicitud.idCrmSolicitud.toString(),
        "tipo": "crm",
        "dni": _solicitud.debitoDni.toString(),
        "usu": _solicitud.usuGen.toString(),
        "fn": "^",
      };
      final Map<String, dynamic> resp = await _solicitudService.conectarTarjeta(
        tarjeta,
      );
      if (resp.isEmpty) {
        return 'Ha ocurrido un error, consulte con el administrador.';
      }
      final int codigo = resp['codigo'] is int ? resp['codigo'] as int : -1;
      if (codigo == 0) {
        _solicitud = _solicitud.copyWith(
          idTarjeta: resp['id'] is int ? resp['id'] as int : 0,
        );
        notifyListeners();
        return '0';
      } else {
        return 'VERIFIQUE NUEVAMENTE EL NUI';
      }
    } catch (e) {
      return 'Error al guardar la solicitud: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<Map<String, dynamic>> registrarTarjeta() async {
    Map<String, String> tarjeta = {
      "op": "tarjeta",
      "id": _solicitud.idTarjeta.toString(),
      "fn": "^",
    };
    return await _solicitudService.conectarTarjeta(tarjeta);
  }

  Future<bool> enviarLinkRegistroTarjeta() async {
    Map<String, String> tarjeta = {
      "op": "tarjeta",
      "id": _solicitud.idTarjeta.toString(),
      "fn": "^",
    };
    return true;
  }
}
