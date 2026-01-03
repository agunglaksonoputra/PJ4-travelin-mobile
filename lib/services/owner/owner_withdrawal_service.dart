import '../../config/api_config.dart';
import '../../models/owner/owner_withdrawal_model.dart';
import '../../models/pagination_meta_model.dart';
import '../../utils/app_logger.dart';
import '../api_services.dart';

class OwnerWithdrawalService {
  static final String _baseUrl = ApiConfig.baseUrl(ApiVersion.v1);

  /// ===============================
  /// GET OWNER WITHDRAWAL LIST
  /// GET /owner-withdrawals
  /// ===============================
  static Future<({List<OwnerWithdrawalModel> data, PaginationMeta meta})>
  getWithdrawals({
    int? ownerId,
    int page = 1,
    int limit = 10,
  }) async {
    AppLogger.i("GET $_baseUrl/owners/withdrawals");

    try {
      String endpoint = "owners/withdrawals?page=$page&limit=$limit";
      if (ownerId != null) endpoint += "&owner_id=$ownerId";

      final resp = await ApiServices.get(_baseUrl, endpoint);

      final rawData = resp['data'];

      /// 🔒 AMAN: pastikan List
      final List list = rawData is List ? rawData : [];

      final withdrawals = list
          .map((e) => OwnerWithdrawalModel.fromJson(e))
          .toList();

      final meta = resp['meta'] != null
          ? PaginationMeta.fromJson(resp['meta'])
          : PaginationMeta(
        total: withdrawals.length,
        page: page,
        limit: limit,
        totalPages: 1,
      );

      return (data: withdrawals, meta: meta);
    } catch (e, stack) {
      AppLogger.e(
        "Failed to fetch owner withdrawals",
        error: e,
        stackTrace: stack,
      );
      throw Exception("Failed to fetch owner withdrawals: $e");
    }
  }

  /// ===============================
  /// CREATE OWNER WITHDRAWAL
  /// POST /owner-withdrawals
  /// ===============================
  static Future<OwnerWithdrawalModel> createWithdrawal({
    required int ownerId,
    required double amount,
    required String method, // cash | transfer
    String? note,
  }) async {
    AppLogger.i("POST $_baseUrl/owners/withdrawals");

    try {
      final payload = {
        "owner_id": ownerId,
        "amount": amount,
        "method": method,
        if (note != null) "note": note,
      };

      final resp = await ApiServices.post(
        _baseUrl,
        "owners/withdrawals",
        payload,
      );

      return OwnerWithdrawalModel.fromJson(resp['data']);
    } catch (e, stack) {
      AppLogger.e(
        "Failed to create owner withdrawal",
        error: e,
        stackTrace: stack,
      );
      throw Exception("Failed to create owner withdrawal: $e");
    }
  }

  /// ===============================
  /// REFUND OWNER WITHDRAWAL
  /// PUT /owners/withdrawals/:id/refund
  /// ===============================
  static Future<OwnerWithdrawalModel> refundWithdrawal({
    required int withdrawalId,
  }) async {
    AppLogger.i("PUT $_baseUrl/owners/withdrawals/$withdrawalId/refund");

    try {
      final resp = await ApiServices.put(
        _baseUrl,
        "owners/withdrawals/$withdrawalId/refund",
        {},
      );

      return OwnerWithdrawalModel.fromJson(resp['data']);
    } catch (e, stack) {
      AppLogger.e(
        "Failed to refund owner withdrawal",
        error: e,
        stackTrace: stack,
      );
      throw Exception("Failed to refund owner withdrawal: $e");
    }
  }

}