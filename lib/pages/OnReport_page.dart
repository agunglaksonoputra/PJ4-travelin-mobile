import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../widgets/bottom_navbar.dart';
import 'package:travelin/services/report_service.dart';
import 'package:travelin/services/vehicle_service.dart';
import 'package:travelin/services/bookings_service.dart';

class OnReportPage extends StatefulWidget {
  const OnReportPage({super.key});

  @override
  State<OnReportPage> createState() => _OnReportPageState();
}

class _OnReportPageState extends State<OnReportPage> {
  String selectedVehicleLabel = 'Pilih Vehicle';
  String? selectedVehicleId;

  List<String> vehicleList = [];
  List<dynamic> vehicles = [];

  bool isDropdownOpen = false;
  bool isLoadingVehicles = false;
  String? vehicleError;

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
    setState(() => isLoadingVehicles = true);
    try {
      final data = await VehicleService.getVehicles();
      vehicles = data ?? [];

      if (vehicles.isNotEmpty) {
        final v = Map<String, dynamic>.from(vehicles.first);
        selectedVehicleLabel =
            '${v['brand']} ${v['model']} ${v['plate_number']}';
        selectedVehicleId = v['id']?.toString();
        if (selectedVehicleId != null) {
          _loadTransactionsForVehicle(selectedVehicleId!);
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('$e')));
    } finally {
      setState(() => isLoadingVehicles = false);
    }
  }

  Future<void> _loadTransactionsForVehicle(String vehicleId) async {
    setState(() {
      isLoadingTransactions = true;
      transactions = [];
    });

    try {
      final data =
          await BookingService.getTransactionsByVehicle(vehicleId);
      final txs = data is List ? data : [];

      double totalPayment = 0;
      DateTime? latestDate;
      String customer = '';

      for (var t in txs) {
        if (t is Map) {
          if (customer.isEmpty && t['customer_name'] != null) {
            customer = t['customer_name'];
          }
          totalPayment +=
              double.tryParse(t['total_cost']?.toString() ?? '0') ?? 0;
          if (t['start_date'] != null) {
            final d = DateTime.tryParse(t['start_date']);
            if (d != null &&
                (latestDate == null || d.isAfter(latestDate))) {
              latestDate = d;
            }
          }
        }
      }

      setState(() {
        transactions = txs;
        summaryCustomer = customer;
        summaryTotalTrips = txs.length;
        summaryTotalPayment = totalPayment;
        summaryDate = latestDate != null
            ? DateFormat('dd/MM/yyyy').format(latestDate)
            : '';
      });
    } catch (e) {
      transactionError = e.toString();
    } finally {
      setState(() => isLoadingTransactions = false);
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
          onPressed: () =>
              Navigator.pushReplacementNamed(context, '/actual'),
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
                BoxShadow(color: Colors.black12, blurRadius: 4),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.directions_bus),
                    const SizedBox(width: 12),
                    Text(
                      selectedVehicleLabel,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                Icon(isDropdownOpen
                    ? Icons.keyboard_arrow_up
                    : Icons.keyboard_arrow_down),
              ],
            ),
          ),
        ),
        if (isDropdownOpen)
          Container(
            margin: const EdgeInsets.only(top: 6),
            constraints: const BoxConstraints(maxHeight: 300),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: const [
                BoxShadow(color: Colors.black26, blurRadius: 6),
              ],
            ),
            child: vehicles.isEmpty
                ? const Padding(
                    padding: EdgeInsets.all(16),
                    child: Text('Tidak ada kendaraan'),
                  )
                : SingleChildScrollView(
                    child: Column(
                      children: vehicles.map((raw) {
                        final v = Map<String, dynamic>.from(raw);
                        final label =
                            '${v['brand']} ${v['model']} ${v['plate_number']}';
                        final id = v['id']?.toString();
                        return InkWell(
                          onTap: () {
                            setState(() {
                              selectedVehicleLabel = label;
                              selectedVehicleId = id;
                              isDropdownOpen = false;
                            });
                            if (id != null) {
                              _loadTransactionsForVehicle(id);
                            }
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Row(
                              children: [
                                const Icon(Icons.directions_bus, size: 18),
                                const SizedBox(width: 10),
                                Text(label),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ),
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
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 15,
              ),
            ),
            const SizedBox(height: 8),
            const Divider(height: 1, color: Colors.black12),
            const SizedBox(height: 8),
            Text("Customer: ${summaryCustomer.isNotEmpty ? summaryCustomer : '—'}"),
            Text("Total Trip: $summaryTotalTrips"),
            Text("Total Payment: Rp ${NumberFormat.currency(locale: 'id', symbol: '', decimalDigits: 0).format(summaryTotalPayment)}"),
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
    final customer = (tx is Map && tx['customer_name'] != null) ? tx['customer_name'].toString() : '—';
    final totalPayment = (tx is Map && tx['total_cost'] != null)
        ? double.tryParse(tx['total_cost'].toString()) ?? 0.0
        : 0.0;
    final dateStr = (tx is Map && (tx['start_date'] ?? tx['created_at']) != null)
        ? (() {
            try {
              return DateFormat('dd/MM/yyyy').format(DateTime.parse((tx['start_date'] ?? tx['created_at']).toString()));
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
            "Report #${index}",
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 15,
            ),
          ),
          const SizedBox(height: 8),
          const Divider(height: 1, color: Colors.black12),
          const SizedBox(height: 8),
          Text("Customer: $customer"),
          const Text("Total Trip: 1"),
          Text("Total Payment: Rp ${NumberFormat.currency(locale: 'id', symbol: '', decimalDigits: 0).format(totalPayment)}"),
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
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Container(
            padding: const EdgeInsets.all(20),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Trip Report Form", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  const SizedBox(height: 10),
                  _buildInputField("Transaction", "Input Transaction ID", transactionIdController),
                  if (isLoadingTransactions) const Padding(padding: EdgeInsets.only(top: 8.0), child: Text('Memuat transaksi...')),
                  if (transactionError != null) Padding(padding: const EdgeInsets.only(top: 8.0), child: Text('Transaksi: ${transactionError!}', style: const TextStyle(color: Colors.red))),
                  const SizedBox(height: 6),
                  _buildInputField("KM Start", "Input Data", kmStartController),
                  _buildInputField("KM End", "Input Data", kmEndController),
                  _buildInputField("Driver Fee", "Input Total", driverFeeController),
                  _buildInputField("Gasoline", "Input Amount", gasolineController),
                  _buildInputField("Destination / Notes", "Input Destination atau catatan", destinationController),
                  _buildInputField("Others (misc)", "Lainnya...", othersController),
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

  Widget _buildInputField(String label, String hint, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 6),
        TextField(controller: controller, decoration: InputDecoration(hintText: hint, filled: true, fillColor: const Color(0xFFEDEDED), border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none))),
      ]),
    );
  }

  Future<void> _saveReport(BuildContext context) async {
    final rawTransaction = transactionIdController.text.trim();
    if (rawTransaction.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Masukkan transaction id terlebih dahulu')));
      return;
    }

    final transactionId = int.tryParse(rawTransaction);
    if (transactionId == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Transaction id tidak valid')));
      return;
    }

    final kmStart = int.tryParse(kmStartController.text.trim());
    final kmEnd = int.tryParse(kmEndController.text.trim());
    final driverFee = double.tryParse(driverFeeController.text.trim()) ?? 0;
    final gasolineCost = double.tryParse(gasolineController.text.trim()) ?? 0;
    final miscCost = double.tryParse(othersController.text.trim()) ?? 0;
    final totalOperational = driverFee + gasolineCost + miscCost;

    if (!mounted) return;
    showDialog(context: context, barrierDismissible: false, builder: (_) => const Center(child: CircularProgressIndicator()));

    // verify transaction exists to avoid FK violation
    try {
      final tx = await BookingService.getTransactionById(transactionId);
      if (tx == null || (tx is Map && (tx['id'] == null))) {
        if (mounted) Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Transaction tidak ditemukan di server')));
        return;
      }
    } catch (e) {
      if (mounted) Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Gagal memverifikasi transaction: $e')));
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
      if (response is Map && response['message'] is String) message = response['message'] as String;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
      // clear
      transactionIdController.clear();
      kmStartController.clear();
      kmEndController.clear();
      driverFeeController.clear();
      gasolineController.clear();
      destinationController.clear();
      othersController.clear();
      // refresh transactions for selected vehicle
      if (selectedVehicleId != null && selectedVehicleId!.isNotEmpty) {
        _loadTransactionsForVehicle(selectedVehicleId!);
      }
    } catch (e) {
      if (mounted) Navigator.of(context).pop();
      final preview = e.toString();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Gagal menyimpan report: $preview')));
    }
  }
}
