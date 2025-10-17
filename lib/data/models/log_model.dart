class LogModel {
  final String? fecha;
  final String? estado;
  final String? usuario;
  final String? observacion;

  LogModel({this.fecha, this.estado, this.usuario, this.observacion});

  factory LogModel.fromJson(Map<String, dynamic> json) {
    return LogModel(
      fecha: json['fecha'] as String?,
      estado: json['estado'] as String?,
      usuario: json['usuario'] as String?,
      observacion: json['observacion'] as String?,
    );
  }
}
