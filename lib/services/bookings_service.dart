import '../config/api_config.dart';
import 'api_services.dart';

class BookingService {
  // API version khusus booking
  static final String _baseUrl =
  ApiConfig.baseUrl(ApiVersion.v1);

  /// Create new booking
  static Future<dynamic> createBooking(
      Map<String, dynamic> payload,
      ) async {
    try {
      return await ApiServices.post(
        _baseUrl,
        "booking",
        payload,
      );
    } catch (e) {
      throw Exception("Failed to create booking: $e");
    }
  }

  /// Get bookings by user ID
  static Future<dynamic> getBookingsByUser(
      String userId,
      ) async {
    try {
      return await ApiServices.get(
        _baseUrl,
        "booking/user/$userId",
      );
    } catch (e) {
      throw Exception("Failed to fetch bookings for user $userId: $e");
    }
  }
}