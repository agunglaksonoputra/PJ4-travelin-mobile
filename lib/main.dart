import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:travelin/pages/OnReport_page.dart';
import 'package:travelin/pages/reservation_page.dart';
import 'pages/login_page.dart';
import 'pages/signup_page.dart';
import 'pages/homepage.dart';
import 'pages/actual_page.dart';
import 'pages/report_page.dart';
import 'pages/OnPaymen_page.dart';
import 'pages/OnPlaning_page.dart';

Future<void> main() async {
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
        '/OnReport' : (context) => const OnReportPage(),
        '/report_progress': (context) => const ReportPage(),
      },
    );
  }
}
