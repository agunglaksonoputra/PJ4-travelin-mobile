import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/payment_models.dart';
import '../models/vehicle_models.dart';
import '../services/payment_service.dart';
import '../services/vehicle_service.dart';
import '../utils/auth_helper.dart';
import '../widgets/bottom_navbar.dart';
import '../widgets/custom_flushbar.dart';
import '../widgets/form/OnPayment/payment_dialog.dart';

class OnPaymentPage extends StatefulWidget {
  const OnPaymentPage({super.key});

  @override
  State<OnPaymentPage> createState() => _OnPaymentPageState();
}

class _OnPaymentPageState extends State<OnPaymentPage> {
  List<VehicleModel> _vehicles = [];
  VehicleModel? _selectedVehicle;
  List<_VehiclePaymentGroup> _paymentGroups = [];

  final NumberFormat _currencyFormat = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 2,
  );

  bool _isDropdownOpen = false;
  bool _isLoadingVehicles = false;
  bool _isLoadingPayments = false;
  String? _vehicleError;
  String? _paymentsError;

  @override
  void initState() {
    super.initState();
    _loadVehicles();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F3F3),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'On Payment',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pushReplacementNamed(context, '/actual'),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.black),
            onPressed: _refresh,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildVehicleDropdown(),
            const SizedBox(height: 20),
            Expanded(child: _buildPaymentsSection()),
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
    if (_isLoadingVehicles) {
      return Container(
        height: 56,
        alignment: Alignment.center,
        decoration: _dropdownDecoration(),
        child: const CircularProgressIndicator(),
      );
    }

    if (_vehicleError != null) {
      return _StatusBanner(
        icon: Icons.error_outline,
        message: _vehicleError!,
        backgroundColor: Colors.white,
        textColor: Colors.redAccent,
      );
    }

    if (_vehicles.isEmpty) {
      return _StatusBanner(
        icon: Icons.directions_bus,
        message: 'Tidak ada kendaraan tersedia',
        backgroundColor: Colors.white,
        textColor: Colors.black87,
      );
    }

    final selected = _selectedVehicle;
    final selectedLabel =
        selected != null ? _vehicleLabel(selected) : 'Pilih kendaraan';

    return Column(
      children: [
        GestureDetector(
          onTap: () => setState(() => _isDropdownOpen = !_isDropdownOpen),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: _dropdownDecoration(),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.directions_bus, color: Colors.black),
                    const SizedBox(width: 8),
                    Text(
                      selectedLabel,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
                Icon(
                  _isDropdownOpen
                      ? Icons.keyboard_arrow_up
                      : Icons.keyboard_arrow_down,
                  color: Colors.black,
                ),
              ],
            ),
          ),
        ),
        if (_isDropdownOpen)
          Container(
            margin: const EdgeInsets.only(top: 6),
            padding: const EdgeInsets.symmetric(vertical: 8),
            decoration: _dropdownDecoration(shadowStrength: 0.18),
            child: Column(
              children:
                  _vehicles.map((vehicle) {
                    final isSelected = vehicle.id == selected?.id;
                    final label = _vehicleLabel(vehicle);
                    return InkWell(
                      onTap: () {
                        setState(() {
                          _selectedVehicle = vehicle;
                          _isDropdownOpen = false;
                        });
                        _loadPayments(vehicle.id);
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
                              color: Colors.black87,
                              size: 18,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              label,
                              style: TextStyle(
                                color:
                                    isSelected
                                        ? Colors.lightBlue
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

  Widget _buildPaymentsSection() {
    if (_isLoadingPayments) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_paymentsError != null) {
      return _StatusBanner(
        icon: Icons.error_outline,
        message: _paymentsError!,
        backgroundColor: Colors.white,
        textColor: Colors.redAccent,
      );
    }

    if (_paymentGroups.isEmpty) {
      return _StatusBanner(
        icon: Icons.receipt_long,
        message:
            _selectedVehicle == null
                ? 'Pilih kendaraan untuk melihat pembayaran'
                : 'Belum ada pembayaran untuk kendaraan ini',
        backgroundColor: Colors.white,
        textColor: Colors.black87,
      );
    }

    return ListView.separated(
      itemCount: _paymentGroups.length,
      separatorBuilder: (_, __) => const SizedBox(height: 16),
      itemBuilder:
          (context, index) => _buildPaymentCard(_paymentGroups[index], index),
    );
  }

  Widget _buildPaymentCard(_VehiclePaymentGroup group, int index) {
    final summary = group.transaction;
    final tripLabel =
        summary?.tripCode?.isNotEmpty == true
            ? summary!.tripCode
            : '#${group.transactionId}';
    final title = '$tripLabel';
    final customerName =
        summary?.customerName?.isNotEmpty == true ? summary!.customerName : '-';
    final totalCost = summary?.totalCost;
    final totalPaid = group.totalPaid;
    final remaining = group.remainingAmount;
    final latest = group.latestPayment;
    final latestDate = _formatDate(latest?.paidAt);
    final isPaidOff = remaining != null && remaining <= 0;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 5, offset: Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Customer: $customerName',
            style: const TextStyle(color: Colors.black87),
          ),
          const Divider(height: 20, thickness: 1, color: Colors.black12),
          if (totalCost != null) Text('Total: ${_formatCurrency(totalCost)}'),
          Text('Dibayar: ${_formatCurrency(totalPaid)}'),
          if (remaining != null)
            Text(
              'Sisa Hutang: ${_formatCurrency(remaining)}',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          Text('Pembayaran terakhir: $latestDate'),
          if (latest?.method != null)
            Text('Metode: ${latest!.method.toUpperCase()}'),
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
                  onPressed: () => _showPaymentDetailDialog(group),
                  child: const Text(
                    'DETAIL',
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
                    backgroundColor:
                        isPaidOff ? Colors.grey[400] : Colors.lightBlue,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  onPressed:
                      isPaidOff ? null : () => _showCreatePaymentDialog(group),
                  child: Text(
                    isPaidOff ? 'LUNAS' : 'PAYMENT',
                    style: const TextStyle(
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

  Future<void> _loadVehicles() async {
    setState(() {
      _isLoadingVehicles = true;
      _vehicleError = null;
    });

    try {
      final vehicles = await VehicleService.getVehicles();
      if (!mounted) return;

      VehicleModel? selected = _selectedVehicle;
      if (vehicles.isNotEmpty) {
        if (selected != null) {
          selected = vehicles.firstWhere(
            (vehicle) => vehicle.id == selected!.id,
            orElse: () => vehicles.first,
          );
        } else {
          selected = vehicles.first;
        }
      } else {
        selected = null;
      }

      setState(() {
        _vehicles = vehicles;
        _selectedVehicle = selected;
        _isLoadingVehicles = false;
      });

      if (selected != null) {
        await _loadPayments(selected.id);
      } else {
        setState(() {
          _paymentGroups = [];
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoadingVehicles = false;
        _vehicleError = e.toString();
        _vehicles = [];
        _selectedVehicle = null;
        _paymentGroups = [];
      });
      _showErrorFlushbar(e.toString());
    }
  }

  Future<void> _loadPayments(int vehicleId) async {
    setState(() {
      _isLoadingPayments = true;
      _paymentsError = null;
    });

    try {
      final payments = await PaymentService.getPaymentsByVehicleId(vehicleId);
      if (!mounted) return;

      setState(() {
        _paymentGroups = _groupPaymentsByTransaction(payments);
        _isLoadingPayments = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoadingPayments = false;
        _paymentsError = e.toString();
        _paymentGroups = [];
      });
      _showErrorFlushbar(e.toString());
    }
  }

  Future<void> _refresh() async {
    if (_selectedVehicle == null) {
      await _loadVehicles();
    } else {
      await _loadPayments(_selectedVehicle!.id);
    }
  }

  void _showPaymentDetailDialog(_VehiclePaymentGroup group) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        final summary = group.transaction;
        final title =
            summary?.tripCode?.isNotEmpty == true
                ? 'Trip ${summary!.tripCode}'
                : 'Transaksi #${group.transactionId}';
        final totalPaid = group.totalPaid;
        final remaining = group.remainingAmount;
        final totalCost = summary?.totalCost;

        return AlertDialog(
          backgroundColor: const Color(0xFFF3F3F3),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          contentPadding: const EdgeInsets.all(16),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Payment Detail',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Colors.black,
                      ),
                    ),
                    Text(
                      title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                const Divider(color: Colors.black12),
                for (var i = 0; i < group.payments.length; i++) ...[
                  Text(
                    'Payment ${i + 1}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Amount:',
                        style: TextStyle(color: Colors.black87),
                      ),
                      Text(
                        _formatCurrency(group.payments[i].amount),
                        style: const TextStyle(color: Colors.black),
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Date:',
                        style: TextStyle(color: Colors.black87),
                      ),
                      Text(
                        _formatDate(group.payments[i].paidAt),
                        style: const TextStyle(color: Colors.black),
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Method:',
                        style: TextStyle(color: Colors.black87),
                      ),
                      Text(
                        group.payments[i].method.toUpperCase(),
                        style: const TextStyle(color: Colors.black),
                      ),
                    ],
                  ),
                  if (group.payments[i].note != null &&
                      group.payments[i].note!.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        'Note: ${group.payments[i].note}',
                        style: const TextStyle(color: Colors.black54),
                      ),
                    ),
                  const SizedBox(height: 12),
                ],
                const Divider(color: Colors.black12),
                if (totalCost != null)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Total',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      Text(
                        _formatCurrency(totalCost),
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Paid',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    Text(
                      _formatCurrency(totalPaid),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
                if (remaining != null)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Remaining',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      Text(
                        _formatCurrency(remaining),
                        style: const TextStyle(
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
                        horizontal: 24,
                        vertical: 10,
                      ),
                    ),
                    child: const Text(
                      'OK',
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

  Future<void> _showCreatePaymentDialog(_VehiclePaymentGroup group) async {
    final result = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      enableDrag: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder:
          (_) => PaymentDialog(
            transactionId: group.transactionId,
            remainingAmount: group.remainingAmount,
            onPaymentSuccess: () async {
              final selectedVehicle = _selectedVehicle;
              if (selectedVehicle != null) {
                await _loadPayments(selectedVehicle.id);
              }
            },
          ),
    );

    if (result == true && mounted) {
      _showSuccessFlushbar('Pembayaran berhasil ditambahkan');
    }
  }

  List<_VehiclePaymentGroup> _groupPaymentsByTransaction(
    List<PaymentModel> payments,
  ) {
    final map = <int, List<PaymentModel>>{};

    for (final payment in payments) {
      map.putIfAbsent(payment.transactionId, () => []).add(payment);
    }

    final groups =
        map.entries.map((entry) {
          final sorted = [...entry.value]..sort((a, b) {
            final aDate = a.paidAt ?? DateTime.fromMillisecondsSinceEpoch(0);
            final bDate = b.paidAt ?? DateTime.fromMillisecondsSinceEpoch(0);
            return bDate.compareTo(aDate);
          });

          final summary =
              sorted
                  .firstWhere(
                    (payment) => payment.transaction != null,
                    orElse: () => sorted.first,
                  )
                  .transaction;

          return _VehiclePaymentGroup(
            transactionId: entry.key,
            transaction: summary,
            payments: sorted,
          );
        }).toList();

    groups.sort((a, b) {
      final aDate =
          a.latestPayment?.paidAt ?? DateTime.fromMillisecondsSinceEpoch(0);
      final bDate =
          b.latestPayment?.paidAt ?? DateTime.fromMillisecondsSinceEpoch(0);
      return bDate.compareTo(aDate);
    });

    return groups;
  }

  BoxDecoration _dropdownDecoration({double shadowStrength = 0.12}) {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(shadowStrength),
          blurRadius: 6,
          offset: const Offset(0, 3),
        ),
      ],
    );
  }

  String _vehicleLabel(VehicleModel vehicle) {
    final buffer = StringBuffer(vehicle.plateNumber);
    if (vehicle.brand != null && vehicle.brand!.isNotEmpty) {
      buffer.write(' • ${vehicle.brand}');
    }
    if (vehicle.model != null && vehicle.model!.isNotEmpty) {
      buffer.write(' ${vehicle.model}');
    }
    return buffer.toString();
  }

  String _formatCurrency(double? amount) {
    if (amount == null) return '-';
    return _currencyFormat.format(amount);
  }

  String _formatDate(DateTime? date) {
    if (date == null) return '-';
    final local = date.toLocal();
    final day = local.day.toString().padLeft(2, '0');
    final month = local.month.toString().padLeft(2, '0');
    final year = local.year.toString();
    return '$day/$month/$year';
  }

  void _showErrorFlushbar(String message) {
    CustomFlushbar.show(context, message: message, type: FlushbarType.error);
  }

  void _showSuccessFlushbar(String message) {
    CustomFlushbar.show(context, message: message, type: FlushbarType.success);
  }
}

class _VehiclePaymentGroup {
  _VehiclePaymentGroup({
    required this.transactionId,
    required this.payments,
    this.transaction,
  });

  final int transactionId;
  final List<PaymentModel> payments;
  final TransactionSummary? transaction;

  double get totalPaid =>
      transaction?.paidAmount ??
      payments.fold(0, (sum, payment) => sum + payment.amount);

  double? get remainingAmount {
    final outstanding = transaction?.outstandingAmount;
    if (outstanding != null) {
      return outstanding < 0 ? 0 : outstanding;
    }

    final total = transaction?.totalCost;
    if (total == null) return null;
    final remaining = total - totalPaid;
    return remaining < 0 ? 0 : remaining;
  }

  PaymentModel? get latestPayment =>
      payments.isNotEmpty ? payments.first : null;
}

class _StatusBanner extends StatelessWidget {
  const _StatusBanner({
    required this.icon,
    required this.message,
    required this.backgroundColor,
    required this.textColor,
  });

  final IconData icon;
  final String message;
  final Color backgroundColor;
  final Color textColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 5, offset: Offset(0, 2)),
        ],
      ),
      child: Row(
        children: [
          Icon(icon, color: textColor),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: TextStyle(color: textColor, fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }
}
