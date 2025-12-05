import 'api_services.dart';

class ReportService {
  static Future<dynamic> getReport() async => ApiServices.get("report");
}
