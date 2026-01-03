import '../config/api_config.dart';
import '../models/cashflow/cashflow_year_model.dart';
import '../models/cashflow/monthly_transaction_detail_model.dart';
import '../models/pagination_meta_model.dart';
import '../utils/app_logger.dart';
import 'api_services.dart';

class CashFlowService {
  static final String _baseUrl = ApiConfig.baseUrl(ApiVersion.v1);

  static Future<({List<CashFlowYear> data, PaginationMeta meta})>
  getCashFlowSummary({
    int page = 1,
    int limit = 1,
    String? year,
  }) async {
    AppLogger.i("GET $_baseUrl/monthly-report/cashflow");

    try {
      String endpoint = "monthly-report/cashflow?page=$page&limit=$limit";
      if (year != null) endpoint += "&year=$year";

      final resp = await ApiServices.get(_baseUrl, endpoint);

      AppLogger.d("Response cashflow: $resp");

      final dataList = (resp['data'] as List)
          .map((e) => CashFlowYear.fromJson(e))
          .toList();

      final meta = PaginationMeta.fromJson(resp['meta']);

      return (data: dataList, meta: meta);
    } catch (e, stack) {
      AppLogger.e(
        "Failed to fetch cashflow summary",
        error: e,
        stackTrace: stack,
      );
      throw Exception("Failed to fetch cashflow summary: $e");
    }
  }

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