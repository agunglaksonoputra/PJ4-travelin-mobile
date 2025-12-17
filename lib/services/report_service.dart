import '../config/api_config.dart';
import 'api_services.dart';
import '../utils/app_logger.dart';

class ReportService {
  static final String _baseUrl = ApiConfig.baseUrl(ApiVersion.v1);

  /// Create transaction report
  static Future<dynamic> createReport(Map<String, dynamic> payload) async {
    try {
      AppLogger.i('Creating transaction report with payload $payload');
      return await ApiServices.post(_baseUrl, "transactions/reports", payload);
    } catch (e, stackTrace) {
      AppLogger.e('Failed to create report', error: e, stackTrace: stackTrace);
      throw Exception("Failed to create report: $e");
    }
  }

  /// Get total operational cost overall
  static Future<double> getTotalOperationalCost() async {
    try {
      AppLogger.i('Fetching total operational cost (overall)');
      final response = await ApiServices.get(
        _baseUrl,
        "transactions/reports/total/overall",
      );
      AppLogger.d('Total operational cost response: $response');

      if (response['success'] == true && response['data'] != null) {
        return (response['data']['total_operational_cost'] as num).toDouble();
      }
      throw Exception("Invalid response format");
    } catch (e, stackTrace) {
      AppLogger.e(
        'Failed to fetch total operational cost',
        error: e,
        stackTrace: stackTrace,
      );
      throw Exception("Failed to fetch total operational cost: $e");
    }
  }
}
