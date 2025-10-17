import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;

class BaseApiService {
  final String baseUrl = 'http://186.209.213.4:5434/klaxerp/api';
  final String baseUrlForm = 'https://sistema.inno.com.ec:8445/klaxprueba';

  Future<dynamic> post(
    String endpoint,
    Map<String, dynamic> body, {
    Map<String, String>? headers,
  }) async {
    final uri = Uri.parse('$baseUrl/$endpoint');
    final defaultHeaders = {'Content-Type': 'application/json'};
    final combinedHeaders = {
      ...defaultHeaders,
      if (headers != null) ...headers,
    };

    final response = await http.post(
      uri,
      headers: combinedHeaders,
      body: jsonEncode(body),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return jsonDecode(response.body);
    } else if (response.statusCode == 204) {
      return <String, dynamic>{};
    } else {
      throw Exception('Error POST $endpoint: ${response.statusCode}');
    }
  }

  Future<dynamic> get(String endpoint, {Map<String, String>? headers}) async {
    final uri = Uri.parse('$baseUrl/$endpoint');
    final defaultHeaders = {'Content-Type': 'application/json'};
    final combinedHeaders = {
      ...defaultHeaders,
      if (headers != null) ...headers,
    };

    final response = await http.get(uri, headers: combinedHeaders);

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else if (response.statusCode == 204) {
      return <String, dynamic>{};
    } else {
      throw Exception('Error GET $endpoint: ${response.statusCode}');
    }
  }

  Future<dynamic> postMultipart({
    required String endpoint,
    required Map<String, String> fields,
    required List<http.MultipartFile> files,
    Map<String, String>? headers,
  }) async {
    final uri = Uri.parse('$baseUrl/$endpoint');
    final request = http.MultipartRequest('POST', uri);
    if (headers != null) {
      request.headers.addAll(headers);
    }
    request.fields.addAll(fields);
    request.files.addAll(files);
    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);
    if (response.statusCode == 200 || response.statusCode == 201) {
      return jsonDecode(response.body);
    } else if (response.statusCode == 204) {
      return <String, dynamic>{};
    } else {
      throw Exception(
        'Error POST Multipart $endpoint: ${response.statusCode} ${response.body}',
      );
    }
  }

  Future<Uint8List> downloadFileBytes(
    String endpoint, {
    Map<String, String>? headers,
    Map<String, dynamic>? queryParams,
  }) async {
    final uri = Uri.parse('$baseUrl/$endpoint').replace(
      queryParameters: queryParams?.map((k, v) => MapEntry(k, v.toString())),
    );

    final response = await http.get(uri, headers: headers);

    if (response.statusCode == 200) {
      return response.bodyBytes;
    } else {
      throw Exception(
        'Error al descargar archivo ($endpoint): ${response.statusCode} ${response.reasonPhrase}',
      );
    }
  }

  Future<dynamic> postForm(
    String endpoint,
    Map<String, String> body, {
    Map<String, String>? headers,
  }) async {
    final uri = Uri.parse('$baseUrlForm/$endpoint');
    final defaultHeaders = {
      'Content-Type': 'application/x-www-form-urlencoded',
    };
    final combinedHeaders = {
      ...defaultHeaders,
      if (headers != null) ...headers,
    };
    final response = await http.post(uri, headers: combinedHeaders, body: body);
    if (response.statusCode == 200 || response.statusCode == 201) {
      String body = response.body;
      body = body.replaceAll("fun»", "");
      return jsonDecode(body);
    } else if (response.statusCode == 204) {
      return <String, dynamic>{};
    } else {
      throw Exception('Error POST FORM $endpoint: ${response.statusCode}');
    }
  }

  Future<dynamic> putForm(
    String endpoint,
    Map<String, String> body, {
    Map<String, String>? headers,
  }) async {
    final uri = Uri.parse('$baseUrlForm/$endpoint');
    final defaultHeaders = {
      'Content-Type': 'application/x-www-form-urlencoded',
    };
    final combinedHeaders = {
      ...defaultHeaders,
      if (headers != null) ...headers,
    };
    final response = await http.put(uri, headers: combinedHeaders, body: body);
    if (response.statusCode == 200 || response.statusCode == 201) {
      String body = response.body;
      body = body.replaceAll("fun»", "");
      return jsonDecode(body);
    } else if (response.statusCode == 204) {
      return <String, dynamic>{};
    } else {
      throw Exception('Error PUT FORM $endpoint: ${response.statusCode}');
    }
  }

  Future<dynamic> deleteForm(
    String endpoint,
    Map<String, String> body, {
    Map<String, String>? headers,
  }) async {
    final uri = Uri.parse('$baseUrlForm/$endpoint');
    final defaultHeaders = {
      'Content-Type': 'application/x-www-form-urlencoded',
    };
    final combinedHeaders = {
      ...defaultHeaders,
      if (headers != null) ...headers,
    };

    final request = http.Request("DELETE", uri)
      ..headers.addAll(combinedHeaders)
      ..bodyFields = body;

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode == 200 || response.statusCode == 201) {
      String body = response.body;
      body = body.replaceAll("fun»", "");
      return jsonDecode(body);
    } else if (response.statusCode == 204) {
      return <String, dynamic>{};
    } else {
      throw Exception('Error DELETE FORM $endpoint: ${response.statusCode}');
    }
  }

  Future<Uint8List> postBytes({
    required String endpoint,
    required Map<String, dynamic> body,
    Map<String, String>? headers,
  }) async {
    final uri = Uri.parse('$baseUrl/$endpoint');
    final defaultHeaders = {'Content-Type': 'application/json'};
    final combinedHeaders = {
      ...defaultHeaders,
      if (headers != null) ...headers,
    };

    final response = await http.post(
      uri,
      headers: combinedHeaders,
      body: jsonEncode(body),
    );

    if (response.statusCode == 200) {
      return response.bodyBytes; // devuelve directamente los bytes
    } else {
      throw Exception(
        'Error POST Bytes $endpoint: ${response.statusCode} ${response.reasonPhrase}',
      );
    }
  }
}
