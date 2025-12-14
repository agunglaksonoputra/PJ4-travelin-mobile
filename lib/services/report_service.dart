import '../config/api_config.dart';
import 'api_services.dart';

class ReportService {
  // Tentukan API version khusus report
  static final String _baseUrl =
  ApiConfig.baseUrl(ApiVersion.v1);

  /// Get report data
  static Future<dynamic> getReport() async {
    try {
      return await ApiServices.get(
        _baseUrl,
        "report",
      );
    } catch (e) {
      throw Exception("Failed to fetch report data: $e");
    }
  }
}
