import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'package:travelin/pages/reservation_page.dart';
import '../services/user_service.dart';
import '../services/report_service.dart';
import '../services/transaction_service.dart';
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
  String name = "Loading...";
  double totalOperationalCost = 0;
  double totalRevenue = 0;
  bool isLoadingCost = true;
  bool isLoadingRevenue = true;

  @override
  void initState() {
    super.initState();
    loadUser();
    loadTotalOperationalCost();
    loadTotalRevenue();
  }

  Future<void> loadUser() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? storedName = prefs.getString("name");

    if (storedName != null && storedName.isNotEmpty) {
      name = storedName;
      setState(() {});
      return;
    }

    try {
      final userProfile = await UserService.getUserProfile();
      name = userProfile.name;
      await prefs.setString("name", userProfile.name);
      setState(() {});
    } catch (e) {
      print("Error loading user profile: $e");
      // Jika user belum login atau error, tampilkan pesan default
      setState(() {
        name = "User";
      });
    }
  }

  Future<void> loadTotalRevenue() async {
    try {
      final revenue = await TransactionService.getTotalPaidAmountClosed();
      setState(() {
        totalRevenue = revenue;
        isLoadingRevenue = false;
      });
    } catch (e) {
      print("Error loading revenue: $e");
      setState(() {
        totalRevenue = 0;
        isLoadingRevenue = false;
      });
    }
  }

  Future<void> loadTotalOperationalCost() async {
    try {
      final cost = await ReportService.getTotalOperationalCost();
      setState(() {
        totalOperationalCost = cost;
        isLoadingCost = false;
      });
    } catch (e) {
      print("Error loading operational cost: $e");
      setState(() {
        totalOperationalCost = 0;
        isLoadingCost = false;
      });
    }
  }

  String _formatCurrency(double amount) {
    final formatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );
    return formatter.format(amount);
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
      case 3:
        Navigator.pushReplacementNamed(context, '/admin');
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
                          name,
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
                      amount:
                          isLoadingRevenue
                              ? 'Loading...'
                              : _formatCurrency(totalRevenue),
                      icon: FontAwesomeIcons.handHoldingDollar,
                    ),
                    const SizedBox(height: 8),
                    SummaryCard(
                      color: Color(0xFFE52F1D),
                      title: 'Pengeluaran',
                      amount:
                          isLoadingCost
                              ? 'Loading...'
                              : _formatCurrency(totalOperationalCost),
                      icon: FontAwesomeIcons.moneyBillTransfer,
                    ),
                    const SizedBox(height: 8),
                    SummaryCard(
                      color: Color(0xFF9D00FF),
                      title: 'Profit',
                      amount:
                          (isLoadingRevenue || isLoadingCost)
                              ? 'Loading...'
                              : _formatCurrency(
                                totalRevenue - totalOperationalCost,
                              ),
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
