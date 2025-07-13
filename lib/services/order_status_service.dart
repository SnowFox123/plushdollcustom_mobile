import 'dart:convert';
import '../network/http_client.dart';

class OrderStatusService {
  // Map status từ API sang tiếng Việt
  static const Map<String, String> statusMap = {
    'ReadyToPick': 'Sẵn sàng lấy hàng',
    'Picked': 'Đã lấy hàng',
    'Delivering': 'Đang giao hàng',
    'Delivered': 'Đã giao hàng',
    'Cancelled': 'Đã hủy',
    'Pending': 'Chờ xác nhận',
    'Confirmed': 'Đã xác nhận',
    'Processing': 'Đang xử lý',
    'Shipped': 'Đã gửi hàng',
    'Returned': 'Đã trả hàng',
    'Refunded': 'Đã hoàn tiền',
  };

  // Lấy thống kê số lượng order theo từng status
  static Future<Map<String, int>> getOrderStatusCount() async {
    try {
      final response = await httpClient.get('order/status-count/token');

      final body = jsonDecode(response.body);

      if (!body['isSuccess']) {
        throw Exception(body['message'] ?? 'Failed to get order status count');
      }

      final responseData = body['responseRequestModel'];
      if (responseData == null) {
        throw Exception('Invalid response format');
      }

      // Parse response data thành Map<String, int>
      Map<String, int> statusCount = {};

      if (responseData is Map<String, dynamic>) {
        responseData.forEach((key, value) {
          if (value is int) {
            statusCount[key] = value;
          }
        });
      }

      return statusCount;
    } catch (e) {
      rethrow;
    }
  }

  // Lấy danh sách order theo status
  static Future<List<dynamic>> getOrdersByStatus({
    required String status,
    int page = 1,
    int size = 100,
  }) async {
    try {
      final response = await httpClient.get(
        'order/list/token?status=$status&page=$page&size=$size',
      );

      final body = jsonDecode(response.body);

      if (!body['isSuccess']) {
        throw Exception(body['message'] ?? 'Failed to get orders by status');
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

  // Lấy tên tiếng Việt của status
  static String getStatusName(String status) {
    return statusMap[status] ?? status;
  }

  // Lấy tất cả status có sẵn
  static List<String> getAllStatuses() {
    return statusMap.keys.toList();
  }

  // Lấy tất cả tên status tiếng Việt
  static List<String> getAllStatusNames() {
    return statusMap.values.toList();
  }
}
