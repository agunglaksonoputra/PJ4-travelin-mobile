import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/vehicle_models.dart';
import '../utils/currency_input_utils.dart';
import '../widgets/bottom_navbar.dart';
import '../widgets/vehicle_dropdown.dart';
import 'package:travelin/services/bookings_service.dart';
import 'package:travelin/services/report_service.dart';

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

  bool _isFormattingDriverFee = false;
  bool _isFormattingGasoline = false;
  bool _isFormattingOthers = false;

  final NumberFormat _currencyFormat = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 0,
  );

  @override
  void initState() {
    super.initState();
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

  Widget _buildReportCard(BuildContext context, int index) {
    // index 0 = summary card
    if (index == 0) {
      final summaryTripCode =
          transactions.isNotEmpty && transactions.first is Map
              ? (() {
                final first = transactions.first as Map;
                final code = first['trip_code'] ?? first['tripCode'];
                return code?.toString();
              })()
              : null;

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
              "Report ${summaryTripCode?.isNotEmpty == true ? summaryTripCode : 'Summary'}",
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
            "Report ${tripCode?.isNotEmpty == true ? tripCode : '#$index'}",
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
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    onChanged: (value) {
                      if (_isFormattingDriverFee) return;

                      final result = formatCurrencyInput(
                        value,
                        _currencyFormat,
                      );

                      if (!result.shouldUpdateText) return;

                      _isFormattingDriverFee = true;

                      if (result.shouldClear) {
                        driverFeeController.clear();
                      } else if (result.isOverride &&
                          result.formattedValue != null) {
                        final currentOffset =
                            driverFeeController.selection.baseOffset;
                        final oldLength = driverFeeController.text.length;
                        final newText = result.formattedValue!;
                        final newLength = newText.length;
                        final diff = newLength - oldLength;
                        final newOffset = (currentOffset + diff).clamp(
                          0,
                          newLength,
                        );

                        driverFeeController
                            .value = driverFeeController.value.copyWith(
                          text: newText,
                          selection: TextSelection.collapsed(offset: newOffset),
                        );
                      }

                      _isFormattingDriverFee = false;
                    },
                  ),
                  _buildInputField(
                    "Gasoline",
                    "Input Amount",
                    gasolineController,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    onChanged: (value) {
                      if (_isFormattingGasoline) return;

                      final result = formatCurrencyInput(
                        value,
                        _currencyFormat,
                      );

                      if (!result.shouldUpdateText) return;

                      _isFormattingGasoline = true;

                      if (result.shouldClear) {
                        gasolineController.clear();
                      } else if (result.isOverride &&
                          result.formattedValue != null) {
                        final currentOffset =
                            gasolineController.selection.baseOffset;
                        final oldLength = gasolineController.text.length;
                        final newText = result.formattedValue!;
                        final newLength = newText.length;
                        final diff = newLength - oldLength;
                        final newOffset = (currentOffset + diff).clamp(
                          0,
                          newLength,
                        );

                        gasolineController
                            .value = gasolineController.value.copyWith(
                          text: newText,
                          selection: TextSelection.collapsed(offset: newOffset),
                        );
                      }

                      _isFormattingGasoline = false;
                    },
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
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    onChanged: (value) {
                      if (_isFormattingOthers) return;

                      final result = formatCurrencyInput(
                        value,
                        _currencyFormat,
                      );

                      if (!result.shouldUpdateText) return;

                      _isFormattingOthers = true;

                      if (result.shouldClear) {
                        othersController.clear();
                      } else if (result.isOverride &&
                          result.formattedValue != null) {
                        final currentOffset =
                            othersController.selection.baseOffset;
                        final oldLength = othersController.text.length;
                        final newText = result.formattedValue!;
                        final newLength = newText.length;
                        final diff = newLength - oldLength;
                        final newOffset = (currentOffset + diff).clamp(
                          0,
                          newLength,
                        );

                        othersController
                            .value = othersController.value.copyWith(
                          text: newText,
                          selection: TextSelection.collapsed(offset: newOffset),
                        );
                      }

                      _isFormattingOthers = false;
                    },
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
    TextEditingController controller, {
    void Function(String)? onChanged,
    TextInputType? keyboardType,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 6),
          TextField(
            controller: controller,
            keyboardType: keyboardType,
            onChanged: onChanged,
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

    final driverFeeDigits = driverFeeController.text.trim().replaceAll(
      RegExp(r'[^0-9]'),
      '',
    );
    final gasolineDigits = gasolineController.text.trim().replaceAll(
      RegExp(r'[^0-9]'),
      '',
    );
    final miscDigits = othersController.text.trim().replaceAll(
      RegExp(r'[^0-9]'),
      '',
    );

    final driverFee = double.tryParse(driverFeeDigits) ?? 0;
    final gasolineCost = double.tryParse(gasolineDigits) ?? 0;
    final miscCost = double.tryParse(miscDigits) ?? 0;
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
