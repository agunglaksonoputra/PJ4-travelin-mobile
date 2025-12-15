import '../config/api_config.dart';
import '../models/vehicle_models.dart';
import '../utils/app_logger.dart';
import 'api_services.dart';

class VehicleService {
  VehicleService._();

  static final String _baseUrl = ApiConfig.baseUrl(ApiVersion.v1);

  static Future<List<VehicleModel>> getVehicles() async {
    AppLogger.i('Fetching vehicles list');

    try {
      final response = await ApiServices.get(_baseUrl, 'vehicles');

      AppLogger.d('Vehicle API response: $response');

      final raw = response['data'];

      final items = _normalizeVehiclePayload(raw);
      final vehicles =
          items
              .whereType<Map<String, dynamic>>()
              .map(VehicleModel.fromJson)
              .toList();

      AppLogger.i('Vehicles fetched successfully (count: ${vehicles.length})');
      return vehicles;
    } catch (e, stackTrace) {
      AppLogger.e('Failed to fetch vehicles', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  static List<dynamic> _normalizeVehiclePayload(dynamic data) {
    if (data is List) {
      return data;
    }

    if (data is Map) {
      AppLogger.w('Vehicle API returned object, normalizing to list');
      return [data];
    }

    AppLogger.e(
      'Invalid vehicle data format',
      error: data,
      stackTrace: StackTrace.current,
    );

    throw Exception('Invalid vehicle data format');
  }
}
