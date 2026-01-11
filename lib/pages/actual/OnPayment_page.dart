import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:travelin/widgets/form/payment_dialog.dart';

import '../../helper/bottom_nav_controller.dart';
import '../../models/transaction_models.dart';
import '../../models/vehicle_models.dart';
import '../../services/transaction_service.dart';
import '../../utils/auth_helper.dart';
import '../../widgets/bottom_navbar.dart';
import '../../widgets/custom_flushbar.dart';
import '../../widgets/trip_card.dart';
import '../../widgets/vehicle_selector.dart';
import '../report/transaction_detail_page.dart';

class OnPaymentPage extends StatefulWidget {
  const OnPaymentPage({super.key});

  @override
  State<OnPaymentPage> createState() => _OnPaymentPageState();
}

class _OnPaymentPageState extends State<OnPaymentPage> {
  int selectedIndex = 1;

  bool _isLoading = false;
  String? _error;

  VehicleModel? selectedVehicle;
  List<VehicleModel> vehicleList = [];

  List<TransactionModel> _transactions = [];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final args = ModalRoute.of(context)?.settings.arguments;

    if (args is Map) {
      selectedVehicle ??= args['selectedVehicle'] as VehicleModel?;
      vehicleList = args['vehicleList'] as List<VehicleModel>;
    }

    if (selectedVehicle != null && _transactions.isEmpty) {
      _isLoading = true;
      _loadTransactions();
    }
  }

  Future<void> _loadTransactions() async {
    if (selectedVehicle == null) return;

    setState(() {
      _isLoading = true;
      _error = null;
      _transactions = [];
    });

    try {
      await Future.delayed(const Duration(milliseconds: 300));

      final items = await TransactionService.getTransactions(
        status: 'payment',
        vehicleId: selectedVehicle!.id,
      );

      if (!mounted) return;
      setState(() {
        _transactions = items;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _error = e.toString();
      });
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
          "On Payment",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
        ),
        leading: IconButton(
          icon: const Icon(FontAwesomeIcons.angleLeft, color: Colors.black),
          onPressed: () {
            Navigator.pop(context, selectedVehicle);
          },
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              VehicleSelector(
                selectedVehicle: selectedVehicle,
                vehicleList: vehicleList,
                onVehicleSelected: (vehicle) async {
                  if (vehicle.id == selectedVehicle?.id) return;

                  setState(() {
                    selectedVehicle = vehicle;
                  });

                  await _loadTransactions();
                },
              ),

              const SizedBox(height: 20),

              Expanded(
                child: RefreshIndicator(
                  onRefresh: _loadTransactions,
                  color: Colors.blue,
                  backgroundColor: Colors.white,
                  child: _buildTransactionList(),
                ),
              ),
            ],
          ),
        ),
      ),

      bottomNavigationBar: BottomNavBar(
        currentIndex: selectedIndex,
        role: AuthHelper.currentRole,
        onTap: onItemTapped,
      ),
    );
  }

  Widget _buildTransactionList() {
    // 🟡 Belum pilih kendaraan
    if (selectedVehicle == null) {
      return _centeredPlaceholder(
        icon: Icons.directions_bus,
        text: 'Pilih kendaraan untuk melihat transaksi.',
      );
    }

    // 🔵 Loading
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: Colors.blue),
      );
    }

    // 🔴 Error
    if (_error != null) {
      return _centeredPlaceholder(
        icon: Icons.error_outline,
        text: _error!,
        color: Colors.redAccent,
      );
    }

    // 🟣 Tidak ada transaksi
    if (_transactions.isEmpty) {
      return _centeredPlaceholder(
        icon: Icons.receipt_long,
        text: 'Belum ada transaksi planning.',
      );
    }

    // ✅ Ada data → tampilkan list
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: _transactions.map(
            (tx) => TripCard(
          transaction: tx,
          type: TripCardType.payment,
          onPayment: () => _showPaymentDialog(context, tx),
          onView: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const TransactionDetailPage(
                  type: TransactionDetailType.actual,
                ),
                settings: RouteSettings(
                  arguments: {
                    'transactionId': tx.id,
                  },
                ),
              ),
            );
          },
        ),
      ).toList(),
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
        borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
      ),
      builder: (dialogContext) {
        return PaymentDialog(
          transaction: transaction,
          type: PaymentDialogType.payment,
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

  Widget _centeredPlaceholder({
    required IconData icon,
    required String text,
    Color? color,
  }) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 48, color: color ?? Colors.black26),
          const SizedBox(height: 12),
          Text(
            text,
            textAlign: TextAlign.center,
            style: TextStyle(color: color ?? Colors.black54),
          ),
        ],
      ),
    );
  }

}

