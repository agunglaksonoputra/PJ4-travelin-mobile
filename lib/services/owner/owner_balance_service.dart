import 'package:travelin/models/owner/owner_balance_model.dart';
import '../../config/api_config.dart';
import '../../models/pagination_meta_model.dart';
import '../../utils/app_logger.dart';
import '../api_services.dart';

class OwnerBalanceService {
  static final String _baseUrl = ApiConfig.baseUrl(ApiVersion.v1);

  /// ===============================
  /// GET OWNER BALANCE LIST
  /// Endpoint: GET /owner-balances
  /// ===============================
  static Future<({List<OwnerBalanceModel> data, PaginationMeta meta})>
  getOwnerBalances({
    int page = 1,
    int limit = 10,
  }) async {
    AppLogger.i("GET $_baseUrl/owners/balance/all");

    try {
      final endpoint = "owners/balance/all?page=$page&limit=$limit";

      final resp = await ApiServices.get(_baseUrl, endpoint);

      AppLogger.d("Response owner balances: $resp");

      final dataList = (resp['data'] as List)
          .map((e) => OwnerBalanceModel.fromJson(e))
          .toList();

      final meta = PaginationMeta.fromJson(resp['meta']);

      return (data: dataList, meta: meta);
    } catch (e, stack) {
      AppLogger.e(
        "Failed to fetch owner balances",
        error: e,
        stackTrace: stack,
      );
      throw Exception("Failed to fetch owner balances: $e");
    }
  }
}
