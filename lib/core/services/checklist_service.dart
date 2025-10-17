import 'dart:io';
import 'dart:typed_data';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'base_api_service.dart';

class ChecklistService extends BaseApiService {
  Future<Map<String, dynamic>> subirArchivoChecklist({
    required int idCrmTicketFk,
    required int idCrmChecklistTipFk,
    required int idCrmEstadoFk,
    required int usu,
    required String observacion,
    required File archivo,
    required String token,
  }) async {
    try {
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/crm/checklist/upload'),
      );

      // JSON que va en el campo "data"
      final dataJson = jsonEncode({
        "idCrmTicketFk": idCrmTicketFk,
        "idCrmChecklistTipFk": idCrmChecklistTipFk,
        "idCrmEstadoFk": idCrmEstadoFk,
        "usu": usu,
        "observacion": observacion,
      });

      request.fields['data'] = dataJson;

      // Archivo adjunto
      request.files.add(await http.MultipartFile.fromPath(
        'adjunto',
        archivo.path,
        filename: archivo.uri.pathSegments.last,
      ));

      request.headers['Authorization'] = 'Bearer $token';

      // Enviar request
      final streamed = await request.send();
      final response = await http.Response.fromStream(streamed);
      if (response.statusCode == 200) {
        return Map<String, dynamic>.from(jsonDecode(response.body));
      } else {
        throw Exception('Error al subir archivo: ${response.body}');
      }
    } catch (e, stack) {
      rethrow;
    }
  }

  // Descargar archivo enviando `idRegistroArchivo`
  Future<Uint8List> descargarArchivoChecklist({
    required int idRegistroArchivo,
    required String token,
  }) async {
    try {

      final response = await http.post(
        Uri.parse('$baseUrl/crm/checklist/archivo'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({"idRegistroArchivo": idRegistroArchivo}),
      );

      if (response.statusCode == 200) {
        return response.bodyBytes;
      } else {
         throw Exception('Error al descargar archivo: ${response.body}');
      }
    } catch (e, stack) {
      rethrow;
    }
  }
}
