import '../config/api_config.dart';
import 'api_services.dart';

class TravelService {
  // Define API version for Travel feature
  static final String _baseUrl =
  ApiConfig.baseUrl(ApiVersion.v1);

  /// Get all travels
  static Future<List<dynamic>> getAll() async {
    try {
      final response = await ApiServices.get(
        _baseUrl,
        "travel",
      );

      final data = response["data"];

      if (data is List) return data;
      if (data is Map) return [data];

      throw Exception("Invalid travel data format");
    } catch (e) {
      throw Exception("Failed to fetch travel list: $e");
    }
  }

  /// Get travel detail by ID
  static Future<dynamic> getDetail(int id) async {
    try {
      final response = await ApiServices.get(
        _baseUrl,
        "travel/$id",
      );

      return response["data"] ?? response;
    } catch (e) {
      throw Exception("Failed to fetch travel detail (id: $id): $e");
    }
  }
}
