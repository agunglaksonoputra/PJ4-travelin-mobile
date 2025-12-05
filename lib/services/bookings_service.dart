import 'package:travelin/services/api_services.dart';

class BookingService {
  // Buat booking baru
  static Future<dynamic> create(Map<String, dynamic> data) async {
    try {
      return await ApiServices.post("booking", data);
    } catch (e) {
      print("Error creating booking: $e");
      return null;
    }
  }

  // Ambil booking berdasarkan userId
  static Future<dynamic> getByUser(String userId) async {
    try {
      return await ApiServices.get("booking/user/$userId");
    } catch (e) {
      print("Error fetching booking for user $userId: $e");
      return null;
    }
  }
}
