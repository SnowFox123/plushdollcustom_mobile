import 'dart:convert';
import '../config/http_client.dart';

class PostService {
  static Future<Map<String, dynamic>> getPost({
    int page = 1,
    int size = 100,
  }) async {
    try {
      final response = await httpClient.get(
        'project-post?page=$page&size=$size',
      );

      final body = jsonDecode(response.body);

      if (!body['isSuccess']) {
        throw Exception(body['message'] ?? 'Failed to get posts');
      }

      final responseList = body['responseRequestModel']?['responseList'];
      if (responseList == null) {
        throw Exception('Invalid response format');
      }

      return responseList;
    } catch (e) {
      rethrow;
    }
  }

  static Future<Map<String, dynamic>> getPostDetail({
    required String projectPostId,
  }) async {
    try {
      final response = await httpClient.get(
        'project-post/detail?ProjectPostId=$projectPostId',
      );

      final body = jsonDecode(response.body);
      print('Full API response: $body');

      if (!body['isSuccess']) {
        throw Exception(body['message'] ?? 'Failed to get post detail');
      }

      final responseData = body['responseRequestModel'];
      if (responseData == null) {
        throw Exception('Invalid response format');
      }

      return responseData;
    } catch (e) {
      rethrow;
    }
  }
}
