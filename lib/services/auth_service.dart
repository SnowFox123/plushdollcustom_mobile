import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import '../network/http_client.dart';
import '../constants/role_constants.dart';
import '../exceptions/auth_exceptions.dart';

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
        throw AuthenticationException('Token không hợp lệ');
      }

      final accessToken = jwtToken['accessToken'];
      final refreshToken = jwtToken['refreshToken'];

      if (accessToken == null) {
        throw AuthenticationException('Access token không hợp lệ');
      }

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('token', accessToken);
      if (refreshToken != null) {
        await prefs.setString('refreshToken', refreshToken);
      }

      // Ensure HTTP client uses the latest access token immediately after login
      httpClient.setAuthToken(accessToken);

      Map<String, dynamic> userInfo;
      try {
        userInfo = JwtDecoder.decode(accessToken);
      } catch (e) {
        throw AuthenticationException(
          'Không thể giải mã thông tin người dùng từ token',
        );
      }

      // Debug: Print user info to understand the structure
      print('UserInfo from JWT: $userInfo');

      // Check if user has customer role - try multiple possible field names
      // Based on the JWT structure, role is in the Microsoft claims field
      final userRole =
          userInfo['http://schemas.microsoft.com/ws/2008/06/identity/claims/role'] ??
          userInfo['role'] ??
          userInfo['roleDisplay'] ??
          userInfo['userRole'] ??
          userInfo['authorities']?.first;

      print('Extracted role: $userRole');

      // If role is null, treat as non-customer
      if (userRole == null) {
        throw RoleAccessDeniedException(
          'Unknown',
          'Tài khoản không có thông tin vai trò. Ứng dụng di động chỉ hỗ trợ cho khách hàng.',
        );
      }

      if (!RoleConstants.isCustomer(userRole)) {
        throw RoleAccessDeniedException(
          userRole,
          RoleConstants.getAccessDeniedMessage(userRole),
        );
      }
      
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
