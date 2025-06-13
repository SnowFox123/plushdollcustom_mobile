import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import '../config/http_client.dart';

class AuthService {
  static Future<Map<String, dynamic>> login(
    String username,
    String password,
  ) async {
    try {
      final response = await httpClient.post(
        'auth/sign-in',
        data: {'username': username, 'password': password},
      );

      final body = jsonDecode(response.body);

      // Handle the new response structure
      final jwtToken = body['responseRequestModel']?['jwtToken'];
      if (jwtToken == null) {
        throw Exception('Token không hợp lệ');
      }

      final accessToken = jwtToken['accessToken'];
      final refreshToken = jwtToken['refreshToken'];

      if (accessToken == null) {
        throw Exception('Access token không hợp lệ');
      }

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('token', accessToken);
      if (refreshToken != null) {
        await prefs.setString('refreshToken', refreshToken);
      }

      final userInfo = JwtDecoder.decode(accessToken);
      return {
        'token': accessToken,
        'refreshToken': refreshToken,
        'userInfo': userInfo,
      };
    } catch (e) {
      rethrow;
    }
  }
}
