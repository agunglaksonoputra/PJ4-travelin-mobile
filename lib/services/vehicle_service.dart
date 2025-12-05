import 'dart:convert';
import 'package:http/http.dart' as http;

class VehicleService {
  // GANTI IP INI
  static const String baseUrl = "http://192.168.1.10:3000/api/v1";

  static Future<List<dynamic>> getVehicles() async {
    final url = Uri.parse("$baseUrl/vehicles");

    try {
      final response = await http.get(url);
      print("RAW RESPONSE = ${response.body}");

      if (response.statusCode != 200) {
        throw Exception("Error ${response.statusCode}");
      }

      final body = json.decode(response.body);

      // Jika backend kirim: { data: {...} } (OBJECT)
      if (body["data"] is Map) {
        return [body["data"]]; // ubah ke LIST agar UI tidak crash
      }

      // Jika backend kirim: { data: [...] } (LIST)
      if (body["data"] is List) {
        return body["data"];
      }

      throw Exception("Invalid vehicle format");
    } catch (e) {
      print("VehicleService ERROR = $e");
      rethrow;
    }
  }
}
