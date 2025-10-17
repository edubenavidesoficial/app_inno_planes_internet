class ProspectoModel {
  final int idCrmProspecto;
  final int idCrmTicketFk;
  final String dni;
  final int? idTaxTipIdeFk;
  final String ruc;
  final String nombre;
  final String telefono;
  final String movil;
  final String email;
  final int idCiuParroquiaFk;
  final String direccion;
  final String? gps;
  final DateTime fecNacimiento;
  final String? carnetConadis;
  final int? idCrmProspectoTipo;
  final int usuGen;
  final DateTime fecGen;
  final String usuario;
  final String? tipo;
  final String? repLegal;
  final String? cargo;
  final String? representante;

  ProspectoModel({
    required this.idCrmProspecto,
    required this.idCrmTicketFk,
    required this.dni,
    required this.idTaxTipIdeFk,
    required this.ruc,
    required this.nombre,
    required this.telefono,
    required this.movil,
    required this.email,
    required this.idCiuParroquiaFk,
    required this.direccion,
    required this.gps,
    required this.fecNacimiento,
    required this.carnetConadis,
    required this.idCrmProspectoTipo,
    required this.usuGen,
    required this.fecGen,
    required this.usuario,
    required this.tipo,
    required this.repLegal,
    required this.cargo,
    required this.representante,
  });

  /// Crea una instancia desde JSON
  factory ProspectoModel.fromJson(Map<String, dynamic> json) {
    return ProspectoModel(
      idCrmProspecto: json['idCrmProspecto'] ?? 0,
      idCrmTicketFk: json['idCrmTicketFk'] ?? 0,
      dni: json['dni'] ?? '',
      idTaxTipIdeFk: json['idTaxTipIdeFk'],
      ruc: json['ruc'] ?? '',
      nombre: json['nombre'] ?? '',
      telefono: json['telefono'] ?? '',
      movil: json['movil'] ?? '',
      email: json['email'] ?? '',
      idCiuParroquiaFk: json['idCiuParroquiaFk'] ?? 0,
      direccion: json['direccion'] ?? '',
      gps: json['gps'],
      fecNacimiento:
          DateTime.tryParse(json['fecNacimiento'] ?? '') ??
          DateTime(1900, 1, 1),
      carnetConadis: json['carnetConadis'],
      idCrmProspectoTipo: json['idCrmProspectoTipo'],
      usuGen: json['usuGen'] ?? 0,
      fecGen: DateTime.tryParse(json['fecGen'] ?? '') ?? DateTime(1900, 1, 1),
      usuario: json['usuario'] ?? '',
      tipo: json['tipo'],
      repLegal: json['repLegal'],
      cargo: json['cargo'],
      representante: json['representante'],
    );
  }

  /// Convierte a JSON
  Map<String, dynamic> toJson() {
    return {
      'idCrmProspecto': idCrmProspecto,
      'idCrmTicketFk': idCrmTicketFk,
      'dni': dni,
      'idTaxTipIdeFk': idTaxTipIdeFk,
      'ruc': ruc,
      'nombre': nombre,
      'telefono': telefono,
      'movil': movil,
      'email': email,
      'idCiuParroquiaFk': idCiuParroquiaFk,
      'direccion': direccion,
      'gps': gps,
      'fecNacimiento': fecNacimiento.toIso8601String(),
      'carnetConadis': carnetConadis,
      'idCrmProspectoTipo': idCrmProspectoTipo,
      'usuGen': usuGen,
      'fecGen': fecGen.toIso8601String(),
      'usuario': usuario,
      'tipo': tipo,
      'repLegal': repLegal,
      'cargo': cargo,
      'representante': representante,
    };
  }

  /// Clona el modelo con datos modificados
  ProspectoModel copyWith({
    int? idCrmProspecto,
    int? idCrmTicketFk,
    String? dni,
    int? idTaxTipIdeFk,
    String? ruc,
    String? nombre,
    String? telefono,
    String? movil,
    String? email,
    int? idCiuParroquiaFk,
    String? direccion,
    String? gps,
    DateTime? fecNacimiento,
    String? carnetConadis,
    int? idCrmProspectoTipo,
    int? usuGen,
    DateTime? fecGen,
    String? usuario,
    String? tipo,
    String? repLegal,
    String? cargo,
    String? representante,
  }) {
    return ProspectoModel(
      idCrmProspecto: idCrmProspecto ?? this.idCrmProspecto,
      idCrmTicketFk: idCrmTicketFk ?? this.idCrmTicketFk,
      dni: dni ?? this.dni,
      idTaxTipIdeFk: idTaxTipIdeFk ?? this.idTaxTipIdeFk,
      ruc: ruc ?? this.ruc,
      nombre: nombre ?? this.nombre,
      telefono: telefono ?? this.telefono,
      movil: movil ?? this.movil,
      email: email ?? this.email,
      idCiuParroquiaFk: idCiuParroquiaFk ?? this.idCiuParroquiaFk,
      direccion: direccion ?? this.direccion,
      gps: gps ?? this.gps,
      fecNacimiento: fecNacimiento ?? this.fecNacimiento,
      carnetConadis: carnetConadis ?? this.carnetConadis,
      idCrmProspectoTipo: idCrmProspectoTipo ?? this.idCrmProspectoTipo,
      usuGen: usuGen ?? this.usuGen,
      fecGen: fecGen ?? this.fecGen,
      usuario: usuario ?? this.usuario,
      tipo: tipo ?? this.tipo,
      repLegal: repLegal ?? this.repLegal,
      cargo: cargo ?? this.cargo,
      representante: representante ?? this.representante,
    );
  }
}
