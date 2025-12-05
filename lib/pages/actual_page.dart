import 'package:flutter/material.dart';
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
        vehicleList = vehicles.map<String>((v) => v["brand"].toString()).toList();

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
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          "Actual",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pushReplacementNamed(context, '/home');
          },
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
                  _buildTripCard(
                    title: "On Planning",
                    trip: 20,
                    amount: "20.000.000",
                    onTap: () => Navigator.pushNamed(context, '/OnPlanning'),
                  ),
                  _buildTripCard(
                    title: "On Progress of Payment",
                    trip: 15,
                    amount: "10.000.000",
                    onTap: () =>
                        Navigator.pushNamed(context, '/OnPayment_progress'),
                  ),
                  _buildTripCard(
                    title: "On Progress of Report",
                    trip: 12,
                    amount: "8.500.000",
                    onTap: () => Navigator.pushNamed(context, '/OnReport'),
                  ),
                  _buildTripCard(
                    title: "Closed",
                    trip: 25,
                    amount: "25.000.000",
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
                    const Icon(Icons.directions_bus, color: Colors.black87),
                    const SizedBox(width: 8),
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
                      ? Icons.keyboard_arrow_up
                      : Icons.keyboard_arrow_down,
                  color: Colors.black87,
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

  // ===============================
  // CARD STATUS PERJALANAN
  // ===============================
  Widget _buildTripCard({
    required String title,
    required int trip,
    required String amount,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 3,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE6F0FF),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.description, color: Colors.blue),
                ),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            const Divider(height: 1, color: Colors.black12),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Trip"),
                Text("$trip",
                    style: const TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Amount"),
                Text("Rp $amount",
                    style: const TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
