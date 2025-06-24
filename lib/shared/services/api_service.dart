import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiClient {
  static const String _baseUrl = 'http://192.168.0.117:8080/api';

  static Uri _buildUri(String endpoint) {
    return Uri.parse('$_baseUrl$endpoint');
  }

  static Future<http.Response> get(String endpoint, {Map<String, String>? headers}) async {
    final uri = _buildUri(endpoint);
    return await http.get(uri, headers: headers);
  }

  static Future<http.Response> post(String endpoint, {Map<String, String>? headers, Object? body}) async {
    final uri = _buildUri(endpoint);
    return await http.post(uri, headers: _withJsonHeader(headers), body: jsonEncode(body));
  }

  static Future<http.Response> put(String endpoint, {Map<String, String>? headers, Object? body}) async {
    final uri = _buildUri(endpoint);
    return await http.put(uri, headers: _withJsonHeader(headers), body: jsonEncode(body));
  }

  static Future<http.Response> delete(String endpoint, {Map<String, String>? headers}) async {
    final uri = _buildUri(endpoint);
    return await http.delete(uri, headers: headers);
  }

  static Map<String, String> _withJsonHeader(Map<String, String>? headers) {
    return {
      'Content-Type': 'application/json',
      ...?headers,
    };
  }
}
