import 'package:klaxcrm/data/models/plan_model..dart';
import 'convenio_model.dart';
import 'formapago_model.dart';
import 'institucion_model.dart';

class SolicitudModel {
  final int? idCrmSolicitud;
  final int? idCrmTicketFk;
  final int? idCiuBarrioFk;
  final String? direccion;
  final String? latitud;
  final String? longitud;
  final DateTime? fecGen;
  final int? usuGen;
  final int? con;
  final int? idConPlanFk;
  final double? numMega;
  final int? idConConvenioPagoFk;
  final int? idConFormaPagoFk;
  final int? idConFormaPagoSubFk;
  final int? debitoDni;
  final String? debitoRuc;
  final String? debitoNombre;
  final String? debitoIdTaxTipIdeFk;
  final int? ctaTipo;
  final String? ctaNumero;
  final String? tarVence;
  final double? valorPlan;
  final double? valorDebitar;
  final int? usuVendedor;
  final int? idConBuroFk;
  final int? idConCasaFk;
  final double? costoFacturar;
  final int? permanenciaMinima;
  final double? pagoInicial;
  final int? idFacVentaPlanFk;
  final int? idConDebitoFk;
  final int? routerFacturado;
  final int? numMesFactura;

  final List<PlanModel> planes;
  final List<ConvenioModel> conveniosDebito;
  final List<FormaPagoModel> formasPago;
  final List<InstitucionModel> instituciones;

  final int? idTarjeta;

  SolicitudModel({
    this.idCrmSolicitud,
    this.idCrmTicketFk,
    this.idCiuBarrioFk,
    this.direccion,
    this.latitud,
    this.longitud,
    this.fecGen,
    this.usuGen,
    this.con,
    this.idConPlanFk,
    this.numMega,
    this.idConConvenioPagoFk,
    this.idConFormaPagoFk,
    this.idConFormaPagoSubFk,
    this.debitoDni,
    this.debitoRuc,
    this.debitoNombre,
    this.debitoIdTaxTipIdeFk,
    this.ctaTipo,
    this.ctaNumero,
    this.tarVence,
    this.valorPlan,
    this.valorDebitar,
    this.usuVendedor,
    this.idConBuroFk,
    this.idConCasaFk,
    this.costoFacturar,
    this.permanenciaMinima,
    this.pagoInicial,
    this.idFacVentaPlanFk,
    this.idConDebitoFk,
    this.routerFacturado,
    this.numMesFactura,
    required this.planes,
    required this.conveniosDebito,
    required this.formasPago,
    required this.instituciones,
    required this.idTarjeta,
  });

  factory SolicitudModel.fromJson(Map<String, dynamic> json) {
    return SolicitudModel(
      idCrmSolicitud: json['idCrmSolicitud'],
      idCrmTicketFk: json['idCrmTicketFk'],
      idCiuBarrioFk: json['idCiuBarrioFk'],
      direccion: json['direccion'],
      latitud: json['latitud'],
      longitud: json['longitud'],
      fecGen: json['fecGen'] != null ? DateTime.tryParse(json['fecGen']) : null,
      usuGen: json['usuGen'],
      con: json['con'],
      idConPlanFk: json['idConPlanFk'],
      numMega: json['numMega'],
      idConConvenioPagoFk: json['idConConvenioPagoFk'],
      idConFormaPagoFk: json['idConFormaPagoFk'],
      idConFormaPagoSubFk: json['idConFormaPagoSubFk'],
      debitoDni: json['debitoDni'],
      debitoRuc: json['debitoRuc'],
      debitoNombre: json['debitoNombre'],
      debitoIdTaxTipIdeFk: json['debitoIdTaxTipIdeFk'],
      ctaTipo: json['ctaTipo'],
      ctaNumero: json['ctaNumero'],
      tarVence: json['tarVence'],
      valorPlan: (json['valorPlan'] as num?)?.toDouble(),
      valorDebitar: (json['valorDebitar'] as num?)?.toDouble(),
      usuVendedor: json['usuVendedor'],
      idConBuroFk: json['idConBuroFk'],
      idConCasaFk: json['idConCasaFk'],
      costoFacturar: (json['costoFacturar'] as num?)?.toDouble(),
      permanenciaMinima: json['permanenciaMinima'],
      pagoInicial: (json['pagoInicial'] as num?)?.toDouble(),
      idFacVentaPlanFk: json['idFacVentaPlanFk'],
      idConDebitoFk: json['idConDebitoFk'],
      routerFacturado: json['routerFacturado'],
      numMesFactura: json['numMesFactura'],
      planes: (json['planes'] as List<dynamic>? ?? [])
          .map((e) => PlanModel.fromJson(e))
          .toList(),
      conveniosDebito: (json['conveniosDebito'] as List<dynamic>? ?? [])
          .map((e) => ConvenioModel.fromJson(e))
          .toList(),
      formasPago: (json['formasPago'] as List<dynamic>? ?? [])
          .map((e) => FormaPagoModel.fromJson(e))
          .toList(),
      instituciones: (json['instituciones'] as List<dynamic>? ?? [])
          .map((e) => InstitucionModel.fromJson(e))
          .toList(),
      idTarjeta: json['idTarjeta'],
    );
  }

