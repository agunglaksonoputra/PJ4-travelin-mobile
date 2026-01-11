import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:travelin/utils/currency_utils.dart';
import 'package:travelin/utils/format_string.dart';

import '../../models/cashflow/monthly_transaction_detail_model.dart';
import '../../services/transaction_service.dart';
import '../../utils/format_month.dart';

enum TransactionDetailType {
  report,
  actual,
}

class TransactionDetailPage extends StatefulWidget {
  final TransactionDetailType? type;

  const TransactionDetailPage({
    super.key,
    this.type = TransactionDetailType.report
  });

  @override
  State<TransactionDetailPage> createState() => _TransactionDetailPageState();
}

class _TransactionDetailPageState extends State<TransactionDetailPage> {
  MonthlyTransactionDetail? transaction;

  bool _loading = false;
  String? _error;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (transaction != null || _loading) return;

    final args = ModalRoute.of(context)?.settings.arguments;

    // =============================
    // REPORT MODE (pakai arguments)
    // =============================
    if (widget.type == TransactionDetailType.report) {
      if (args is MonthlyTransactionDetail) {
        setState(() {
          transaction = args;
        });
      }
      return;
    }

    // =============================
    // ACTUAL MODE (fetch API)
    // =============================
    if (widget.type == TransactionDetailType.actual) {
      if (args is Map && args['transactionId'] != null) {
        final transactionId = args['transactionId'] as int;
        _loadTransactionDetail(transactionId);
      }
    }
  }

  Future<void> _loadTransactionDetail(int transactionId) async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final result = await TransactionService.getMonthlyTransactionDetail(transactionId);

      if (!mounted) return;
      setState(() {
        transaction = result;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = e.toString();
      });
    }
  }

  @override
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
          "Detail Transaksi",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
        ),
        leading: IconButton(
          icon: const Icon(FontAwesomeIcons.angleLeft, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: _contentSection(),
      ),
    );
  }

  Widget _contentSection() {
    // 🔵 Loading
    if (_loading) {
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

    // 🟡 Data belum ada
    if (transaction == null) {
      return _centeredPlaceholder(
        icon: Icons.receipt_long,
        text: 'Data transaksi tidak tersedia',
      );
    }

    // ✅ DATA AMAN
    final tx = transaction!;
    final statusColor = tx.isClosed ? Colors.green : Colors.orange;

    return SingleChildScrollView(
      child: Column(
        children: [
          // HEADER CARD
          Container(
            width: double.infinity,
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  statusColor.withOpacity(0.8),
                  statusColor,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: statusColor.withOpacity(0.3),
                  blurRadius: 15,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: FaIcon(
                    tx.isClosed
                        ? FontAwesomeIcons.circleCheck
                        : FontAwesomeIcons.clock,
                    color: Colors.white,
                    size: 40,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  tx.tripCode,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.25),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    tx.status.toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // INFORMASI UTAMA
          _buildSection(
            title: "Informasi Utama",
            icon: FontAwesomeIcons.circleInfo,
            color: Colors.blue,
            children: [
              _infoCard(
                icon: FontAwesomeIcons.user,
                label: "Customer",
                value: tx.customerName,
                color: Colors.blue,
              ),
              _infoCard(
                icon: FontAwesomeIcons.phone,
                label: "Telepon",
                value: tx.customerPhone ?? "-",
                color: Colors.green,
              ),
              _infoCard(
                icon: FontAwesomeIcons.car,
                label: "Kendaraan",
                value: tx.vehicle ?? "-",
                color: Colors.orange,
              ),
              _infoCard(
                icon: FontAwesomeIcons.locationDot,
                label: "Tujuan",
                value: tx.destination ?? "-",
                color: Colors.red,
              ),
            ],
          ),

          // KEUANGAN
          _buildSection(
            title: "Ringkasan Keuangan",
            icon: FontAwesomeIcons.wallet,
            color: Colors.green,
            children: [
              _financialCard(
                icon: FontAwesomeIcons.moneyBillWave,
                label: "Total Dibayar",
                value: CurrencyUtils.format(tx.paidAmount),
                color: Colors.green,
                isLarge: true,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _financialCard(
                      icon: FontAwesomeIcons.clockRotateLeft,
                      label: "Sisa Tagihan",
                      value: CurrencyUtils.format(tx.outstandingAmount),
                      color: Colors.orange,
                      isCompact: true,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _financialCard(
                      icon: FontAwesomeIcons.fileInvoiceDollar,
                      label: "Biaya Ops",
                      value: CurrencyUtils.format(tx.operationalCost),
                      color: Colors.red,
                      isCompact: true,
                    ),
                  ),
                ],
              ),
            ],
          ),

          // RIWAYAT PEMBAYARAN
          _buildSection(
            title: "Riwayat Pembayaran",
            icon: FontAwesomeIcons.clockRotateLeft,
            color: Colors.purple,
            children: [
              if (tx.payments.isEmpty)
                _centeredPlaceholder(
                  icon: FontAwesomeIcons.fileInvoice,
                  text: "Belum ada pembayaran",
                )
              else
                ...tx.payments.map(_paymentCard),
            ],
          ),

          const SizedBox(height: 24),
        ],
      ),
    );
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

  Widget _buildSection({
    required String title,
    required IconData icon,
    required Color color,
    required List<Widget> children,
  }) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: FaIcon(
                  icon,
                  size: 18,
                  color: color,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }

  Widget _infoCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: FaIcon(
              icon,
              size: 20,
              color: color,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.2,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _financialCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
    bool isLarge = false,
    bool isCompact = false,
  }) {
    return Container(
      padding: EdgeInsets.all(isCompact ? 14 : 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: color.withOpacity(0.2),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: isCompact
          ? Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FaIcon(
            icon,
            size: 20,
            color: color,
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: color,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      )
          : Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: FaIcon(
              icon,
              size: isLarge ? 24 : 20,
              color: color,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: isLarge ? 18 : 16,
                    fontWeight: FontWeight.bold,
                    color: color,
                    letterSpacing: 0.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _paymentCard(payment) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const FaIcon(
              FontAwesomeIcons.checkDouble,
              size: 20,
              color: Colors.green,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  CurrencyUtils.format(payment.amount),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    FaIcon(
                      FontAwesomeIcons.creditCard,
                      size: 11,
                      color: Colors.grey[500],
                    ),
                    const SizedBox(width: 6),
                    Text(
                      FormatString.format(payment.method),
                      // payment.method,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              FaIcon(
                FontAwesomeIcons.calendar,
                size: 12,
                color: Colors.grey[500],
              ),
              const SizedBox(height: 4),
              Text(
                formatDate2(payment.paidAt),
                // formatDate(payment.paidAt),
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}