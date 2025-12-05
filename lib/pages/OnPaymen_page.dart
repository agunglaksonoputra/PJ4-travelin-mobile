import 'package:flutter/material.dart';
import '../widgets/bottom_navbar.dart';

class OnPaymentPage extends StatefulWidget {
  const OnPaymentPage({super.key});

  @override
  State<OnPaymentPage> createState() => _OnPaymentPageState();
}

class _OnPaymentPageState extends State<OnPaymentPage> {
  String selectedVehicle = "Vehicle 1";
  List<String> vehicleList = [
    "Vehicle 1",
    "Vehicle 2",
    "Vehicle 3",
    "Vehicle 4",
    "Vehicle 5"
  ];

  bool isDropdownOpen = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F3F3),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          "On Payment",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pushReplacementNamed(context, '/actual');
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
              child: ListView.builder(
                itemCount: 3,
                itemBuilder: (context, index) => _buildPaymentCard(context),
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
              Navigator.pushNamed(context, '/home');
              break;
            case 1:
              Navigator.pushNamed(context, '/actual');
              break;
            case 2:
              Navigator.pushNamed(context, '/report');
              break;
          }
        },
      ),
    );
  }

  Widget _buildVehicleDropdown() {
    return Column(
      children: [
        GestureDetector(
          onTap: () {
            setState(() {
              isDropdownOpen = !isDropdownOpen;
            });
          },
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
                    const Icon(Icons.directions_bus, color: Colors.black),
                    const SizedBox(width: 8),
                    Text(
                      selectedVehicle,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
                Icon(
                  isDropdownOpen
                      ? Icons.keyboard_arrow_up
                      : Icons.keyboard_arrow_down,
                  color: Colors.black,
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
                        vertical: 10, horizontal: 16),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.directions_bus,
                          color: Colors.black87,
                          size: 18,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          vehicle,
                          style: TextStyle(
                            color: vehicle == selectedVehicle
                                ? Colors.lightBlue
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

  /// 🔹 Kartu pembayaran
  Widget _buildPaymentCard(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 5,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "TRIP #1",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 6),
          const Text("Customer: PT Maju Jaya",
              style: TextStyle(color: Colors.black87)),
          const Divider(height: 20, thickness: 1, color: Colors.black12),
          const Text("Total: Rp 5.000.000"),
          const Text("Dibayar: Rp 3.000.000"),
          const Text("Sisa: Rp 2.000.000"),
          const Text("Payment Date: 15/10/2025"),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.lightBlue,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  onPressed: () => _showPaymentDetailDialog(context),
                  child: const Text(
                    "DETAIL",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.lightBlue,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('✅ Payment processed successfully!')),
                    );
                  },
                  child: const Text(
                    "PAYMENT",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// 🔹 Popup Detail Pembayaran
  void _showPaymentDetailDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor:
              const Color(0xFFF3F3F3), // abu-abu lembut untuk hilangkan pink
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          contentPadding: const EdgeInsets.all(16),
          content: Container(
            width: 300,
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: const Color(0xFFF3F3F3),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: const [
                    Text(
                      "Payment Detail",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Colors.black,
                      ),
                    ),
                    Text(
                      "Trip #1",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                const Divider(color: Colors.black12),

                // Payment 1
                const Text("Payment 1",
                    style: TextStyle(fontWeight: FontWeight.bold)),
                const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("Amount:", style: TextStyle(color: Colors.black87)),
                    Text("1.000.000", style: TextStyle(color: Colors.black)),
                  ],
                ),
                const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("Date:", style: TextStyle(color: Colors.black87)),
                    Text("15/10/2025", style: TextStyle(color: Colors.black)),
                  ],
                ),
                const SizedBox(height: 8),

                // Payment 2
                const Text("Payment 2",
                    style: TextStyle(fontWeight: FontWeight.bold)),
                const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("Amount:", style: TextStyle(color: Colors.black87)),
                    Text("1.000.000", style: TextStyle(color: Colors.black)),
                  ],
                ),
                const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("Date:", style: TextStyle(color: Colors.black87)),
                    Text("17/10/2025", style: TextStyle(color: Colors.black)),
                  ],
                ),
                const SizedBox(height: 8),

                // Payment 3
                const Text("Payment 3",
                    style: TextStyle(fontWeight: FontWeight.bold)),
                const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("Amount:", style: TextStyle(color: Colors.black87)),
                    Text("None", style: TextStyle(color: Colors.black)),
                  ],
                ),
                const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("Date:", style: TextStyle(color: Colors.black87)),
                    Text("--/--/----", style: TextStyle(color: Colors.black)),
                  ],
                ),
                const SizedBox(height: 12),
                const Divider(color: Colors.black12),

                // Total
                const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Total",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    Text(
                      "2.000.000",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                Align(
                  alignment: Alignment.centerRight,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.lightBlue,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 10),
                    ),
                    child: const Text(
                      "OK",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}