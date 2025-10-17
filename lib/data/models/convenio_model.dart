class ConvenioModel {
  final int idConConvenioPago;
  final String convenio;

  ConvenioModel({required this.idConConvenioPago, required this.convenio});

  factory ConvenioModel.fromJson(Map<String, dynamic> json) => ConvenioModel(
    idConConvenioPago: json['idConConvenioPago'] ?? 0,
    convenio: json['convenio'] ?? '',
  );

  Map<String, dynamic> toJson() => {
    'idConConvenioPago': idConConvenioPago,
    'convenio': convenio,
  };
}
