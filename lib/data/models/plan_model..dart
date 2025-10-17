class PlanModel {
  final int idConPlan;
  final String detalle;
  final String comportamiento;
  final double tarifaCompletaDes;
  final double comision;
  final double insCompleto;
  final int promoMes;
  final int primerMes;
  final int routerArt;

  PlanModel({
    required this.idConPlan,
    required this.detalle,
    required this.comportamiento,
    required this.tarifaCompletaDes,
    required this.comision,
    required this.insCompleto,
    required this.promoMes,
    required this.primerMes,
    required this.routerArt,
  });

  factory PlanModel.fromJson(Map<String, dynamic> json) => PlanModel(
    idConPlan: json['idConPlan'] ?? 0,
    detalle: json['detalle'] ?? '',
    comportamiento: json['comportamiento'] ?? '',
    tarifaCompletaDes: (json['tarifaCompletaDes'] as num?)?.toDouble() ?? 0.0,
    comision: (json['comision'] as num?)?.toDouble() ?? 0.0,
    insCompleto: (json['insCompleto'] as num?)?.toDouble() ?? 0.0,
    promoMes: json['promoMes'] ?? 0,
    primerMes: json['primerMes'] ?? 0,
    routerArt: json['routerArt'] ?? 0,
  );

  Map<String, dynamic> toJson() => {
    'idConPlan': idConPlan,
    'detalle': detalle,
    'comportamiento': comportamiento,
    'tarifaCompletaDes': tarifaCompletaDes,
    'comision': comision,
    'insCompleto': insCompleto,
    'promoMes': promoMes,
    'primerMes': primerMes,
    'routerArt': routerArt,
  };

  factory PlanModel.empty() {
    return PlanModel(
      idConPlan: 0,
      detalle: '',
      comportamiento: '',
      tarifaCompletaDes: 0.0,
      comision: 0.0,
      insCompleto: 0.0,
      promoMes: 0,
      primerMes: 0,
      routerArt: 0,
    );
  }
}
