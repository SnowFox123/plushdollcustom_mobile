import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/api_constants.dart';

class HttpClient {
  static final HttpClient _instance = HttpClient._internal();
  factory HttpClient() => _instance;
  HttpClient._internal();

  late http.Client _client;
  final Map<String, String> _defaultHeaders = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  // Initialize client
  void init() {
    _client = http.Client();
  }

  // Set default headers
  void setDefaultHeaders(Map<String, String> headers) {
    _defaultHeaders.addAll(headers);
  }

  // Add authorization header
  void setAuthToken(String token) {
    _defaultHeaders['Authorization'] = 'Bearer $token';
  }

  // Remove authorization header
  void removeAuthToken() {
    _defaultHeaders.remove('Authorization');
  }

  // Get headers with optional additional headers
  Map<String, String> _getHeaders([Map<String, String>? additionalHeaders]) {
    final headers = Map<String, String>.from(_defaultHeaders);
    if (additionalHeaders != null) {
      headers.addAll(additionalHeaders);
    }
    return headers;
  }

  // GET request
  Future<http.Response> get(
    String endpoint, {
    Map<String, String>? headers,
  }) async {
    final url = Uri.parse('${ApiConstants.baseUrl}$endpoint');
    final requestHeaders = _getHeaders(headers);

    print('GET Request URL: $url');
    print('GET Request Headers: $requestHeaders');

    try {
      final response = await _client.get(url, headers: requestHeaders);
      _handleResponse(response);
      return response;
    } catch (e) {
      print('GET Request Error: $e');
      rethrow;
    }
  }

  // POST request
  Future<http.Response> post(
    String endpoint, {
    Map<String, dynamic>? data,
    Map<String, String>? headers,
  }) async {
    final url = Uri.parse('${ApiConstants.baseUrl}$endpoint');
    final requestHeaders = _getHeaders(headers);

    print('POST Request URL: $url');
    print('POST Request Headers: $requestHeaders');
    print('POST Request Body: $data');

    try {
      final response = await _client.post(
        url,
        headers: requestHeaders,
        body: data != null ? jsonEncode(data) : null,
      );
      _handleResponse(response);
      return response;
    } catch (e) {
      print('POST Request Error: $e');
      rethrow;
    }
  }

  // PUT request
  Future<http.Response> put(
    String endpoint, {
    Map<String, dynamic>? data,
    Map<String, String>? headers,
  }) async {
    final url = Uri.parse('${ApiConstants.baseUrl}$endpoint');
    final requestHeaders = _getHeaders(headers);

    try {
      final response = await _client.put(
        url,
        headers: requestHeaders,
        body: data != null ? jsonEncode(data) : null,
      );
      _handleResponse(response);
      return response;
    } catch (e) {
      print('PUT Request Error: $e');
      rethrow;
    }
  }

  // DELETE request
  Future<http.Response> delete(
    String endpoint, {
    Map<String, String>? headers,
  }) async {
    final url = Uri.parse('${ApiConstants.baseUrl}$endpoint');
    final requestHeaders = _getHeaders(headers);

    try {
      final response = await _client.delete(url, headers: requestHeaders);
      _handleResponse(response);
      return response;
    } catch (e) {
      print('DELETE Request Error: $e');
      rethrow;
    }
  }

  // Handle response
  void _handleResponse(http.Response response) {
    print('Response Status: ${response.statusCode}');
    print('Response Body: ${response.body}');

    if (response.statusCode >= 400) {
      String errorMessage = 'Đã xảy ra lỗi. Vui lòng thử lại.';

      try {
        final errorData = jsonDecode(response.body);

        if (errorData['errors'] != null) {
          final errors = errorData['errors'] as Map<String, dynamic>;
          for (var entry in errors.entries) {
            final fieldName = entry.key;
            final fieldErrors = entry.value;
            if (fieldErrors is List && fieldErrors.isNotEmpty) {
              final errorText = fieldErrors.first;
              errorMessage = '$fieldName: $errorText';
              break;
            }
          }
        }
        // Ưu tiên lấy message nếu có
        else if (errorData['message'] != null &&
            errorData['message'].toString().isNotEmpty) {
          errorMessage = errorData['message'];
        } else if (errorData['title'] != null) {
          errorMessage = errorData['title'] as String;
        }
      } catch (e) {
        print('Error parsing error response: $e');
      }

      throw errorMessage;
    }
  }

  // Dispose client
  void dispose() {
    _client.close();
  }
}

// Global instance
final httpClient = HttpClient();
