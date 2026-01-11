import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:travelin/widgets/fitur_card.dart';
import 'package:intl/intl.dart';
import 'package:travelin/widgets/vehicle_selector.dart';
import '../../helper/bottom_nav_controller.dart';
import '../../models/vehicle_models.dart';
import '../../models/transaction_summary_model.dart';
import '../../services/vehicle_service.dart';
import '../../services/transaction_service.dart';
import '../../utils/auth_helper.dart';
import '../../widgets/bottom_navbar.dart';

class ActualPage extends StatefulWidget {
  const ActualPage({super.key});

  @override
  State<ActualPage> createState() => _ActualPageState();
}

class _ActualPageState extends State<ActualPage> {
  int selectedIndex = 1;
  VehicleModel? selectedVehicle;
  List<VehicleModel> vehicleList = [];
  Map<String, TransactionSummaryModel> summaryByStatus = {};
  bool isLoadingSummary = false;

  @override
  void initState() {
    super.initState();
    loadVehicles();
  }

  Future<void> loadVehicles() async {
    try {
      final vehicles = await VehicleService.getVehicles();

      if (!mounted) return;

      setState(() {
        vehicleList = vehicles;
        selectedVehicle = vehicles.isNotEmpty ? vehicles.first : null;
      });

      if (selectedVehicle != null) {
        await _loadSummaryForVehicle(selectedVehicle!.id);
      }
    } catch (_) {
      if (!mounted) return;

      setState(() {
        vehicleList = [];
      });
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

  Future<void> onItemTapped(int index) async {
    await BottomNavController.onItemTapped(
      context: context,
      index: index,
      onIndexChanged: (i) {
        setState(() => selectedIndex = i);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F3F3),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        scrolledUnderElevation: 0,
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
            VehicleSelector(
              selectedVehicle: selectedVehicle,
              vehicleList: vehicleList,
              onVehicleSelected: (vehicle) async {
                setState(() {
                  selectedVehicle = vehicle;
                });

                await _loadSummaryForVehicle(vehicle.id);
              },
            ),
            const SizedBox(height: 20),
            Expanded(
              child:
                isLoadingSummary
                  ? const Center(child: CircularProgressIndicator())
                  : ListView(
                    children: [
                      FiturCard(
                        title: "On Planning",
                        trip: _tripCount('planning'),
                        amount: _formattedAmount('planning'),
                        icon: FontAwesomeIcons.clipboardList,
                        onTap: () async {
                          final result = await Navigator.pushNamed(
                            context,
                            '/OnPlanning',
                            arguments: {
                              'selectedVehicle': selectedVehicle,
                              'vehicleList': vehicleList,
                            },
                          );

                          if (!mounted) return;

                          if (result is VehicleModel) {
                            setState(() {
                              selectedVehicle = result;
                            });

                            await _loadSummaryForVehicle(result.id);
                          }
                        },
                      ),
                      FiturCard(
                        title: "On Progress of Payment",
                        trip: _tripCount('payment'),
                        amount: _formattedAmount('payment'),
                        icon: FontAwesomeIcons.moneyBillWave,
                        onTap: () async {
                          final result = await Navigator.pushNamed(
                            context,
                            '/OnPayment_progress',
                            arguments: {
                              'selectedVehicle': selectedVehicle,
                              'vehicleList': vehicleList,
                            },
                          );

                          if (!mounted) return;

                          if (result is VehicleModel) {
                            setState(() {
                              selectedVehicle = result;
                            });

                            await _loadSummaryForVehicle(result.id);
                          }
                        },
                      ),
                      FiturCard(
                        title: "On Progress of Report",
                        trip: _tripCount('reporting'),
                        amount: _formattedAmount('reporting'),
                        icon: FontAwesomeIcons.fileLines,
                        onTap: () async {
                          final result = await Navigator.pushNamed(
                            context,
                            '/OnReport',
                            arguments: {
                              'selectedVehicle': selectedVehicle,
                              'vehicleList': vehicleList,
                            },
                          );

                          if (!mounted) return;

                          if (result is VehicleModel) {
                            setState(() {
                              selectedVehicle = result;
                            });

                            await _loadSummaryForVehicle(result.id);
                          }
                        },
                      ),
                      FiturCard(
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
        currentIndex: selectedIndex,
        role: AuthHelper.currentRole,
        onTap: onItemTapped,
      ),
    );
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
