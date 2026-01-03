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

  /// Fetch reporting transactions
  static Future<List<dynamic>> fetchReportingTransactions({
    int? vehicleId,
  }) async {
    try {
      AppLogger.i('Fetching reporting transactions for vehicle: $vehicleId');

      String endpoint = "transactions/reporting";
      if (vehicleId != null) {
        endpoint += "?vehicle_id=$vehicleId";
      }

      final response = await ApiServices.get(_baseUrl, endpoint);
      AppLogger.d('Reporting transactions response: $response');

      if (response is Map && response['success'] == true) {
        final data = response['data'];
        if (data is List) return data;
      }

      throw Exception('Invalid response format');
    } catch (e, stackTrace) {
      AppLogger.e(
        'Failed to fetch reporting transactions',
        error: e,
        stackTrace: stackTrace,
      );
      throw Exception('Failed to fetch reporting transactions: $e');
    }
  }

  /// Fetch closed transactions
  static Future<List<dynamic>> fetchClosedTransactions({int? limit}) async {
    try {
      AppLogger.i('Fetching closed transactions');

      String endpoint = "transactions/by-status/closed";
      if (limit != null && limit > 0) {
        endpoint += "?limit=$limit";
      }

      final response = await ApiServices.get(_baseUrl, endpoint);
      AppLogger.d('Closed transactions response: $response');

      if (response is Map && response['success'] == true) {
        final data = response['data'];
        if (data is List) return data;
      }

      throw Exception('Invalid response format');
    } catch (e, stackTrace) {
      AppLogger.e(
        'Failed to fetch closed transactions',
        error: e,
        stackTrace: stackTrace,
      );
      throw Exception('Failed to fetch closed transactions: $e');
    }
  }
}
