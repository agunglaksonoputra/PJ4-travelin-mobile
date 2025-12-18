import '../config/api_config.dart';
import '../models/transaction_models.dart';
import '../models/transaction_summary_model.dart';
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

  static Future<double> getTotalPaidAmountClosed() async {
    final endpoint = '$_resource/paid-amount/closed/total';
    AppLogger.i('Fetching total paid amount for closed transactions');

    try {
      final response = await ApiServices.get(_baseUrl, endpoint);

      AppLogger.d('Total paid closed response: $response');

      final payload = _asMap(response);
      _ensureSuccess(payload);

      final data = payload['data'];
      if (data is Map<String, dynamic>) {
        final raw = data['total_paid_amount'];
        if (raw is num) return raw.toDouble();
        if (raw is String) return double.tryParse(raw) ?? 0.0;
      } else if (data is num) {
        return data.toDouble();
      }

      throw Exception('Invalid response format: expected total_paid_amount');
    } catch (e, stackTrace) {
      AppLogger.e(
        'Failed to fetch total paid amount (closed)',
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

      final responsePayload = _asMap(response);
      _ensureSuccess(responsePayload);

      final body = responsePayload['data'];
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

      final responsePayload = _asMap(response);
      _ensureSuccess(responsePayload);

      final body = responsePayload['data'];
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
      // Normalize currency inputs: allow strings like "Rp 1.250.000" or "1,250,000"
      Map<String, dynamic> payload = Map<String, dynamic>.from(data);
      double? _normalizeAmount(dynamic v) {
        if (v == null) return null;
        if (v is num) return v.toDouble();
        if (v is String) {
          // Keep only digits and separators
          String cleaned = v.replaceAll(RegExp(r'[^0-9.,]'), '');
          final hasComma = cleaned.contains(',');
          final hasDot = cleaned.contains('.');

          String numStr = cleaned;
          if (hasComma && hasDot) {
            // Assume Indonesian format: dot thousands, comma decimal
            numStr = cleaned.replaceAll('.', '');
            numStr = numStr.replaceFirst(',', '.');
          } else if (hasComma && !hasDot) {
            // Only comma -> treat as decimal separator
            numStr = cleaned.replaceFirst(',', '.');
          } else if (!hasComma && hasDot) {
            // Only dot -> assume dot as decimal separator (leave as is)
            numStr = cleaned;
          } else {
            // Digits only
            numStr = cleaned;
          }
          return double.tryParse(numStr);
        }
        return null;
      }

      double? normalized;
      if (payload.containsKey('paid_amount')) {
        normalized = _normalizeAmount(payload['paid_amount']);
        if (normalized != null) payload['paid_amount'] = normalized;
      } else if (payload.containsKey('amount')) {
        normalized = _normalizeAmount(payload['amount']);
        if (normalized != null) payload['amount'] = normalized;
      }

      if (normalized == null || normalized <= 0) {
        throw Exception('Nominal pembayaran tidak valid');
      }

      final response = await ApiServices.post(
        _baseUrl,
        '$_resource/$transactionId/payment-plan',
        payload,
      );

      AppLogger.d('Set payment plan response: $response');

      final responsePayload = _asMap(response);
      _ensureSuccess(responsePayload);

      final body = responsePayload['data'];
      if (body is Map<String, dynamic>) {
        // Parse initial update result
        final updated = TransactionModel.fromJson(body);
        try {
          // Move status to 'payment' after recording payment
          final moved = await updateTransaction(transactionId, {
            'status': 'payment',
          });
          return moved;
        } catch (_) {
          // If status update fails, return payment-plan updated transaction
          return updated;
        }
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

  static Future<List<TransactionSummaryModel>> getTransactionSummary({
    int? vehicleId,
  }) async {
    final query = _buildQuery({'vehicle_id': vehicleId});
    final endpoint =
        query.isEmpty ? '$_resource/summary' : '$_resource/summary?$query';

    AppLogger.i('Fetching transaction summary with vehicleId=$vehicleId');

    try {
      final response = await ApiServices.get(_baseUrl, endpoint);

      AppLogger.d('Transaction summary response: $response');

      final payload = _asMap(response);
      _ensureSuccess(payload);

      final data = payload['data'];
      if (data is List) {
        return data
            .whereType<Map<String, dynamic>>()
            .map(TransactionSummaryModel.fromJson)
            .toList();
      }

      throw Exception('Invalid response format: expected list in data field');
    } catch (e, stackTrace) {
      AppLogger.e(
        'Failed to fetch transaction summary',
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
