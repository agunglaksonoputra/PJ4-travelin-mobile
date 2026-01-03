import '../../config/api_config.dart';
import '../../models/owner/owner_model.dart';
import '../../utils/app_logger.dart';
import '../api_services.dart';

class OwnerService {
  static final String _baseUrl = ApiConfig.baseUrl(ApiVersion.v1);

  /// ===============================
  /// GET ALL OWNERS
  /// GET /owners
  /// ===============================
  static Future<List<OwnerModel>> getAllOwners() async {
    AppLogger.i("GET $_baseUrl/owners");

    try {
      final resp = await ApiServices.get(_baseUrl, "owners");

      final List list = resp['data'] is List ? resp['data'] : [];

      return list.map((e) => OwnerModel.fromJson(e)).toList();
    } catch (e, stack) {
      AppLogger.e(
        "Failed to fetch owners",
        error: e,
        stackTrace: stack,
      );
      throw Exception("Failed to fetch owners: $e");
    }
  }

  static Future<OwnerModel> updateOwner(
      int ownerId,
      Map<String, dynamic> payload,
      ) async {
    AppLogger.i("PUT $_baseUrl/owners/$ownerId");
    AppLogger.d("Update owner payload: $payload");

    try {
      final resp = await ApiServices.put(
        _baseUrl,
        "owners/$ownerId",
        payload,
      );

      final data = resp['data'];

      if (data is! Map<String, dynamic>) {
        throw Exception("Invalid owner response format");
      }

      return OwnerModel.fromJson(data);
    } catch (e, stack) {
      AppLogger.e(
        "Failed to update owner (id: $ownerId)",
        error: e,
        stackTrace: stack,
      );
      rethrow;
    }
  }

}
