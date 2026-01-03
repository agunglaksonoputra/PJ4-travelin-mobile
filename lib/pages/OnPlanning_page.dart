import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../utils/auth_helper.dart';
import '../widgets/custom_flushbar.dart';
import '../models/tariff_model.dart';
import '../models/transaction_models.dart';
import '../models/vehicle_models.dart';
import '../services/transaction_service.dart';
import '../widgets/bottom_navbar.dart';
import '../widgets/form/OnPlanning/payment_dialog.dart';
import '../widgets/tariff_dropdown.dart';
import '../widgets/vehicle_dropdown.dart';

class OnPlanningPage extends StatefulWidget {
  const OnPlanningPage({super.key});

  @override
  State<OnPlanningPage> createState() => _OnPlanningPageState();
}

class _OnPlanningPageState extends State<OnPlanningPage> {
  bool _isLoadingTransactions = false;
  String? _transactionError;
  VehicleModel? _selectedVehicle;
  TariffModel? _selectedTariff;
  List<TransactionModel> _transactions = [];

  final NumberFormat _currencyFormat = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 2,
  );

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
            const SizedBox(height: 12),
            _buildTariffDropdown(),
            const SizedBox(height: 20),
            Expanded(child: _buildTransactionSection()),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavBar(
        currentIndex: 1,
        role: AuthHelper.currentRole,
        onTap: (index) {
          switch (index) {
            case 0:
              Navigator.pushReplacementNamed(context, '/home');
              break;
            case 1:
            // already on actual
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
    return VehicleDropdown(
      showLabel: false,
      initialVehicle: _selectedVehicle,
      onChanged: (vehicle) {
        setState(() {
          _selectedVehicle = vehicle;
          _transactions = [];
          _transactionError = null;
        });
        _loadTransactions();
      },
    );
  }

  Widget _buildTariffDropdown() {
    return TariffDropdown(
      showLabel: false,
      hintText: 'Filter tarif',
      includeAllItem: true,
      initialTariff: _selectedTariff,
      onChanged: (tariff) {
        setState(() {
          _selectedTariff = tariff;
          _transactions = [];
          _transactionError = null;
        });
        if (_selectedVehicle != null) {
          _loadTransactions();
        }
      },
      onCleared: () {
        if (_selectedTariff == null) return;
        setState(() {
          _selectedTariff = null;
          _transactions = [];
          _transactionError = null;
        });
        if (_selectedVehicle != null) {
          _loadTransactions();
        }
      },
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

    final tariffId = _selectedTariff?.id;

    setState(() {
      _isLoadingTransactions = true;
      _transactionError = null;
    });

    try {
      final items = await TransactionService.getTransactions(
        status: 'planning',
        vehicleId: vehicleId,
        tariffId: tariffId,
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
    BuildContext _,
    TransactionModel transaction,
    int index,
  ) {
    final schedule = _tripSchedule(transaction);
    final duration =
        transaction.durationDays != null
            ? '${transaction.durationDays} hari'
            : '-';
    final totalText = _formatCurrency(transaction.totalCost);
    final double paidAmount = transaction.paidAmount ?? 0;
    final bool hasAnyPayment = paidAmount > 0;

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
                transaction.tripCode,
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
                backgroundColor: hasAnyPayment ? Colors.grey : Colors.lightBlue,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              onPressed:
                  hasAnyPayment
                      ? null
                      : () => _showPaymentDialog(context, transaction),
              child: Text(
                hasAnyPayment ? 'PAYMENT RECORDED' : 'PAYMENT',
                style: const TextStyle(
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

  Future<void> _showPaymentDialog(
    BuildContext context,
    TransactionModel transaction,
  ) async {
    final result = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      isDismissible: true,
      enableDrag: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (dialogContext) {
        return PaymentDialog(
          transaction: transaction,
          onPaymentSuccess: _loadTransactions,
        );
      },
    );

    if (result == true && mounted) {
      CustomFlushbar.show(
        context,
        message: 'Payment plan updated',
        type: FlushbarType.success,
      );
    }
  }
}
