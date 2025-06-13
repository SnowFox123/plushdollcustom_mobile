import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiConstants {
  static String get baseUrl {
    if (kIsWeb) {
      return 'https://pdcbackendapi.tlog.website/api/v1';
    } else {
      return dotenv.env['API_BASE_URL'] ??
          'https://pdcbackendapi.tlog.website/api/v1';
    }
  }
}
