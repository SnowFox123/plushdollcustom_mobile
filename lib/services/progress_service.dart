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

  static Future<Map<String, dynamic>> postProgressReview({
    required String progressStepID,
    required int qualityScore,
    required bool isDesignAccurate,
    required bool isMaterialCorrect,
    required bool isColorCorrect,
    required bool isFunctionalityMet,
    required String customerComment,
  }) async {
    try {
      final response = await httpClient.post(
        'progress/review',
        data: {
          'progressStepID': progressStepID,
          'qualityScore': qualityScore,
          'isDesignAccurate': isDesignAccurate,
          'isMaterialCorrect': isMaterialCorrect,
          'isColorCorrect': isColorCorrect,
          'isFunctionalityMet': isFunctionalityMet,
          'customerComment': customerComment,
        },
      );

      final body = jsonDecode(response.body);

      if (!body['isSuccess']) {
        throw Exception(body['message'] ?? 'Failed to get posts');
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

  static Future<List<dynamic>> getReviewDetail({
    required String progressStepID,
  }) async {
    try {
      final response = await httpClient.get(
        'progress/review-detail?progressStepID=$progressStepID',
      );

      final body = jsonDecode(response.body);

      if (!body['isSuccess']) {
        throw Exception(body['message'] ?? 'Failed to get review detail');
      }

      // The API returns the review data directly in responseRequestModel
      final responseData = body['responseRequestModel'];
      if (responseData != null) {
        // Return as a list with single item to maintain compatibility
        return [responseData];
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
