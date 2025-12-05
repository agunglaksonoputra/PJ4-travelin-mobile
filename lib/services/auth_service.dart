import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_models.dart';

class AuthService {
  final String baseUrl = "http://localhost:3000/api/v1"; // sesuaikan API

  // LOGIN
  Future<UserModel?> login(String email, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );

    if (response.statusCode == 200) {
      final resp = jsonDecode(response.body);

      if (resp['success'] == true && resp['data'] != null) {
        final userData = resp['data']['user'];
        final token = resp['data']['token'];

        // Simpan token di SharedPreferences
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString("token", token);

        // Kembalikan UserModel
        return UserModel.fromJson(userData);
      }
    } else {
      print('Login failed: ${response.body}');
    }
    return null;
  }

  // REGISTER
  Future<UserModel?> register(
      String name, String username, String email, String password) async {
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
