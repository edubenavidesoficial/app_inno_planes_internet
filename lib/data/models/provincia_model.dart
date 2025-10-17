class ProvinciaModel {
  final int id;
  final String nombre;

  /// Campos extra que vengan del backend
  final Map<String, dynamic> extras;

  ProvinciaModel({
    required this.id,
    required this.nombre,
    this.extras = const {},
  });

  factory ProvinciaModel.fromJson(Map<String, dynamic> json) {
    if (!json.containsKey('idCiuProvincia') || !json.containsKey('provincia')) {
      throw FormatException(
        'Faltan campos requeridos en ProvinciaModel: $json',
      );
    }

    final int idParsed = _safeParseInt(json['idCiuProvincia']);
    final String nombreParsed = json['provincia'].toString().trim();

    // Guardar campos adicionales
    final extrasMap = Map<String, dynamic>.from(json)
      ..remove('idCiuProvincia')
      ..remove('provincia');

    return ProvinciaModel(
      id: idParsed,
      nombre: nombreParsed,
      extras: extrasMap,
    );
  }

  Map<String, dynamic> toJson() {
    return {'idCiuProvincia': id, 'provincia': nombre, ...extras};
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
      other is ProvinciaModel &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}
