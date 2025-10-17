class FormaPagoModel {
  final int idConFormaPago;
  final String tipo;
  final String institucion;
  final bool? activado;

  FormaPagoModel({
    required this.idConFormaPago,
    required this.tipo,
    required this.institucion,
    this.activado,
  });

  factory FormaPagoModel.fromJson(Map<String, dynamic> json) => FormaPagoModel(
    idConFormaPago: json['idConFormaPago'] ?? 0,
    tipo: json['tipo'] ?? '',
    institucion: json['institucion'] ?? '',
    activado: json['activado'],
  );

  Map<String, dynamic> toJson() => {
    'idConFormaPago': idConFormaPago,
    'tipo': tipo,
    'institucion': institucion,
    'activado': activado,
  };

  factory FormaPagoModel.empty() => FormaPagoModel(
    idConFormaPago: 0,
    tipo: '',
    institucion: '',
    activado: null,
  );
}
