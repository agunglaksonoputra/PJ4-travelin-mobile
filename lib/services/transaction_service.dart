import '../config/api_config.dart';
import '../models/transaction_models.dart';
import '../utils/app_logger.dart';
import 'api_services.dart';

class TransactionService {
  TransactionService._();

  static final String _baseUrl = ApiConfig.baseUrl(ApiVersion.v1);
  static const String _resource = 'transactions';

  static Future<List<TransactionModel>> getTransactions({
    String? status,
    int? vehicleId,
    String? tripCode,
    int? tariffId,
    String? customerName,
  }) async {
    final filters = <String, dynamic>{
      'status': status,
      'vehicle_id': vehicleId,
      'trip_code': tripCode,
      'tariff_id': tariffId,
      'customer_name': customerName,
    };

    final query = _buildQuery(filters);
    final endpoint = query.isEmpty ? _resource : '$_resource?$query';

    AppLogger.i('Fetching transactions with filters $filters');

    try {
      final response = await ApiServices.get(_baseUrl, endpoint);

      AppLogger.d('Transaction list response: $response');

      final payload = _asMap(response);
      _ensureSuccess(payload);

      final data = payload['data'];
      if (data is List) {
        return data
            .whereType<Map<String, dynamic>>()
            .map(TransactionModel.fromJson)
            .toList();
      }

      throw Exception('Invalid response format: expected list in data field');
    } catch (e, stackTrace) {
      AppLogger.e(
        'Failed to fetch transactions',
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  static Future<TransactionModel> getTransactionById(int transactionId) async {
    AppLogger.i('Fetching transaction detail for id $transactionId');

    try {
      final response = await ApiServices.get(
        _baseUrl,
        '$_resource/$transactionId',
      );

      AppLogger.d('Transaction detail response: $response');

      final payload = _asMap(response);
      _ensureSuccess(payload);

      final data = payload['data'];
      if (data is Map<String, dynamic>) {
        return TransactionModel.fromJson(data);
      }

      throw Exception('Invalid response format: expected object in data field');
    } catch (e, stackTrace) {
      AppLogger.e(
        'Failed to fetch transaction detail',
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  static Future<TransactionModel> createTransaction(
    Map<String, dynamic> data,
  ) async {
    AppLogger.i('Creating transaction with payload $data');

    try {
      final response = await ApiServices.post(_baseUrl, _resource, data);

      AppLogger.d('Create transaction response: $response');

      final payload = _asMap(response);
      _ensureSuccess(payload);

      final body = payload['data'];
      if (body is Map<String, dynamic>) {
        return TransactionModel.fromJson(body);
      }

      throw Exception('Invalid response format: expected object in data field');
    } catch (e, stackTrace) {
      AppLogger.e(
        'Failed to create transaction',
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  static Future<TransactionModel> updateTransaction(
    int transactionId,
    Map<String, dynamic> data,
  ) async {
    AppLogger.i('Updating transaction $transactionId with payload $data');

    try {
      final response = await ApiServices.put(
        _baseUrl,
        '$_resource/$transactionId',
        data,
      );

      AppLogger.d('Update transaction response: $response');

      final payload = _asMap(response);
      _ensureSuccess(payload);

      final body = payload['data'];
      if (body is Map<String, dynamic>) {
        return TransactionModel.fromJson(body);
      }

      throw Exception('Invalid response format: expected object in data field');
    } catch (e, stackTrace) {
      AppLogger.e(
        'Failed to update transaction',
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  static Future<TransactionModel> setPaymentPlan(
    int transactionId,
    Map<String, dynamic> data,
  ) async {
    AppLogger.i(
      'Setting payment plan for transaction $transactionId with payload $data',
    );

    try {
      final response = await ApiServices.post(
        _baseUrl,
        '$_resource/$transactionId/payment-plan',
        data,
      );

      AppLogger.d('Set payment plan response: $response');

      final payload = _asMap(response);
      _ensureSuccess(payload);

      final body = payload['data'];
      if (body is Map<String, dynamic>) {
        return TransactionModel.fromJson(body);
      }

      throw Exception('Invalid response format: expected object in data field');
    } catch (e, stackTrace) {
      AppLogger.e(
        'Failed to set payment plan',
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  static Future<void> deleteTransaction(int transactionId) async {
    AppLogger.i('Deleting transaction id $transactionId');

    try {
      final response = await ApiServices.delete(
        _baseUrl,
        '$_resource/$transactionId',
      );

      AppLogger.d('Delete transaction response: $response');

      final payload = _asMap(response);
      _ensureSuccess(payload);
    } catch (e, stackTrace) {
      AppLogger.e(
        'Failed to delete transaction',
        error: e,
        stackTrace: stackTrace,
      );
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

  static String _buildQuery(Map<String, dynamic> params) {
    final buffer = StringBuffer();
    var hasValue = false;

    params.forEach((key, value) {
      if (value == null) return;
      if (value is String && value.isEmpty) return;

      buffer
        ..write(hasValue ? '&' : '')
        ..write(Uri.encodeQueryComponent(key))
        ..write('=')
        ..write(Uri.encodeQueryComponent(value.toString()));

      hasValue = true;
    });

    return buffer.toString();
  }
}
