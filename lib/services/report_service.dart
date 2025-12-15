import '../config/api_config.dart';
import 'api_services.dart';

class ReportService {
  static final String _baseUrl = ApiConfig.baseUrl(ApiVersion.v1);

  /// Create transaction report
  static Future<dynamic> createReport(Map<String, dynamic> payload) async {
    try {
      return await ApiServices.post(
        _baseUrl,
        "transactions/reports",
        payload,
      );
    } catch (e) {
      throw Exception("Failed to create report: $e");
    }
  }
}