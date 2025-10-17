class ParroquiaModel {
  final int id;
  final String nombre;
  final int cantonId;

  /// Campos adicionales que vengan del backend
  final Map<String, dynamic> extras;

  ParroquiaModel({
    required this.id,
    required this.nombre,
    required this.cantonId,
    this.extras = const {},
  });

  factory ParroquiaModel.fromJson(Map<String, dynamic> json) {
    if (!json.containsKey('idCiuParroquia') || !json.containsKey('parroquia')) {
      throw FormatException(
        'Faltan campos requeridos en ParroquiaModel: $json',
      );
    }

    final idParsed = _safeParseInt(json['idCiuParroquia']);
    final nombreParsed = json['parroquia'].toString().trim();
    final cantonIdParsed = _safeParseInt(json['idCiuCantonFk']);

    // Guardar campos no utilizados
    final extrasMap = Map<String, dynamic>.from(json)
      ..remove('idCiuParroquia')
      ..remove('parroquia')
      ..remove('idCiuCantonFk');

    return ParroquiaModel(
      id: idParsed,
      nombre: nombreParsed,
      cantonId: cantonIdParsed,
      extras: extrasMap,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'idCiuParroquia': id,
      'parroquia': nombre,
      'idCiuCantonFk': cantonId,
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

  static bool _safeParseBool(dynamic value) {
    if (value is bool) return value;
    if (value is String) return value.toLowerCase() == 'true';
    if (value is int) return value != 0;
    throw FormatException('No se pudo convertir a bool: $value');
  }

  @override
  String toString() => nombre;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ParroquiaModel &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}
