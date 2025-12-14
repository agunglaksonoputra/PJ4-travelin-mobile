import '../config/api_config.dart';
import 'api_services.dart';

class ProfitShareService {
  // Tentukan API version khusus profit share
  static final String _baseUrl =
  ApiConfig.baseUrl(ApiVersion.v1);

  /// Get all profit share data
  static Future<List<dynamic>> getAll() async {
    try {
      final response = await ApiServices.get(
        _baseUrl,
        "profitShare",
      );

      final data = response["data"];

      if (data is List) {
        return data;
      }

      if (data is Map) {
        return [data]; // normalisasi ke list
      }

      throw Exception("Invalid profit share data format");
    } catch (e) {
      throw Exception("Failed to fetch profit share data: $e");
    }
  }
}
