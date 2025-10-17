class BuroResponse {
  final int id;
  final int usu;
  final String fecha;
  final String tipoDoc;
  final String ruc;
  final String nombre;
  final double puntuacion;
  final Report report;

  BuroResponse({
    required this.id,
    required this.usu,
    required this.fecha,
    required this.tipoDoc,
    required this.ruc,
    required this.nombre,
    required this.puntuacion,
    required this.report,
  });

  factory BuroResponse.fromJson(Map<String, dynamic> json) {
    return BuroResponse(
      id: json['id'],
      usu: json['usu'],
      fecha: json['fecha'],
      tipoDoc: json['tipoDoc'],
      ruc: json['ruc'],
      nombre: json['nombre'],
      puntuacion: (json['puntuacion'] as num).toDouble(),
      report: Report.fromJson(json['report']),
    );
  }
}

class Report {
  final String status;
  final String transactionId;
  final ReporteCrediticio reporteCrediticio;

  Report({
    required this.status,
    required this.transactionId,
    required this.reporteCrediticio,
  });

  factory Report.fromJson(Map<String, dynamic> json) {
    return Report(
      status: json['status'],
      transactionId: json['transactionId'],
      reporteCrediticio: ReporteCrediticio.fromJson(json['reporteCrediticio']),
    );
  }
}

class ReporteCrediticio {
  final List<Score> score;

  ReporteCrediticio({required this.score});

  factory ReporteCrediticio.fromJson(Map<String, dynamic> json) {
    var list = (json['score'] as List)
        .map((item) => Score.fromJson(item))
        .toList();
    return ReporteCrediticio(score: list);
  }
}

class Score {
  final int score;
  final int scoreMax;
  final int scoreMin;
  final int totalAcum;
  final String fechaFinal;
  final String fechaInicial;
  final double tasaDeMalosAcum;

  Score({
    required this.score,
    required this.scoreMax,
    required this.scoreMin,
    required this.totalAcum,
    required this.fechaFinal,
    required this.fechaInicial,
    required this.tasaDeMalosAcum,
  });

  factory Score.fromJson(Map<String, dynamic> json) {
    return Score(
      score: json['score'],
      scoreMax: json['score_max'],
      scoreMin: json['score_min'],
      totalAcum: json['total_acum'],
      fechaFinal: json['fecha_final'],
      fechaInicial: json['fecha_inicial'],
      tasaDeMalosAcum: (json['tasa_de_malos_acum'] as num).toDouble(),
    );
  }
}
