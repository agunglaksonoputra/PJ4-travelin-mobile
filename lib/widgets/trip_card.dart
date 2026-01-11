import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:travelin/utils/currency_utils.dart';
import 'package:travelin/utils/format_month.dart';
import 'package:travelin/widgets/button/primary_button.dart';
import '../../models/transaction_models.dart';

enum TripCardType {
  planning,
  payment,
  report,
  closed,
}

class TripCard extends StatelessWidget {
  final TransactionModel transaction;
  final TripCardType type;

  final VoidCallback? onPayment;
  final VoidCallback? onView;
  final VoidCallback? onReport;

  const TripCard({
    super.key,
    required this.transaction,
    required this.type,
    this.onPayment,
    this.onView,
    this.onReport,
  });

  String get _schedule =>
      '${formatDate2(transaction.startDate)} - ${formatDate2(transaction.endDate)}';

  String get _duration =>
      transaction.durationDays != null ? '${transaction.durationDays} hari' : '-';

  String get _total =>
      CurrencyUtils.formatCurrencyInDouble(transaction.totalCost);

  String get _paid =>
      CurrencyUtils.formatCurrencyInDouble(transaction.paidAmount);

  String get _remaining {
    final total = transaction.totalCost ?? 0;
    final paid = transaction.paidAmount ?? 0;
    return CurrencyUtils.formatCurrencyInDouble(total - paid);
  }

  @override
  Widget build(BuildContext context) {

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.blue.shade100,
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.lightBlue,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.blue.withOpacity(0.3),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Text(
                  transaction.tripCode,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: Colors.white,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(
                FontAwesomeIcons.user,
                size: 18,
                color: Colors.blue.shade700,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  transaction.customerName,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          const Divider(height: 1),
          const SizedBox(height: 14),
          _buildInfoSection(),
          const SizedBox(height: 18),
          _buildActionButton(),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value, {bool isTotal = false}) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: Colors.blue.shade50,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            size: 16,
            color: Colors.blue.shade700,
          ),
        ),
        const SizedBox(width: 10),
        Text(
          '$label: ',
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey.shade700,
            fontWeight: FontWeight.w500,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.w600,
              color: isTotal ? Colors.green.shade700 : Colors.grey.shade800,
            ),
            textAlign: TextAlign.right,
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton() {
    switch (type) {
      case TripCardType.planning:
        return Container(
          width: double.infinity,
          child: PrimaryButton(
            label: 'Payment',
            icon: FontAwesomeIcons.creditCard,
            onPressed: onPayment,
          ),
        );

      case TripCardType.payment:
        return Container(
          width: double.infinity,
          child: PrimaryButton(
            label: 'VIEW PAYMENT',
            icon: FontAwesomeIcons.moneyBillWave,
            onPressed: onView,
          ),
        );

      case TripCardType.report:
        return Container(
          width: double.infinity,
          child: PrimaryButton(
            label: 'VIEW REPORT',
            icon: FontAwesomeIcons.fileLines,
            onPressed: onReport,
          ),
        );

      case TripCardType.closed:
        return const SizedBox.shrink();
    }
  }

  Widget _buildInfoSection() {
    switch (type) {
      case TripCardType.planning:
        return _planningInfo();

      case TripCardType.payment:
        return _paymentInfo();

      case TripCardType.report:
        return _reportInfo();

      case TripCardType.closed:
        return _closedInfo();
    }
  }

  Widget _planningInfo() {
    return Column(
      children: [
        _buildInfoRow(FontAwesomeIcons.calendarDay, 'Jadwal', _schedule),
        const SizedBox(height: 8),
        _buildInfoRow(FontAwesomeIcons.clock, 'Trip(s)', _duration),
        const SizedBox(height: 8),
        _buildInfoRow(FontAwesomeIcons.wallet, 'Total', _total,
            isTotal: true),
      ],
    );
  }

  Widget _paymentInfo() {
    return Column(
      children: [
        _buildInfoRow(FontAwesomeIcons.calendarDay, 'Jadwal', _schedule),
        const SizedBox(height: 8),
        _buildInfoRow(FontAwesomeIcons.clock, 'Trip(s)', _duration),
        const SizedBox(height: 8),
        _buildInfoRow(FontAwesomeIcons.wallet, 'Total', _total,
            isTotal: true),
      ],
    );
  }

  Widget _reportInfo() {
    return Column(
      children: [
        _buildInfoRow(FontAwesomeIcons.calendarDay, 'Jadwal', _schedule),
        const SizedBox(height: 8),
        _buildInfoRow(FontAwesomeIcons.clock, 'Trip(s)', _duration),
        const SizedBox(height: 8),
        _buildInfoRow(FontAwesomeIcons.wallet, 'Total', _total,
            isTotal: true),
      ],
    );
  }

  Widget _closedInfo() {
    return Column(
      children: [
        _buildInfoRow(FontAwesomeIcons.calendarDay, 'Jadwal', _schedule),
        const SizedBox(height: 8),
        _buildInfoRow(FontAwesomeIcons.clock, 'Trip(s)', _duration),
        const SizedBox(height: 8),
        _buildInfoRow(FontAwesomeIcons.wallet, 'Total', _total,
            isTotal: true),
      ],
    );
  }

}
