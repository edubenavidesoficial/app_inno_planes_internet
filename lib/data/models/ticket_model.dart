import 'package:klaxcrm/data/models/prospecto_model.dart';
import 'checklist_model.dart';
import 'solicitud_model.dart';

class TicketModel {
  final int idCrmTicket;
  final DateTime fecGen;
  final int usuGen;
  final String token;
  final String direccion;
  final int idCiuParroquiaFk;
  final List<ProspectoModel> prospectos;
  final List<SolicitudModel> solicitudes;
  final List<ChecklistModel> checklist;

  // Campos adicionales del JSON
  final int? idCrmEstadoFk;
  final String? estado;
  final String? nombre;
  final String? ruc;
  final String? movil;
  final String? telefono;
  final String? email;
  final String? carnetConadis;
  final String? usuarioGen;
  final String? dice;
  final String? detalle;
  final String? color;
  final String? colorTexto;
  final int? usuResponsable;
  final int? usuDev;

  TicketModel({
    required this.idCrmTicket,
    required this.fecGen,
    required this.usuGen,
    required this.token,
    required this.direccion,
    required this.idCiuParroquiaFk,
    required this.prospectos,
    required this.solicitudes,
    required this.checklist,
    // opcionales
    this.idCrmEstadoFk,
    this.estado,
    this.nombre,
    this.ruc,
    this.movil,
    this.telefono,
    this.email,
    this.carnetConadis,
    this.usuarioGen,
    this.dice,
    this.detalle,
    this.color,
    this.colorTexto,
    this.usuResponsable,
    this.usuDev,
  });

  factory TicketModel.fromJson(Map<String, dynamic> json) {
    return TicketModel(
      idCrmTicket: json['idCrmTicket'] ?? 0,
      fecGen: DateTime.tryParse(json['fecGen'] ?? '') ?? DateTime.now(),
      usuGen: json['usuGen'] ?? 0,
      token: json['token'] ?? '',
      direccion: json['direccion'] ?? '',
      idCiuParroquiaFk: json['idCiuParroquiaFk'] ?? 0,
      prospectos: (json['prospectos'] as List<dynamic>? ?? [])
          .map((e) => ProspectoModel.fromJson(e))
          .toList(),
      solicitudes: (json['solicitudes'] as List<dynamic>? ?? [])
          .map((e) => SolicitudModel.fromJson(e))
          .toList(),
      checklist: (json['checklist'] as List<dynamic>? ?? [])
          .map((e) => ChecklistModel.fromJson(e))
          .toList(),
      // adicionales
      idCrmEstadoFk: json['idCrmEstadoFk'],
      estado: json['estado'],
      nombre: json['nombre'],
      ruc: json['ruc'],
      movil: json['movil'],
      telefono: json['telefono'],
      email: json['email'],
      carnetConadis: json['carnetConadis'],
      usuarioGen: json['usuarioGen'],
      dice: json['dice'],
      detalle: json['detalle'],
      color: json['color'],
      colorTexto: json['colorTexto'],
      usuResponsable: json['usuResponsable'],
      usuDev: json['usuDev'],
    );
  }

  Map<String, dynamic> toJson() => {
    'idCrmTicket': idCrmTicket,
    'fecGen': fecGen.toIso8601String(),
    'usuGen': usuGen,
    'token': token,
    'direccion': direccion,
    'idCiuParroquiaFk': idCiuParroquiaFk,
    'prospectos': prospectos.map((e) => e.toJson()).toList(),
    'solicitudes': solicitudes.map((e) => e.toJson()).toList(),
    'checklist': checklist.map((e) => e.toJson()).toList(),
    // adicionales
    'idCrmEstadoFk': idCrmEstadoFk,
    'estado': estado,
    'nombre': nombre,
    'ruc': ruc,
    'movil': movil,
    'telefono': telefono,
    'email': email,
    'carnetConadis': carnetConadis,
    'usuarioGen': usuarioGen,
    'dice': dice,
    'detalle': detalle,
    'color': color,
    'colorTexto': colorTexto,
    'usuResponsable': usuResponsable,
    'usuDev': usuDev,
  };
}
