import 'dart:convert';
import 'package:http/http.dart' as http;

import '../config/api_config.dart';

class VehicleService {
  static final String baseUrl = ApiConfig.baseUrl(ApiVersion.v1);

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