  Map<String, dynamic> toJson() => {
    'idCrmSolicitud': idCrmSolicitud,
    'idCrmTicketFk': idCrmTicketFk,
    'idCiuBarrioFk': idCiuBarrioFk,
    'direccion': direccion,
    'latitud': latitud,
    'longitud': longitud,
    'fecGen': fecGen?.toIso8601String(),
    'usuGen': usuGen,
    'con': con,
    'idConPlanFk': idConPlanFk,
    'numMega': numMega,
    'idConConvenioPagoFk': idConConvenioPagoFk,
    'idConFormaPagoFk': idConFormaPagoFk,
    'idConFormaPagoSubFk': idConFormaPagoSubFk,
    'debitoDni': debitoDni,
    'debitoRuc': debitoRuc,
    'debitoNombre': debitoNombre,
    'debitoIdTaxTipIdeFk': debitoIdTaxTipIdeFk,
    'ctaTipo': ctaTipo,
    'ctaNumero': ctaNumero,
    'tarVence': tarVence,
    'valorPlan': valorPlan,
    'valorDebitar': valorDebitar,
    'usuVendedor': usuVendedor,
    'idConBuroFk': idConBuroFk,
    'idConCasaFk': idConCasaFk,
    'costoFacturar': costoFacturar,
    'permanenciaMinima': permanenciaMinima,
    'pagoInicial': pagoInicial,
    'idFacVentaPlanFk': idFacVentaPlanFk,
    'idConDebitoFk': idConDebitoFk,
    'routerFacturado': routerFacturado,
    'numMesFactura': numMesFactura,
    'idTarjeta': idTarjeta,
  };

  factory SolicitudModel.empty() {
    return SolicitudModel(
      idCrmSolicitud: null,
      idCrmTicketFk: null,
      idCiuBarrioFk: null,
      direccion: '',
      latitud: '',
      longitud: '',
      fecGen: null,
      usuGen: null,
      con: null,
      idConPlanFk: null,
      numMega: null,
      idConConvenioPagoFk: null,
      idConFormaPagoFk: null,
      idConFormaPagoSubFk: null,
      debitoDni: null,
      debitoRuc: '',
      debitoNombre: '',
      debitoIdTaxTipIdeFk: '',
      ctaTipo: null,
      ctaNumero: '',
      tarVence: '',
      valorPlan: null,
      valorDebitar: null,
      usuVendedor: null,
      idConBuroFk: null,
      idConCasaFk: null,
      costoFacturar: null,
      permanenciaMinima: null,
      pagoInicial: null,
      idFacVentaPlanFk: null,
      idConDebitoFk: null,
      routerFacturado: null,
      numMesFactura: null,
      planes: [],
      conveniosDebito: [],
      formasPago: [],
      instituciones: [],
      idTarjeta: null,
    );
  }

