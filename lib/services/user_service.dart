import '../config/api_config.dart';
import '../models/user_models.dart';
import '../utils/app_logger.dart';
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

  /// Get all users
  static Future<List<UserModel>> getAllUsers({
    int page = 1,
    int limit = 10,
  }) async {
    AppLogger.i("Fetching users list");

    try {
      final response = await ApiServices.get(
        _baseUrl,
        "users?page=$page&limit=$limit",
      );

      AppLogger.d("Users API response: $response");

      final List data = response["data"];

      final users = data
          .map((e) => UserModel.fromJson(e))
          .toList();

      AppLogger.i("Users fetched successfully (count: ${users.length})");
      return users;
    } catch (e, stackTrace) {
      AppLogger.e(
        "Failed to fetch users",
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }
}
