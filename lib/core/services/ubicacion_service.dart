import '../../data/models/barrio_model.dart';
import '../../data/models/canton_model.dart';
import '../../data/models/parroquia_model.dart';
import '../../data/models/provincia_model.dart';
import 'base_api_service.dart';

class UbicacionService extends BaseApiService {
  /// GET /crm/ubicaciones/provincias
  Future<List<ProvinciaModel>> getProvincias({String? token}) async {
    final data = await get(
      'crm/ubicaciones/provincias',
      headers: token != null ? {"Authorization": "Bearer $token"} : null,
    );

    if (data is List) {
      return data.map((e) => ProvinciaModel.fromJson(e)).toList();
    } else {
      throw Exception('Formato inválido al obtener provincias');
    }
  }

  /// POST /crm/ubicaciones/cantones
  Future<List<CantonModel>> getCantones(
    int provinciaId, {
    String? token,
  }) async {
    final data = await post(
      'crm/ubicaciones/cantones',
      {'provinciaId': provinciaId},
      headers: token != null ? {"Authorization": "Bearer $token"} : null,
    );

    if (data is List) {
      return data.map((e) => CantonModel.fromJson(e)).toList();
    } else {
      throw Exception('Formato inválido al obtener cantones');
    }
  }

  /// POST /crm/ubicaciones/parroquias
  Future<List<ParroquiaModel>> getParroquias(
    int cantonId, {
    String? token,
  }) async {
    final data = await post(
      'crm/ubicaciones/parroquias',
      {'cantonId': cantonId},
      headers: token != null ? {"Authorization": "Bearer $token"} : null,
    );

    if (data is List) {
      return data.map((e) => ParroquiaModel.fromJson(e)).toList();
    } else {
      throw Exception('Formato inválido al obtener parroquias');
    }
  }

  /// POST /crm/ubicaciones/barrios
  Future<List<BarrioModel>> getBarrios(int parroquiaId, {String? token}) async {
    final data = await post(
      'crm/ubicaciones/barrios',
      {'parroquiaId': parroquiaId},
      headers: token != null ? {"Authorization": "Bearer $token"} : null,
    );

    if (data is List) {
      return data.map((e) => BarrioModel.fromJson(e)).toList();
    } else {
      throw Exception('Formato inválido al obtener barrios');
    }
  }

  /// Buscar barrio por ID navegando jerarquía
  Future<BarrioModel?> getBarrioPorId(int id, {String? token}) async {
    final provincias = await getProvincias(token: token);
    for (final provincia in provincias) {
      final cantones = await getCantones(provincia.id, token: token);
      for (final canton in cantones) {
        final parroquias = await getParroquias(canton.id, token: token);
        for (final parroquia in parroquias) {
          final barrios = await getBarrios(parroquia.id, token: token);
          try {
            final match = barrios.firstWhere((b) => b.id == id);
            return match;
          } catch (_) {}
        }
      }
    }
    return null;
  }

  /// Buscar parroquia por ID navegando jerarquía
  Future<ParroquiaModel?> getParroquiaPorId(int id, {String? token}) async {
    final provincias = await getProvincias(token: token);
    for (final provincia in provincias) {
      final cantones = await getCantones(provincia.id, token: token);
      for (final canton in cantones) {
        final parroquias = await getParroquias(canton.id, token: token);
        try {
          final match = parroquias.firstWhere((p) => p.id == id);
          return match;
        } catch (_) {}
      }
    }
    return null;
  }

  /// Buscar cantón por ID navegando provincias
  Future<CantonModel?> getCantonPorId(int id, {String? token}) async {
    final provincias = await getProvincias(token: token);
    for (final provincia in provincias) {
      final cantones = await getCantones(provincia.id, token: token);
      try {
        final match = cantones.firstWhere((c) => c.id == id);
        return match;
      } catch (_) {}
    }
    return null;
  }

  /// Buscar provincia por ID directamente
  Future<ProvinciaModel?> getProvinciaPorId(int id, {String? token}) async {
    final provincias = await getProvincias(token: token);
    try {
      final match = provincias.firstWhere((p) => p.id == id);
      return match;
    } catch (_) {
      return null;
    }
  }
}
