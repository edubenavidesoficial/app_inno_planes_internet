class BarrioModel {
  final int id;
  final String nombre;
  final int parroquiaId;

  /// Campos adicionales que vengan del backend
  final Map<String, dynamic> extras;

  BarrioModel({
    required this.id,
    required this.nombre,
    required this.parroquiaId,
    this.extras = const {},
  });

  factory BarrioModel.fromJson(Map<String, dynamic> json) {
    if (!json.containsKey('idCiuBarrio') || !json.containsKey('barrio')) {
      throw FormatException('Faltan campos requeridos en BarrioModel: $json');
    }

    final idParsed = _safeParseInt(json['idCiuBarrio']);
    final nombreParsed = json['barrio'].toString().trim();
    final parroquiaIdParsed = _safeParseInt(json['idCiuParroquiaFk']);

    final extrasMap = Map<String, dynamic>.from(json)
      ..remove('idCiuBarrio')
      ..remove('barrio')
      ..remove('idCiuParroquiaFk');

    return BarrioModel(
      id: idParsed,
      nombre: nombreParsed,
      parroquiaId: parroquiaIdParsed,
      extras: extrasMap,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'idCiuBarrio': id,
      'barrio': nombre,
      'idCiuParroquiaFk': parroquiaId,
      ...extras,
    };
  }

  static int _safeParseInt(dynamic value) {
    if (value is int) return value;
    if (value is String) {
      final parsed = int.tryParse(value);
      if (parsed != null) return parsed;
    }
    throw FormatException('No se pudo convertir a int: $value');
  }

  @override
  String toString() => nombre;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BarrioModel &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}
