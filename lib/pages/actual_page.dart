import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:travelin/widgets/trip_card.dart';
import '../services/vehicle_service.dart';
import '../widgets/bottom_navbar.dart';

class ActualPage extends StatefulWidget {
  const ActualPage({super.key});

  @override
  State<ActualPage> createState() => _ActualPageState();
}

class _ActualPageState extends State<ActualPage> {
  String selectedVehicle = "";
  List<String> vehicleList = [];

  bool isDropdownOpen = false;

  @override
  void initState() {
    super.initState();
    loadVehicles();
  }

  // ===============================
  // LOAD VEHICLE FROM API (FIX)
  // ===============================
  Future<void> loadVehicles() async {
    try {
      final List vehicles = await VehicleService.getVehicles();

      setState(() {
        // ambil field brand
        vehicleList = vehicles
          .map<String>((v) => "${v["brand"]} ${v["model"]} ${v["plate_number"]}")
          .toList();

        selectedVehicle =
            vehicleList.isNotEmpty ? vehicleList.first : "";
      });
    } catch (e) {
      print("Error load vehicle: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F3F3),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          "Actual",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildVehicleDropdown(),
            const SizedBox(height: 20),
            Expanded(
              child: ListView(
                children: [
                  TripCard(
                    title: "On Planning",
                    trip: 20,
                    amount: "20.000.000",
                    icon: FontAwesomeIcons.clipboardList,
                    onTap: () => Navigator.pushNamed(context, '/OnPlanning'),
                  ),
                  TripCard(
                    title: "On Progress of Payment",
                    trip: 15,
                    amount: "10.000.000",
                    icon: FontAwesomeIcons.moneyBillWave,
                    onTap: () =>
                        Navigator.pushNamed(context, '/OnPayment_progress'),
                  ),
                  TripCard(
                    title: "On Progress of Report",
                    trip: 12,
                    amount: "8.500.000",
                    icon: FontAwesomeIcons.fileLines,
                    onTap: () => Navigator.pushNamed(context, '/OnReport'),
                  ),
                  TripCard(
                    title: "Closed",
                    trip: 25,
                    amount: "25.000.000",
                    icon: FontAwesomeIcons.circleCheck,
                    onTap: () => Navigator.pushNamed(context, '/report'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavBar(
        currentIndex: 1,
        onTap: (index) {
          switch (index) {
            case 0:
              Navigator.pushReplacementNamed(context, '/home');
              break;
            case 1:
              break;
            case 2:
              Navigator.pushReplacementNamed(context, '/report');
              break;
          }
        },
      ),
    );
  }

  // ===============================
  // DROPDOWN VEHICLE
  // ===============================
  Widget _buildVehicleDropdown() {
    return Column(
      children: [
        GestureDetector(
          onTap: () => setState(() => isDropdownOpen = !isDropdownOpen),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 4,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(FontAwesomeIcons.bus, color: Colors.black87, size: 20),
                    const SizedBox(width: 12),
                    Text(
                      selectedVehicle.isNotEmpty
                          ? selectedVehicle
                          : "Select Vehicle",
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                Icon(
                  isDropdownOpen
                      ? FontAwesomeIcons.angleUp
                      : FontAwesomeIcons.angleDown,
                  color: Colors.black87,
                  size: 20,
                ),
              ],
            ),
          ),
        ),

        if (isDropdownOpen)
          Container(
            margin: const EdgeInsets.only(top: 6),
            padding: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 6,
                  offset: Offset(0, 3),
                ),
              ],
            ),
            child: Column(
              children: vehicleList.map((vehicle) {
                return InkWell(
                  onTap: () {
                    setState(() {
                      selectedVehicle = vehicle;
                      isDropdownOpen = false;
                    });
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: 10,
                      horizontal: 16,
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.directions_bus, size: 18),
                        const SizedBox(width: 8),
                        Text(
                          vehicle,
                          style: TextStyle(
                            color: vehicle == selectedVehicle
                                ? Colors.blue
                                : Colors.black87,
                            fontWeight: vehicle == selectedVehicle
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
      ],
    );
  }
}
