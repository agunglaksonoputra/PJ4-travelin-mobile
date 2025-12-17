import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/vehicle_models.dart';
import '../widgets/bottom_navbar.dart';
import '../widgets/vehicle_dropdown.dart';
import '../widgets/form/OnReport/report_dialog.dart';
import 'package:travelin/services/bookings_service.dart';

class OnReportPage extends StatefulWidget {
  const OnReportPage({super.key});

  @override
  State<OnReportPage> createState() => _OnReportPageState();
}

class _OnReportPageState extends State<OnReportPage> {
  VehicleModel? _selectedVehicle;

  List<dynamic> transactions = [];
  bool isLoadingTransactions = false;
  String? transactionError;

  @override
  void initState() {
    super.initState();
  }

  Future<void> _loadTransactionsForVehicle(int vehicleId) async {
    setState(() {
      isLoadingTransactions = true;
      transactionError = null;
      transactions = [];
    });

    try {
      final allTxs = await BookingService.getTransactionsByVehicle(vehicleId);

      // Filter only transactions with 'reporting' status
      final txs =
          allTxs
              .where(
                (t) =>
                    t is Map && (t['status'] ?? '').toString() == 'reporting',
              )
              .toList();

      if (!mounted) return;
      setState(() {
        transactions = txs;
        isLoadingTransactions = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        transactionError = e.toString();
        isLoadingTransactions = false;
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F3F3),
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text(
          "On Report",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pushReplacementNamed(context, '/actual'),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            VehicleDropdown(
              showLabel: false,
              initialVehicle: _selectedVehicle,
              onChanged: (vehicle) {
                setState(() {
                  _selectedVehicle = vehicle;
                });
                _loadTransactionsForVehicle(vehicle.id);
              },
            ),
            const SizedBox(height: 20),
            Expanded(
              child:
                  transactions.isEmpty
                      ? Center(
                        child: Text(
                          'Tidak ada transaksi dengan status reporting',
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                      )
                      : ListView.builder(
                        itemCount: transactions.length,
                        itemBuilder: (c, i) => _buildReportCard(c, i),
                      ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavBar(
        currentIndex: 2,
        onTap: (i) {
          if (i == 0) Navigator.pushReplacementNamed(context, '/home');
          if (i == 1) Navigator.pushReplacementNamed(context, '/actual');
          if (i == 2) Navigator.pushReplacementNamed(context, '/report');
        },
      ),
    );
  }

  Widget _buildReportCard(BuildContext context, int index) {
    final tx = transactions[index];
    final customer =
        (tx is Map && tx['customer_name'] != null)
            ? tx['customer_name'].toString()
            : '—';
    final tripCode =
        (tx is Map && (tx['trip_code'] ?? tx['tripCode']) != null)
            ? (tx['trip_code'] ?? tx['tripCode']).toString()
            : null;
    final totalPayment =
        (tx is Map && tx['total_cost'] != null)
            ? double.tryParse(tx['total_cost'].toString()) ?? 0.0
            : 0.0;
    final dateStr =
        (tx is Map && (tx['start_date'] ?? tx['created_at']) != null)
            ? (() {
              try {
                return DateFormat('dd/MM/yyyy').format(
                  DateTime.parse(
                    (tx['start_date'] ?? tx['created_at']).toString(),
                  ),
                );
              } catch (_) {
                return '-';
              }
            })()
            : '-';

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Report ${tripCode?.isNotEmpty == true ? tripCode : '#${index + 1}'}",
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
          ),
          const SizedBox(height: 8),
          const Divider(height: 1, color: Colors.black12),
          const SizedBox(height: 8),
          Text("Customer: $customer"),
          const Text("Total Trip: 1"),
          Text(
            "Total Payment: Rp ${NumberFormat.currency(locale: 'id', symbol: '', decimalDigits: 0).format(totalPayment)}",
          ),
          Text("Date: $dateStr"),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.lightBlue,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              onPressed: () {
                showDialog(
                  context: context,
                  builder:
                      (context) => ReportDialog(
                        transaction: tx,
                        onReportSuccess: () {
                          if (_selectedVehicle != null) {
                            _loadTransactionsForVehicle(_selectedVehicle!.id);
                          }
                        },
                      ),
                );
              },
              child: const Text(
                "TRIP REPORT",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
