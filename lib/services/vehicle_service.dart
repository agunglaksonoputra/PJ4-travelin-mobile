import '../config/api_config.dart';
import 'api_services.dart';
import '../utils/app_logger.dart';

class VehicleService {
  static final String _baseUrl =
  ApiConfig.baseUrl(ApiVersion.v1);

  static Future<List<dynamic>> getVehicles() async {
    AppLogger.i("Fetching vehicles list");

    try {
      final response = await ApiServices.get(
        _baseUrl,
        "vehicles",
      );

      AppLogger.d("Vehicle API response: $response");

      final data = response["data"];

      if (data is List) {
        AppLogger.i("Vehicles fetched successfully (count: ${data.length})");
        return data;
      }

      if (data is Map) {
        AppLogger.w("Vehicle API returned object, normalizing to list");
        return [data];
      }

      AppLogger.e(
        "Invalid vehicle data format",
        error: data,
        stackTrace: StackTrace.current,
      );

      throw Exception("Invalid vehicle data format");
    } catch (e, stackTrace) {
      AppLogger.e(
        "Failed to fetch vehicles",
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }
}