  SolicitudModel copyWith({
    int? idCrmSolicitud,
    int? idCrmTicketFk,
    int? idCiuBarrioFk,
    String? direccion,
    String? latitud,
    String? longitud,
    DateTime? fecGen,
    int? usuGen,
    int? con,
    int? idConPlanFk,
    double? numMega,
    int? idConConvenioPagoFk,
    int? idConFormaPagoFk,
    int? idConFormaPagoSubFk,
    int? debitoDni,
    String? debitoRuc,
    String? debitoNombre,
    String? debitoIdTaxTipIdeFk,
    int? ctaTipo,
    String? ctaNumero,
    String? tarVence,
    double? valorPlan,
    double? valorDebitar,
    int? usuVendedor,
    int? idConBuroFk,
    int? idConCasaFk,
    double? costoFacturar,
    int? permanenciaMinima,
    double? pagoInicial,
    int? idFacVentaPlanFk,
    int? idConDebitoFk,
    int? routerFacturado,
    int? numMesFactura,
    List<PlanModel>? planes,
    List<ConvenioModel>? conveniosDebito,
    List<FormaPagoModel>? formasPago,
    List<InstitucionModel>? instituciones,
    int? idTarjeta,
  }) {
    return SolicitudModel(
      idCrmSolicitud: idCrmSolicitud ?? this.idCrmSolicitud,
      idCrmTicketFk: idCrmTicketFk ?? this.idCrmTicketFk,
      idCiuBarrioFk: idCiuBarrioFk ?? this.idCiuBarrioFk,
      direccion: direccion ?? this.direccion,
      latitud: latitud ?? this.latitud,
      longitud: longitud ?? this.longitud,
      fecGen: fecGen ?? this.fecGen,
      usuGen: usuGen ?? this.usuGen,
      con: con ?? this.con,
      idConPlanFk: idConPlanFk ?? this.idConPlanFk,
      numMega: numMega ?? this.numMega,
      idConConvenioPagoFk: idConConvenioPagoFk ?? this.idConConvenioPagoFk,
      idConFormaPagoFk: idConFormaPagoFk ?? this.idConFormaPagoFk,
      idConFormaPagoSubFk: idConFormaPagoSubFk ?? this.idConFormaPagoSubFk,
      debitoDni: debitoDni ?? this.debitoDni,
      debitoRuc: debitoRuc ?? this.debitoRuc,
      debitoNombre: debitoNombre ?? this.debitoNombre,
      debitoIdTaxTipIdeFk: debitoIdTaxTipIdeFk ?? this.debitoIdTaxTipIdeFk,
      ctaTipo: ctaTipo ?? this.ctaTipo,
      ctaNumero: ctaNumero ?? this.ctaNumero,
      tarVence: tarVence ?? this.tarVence,
      valorPlan: valorPlan ?? this.valorPlan,
      valorDebitar: valorDebitar ?? this.valorDebitar,
      usuVendedor: usuVendedor ?? this.usuVendedor,
      idConBuroFk: idConBuroFk ?? this.idConBuroFk,
      idConCasaFk: idConCasaFk ?? this.idConCasaFk,
      costoFacturar: costoFacturar ?? this.costoFacturar,
      permanenciaMinima: permanenciaMinima ?? this.permanenciaMinima,
      pagoInicial: pagoInicial ?? this.pagoInicial,
      idFacVentaPlanFk: idFacVentaPlanFk ?? this.idFacVentaPlanFk,
      idConDebitoFk: idConDebitoFk ?? this.idConDebitoFk,
      routerFacturado: routerFacturado ?? this.routerFacturado,
      numMesFactura: numMesFactura ?? this.numMesFactura,
      planes: planes ?? this.planes,
      conveniosDebito: conveniosDebito ?? this.conveniosDebito,
      formasPago: formasPago ?? this.formasPago,
      instituciones: instituciones ?? this.instituciones,
      idTarjeta: idTarjeta ?? this.idTarjeta,
    );
  }
}
