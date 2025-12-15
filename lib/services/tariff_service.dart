import '../config/api_config.dart';
import '../models/tariff_model.dart';
import '../utils/app_logger.dart';
import 'api_services.dart';

class TariffService {
  TariffService._();

  static final String _baseUrl = ApiConfig.baseUrl(ApiVersion.v1);

  static Future<List<TariffModel>> getTariffs() async {
    AppLogger.i('Fetching tariffs list');

    try {
      final response = await ApiServices.get(_baseUrl, 'tariffs');

      AppLogger.d('Tariff API response: $response');

      final raw = _extractData(response);
      final items = _normalizeTariffPayload(raw);

      final tariffs =
          items
              .whereType<Map<String, dynamic>>()
              .map(TariffModel.fromJson)
              .toList();

      AppLogger.i('Tariffs fetched successfully (count: ${tariffs.length})');
      return tariffs;
    } catch (e, stackTrace) {
      AppLogger.e('Failed to fetch tariffs', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  static dynamic _extractData(dynamic response) {
    if (response is Map<String, dynamic>) {
      return response['data'];
    }

    AppLogger.w('Tariff API returned non-map payload, using raw response');
    return response;
  }

  static List<dynamic> _normalizeTariffPayload(dynamic data) {
    if (data is List) {
      return data;
    }

    if (data is Map) {
      AppLogger.w('Tariff API returned object, normalizing to list');
      return [data];
    }

    AppLogger.e(
      'Invalid tariff data format',
      error: data,
      stackTrace: StackTrace.current,
    );
    throw Exception('Invalid tariff data format');
  }
}
