import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../config/api_config.dart';
import '../models/user_models.dart';
import '../utils/app_logger.dart';

class AuthService {
  static final String baseUrl = ApiConfig.baseUrl(ApiVersion.v1);

  // LOGIN
  Future<UserModel?> login(String username, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'username': username, 'password': password}),
      );

      if (response.statusCode == 200) {
        final resp = jsonDecode(response.body);

        if (resp['success'] == true && resp['data'] != null) {
          final userData = resp['data']['user'];
          final token = resp['data']['token'];

          // Simpan token dan user ID
          SharedPreferences prefs = await SharedPreferences.getInstance();
          await prefs.setString("token", token);
          await prefs.setString("userId", userData['id'].toString());

          AppLogger.i('Login success for $username');

          return UserModel.fromJson(userData);
        } else {
          AppLogger.w('Login failed: invalid response structure');
        }
      } else {
        AppLogger.w('Login failed with status ${response.statusCode}');
      }
    } catch (e, s) {
      AppLogger.e('Login exception occurred', error: e, stackTrace: s);
    }

    return null;
  }

  // REGISTER
  Future<UserModel?> register(
    String name,
    String username,
    String email,
    String password,
  ) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/register'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'name': name,
        'username': username,
        'email': email,
        'password': password,
      }),
    );

    if (response.statusCode == 201) {
      final resp = jsonDecode(response.body);
      final userData = resp['data']['user'];
      return UserModel.fromJson(userData);
    } else {
      print('Register failed: ${response.body}');
      return null;
    }
  }
}
