import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:travelin/pages/reservation_page.dart';
import '../services/user_service.dart';
import '../widgets/summary_card.dart';
import '../widgets/planning_table.dart';
import '../widgets/bottom_navbar.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int selectedIndex = 0;
  String username = "Loading...";

  @override
  void initState() {
    super.initState();
    loadUser();
  }

  Future<void> loadUser() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? storedUsername = prefs.getString("username");

    if (storedUsername != null && storedUsername.isNotEmpty) {
      username = storedUsername;
    } else {
      username = await UserService.getUserName();
    }
    setState(() {});
  }

  void onItemTapped(int index) {
    setState(() => selectedIndex = index);
    switch (index) {
      case 0:
        break;
      case 1:
        Navigator.pushReplacementNamed(context, '/actual');
        break;
      case 2:
        Navigator.pushReplacementNamed(context, '/report');
        break;
    }
  }

  void _openReservasiPage() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const ReservationPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F3F3),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 40),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // HEADER
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'WELCOME,',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                            fontSize: 20,
                          ),
                        ),
                        Text(
                          username,
                          style: const TextStyle(
                            fontSize: 22,
                            color: Colors.black,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        _circleIcon(FontAwesomeIcons.bell),
                        const SizedBox(width: 12),
                        GestureDetector(
                          onTap: () {
                            Navigator.pushNamed(context, '/login');
                          },
                          child: _circleIcon(FontAwesomeIcons.user),
                        ),
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // SUMMARY
                const Text(
                  'SUMMARY',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                    fontSize: 18,
                  ),
                ),
                const SizedBox(height: 12),

                Column(
                  children: [
                    SummaryCard(
                      color: Color(0xFF00BFA6),
                      title: 'Pendapatan',
                      amount: 'Rp 1.000.000',
                      icon: FontAwesomeIcons.handHoldingDollar,
                    ),
                    const SizedBox(height: 8),
                    SummaryCard(
                      color: Color(0xFFE52F1D),
                      title: 'Pengeluaran',
                      amount: 'Rp 1.000.000',
                      icon: FontAwesomeIcons.moneyBillTransfer,
                    ),
                    const SizedBox(height: 8),
                    SummaryCard(
                      color: Color(0xFF9D00FF),
                      title: 'Profit',
                      amount: 'Rp 1.000.000',
                      icon: FontAwesomeIcons.sackDollar,
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // PLANNING
                const Text(
                  'PLANNING',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                    fontSize: 18,
                  ),
                ),
                const SizedBox(height: 12),

                // const Expanded(
                //   flex: 3,
                //   child: PlanningTable(),
                // ),
              ],
            ),
          ),
        ),
      ),

      // FLOATING BUTTON
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 8, right: 8),
        child: SizedBox(
          width: 50,
          height: 50,
          child: FloatingActionButton(
            backgroundColor: Colors.redAccent,
            elevation: 5,
            shape: const CircleBorder(),
            onPressed: _openReservasiPage,
            child: const Icon(Icons.add, color: Colors.white, size: 26),
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,

      // BOTTOM NAVBAR
      bottomNavigationBar: BottomNavBar(
        currentIndex: selectedIndex,
        onTap: onItemTapped,
      ),
    );
  }

  // ICON HELPER
  static Widget _circleIcon(IconData icon) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 6),
        ],
      ),
      child: Icon(icon, color: Colors.black, size: 18),
    );
  }
}
