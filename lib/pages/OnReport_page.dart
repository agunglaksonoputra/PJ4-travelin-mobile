import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/vehicle_models.dart';
import '../widgets/bottom_navbar.dart';
import 'package:travelin/services/bookings_service.dart';
import 'package:travelin/services/report_service.dart';
import 'package:travelin/services/vehicle_service.dart';

class OnReportPage extends StatefulWidget {
  const OnReportPage({super.key});

  @override
  State<OnReportPage> createState() => _OnReportPageState();
}

class _OnReportPageState extends State<OnReportPage> {
  bool isDropdownOpen = false;
  bool _isLoadingVehicles = false;
  String? _vehicleError;
  VehicleModel? _selectedVehicle;
  List<VehicleModel> _vehicles = [];

  List<dynamic> transactions = [];
  bool isLoadingTransactions = false;
  String? transactionError;
  String? selectedTransactionId;

  String summaryCustomer = '';
  int summaryTotalTrips = 0;
  double summaryTotalPayment = 0.0;
  String summaryDate = '';

  final TextEditingController transactionIdController = TextEditingController();
  final TextEditingController kmStartController = TextEditingController();
  final TextEditingController kmEndController = TextEditingController();
  final TextEditingController driverFeeController = TextEditingController();
  final TextEditingController gasolineController = TextEditingController();
  final TextEditingController destinationController = TextEditingController();
  final TextEditingController othersController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadVehicles();
  }

  @override
  void dispose() {
    transactionIdController.dispose();
    kmStartController.dispose();
    kmEndController.dispose();
    driverFeeController.dispose();
    gasolineController.dispose();
    destinationController.dispose();
    othersController.dispose();
    super.dispose();
  }

  Future<void> _loadVehicles() async {
    setState(() {
      _isLoadingVehicles = true;
      _vehicleError = null;
    });

    try {
      final vehicles = await VehicleService.getVehicles();
      final selected = vehicles.isNotEmpty ? vehicles.first : null;

      if (!mounted) return;
      setState(() {
        _vehicles = vehicles;
        _selectedVehicle = selected;
        _isLoadingVehicles = false;
      });

      if (selected != null) {
        await _loadTransactionsForVehicle(selected.id);
      } else {
        setState(() {
          transactions = [];
          summaryCustomer = '';
          summaryTotalTrips = 0;
          summaryTotalPayment = 0;
          summaryDate = '';
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoadingVehicles = false;
        _vehicleError = e.toString();
      });
    }
  }

  Future<void> _loadTransactionsForVehicle(int vehicleId) async {
    setState(() {
      isLoadingTransactions = true;
      transactionError = null;
      transactions = [];
      summaryCustomer = '';
      summaryTotalTrips = 0;
      summaryTotalPayment = 0;
      summaryDate = '';
    });

    try {
      final txs = await BookingService.getTransactionsByVehicle(vehicleId);

      double totalPayment = 0;
      DateTime? latestDate;
      String customer = '';

      for (final t in txs) {
        if (t is Map) {
          if (customer.isEmpty && t['customer_name'] != null) {
            customer = t['customer_name'].toString();
          }
          totalPayment +=
              double.tryParse(t['total_cost']?.toString() ?? '0') ?? 0;
          final maybeDate = t['start_date'] ?? t['created_at'];
          if (maybeDate != null) {
            final parsed = DateTime.tryParse(maybeDate.toString());
            if (parsed != null &&
                (latestDate == null || parsed.isAfter(latestDate))) {
              latestDate = parsed;
            }
          }
        }
      }

      if (!mounted) return;
      setState(() {
        transactions = txs;
        summaryCustomer = customer;
        summaryTotalTrips = txs.length;
        summaryTotalPayment = totalPayment;
        summaryDate =
            latestDate != null
                ? DateFormat('dd/MM/yyyy').format(latestDate)
                : '';
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

  String _vehicleLabel(VehicleModel vehicle) {
    final parts = [
      if (vehicle.brand != null && vehicle.brand!.isNotEmpty) vehicle.brand!,
      if (vehicle.model != null && vehicle.model!.isNotEmpty) vehicle.model!,
      vehicle.plateNumber,
    ];
    return parts.join(' ').trim();
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
            _buildVehicleDropdown(),
            const SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: 1 + transactions.length,
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

  // =========================
  // DROPDOWN (ONLY THIS PART CHANGED)
  // =========================
  Widget _buildVehicleDropdown() {
    if (_isLoadingVehicles) {
      return Container(
        height: 56,
        alignment: Alignment.center,
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
        child: const CircularProgressIndicator(),
      );
    }

    if (_vehicleError != null) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
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
          children: [
            const Icon(Icons.error_outline, color: Colors.redAccent),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                _vehicleError!,
                style: const TextStyle(color: Colors.redAccent),
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        GestureDetector(
          onTap: () => setState(() => isDropdownOpen = !isDropdownOpen),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
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
                      _selectedVehicle != null
                          ? _vehicleLabel(_selectedVehicle!)
                          : 'Pilih kendaraan',
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
            child:
                _vehicles.isEmpty
                    ? const Padding(
                      padding: EdgeInsets.all(16),
                      child: Text('Tidak ada kendaraan'),
                    )
                    : Column(
                      children:
                          _vehicles.map((vehicle) {
                            final isSelected =
                                vehicle.id == _selectedVehicle?.id;
                            return InkWell(
                              onTap: () {
                                setState(() {
                                  _selectedVehicle = vehicle;
                                  isDropdownOpen = false;
                                });
                                _loadTransactionsForVehicle(vehicle.id);
                              },
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 10,
                                  horizontal: 16,
                                ),
                                child: Row(
                                  children: [
                                    const Icon(
                                      Icons.directions_bus,
                                      color: Colors.black54,
                                      size: 18,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      _vehicleLabel(vehicle),
                                      style: TextStyle(
                                        color:
                                            isSelected
                                                ? Colors.blue
                                                : Colors.black87,
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

  Widget _buildReportCard(BuildContext context, int index) {
    // index 0 = summary card
    if (index == 0) {
      return Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 4,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Report Summary",
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
            ),
            const SizedBox(height: 8),
            const Divider(height: 1, color: Colors.black12),
            const SizedBox(height: 8),
            Text(
              "Customer: ${summaryCustomer.isNotEmpty ? summaryCustomer : '—'}",
            ),
            Text("Total Trip: $summaryTotalTrips"),
            Text(
              "Total Payment: Rp ${NumberFormat.currency(locale: 'id', symbol: '', decimalDigits: 0).format(summaryTotalPayment)}",
            ),
            Text("Date: ${summaryDate.isNotEmpty ? summaryDate : '-'}"),
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
                  _showTripReportDialog(context);
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

    // transaction cards (index > 0) generated from transactions list
    final tx = transactions[index - 1];
    final customer =
        (tx is Map && tx['customer_name'] != null)
            ? tx['customer_name'].toString()
            : '—';
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
            "Report #${index}",
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
                _showTripReportDialog(context);
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

  void _showTripReportDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Container(
            padding: const EdgeInsets.all(20),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Trip Report Form",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                  const SizedBox(height: 10),
                  _buildInputField(
                    "Transaction",
                    "Input Transaction ID",
                    transactionIdController,
                  ),
                  if (isLoadingTransactions)
                    const Padding(
                      padding: EdgeInsets.only(top: 8.0),
                      child: Text('Memuat transaksi...'),
                    ),
                  if (transactionError != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(
                        'Transaksi: ${transactionError!}',
                        style: const TextStyle(color: Colors.red),
                      ),
                    ),
                  const SizedBox(height: 6),
                  _buildInputField("KM Start", "Input Data", kmStartController),
                  _buildInputField("KM End", "Input Data", kmEndController),
                  _buildInputField(
                    "Driver Fee",
                    "Input Total",
                    driverFeeController,
                  ),
                  _buildInputField(
                    "Gasoline",
                    "Input Amount",
                    gasolineController,
                  ),
                  _buildInputField(
                    "Destination / Notes",
                    "Input Destination atau catatan",
                    destinationController,
                  ),
                  _buildInputField(
                    "Others (misc)",
                    "Lainnya...",
                    othersController,
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () async {
                        await _saveReport(context);
                      },
                      child: const Text("SAVE"),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildInputField(
    String label,
    String hint,
    TextEditingController controller,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 6),
          TextField(
            controller: controller,
            decoration: InputDecoration(
              hintText: hint,
              filled: true,
              fillColor: const Color(0xFFEDEDED),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _saveReport(BuildContext context) async {
    final rawTransaction = transactionIdController.text.trim();
    if (rawTransaction.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Masukkan transaction id terlebih dahulu'),
        ),
      );
      return;
    }

    final transactionId = int.tryParse(rawTransaction);
    if (transactionId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Transaction id tidak valid')),
      );
      return;
    }

    final kmStart = int.tryParse(kmStartController.text.trim());
    final kmEnd = int.tryParse(kmEndController.text.trim());
    final driverFee = double.tryParse(driverFeeController.text.trim()) ?? 0;
    final gasolineCost = double.tryParse(gasolineController.text.trim()) ?? 0;
    final miscCost = double.tryParse(othersController.text.trim()) ?? 0;
    final totalOperational = driverFee + gasolineCost + miscCost;

    if (!mounted) return;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    // verify transaction exists to avoid FK violation
    try {
      final tx = await BookingService.getTransactionById(transactionId);
      if (tx == null || (tx is Map && (tx['id'] == null))) {
        if (mounted) Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Transaction tidak ditemukan di server'),
          ),
        );
        return;
      }
    } catch (e) {
      if (mounted) Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal memverifikasi transaction: $e')),
      );
      return;
    }

    final payload = <String, dynamic>{
      'transaction_id': transactionId,
      'report_date': DateFormat('yyyy-MM-dd').format(DateTime.now()),
      'km_start': kmStart,
      'km_end': kmEnd,
      'driver_fee': driverFee,
      'gasoline_cost': gasolineCost,
      'misc_cost': miscCost,
      'notes': destinationController.text.trim(),
      'total_operational_cost': totalOperational,
    };

    try {
      final response = await ReportService.createReport(payload);
      if (!mounted) return;
      Navigator.of(context).pop(); // close loading
      Navigator.of(context).pop(); // close dialog
      String message = 'Report berhasil disimpan';
      if (response is Map && response['message'] is String)
        message = response['message'] as String;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
      // clear
      transactionIdController.clear();
      kmStartController.clear();
      kmEndController.clear();
      driverFeeController.clear();
      gasolineController.clear();
      destinationController.clear();
      othersController.clear();
      // refresh transactions for selected vehicle
      if (_selectedVehicle != null) {
        _loadTransactionsForVehicle(_selectedVehicle!.id);
      }
    } catch (e) {
      if (mounted) Navigator.of(context).pop();
      final preview = e.toString();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal menyimpan report: $preview')),
      );
    }
  }
}
