import 'dart:convert';
import '../network/http_client.dart';

class UserService {
  static Future<Map<String, dynamic>> getUserProfile() async {
    try {
      final response = await httpClient.get('auth/profile');

      final body = jsonDecode(response.body);

      if (!body['isSuccess']) {
        throw Exception(body['message'] ?? 'Failed to get user profile');
      }

      final responseRequestModel = body['responseRequestModel'];
      if (responseRequestModel == null) {
        throw Exception('Invalid response format');
      }

      return responseRequestModel;
    } catch (e) {
      rethrow;
    }
  }

  static Future<Map<String, dynamic>> getUserReputation() async {
    try {
      final response = await httpClient.get('reputation');

      final body = jsonDecode(response.body);

      if (!body['isSuccess']) {
        throw Exception(body['message'] ?? 'Failed to get user reputation');
      }

      final responseRequestModel = body['responseRequestModel'];
      if (responseRequestModel == null) {
        throw Exception('Invalid response format');
      }

      return responseRequestModel;
    } catch (e) {
      rethrow;
    }
  }
}
