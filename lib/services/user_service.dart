import '../config/api_config.dart';
import '../models/user_models.dart';
import '../utils/app_logger.dart';
import 'api_services.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserService {
  // API version khusus user
  static final String _baseUrl = ApiConfig.baseUrl(ApiVersion.v1);

  /// Get current user profile
  static Future<UserModel> getUserProfile() async {
    AppLogger.i('Fetching current user profile');

    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString("userId");

      if (userId == null || userId.isEmpty) {
        AppLogger.w("User ID not found in SharedPreferences");
        throw Exception("User ID not found. Please login first.");
      }

      final response = await ApiServices.get(_baseUrl, "users/$userId");

      AppLogger.d('User profile API response: $response');

      final data = response["data"];

      if (data != null && data is Map<String, dynamic>) {
        final user = UserModel.fromJson(data);
        AppLogger.i('User profile fetched successfully (id: ${user.id})');
        return user;
      }

      throw Exception("Invalid user data in response");
    } catch (e, stackTrace) {
      AppLogger.e(
        'Failed to fetch user profile',
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  /// Get all users
  static Future<List<UserModel>> getAllUsers() async {
    AppLogger.i("Fetching users list");

    try {
      final response = await ApiServices.get(_baseUrl, "users");

      AppLogger.d("Users API response: $response");

      final List data = response["data"];

      final users = data.map((e) => UserModel.fromJson(e)).toList();

      AppLogger.i("Users fetched successfully (count: ${users.length})");
      return users;
    } catch (e, stackTrace) {
      AppLogger.e("Failed to fetch users", error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  /// Create new user
  static Future<UserModel> createUser(Map<String, dynamic> payload) async {
    AppLogger.i('Creating new user');
    AppLogger.d('Create user payload: $payload');

    try {
      final response = await ApiServices.post(_baseUrl, 'users', payload);

      AppLogger.d('Create user response: $response');

      final data = response['data'];

      if (data is! Map<String, dynamic>) {
        throw Exception('Invalid user response format');
      }

      final user = UserModel.fromJson(data);

      AppLogger.i('User created successfully (id: ${user.id})');
      return user;
    } catch (e, stackTrace) {
      AppLogger.e('Failed to create user', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  /// Update user by ID
  static Future<UserModel> updateUser(
    String userId,
    Map<String, dynamic> payload,
  ) async {
    AppLogger.i("Updating user with id: $userId");
    AppLogger.d("Update user payload: $payload");

    try {
      final response = await ApiServices.put(
        _baseUrl,
        "users/$userId",
        payload,
      );

      AppLogger.d("Update user response: $response");

      final data = response['data'];

      if (data is! Map<String, dynamic>) {
        throw Exception('Invalid user response format');
      }

      final user = UserModel.fromJson(data);

      AppLogger.i("User updated successfully (id: ${user.id})");
      return user;
    } catch (e, stackTrace) {
      AppLogger.e(
        "Failed to update user (id: $userId)",
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  /// Delete user by ID
  static Future<void> deleteUser(String userId) async {
    AppLogger.i("Deleting user with id: $userId");

    try {
      await ApiServices.delete(_baseUrl, "users/$userId");

      AppLogger.i("User deleted successfully (id: $userId)");
    } catch (e, stackTrace) {
      AppLogger.e(
        "Failed to delete user (id: $userId)",
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }
}
