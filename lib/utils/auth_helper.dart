import 'package:shared_preferences/shared_preferences.dart';

class AuthHelper {
  static String? _currentRole;

  /// Ambil role dari memory cache
  static String get currentRole => _currentRole ?? '';

  /// Load role dari SharedPreferences (panggil setelah login / app start)
  static Future<void> loadRole() async {
    final prefs = await SharedPreferences.getInstance();
    _currentRole = prefs.getString("role");
  }

  /// Clear role saat logout
  static Future<void> clearRole() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove("role");
    _currentRole = null;
  }

  /// Check role (async, aman untuk guard)
  static Future<bool> hasRole(List<String> allowedRoles) async {
    final prefs = await SharedPreferences.getInstance();
    final role = prefs.getString("role");
    return role != null && allowedRoles.contains(role);
  }
}
