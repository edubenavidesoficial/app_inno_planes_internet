class CantonModel {
  final int id;
  final String nombre;
  final int provinciaId;

  /// Campos adicionales no declarados
  final Map<String, dynamic> extras;

  CantonModel({
    required this.id,
    required this.nombre,
    required this.provinciaId,
    this.extras = const {},
  });

  factory CantonModel.fromJson(Map<String, dynamic> json) {
    if (!json.containsKey('idCiuCanton') || !json.containsKey('canton')) {
      throw FormatException('Faltan campos requeridos en CantonModel: $json');
    }

    final idParsed = _safeParseInt(json['idCiuCanton']);
    final nombreParsed = json['canton'].toString().trim();
    final provinciaIdParsed = _safeParseInt(json['idCiuProvinciaFk']);

    final extrasMap = Map<String, dynamic>.from(json)
      ..remove('idCiuCanton')
      ..remove('canton')
      ..remove('idCiuProvinciaFk');

    return CantonModel(
      id: idParsed,
      nombre: nombreParsed,
      provinciaId: provinciaIdParsed,
      extras: extrasMap,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'idCiuCanton': id,
      'canton': nombre,
      'idCiuProvinciaFk': provinciaId,
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
      other is CantonModel &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}
