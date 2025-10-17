class ChecklistModel {
  final int? idCrmChecklistTicket;
  final int idCrmChecklistTip;
  final String nombre;
  final String? nombreDocumento;
  final String? observacion;
  final String? estado;
  final int? idCrmTicketFk;
  final bool? transferido;
  final String? txtEstado;

  ChecklistModel({
    this.idCrmChecklistTicket,
    required this.idCrmChecklistTip,
    required this.nombre,
    this.nombreDocumento,
    this.observacion,
    this.estado,
    this.idCrmTicketFk,
    this.transferido,
    this.txtEstado,
  });

  factory ChecklistModel.fromJson(Map<String, dynamic> json) => ChecklistModel(
    idCrmChecklistTicket: json['idCrmChecklistTicket'],
    idCrmChecklistTip: json['idCrmChecklistTip'] ?? 0,
    nombre: json['nombre'] ?? '',
    nombreDocumento: json['nombreDocumento'],
    observacion: json['observacion'],
    estado: json['estado'],
    idCrmTicketFk: json['idCrmTicketFk'],
    transferido: json['transferido'],
    txtEstado: json['txtEstado'],
  );

  Map<String, dynamic> toJson() => {
    'idCrmChecklistTicket': idCrmChecklistTicket,
    'idCrmChecklistTip': idCrmChecklistTip,
    'nombre': nombre,
    'nombreDocumento': nombreDocumento,
    'observacion': observacion,
    'estado': estado,
    'idCrmTicketFk': idCrmTicketFk,
    'transferido': transferido,
    'txtEstado': txtEstado,
  };

  ChecklistModel copyWith({
    int? idCrmChecklistTicket,
    int? idCrmChecklistTip,
    String? nombre,
    String? nombreDocumento,
    String? observacion,
    String? estado,
    int? idCrmTicketFk,
    bool? transferido,
    String? txtEstado,
  }) {
    return ChecklistModel(
      idCrmChecklistTicket: idCrmChecklistTicket ?? this.idCrmChecklistTicket,
      idCrmChecklistTip: idCrmChecklistTip ?? this.idCrmChecklistTip,
      nombre: nombre ?? this.nombre,
      nombreDocumento: nombreDocumento ?? this.nombreDocumento,
      observacion: observacion ?? this.observacion,
      estado: estado ?? this.estado,
      idCrmTicketFk: idCrmTicketFk ?? this.idCrmTicketFk,
      transferido: transferido ?? this.transferido,
      txtEstado: txtEstado ?? this.txtEstado,
    );
  }
}
