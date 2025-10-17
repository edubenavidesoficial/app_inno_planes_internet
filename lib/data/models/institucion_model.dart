class InstitucionModel {
  final int idConFormaPagoSub;
  final String institucion;
  final int idConFormaPagoFk;

  InstitucionModel({
    required this.idConFormaPagoSub,
    required this.institucion,
    required this.idConFormaPagoFk,
  });

  factory InstitucionModel.fromJson(Map<String, dynamic> json) =>
      InstitucionModel(
        idConFormaPagoSub: json['idConFormaPagoSub'] ?? 0,
        institucion: json['institucion'] ?? '',
        idConFormaPagoFk: json['idConFormaPagoFk'] ?? 0,
      );

  Map<String, dynamic> toJson() => {
    'idConFormaPagoSub': idConFormaPagoSub,
    'institucion': institucion,
    'idConFormaPagoFk': idConFormaPagoFk,
  };
}
