import 'api_services.dart';

class TravelService {
  static Future<dynamic> getAll() async => ApiServices.get("travel");
  static Future<dynamic> getDetail(int id) async => ApiServices.get("travel/$id");
}
