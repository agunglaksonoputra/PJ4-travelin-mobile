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

  static Future<VehicleModel> createVehicle(
      Map<String, dynamic> payload,
      ) async {
    AppLogger.i('Creating new vehicle');
    AppLogger.d('Create vehicle payload: $payload');

    try {
      final response = await ApiServices.post(
        _baseUrl,
        'vehicles',
        payload,
      );

      AppLogger.d('Create vehicle response: $response');

      final data = response['data'];

      if (data is! Map<String, dynamic>) {
        throw Exception('Invalid vehicle response format');
      }

      final vehicle = VehicleModel.fromJson(data);

      AppLogger.i('Vehicle created successfully (id: ${vehicle.id})');
      return vehicle;
    } catch (e, stackTrace) {
      AppLogger.e(
        'Failed to create vehicle',
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  // DELETE vehicle by ID
  static Future<void> deleteVehicle(int vehicleId) async {
    AppLogger.i("Deleting vehicle with id: $vehicleId");

    try {
      await ApiServices.delete(
        _baseUrl,
        "vehicles/$vehicleId",
      );

      AppLogger.i("Vehicle deleted successfully (id: $vehicleId)");
    } catch (e, stackTrace) {
      AppLogger.e(
        "Failed to delete vehicle (id: $vehicleId)",
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  static Future<VehicleModel> updateVehicle(
      int vehicleId,
      Map<String, dynamic> payload,
      ) async {
    AppLogger.i("Updating vehicle with id: $vehicleId");
    AppLogger.d("Update vehicle payload: $payload");

    try {
      final response = await ApiServices.put(
        _baseUrl,
        "vehicles/$vehicleId",
        payload,
      );

      AppLogger.d("Update vehicle response: $response");

      final data = response['data'];

      if (data is! Map<String, dynamic>) {
        throw Exception('Invalid vehicle response format');
      }

      final vehicle = VehicleModel.fromJson(data);

      AppLogger.i("Vehicle updated successfully (id: ${vehicle.id})");
      return vehicle;
    } catch (e, stackTrace) {
      AppLogger.e(
        "Failed to update vehicle (id: $vehicleId)",
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

}


