import '../config/api_config.dart';
import '../models/payment_models.dart';
import '../utils/app_logger.dart';
import 'api_services.dart';

class PaymentService {
  PaymentService._();

  static final String _baseUrl = ApiConfig.baseUrl(ApiVersion.v1);
  static const String _resource = 'transactions/payments';

  static Future<List<PaymentModel>> getPaymentsByVehicleId(
    int vehicleId,
  ) async {
    AppLogger.i('Fetching payments for vehicleId $vehicleId');

    try {
      final response = await ApiServices.get(
        _baseUrl,
        '$_resource/vehicle/$vehicleId?includeTransaction=true',
      );

      AppLogger.d('Payment list response: $response');

      final payload = _asMap(response);
      _ensureSuccess(payload);

      final data = payload['data'];
      if (data is List) {
        return data
            .whereType<Map<String, dynamic>>()
            .map(PaymentModel.fromJson)
            .toList();
      }

      throw Exception('Invalid response format: expected list in data field');
    } catch (e, stackTrace) {
      AppLogger.e(
        'Failed to fetch payments by vehicle',
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  static Future<PaymentModel> getPaymentById(int paymentId) async {
    AppLogger.i('Fetching payment detail for id $paymentId');

    try {
      final response = await ApiServices.get(_baseUrl, '$_resource/$paymentId');

      AppLogger.d('Payment detail response: $response');

      final payload = _asMap(response);
      _ensureSuccess(payload);

      final data = payload['data'];
      if (data is Map<String, dynamic>) {
        return PaymentModel.fromJson(data);
      }

      throw Exception('Invalid response format: expected object in data field');
    } catch (e, stackTrace) {
      AppLogger.e(
        'Failed to fetch payment detail',
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  static Future<PaymentModel> createPayment({
    required int transactionId,
    required double amount,
    required String method,
    String? note,
  }) async {
    AppLogger.i('Creating payment for transaction $transactionId');

    try {
      final response = await ApiServices.post(_baseUrl, _resource, {
        'transaction_id': transactionId,
        'amount': amount,
        'method': method,
        if (note != null && note.isNotEmpty) 'note': note,
      });

      AppLogger.d('Create payment response: $response');

      final payload = _asMap(response);
      _ensureSuccess(payload);

      final data = payload['data'];
      if (data is Map<String, dynamic>) {
        return PaymentModel.fromJson(data);
      }

      throw Exception('Invalid response format: expected object in data field');
    } catch (e, stackTrace) {
      AppLogger.e('Failed to create payment', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  static Future<void> deletePayment(int paymentId) async {
    AppLogger.i('Deleting payment id $paymentId');

    try {
      final response = await ApiServices.delete(
        _baseUrl,
        '$_resource/$paymentId',
      );

      AppLogger.d('Delete payment response: $response');

      final payload = _asMap(response);
      _ensureSuccess(payload);
    } catch (e, stackTrace) {
      AppLogger.e('Failed to delete payment', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  static Map<String, dynamic> _asMap(dynamic value) {
    if (value is Map<String, dynamic>) {
      return value;
    }
    throw Exception('Invalid response format: expected JSON object');
  }

  static void _ensureSuccess(Map<String, dynamic> payload) {
    final success = payload['success'];
    if (success == null || success == true) {
      return;
    }

    final message = payload['message'] ?? payload['error'] ?? 'Request failed';
    throw Exception(message.toString());
  }
}
