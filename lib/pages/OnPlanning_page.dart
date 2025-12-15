import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/transaction_models.dart';
import '../models/vehicle_models.dart';
import '../services/transaction_service.dart';
import '../services/vehicle_service.dart';
import '../widgets/bottom_navbar.dart';

class OnPlanningPage extends StatefulWidget {
  const OnPlanningPage({super.key});

  @override
  State<OnPlanningPage> createState() => _OnPlanningPageState();
}

class _OnPlanningPageState extends State<OnPlanningPage> {
  bool isDropdownOpen = false;
  bool _isLoadingVehicles = false;
  bool _isLoadingTransactions = false;
  String? _vehicleError;
  String? _transactionError;
  VehicleModel? _selectedVehicle;
  List<VehicleModel> _vehicles = [];
  List<TransactionModel> _transactions = [];

  final NumberFormat _currencyFormat = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 0,
  );

  final TextEditingController _dateController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadVehicles();
  }

  @override
  void dispose() {
    _dateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F3F3),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        title: const Text(
          "On Planning",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
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
            Expanded(child: _buildTransactionSection()),
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
              Navigator.pushReplacementNamed(context, '/actual');
              break;
            case 2:
              Navigator.pushReplacementNamed(context, '/report');
              break;
          }
        },
      ),
    );
  }

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
            child: Column(
              children:
                  _vehicles.map((vehicle) {
                    final isSelected = vehicle.id == _selectedVehicle?.id;
                    return InkWell(
                      onTap: () {
                        setState(() {
                          _selectedVehicle = vehicle;
                          isDropdownOpen = false;
                        });
                        _loadTransactions();
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

  Widget _buildTransactionSection() {
    if (_selectedVehicle == null) {
      return _buildPlaceholder(
        icon: Icons.directions_bus,
        message: 'Pilih kendaraan untuk melihat transaksi planning.',
      );
    }

    if (_isLoadingTransactions) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_transactionError != null) {
      return _buildPlaceholder(
        icon: Icons.error_outline,
        message: _transactionError!,
        messageColor: Colors.redAccent,
      );
    }

    if (_transactions.isEmpty) {
      return _buildPlaceholder(
        icon: Icons.receipt_long,
        message: 'Belum ada transaksi planning untuk kendaraan ini.',
      );
    }

    return ListView.builder(
      padding: EdgeInsets.zero,
      itemCount: _transactions.length,
      itemBuilder:
          (context, index) =>
              _buildTripCard(context, _transactions[index], index),
    );
  }

  Future<void> _loadVehicles() async {
    setState(() {
      _isLoadingVehicles = true;
      _vehicleError = null;
      _transactions = [];
      _transactionError = null;
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
        await _loadTransactions();
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoadingVehicles = false;
        _vehicleError = e.toString();
        _transactions = [];
      });
    }
  }

  Future<void> _loadTransactions() async {
    final vehicleId = _selectedVehicle?.id;
    if (vehicleId == null) {
      setState(() {
        _transactions = [];
        _transactionError = null;
        _isLoadingTransactions = false;
      });
      return;
    }

    setState(() {
      _isLoadingTransactions = true;
      _transactionError = null;
    });

    try {
      final items = await TransactionService.getTransactions(
        status: 'planning',
        vehicleId: vehicleId,
      );
      if (!mounted) return;
      setState(() {
        _transactions = items;
        _isLoadingTransactions = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoadingTransactions = false;
        _transactionError = e.toString();
        _transactions = [];
      });
    }
  }

  String _vehicleLabel(VehicleModel vehicle) {
    final pieces = [
      if (vehicle.brand != null && vehicle.brand!.isNotEmpty) vehicle.brand!,
      if (vehicle.model != null && vehicle.model!.isNotEmpty) vehicle.model!,
      vehicle.plateNumber,
    ];
    return pieces.join(' ').trim();
  }

  Widget _buildPlaceholder({
    required IconData icon,
    required String message,
    Color messageColor = Colors.black54,
  }) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 48, color: Colors.black26),
          const SizedBox(height: 12),
          Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(color: messageColor),
          ),
        ],
      ),
    );
  }

  String _tripSchedule(TransactionModel transaction) {
    final start = transaction.formattedStartDate;
    final end = transaction.formattedEndDate;

    if (start != null && end != null) {
      return '$start - $end';
    }

    return start ?? end ?? '-';
  }

  String _formatCurrency(double? value) {
    final amount = value ?? 0;
    return _currencyFormat.format(amount);
  }

  Widget _buildTripCard(
    BuildContext context,
    TransactionModel transaction,
    int index,
  ) {
    final schedule = _tripSchedule(transaction);
    final duration =
        transaction.durationDays != null
            ? '${transaction.durationDays} hari'
            : '-';
    final totalText = _formatCurrency(transaction.totalCost);

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
          Row(
            children: [
              Text(
                'Trip #${index + 1} - ${transaction.tripCode}',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(transaction.customerName, style: const TextStyle(fontSize: 14)),
          const SizedBox(height: 8),
          Text('Jadwal: $schedule'),
          Text('Trip(s): $duration'),
          Text('Total: $totalText'),
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
                _showPaymentDialog(context, transaction);
              },
              child: const Text(
                "PAYMENT",
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

  void _showPaymentDialog(BuildContext context, TransactionModel transaction) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
              surface: Colors.white,
              primary: Colors.black,
            ),
            dialogBackgroundColor: Colors.white,
          ),
          child: AlertDialog(
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            contentPadding: const EdgeInsets.all(16),
            content: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Payment Details",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Trip: ${transaction.tripCode}',
                    style: const TextStyle(color: Colors.black54),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Customer: ${transaction.customerName}',
                    style: const TextStyle(color: Colors.black54),
                  ),
                  const SizedBox(height: 12),

                  // Payment Amount
                  const Text(
                    "Payment Amount",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  TextField(
                    decoration: InputDecoration(
                      hintText: "Input Total",
                      filled: true,
                      fillColor: Colors.grey[200],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 10),

                  // Payment Method
                  const Text(
                    "Payment Method",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  TextField(
                    decoration: InputDecoration(
                      hintText: "Select Payment Method",
                      filled: true,
                      fillColor: Colors.grey[200],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),

                  const Text(
                    "Payment Type",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: DropdownButtonFormField<String>(
                      dropdownColor: Colors.white,
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 4,
                        ),
                      ),
                      hint: const Text("Select Payment Type"),
                      items: const [
                        DropdownMenuItem(value: "Cash", child: Text("Cash")),
                        DropdownMenuItem(
                          value: "Transfer",
                          child: Text("Transfer"),
                        ),
                      ],
                      onChanged: (value) {},
                    ),
                  ),
                  const SizedBox(height: 10),

                  const Text(
                    "Date",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  TextField(
                    controller: _dateController,
                    readOnly: true,
                    decoration: InputDecoration(
                      hintText: "Select Date",
                      filled: true,
                      fillColor: Colors.grey[200],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    onTap: () async {
                      DateTime? picked = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime(2020),
                        lastDate: DateTime(2030),
                      );
                      if (picked != null) {
                        setState(() {
                          _dateController.text = DateFormat(
                            'dd/MM/yyyy',
                          ).format(picked);
                        });
                      }
                    },
                  ),
                  const SizedBox(height: 10),

                  // Note
                  const Text(
                    "Note",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  TextField(
                    maxLines: 4,
                    decoration: InputDecoration(
                      hintText: "Write notes here...",
                      filled: true,
                      fillColor: Colors.grey[200],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () => Navigator.pop(context),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.redAccent,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                          child: const Text("Back"),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.pop(context);
                            Navigator.pushReplacementNamed(
                              this.context,
                              '/OnPlanningPage',
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.teal,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                          child: const Text("Submit"),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
