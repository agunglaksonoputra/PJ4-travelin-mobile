import 'package:shared_preferences/shared_preferences.dart';

class AuthHelper {
  static String? _currentRole;

  static String get currentRole => _currentRole ?? '';

  static Future<String?> getRole() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString("role");
  }

  static Future<bool> hasRole(List<String> allowedRoles) async {
    final role = await getRole();
    return role != null && allowedRoles.contains(role);
  }

}
