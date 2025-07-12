import 'dart:convert';
import '../network/http_client.dart';

class OrderService {
  static Future<List<dynamic>> getOrder({
    int page = 1,
    int size = 100,
  }) async {
    try {
      final response = await httpClient.get(
        'order/list/token?page=$page&size=$size',
      );

      final body = jsonDecode(response.body);

      if (!body['isSuccess']) {
        throw Exception(body['message'] ?? 'Failed to get posts');
      }

      final responseList = body['responseRequestModel']?['responseList'];
      if (responseList == null) {
        throw Exception('Invalid response format');
      }

      final items = responseList['items'] as List<dynamic>?;
      if (items == null) {
        throw Exception('Invalid response format - missing items');
      }

      return items;
    } catch (e) {
      rethrow;
    }
  }

  static Future<Map<String, dynamic>> getOrderDetail({
    required String orderId,
  }) async {
    try {
      final response = await httpClient.get(
        'order/detail?orderID=$orderId',
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
