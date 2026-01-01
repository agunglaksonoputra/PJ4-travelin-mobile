import '../../config/api_config.dart';
import '../../models/cashflow/monthly_transaction_detail_model.dart';
import '../../models/pagination_meta_model.dart';
import '../../utils/app_logger.dart';
import '../api_services.dart';

class MonthlyReportDetailService {
  static final String _baseUrl = ApiConfig.baseUrl(ApiVersion.v1);

  /// GET /monthly-report/cashflow/:year/:month
  static Future<({List<MonthlyTransactionDetail> data, PaginationMeta meta})>
  getMonthlyDetail({
    required String year,
    required String month,
    int page = 1,
    int limit = 10,
  }) async {
    final endpoint =
        "monthly-report/cashflow/$year/$month?page=$page&limit=$limit";

    AppLogger.i("GET $_baseUrl/$endpoint");

    try {
      final resp = await ApiServices.get(_baseUrl, endpoint);

      final data = (resp['data'] as List)
          .map((e) => MonthlyTransactionDetail.fromJson(e))
          .toList();

      final meta = PaginationMeta.fromJson(resp['meta']);

      return (data: data, meta: meta);
    } catch (e, stack) {
      AppLogger.e(
        "Failed to fetch monthly cashflow detail",
        error: e,
        stackTrace: stack,
      );
      throw Exception("Failed to fetch monthly cashflow detail: $e");
    }
  }
}
