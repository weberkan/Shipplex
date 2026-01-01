import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';

class ApiService {
  static String? _token;

  static void setToken(String? token) {
    _token = token;
  }

  static Map<String, String> get _headers {
    final headers = {'Content-Type': 'application/json'};
    if (_token != null) {
      headers['Authorization'] = 'Bearer $_token';
    }
    return headers;
  }

  static Future<Map<String, dynamic>> get(String endpoint) async {
    final response = await http
        .get(
          Uri.parse('${ApiConfig.baseUrl}$endpoint'),
          headers: _headers,
        )
        .timeout(ApiConfig.timeout);

    return _handleResponse(response);
  }

  static Future<Map<String, dynamic>> post(
    String endpoint,
    Map<String, dynamic> body,
  ) async {
    final response = await http
        .post(
          Uri.parse('${ApiConfig.baseUrl}$endpoint'),
          headers: _headers,
          body: jsonEncode(body),
        )
        .timeout(ApiConfig.timeout);

    return _handleResponse(response);
  }

  static Future<Map<String, dynamic>> put(
    String endpoint,
    Map<String, dynamic> body,
  ) async {
    final response = await http
        .put(
          Uri.parse('${ApiConfig.baseUrl}$endpoint'),
          headers: _headers,
          body: jsonEncode(body),
        )
        .timeout(ApiConfig.timeout);

    return _handleResponse(response);
  }

  static Future<Map<String, dynamic>> delete(String endpoint) async {
    final response = await http
        .delete(
          Uri.parse('${ApiConfig.baseUrl}$endpoint'),
          headers: _headers,
        )
        .timeout(ApiConfig.timeout);

    return _handleResponse(response);
  }

  static Map<String, dynamic> _handleResponse(http.Response response) {
    final body = jsonDecode(response.body);
    
    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (body is List) {
        return {'data': body};
      }
      return body;
    } else {
      throw ApiException(
        body['error'] ?? 'Bir hata oluştu',
        response.statusCode,
      );
    }
  }
}

class ApiException implements Exception {
  final String message;
  final int statusCode;

  ApiException(this.message, this.statusCode);

  @override
  String toString() => message;
}
