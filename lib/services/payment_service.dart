import 'dart:convert';
import 'package:http/http.dart' as http;

class PaymentService {
  static const String baseUrl = "http://localhost:3000/api/v1";

  static Future<List<dynamic>> getPaymentsByVehicleId(int vehicleId) async {
    final url = Uri.parse("$baseUrl/payments/vehicle/$vehicleId");

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data["data"]; // sesuaikan format API backend kamu
    } else {
      throw Exception("Failed to load payments");
    }
  }
}
