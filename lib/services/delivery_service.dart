import 'dart:convert';
import '../network/http_client.dart';

class DeliveryService {
  static Future<List<dynamic>> getDelivery({
    int page = 1,
    int size = 100,
  }) async {
    try {
      final response = await httpClient.get(
        'delivery/token?page=$page&size=$size',
      );

      final body = jsonDecode(response.body);

      if (!body['isSuccess']) {
        throw Exception(
          body['message'] ?? 'Không thể lấy danh sách đơn giao hàng',
        );
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

  static Future<Map<String, dynamic>> getDeliveryDetail({
    required String deliveryId,
  }) async {
    try {
      final response = await httpClient.get(
        'delivery/delivery-detail?DeliveryID=$deliveryId',
      );

      final body = jsonDecode(response.body);
      print('Full API response: $body');

      if (!body['isSuccess']) {
        throw Exception(
          body['message'] ?? 'Không thể lấy chi tiết đơn giao hàng',
        );
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
