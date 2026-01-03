import '../../config/api_config.dart';
import '../../models/cashflow/cashflow_year_model.dart';
import '../../models/pagination_meta_model.dart';
import '../../utils/app_logger.dart';
import '../api_services.dart';

class MonthlyReportService {
  static final String _baseUrl = ApiConfig.baseUrl(ApiVersion.v1);

  /// GET /monthly-report/cashflow?page=&limit=&year=
  static Future<({List<CashFlowYear> data, PaginationMeta meta})>
  getCashflowSummary({
    int page = 1,
    int limit = 1,
    String? year,
  }) async {
    String endpoint = "monthly-report/cashflow?page=$page&limit=$limit";
    if (year != null) endpoint += "&year=$year";

    AppLogger.i("GET $_baseUrl/$endpoint");

    try {
      final resp = await ApiServices.get(_baseUrl, endpoint);

      final data = (resp['data'] as List)
          .map((e) => CashFlowYear.fromJson(e))
          .toList();

      final meta = PaginationMeta.fromJson(resp['meta']);

      return (data: data, meta: meta);
    } catch (e, stack) {
      AppLogger.e(
        "Failed to fetch cashflow summary",
        error: e,
        stackTrace: stack,
      );
      throw Exception("Failed to fetch cashflow summary: $e");
    }
  }
}
