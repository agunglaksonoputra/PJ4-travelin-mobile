import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:travelin/pages/OnReport_page.dart';
import 'package:travelin/pages/admin/admin_page.dart';
import 'package:travelin/pages/admin/user_master_page.dart';
import 'package:travelin/pages/admin/vehicle_master_page.dart';
import 'package:travelin/pages/reservation_page.dart';
import 'pages/login_page.dart';
import 'pages/signup_page.dart';
import 'pages/homepage.dart';
import 'pages/actual_page.dart';
import 'pages/report_page.dart';
import 'pages/OnPayment_page.dart';
import 'pages/OnPlanning_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('id_ID', null);
  Intl.defaultLocale = 'id_ID';
  await dotenv.load(fileName: ".env");

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Travelin',
      theme: ThemeData(
        primarySwatch: Colors.teal,
        scaffoldBackgroundColor: Colors.grey[100],
      ),
      initialRoute: '/login',
      routes: {
        '/login': (context) => const LoginPage(),
        '/signup': (context) => const SignupPage(),
        '/home': (context) => const HomePage(),
        '/actual': (context) => const ActualPage(),
        '/report': (context) => const ReportPage(),
        '/reservation': (context) => const ReservationPage(),
        '/OnPlanning': (context) => const OnPlanningPage(),
        '/OnPayment_progress': (context) => const OnPaymentPage(),
        '/OnReport': (context) => const OnReportPage(),
        '/report_progress': (context) => const ReportPage(),
        '/admin': (context) => const AdminPage(),
        '/admin/users': (context) => const UserMasterPage(),
        '/admin/vehicles': (context) => const VehicleMasterPage(),
      },
    );
  }
}
