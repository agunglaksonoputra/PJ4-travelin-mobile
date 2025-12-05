import 'dart:convert';
import 'package:http/http.dart' as http;

class TransactionService {
  static const String baseUrl = "http://your-ip:3000/api/v1/transactions";

  static Future<bool> createReservation(Map<String, dynamic> data) async {
    try {
      final res = await http.post(
        Uri.parse("$baseUrl"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(data),
      );

      return res.statusCode == 201 || res.statusCode == 200;
    } catch (e) {
      print("Error createReservation: $e");
      return false;
    }
  }
}
