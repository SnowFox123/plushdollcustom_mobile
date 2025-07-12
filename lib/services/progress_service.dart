import 'dart:convert';
import '../network/http_client.dart';

class ProgressService {
  static Future<List<dynamic>> getProgressDetail({
    required String orderID,
    required String offerPhaseID,
  }) async {
    try {
      final response = await httpClient.get(
        'progress/?orderID=$orderID&offerPhaseID=$offerPhaseID',
      );

      final body = jsonDecode(response.body);

      if (!body['isSuccess']) {
        throw Exception(body['message'] ?? 'Failed to get posts');
      }

      final responseList = body['responseRequestModel']?['responseList'];
      if (responseList is List) {
        return responseList;
      } else {
        return [];
      }
    } catch (e) {
      rethrow;
    }
  }

  // static Future<Map<String, dynamic>> getProgressDetail({
  //   required String progressId,
  // }) async {
  //   try {
  //     final response = await httpClient.get(
  //       'progress/detail?progressID=$progressId',
  //     );

  //     final body = jsonDecode(response.body);
  //     print('Full API response: $body');

  //     if (!body['isSuccess']) {
  //       throw Exception(body['message'] ?? 'Failed to get post detail');
  //     }

  //     final responseData = body['responseRequestModel'];
  //     if (responseData == null) {
  //       throw Exception('Invalid response format');
  //     }

  //     return responseData;
  //   } catch (e) {
  //     rethrow;
  //   }
  // }
}
