import '../config/api_config.dart';
import 'api_services.dart';

class BookingService {
  static final String _baseUrl = ApiConfig.baseUrl(ApiVersion.v1);

  /// Create new booking mapped to backend transactions
  static Future<dynamic> createBooking(Map<String, dynamic> payload) async {
    try {
      return await ApiServices.post(
        _baseUrl,
        "transactions",
        payload,
      );
    } catch (e) {
      throw Exception("Failed to create booking: $e");
    }
  }

  /// Get transactions for a user (adjust query param name if needed)
  static Future<dynamic> getBookingsByUser(String userId) async {
    try {
      return await ApiServices.get(
        _baseUrl,
        "transactions?user_id=$userId",
      );
    } catch (e) {
      throw Exception("Failed to fetch bookings for user $userId: $e");
    }
  }

  /// Get single transaction by id
  static Future<dynamic> getTransactionById(dynamic id) async {
    try {
      return await ApiServices.get(
        _baseUrl,
        "transactions/$id",
      );
    } catch (e) {
      throw Exception("Failed to fetch transaction $id: $e");
    }
  }
    /// Get transactions by vehicle id
  static Future<List<dynamic>> getTransactionsByVehicle(dynamic vehicleId) async {
    try {
      final resp = await ApiServices.get(
        _baseUrl,
        "transactions?vehicle_id=$vehicleId",
      );
      if (resp is Map && resp['success'] == true && resp['data'] is List) {
        return resp['data'] as List<dynamic>;
      }
      // If API returns list directly
      if (resp is List) return resp;
      return [];
    } catch (e) {
      throw Exception("Failed to fetch transactions for vehicle $vehicleId: $e");
    }
  }
}