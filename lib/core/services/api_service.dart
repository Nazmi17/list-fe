import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:monlist_frontend/core/models/api_error.dart';
import '../constants/api_constants.dart';

class ApiService {
  final String baseUrl;
  String? _token;

  ApiService({this.baseUrl = ApiConstants.baseUrl});

  void setToken(String? token) {
    _token = token;
  }

  Map<String, String> _getHeaders({bool includeAuth = true}) {
    final headers = {'Content-Type': ApiConstants.contentType};

    if (includeAuth && _token != null) {
      headers[ApiConstants.authorization] = '${ApiConstants.bearer} $_token';
    }

    return headers;
  }

  dynamic _handleResponse(http.Response response) {
    print('Response Status: ${response.statusCode}');
    print('Response Body: ${response.body}');

    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (response.body.isEmpty) return null;
      try {
        return json.decode(response.body);
      } catch (e) {
        throw Exception('Success but invalid JSON: ${response.body}');
      }
    } else {
      try {
        final errorBody = json.decode(response.body);
        throw ApiError.fromJson(errorBody);
      } catch (e) {
        if (e is ApiError) rethrow;

        throw Exception(
          'Server Error (${response.statusCode}): ${response.body}',
        );
      }
    }
  }

  // GET request
  Future<dynamic> get(
    String endpoint, {
    Map<String, String>? queryParams,
    bool includeAuth = true,
  }) async {
    try {
      var uri = Uri.parse('$baseUrl$endpoint');
      if (queryParams != null && queryParams.isNotEmpty) {
        uri = uri.replace(queryParameters: queryParams);
      }

      print('GET Request to: $uri');


      final response = await http.get(
        uri,
        headers: _getHeaders(includeAuth: includeAuth),
      );

      return _handleResponse(response);
    } catch (e) {
      rethrow;
    }
  }

  // POST request
  Future<dynamic> post(
    String endpoint, {
    Map<String, dynamic>? body,
    bool includeAuth = true,
  }) async {
    try {
      final uri = Uri.parse('$baseUrl$endpoint');

      print('POST Request to: $uri');
      if (body != null) print('Request Body: $body');

      final response = await http.post(
        uri,
        headers: _getHeaders(includeAuth: includeAuth),
        body: body != null ? json.encode(body) : null,
      );

      return _handleResponse(response);
    } catch (e) {
      rethrow;
    }
  }

  // PUT request
  Future<dynamic> put(
    String endpoint, {
    Map<String, dynamic>? body,
    bool includeAuth = true,
  }) async {
    try {
      final uri = Uri.parse('$baseUrl$endpoint');

      print('PUT Request to: $uri');

      final response = await http.put(
        uri,
        headers: _getHeaders(includeAuth: includeAuth),
        body: body != null ? json.encode(body) : null,
      );

      return _handleResponse(response);
    } catch (e) {
      rethrow;
    }
  }

  // PATCH request
  Future<dynamic> patch(
    String endpoint, {
    Map<String, dynamic>? body,
    bool includeAuth = true,
  }) async {
    try {
      final uri = Uri.parse('$baseUrl$endpoint');

      print('PATCH Request to: $uri');

      final response = await http.patch(
        uri,
        headers: _getHeaders(includeAuth: includeAuth),
        body: body != null ? json.encode(body) : null,
      );

      return _handleResponse(response);
    } catch (e) {
      rethrow;
    }
  }

  // DELETE request
  Future<dynamic> delete(String endpoint, {bool includeAuth = true}) async {
    try {
      final uri = Uri.parse('$baseUrl$endpoint');

      print('DELETE Request to: $uri');

      final response = await http.delete(
        uri,
        headers: _getHeaders(includeAuth: includeAuth),
      );

      return _handleResponse(response);
    } catch (e) {
      rethrow;
    }
  }
}
