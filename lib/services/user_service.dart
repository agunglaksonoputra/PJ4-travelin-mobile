import '../config/api_config.dart';
import 'api_services.dart';

class UserService {
  // API version khusus user
  static final String _baseUrl =
  ApiConfig.baseUrl(ApiVersion.v1);

  /// Get current user profile
  static Future<String> getUserName() async {
    try {
      final response = await ApiServices.get(
        _baseUrl,
        "users/profile",
      );

      final data = response["data"];

      if (data != null && data["username"] != null) {
        return data["username"] as String;
      }

      throw Exception("Username not found in response");
    } catch (e) {
      throw Exception("Failed to fetch user profile: $e");
    }
  }
}
