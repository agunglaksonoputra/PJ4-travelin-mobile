import 'api_services.dart';

class ProfitShareService {
  static Future<List<dynamic>> getAll() async {
    final data = await ApiServices.get("profitShare");
    return data["data"];
  }
}
