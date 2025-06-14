import 'dart:convert';
import '../config/http_client.dart';

class OfferService {
  static Future<Map<String, dynamic>> getOffer({
    required String projectPostID,
    int page = 1,
    int size = 100,
  }) async {
    try {
      final response = await httpClient.get(
        'offer/all-offer-in-post?projectPostID=$projectPostID&page=$page&size=$size',
      );

      final body = jsonDecode(response.body);

      if (!body['isSuccess']) {
        throw Exception(body['message'] ?? 'Failed to get offers');
      }

      // Return the full response body so the caller can parse it properly
      return body;
    } catch (e) {
      rethrow;
    }
  }
}
