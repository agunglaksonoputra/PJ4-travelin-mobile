import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiServices {
  static const Duration _timeout = Duration(seconds: 15);

  static Future<Map<String, String>> _headers() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("token");

    return {
      HttpHeaders.contentTypeHeader: "application/json",
      if (token != null && token.isNotEmpty)
        HttpHeaders.authorizationHeader: "Bearer $token",
    };
  }

  static Future<dynamic> get(
      String baseUrl,
      String endpoint,
      ) =>
      _request("GET", baseUrl, endpoint);

  static Future<dynamic> post(
      String baseUrl,
      String endpoint,
      Map<String, dynamic> body,
      ) =>
      _request("POST", baseUrl, endpoint, body: body);

  static Future<dynamic> put(
      String baseUrl,
      String endpoint,
      Map<String, dynamic> body,
      ) =>
      _request("PUT", baseUrl, endpoint, body: body);

  static Future<dynamic> delete(
      String baseUrl,
      String endpoint,
      ) =>
      _request("DELETE", baseUrl, endpoint);

  static Future<dynamic> _request(
      String method,
      String baseUrl,
      String endpoint, {
        Map<String, dynamic>? body,
      }) async {
    final uri = Uri.parse("$baseUrl/$endpoint");
    final headers = await _headers();

    http.Response response;

    try {
      switch (method) {
        case "GET":
          response = await http
              .get(uri, headers: headers)
              .timeout(_timeout);
          break;
        case "POST":
          response = await http
              .post(uri, headers: headers, body: jsonEncode(body))
              .timeout(_timeout);
          break;
        case "PUT":
          response = await http
              .put(uri, headers: headers, body: jsonEncode(body))
              .timeout(_timeout);
          break;
        case "DELETE":
          response = await http
              .delete(uri, headers: headers)
              .timeout(_timeout);
          break;
        default:
          throw Exception("Unsupported HTTP method");
      }

      return _handle(response);
    } on SocketException {
      throw Exception("No internet connection");
    } on TimeoutException {
      throw Exception("Request timeout");
    }
  }

  static dynamic _handle(http.Response response) {
    if (response.body.isEmpty) return null;

    final decoded = jsonDecode(response.body);

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return decoded;
    }

    final message = decoded is Map && decoded["message"] != null
        ? decoded["message"]
        : response.body;

    throw Exception("Error ${response.statusCode}: $message");
  }
}