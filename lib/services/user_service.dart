import 'package:travelin/services/api_services.dart';

class UserService {
  // Ambil username user
  Future<String> getUserName() async {
    try {
      final response = await ApiServices.get("users/profile");
      if (response["data"] != null && response["data"]["username"] != null) {
        return response["data"]["username"];
      }
      return "Unknown User";
    } catch (e) {
      print("Error fetching user: $e");
      return "Unknown User";
    }
  }
}
