import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:travelin/widgets/trip_card.dart';
import 'package:intl/intl.dart';
import '../models/vehicle_models.dart';
import '../models/transaction_summary_model.dart';
import '../services/vehicle_service.dart';
import '../services/transaction_service.dart';
import '../widgets/bottom_navbar.dart';

class ActualPage extends StatefulWidget {
  const ActualPage({super.key});

  @override
  State<ActualPage> createState() => _ActualPageState();
}

class _ActualPageState extends State<ActualPage> {
  VehicleModel? selectedVehicle;
  List<VehicleModel> vehicleList = [];
  Map<String, TransactionSummaryModel> summaryByStatus = {};
  bool isLoadingSummary = false;

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
      final List<VehicleModel> vehicles = await VehicleService.getVehicles();

      setState(() {
        vehicleList = vehicles;
        selectedVehicle = vehicles.isNotEmpty ? vehicles.first : null;
      });

      if (selectedVehicle != null) {
        await _loadSummaryForVehicle(selectedVehicle!.id);
      }
    } catch (e) {
      debugPrint("Error load vehicle: $e");
    }
  }

  Future<void> _loadSummaryForVehicle(int vehicleId) async {
    setState(() {
      isLoadingSummary = true;
      summaryByStatus = {};
    });

    try {
      final summaries = await TransactionService.getTransactionSummary(
        vehicleId: vehicleId,
      );
      debugPrint("=== Transaction Summary Debug ===");
      debugPrint("Summaries received: $summaries");
      for (final item in summaries) {
        debugPrint(
          "Status: ${item.status}, TripCount: ${item.tripCount}, Amount: ${item.totalAmount}",
        );
      }
      setState(() {
        summaryByStatus = {for (final item in summaries) item.status: item};
      });
    } catch (e) {
      debugPrint("Error load summary: $e");
    } finally {
      if (mounted) {
        setState(() {
          isLoadingSummary = false;
        });
      }
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
              child:
                  isLoadingSummary
                      ? const Center(child: CircularProgressIndicator())
                      : ListView(
                        children: [
                          TripCard(
                            title: "On Planning",
                            trip: _tripCount('planning'),
                            amount: _formattedAmount('planning'),
                            icon: FontAwesomeIcons.clipboardList,
                            onTap:
                                () =>
                                    Navigator.pushNamed(context, '/OnPlanning'),
                          ),
                          TripCard(
                            title: "On Progress of Payment",
                            trip: _tripCount('payment'),
                            amount: _formattedAmount('payment'),
                            icon: FontAwesomeIcons.moneyBillWave,
                            onTap:
                                () => Navigator.pushNamed(
                                  context,
                                  '/OnPayment_progress',
                                ),
                          ),
                          TripCard(
                            title: "On Progress of Report",
                            trip: _tripCount('reporting'),
                            amount: _formattedAmount('reporting'),
                            icon: FontAwesomeIcons.fileLines,
                            onTap:
                                () => Navigator.pushNamed(context, '/OnReport'),
                          ),
                          TripCard(
                            title: "Closed",
                            trip: _tripCount('closed'),
                            amount: _formattedAmount('closed'),
                            icon: FontAwesomeIcons.circleCheck,
                            onTap:
                                () => Navigator.pushNamed(context, '/report'),
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
                    const Icon(
                      FontAwesomeIcons.bus,
                      color: Colors.black87,
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      _vehicleLabelAny(selectedVehicle),
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
              children:
                  vehicleList.map((vehicle) {
                    final isSelected = vehicle.id == selectedVehicle?.id;
                    return InkWell(
                      onTap: () async {
                        setState(() {
                          selectedVehicle = vehicle;
                          isDropdownOpen = false;
                        });
                        await _loadSummaryForVehicle(vehicle.id);
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
                              _vehicleLabelAny(vehicle),
                              style: TextStyle(
                                color:
                                    isSelected ? Colors.blue : Colors.black87,
                                fontWeight:
                                    isSelected
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

  String _vehicleLabel(VehicleModel vehicle) {
    final parts = [
      if (vehicle.brand != null && vehicle.brand!.isNotEmpty) vehicle.brand!,
      if (vehicle.model != null && vehicle.model!.isNotEmpty) vehicle.model!,
      vehicle.plateNumber,
    ];
    return parts.join(' ').trim();
  }

  String _vehicleLabelAny(dynamic vehicle) {
    if (vehicle is VehicleModel) {
      return _vehicleLabel(vehicle);
    }
    return "Select Vehicle";
  }

  int _tripCount(String status) {
    return summaryByStatus[status]?.tripCount ?? 0;
  }

  String _formattedAmount(String status) {
    final amount = summaryByStatus[status]?.totalAmount ?? 0;
    final formatter = NumberFormat.decimalPattern('id_ID');
    return formatter.format(amount);
  }
}
