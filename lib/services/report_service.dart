import '../config/api_config.dart';
import 'api_services.dart';

class ReportService {
  static final String _baseUrl = ApiConfig.baseUrl(ApiVersion.v1);

  /// Create transaction report
  static Future<dynamic> createReport(Map<String, dynamic> payload) async {
    try {
      return await ApiServices.post(_baseUrl, "transactions/reports", payload);
    } catch (e) {
      throw Exception("Failed to create report: $e");
    }
  }

  /// Get total operational cost overall
  static Future<double> getTotalOperationalCost() async {
    try {
      final response = await ApiServices.get(
        _baseUrl,
        "transaction-reports/total/overall",
      );

      if (response['success'] == true && response['data'] != null) {
        return (response['data']['total_operational_cost'] as num).toDouble();
      }
      throw Exception("Invalid response format");
    } catch (e) {
      throw Exception("Failed to fetch total operational cost: $e");
    }
  }
}
