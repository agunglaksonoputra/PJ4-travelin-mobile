import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

enum ApiVersion { v1, v2 }

class ApiConfig {
  static String get _baseHost {
    return kReleaseMode
        ? (dotenv.env['API_PROD_URL'] ?? '')
        : (dotenv.env['API_DEV_URL'] ?? '');
  }

  static String baseUrl(ApiVersion version) {
    if (_baseHost.isEmpty) {
      throw Exception('API_BASE_URL is not defined in .env');
    }

    switch (version) {
      case ApiVersion.v1:
        return '$_baseHost/api/v1';
      case ApiVersion.v2:
        return '$_baseHost/api/v2';
    }
  }
}
