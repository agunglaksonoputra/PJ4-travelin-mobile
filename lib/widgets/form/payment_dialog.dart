import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:travelin/models/transaction_models.dart';
import 'package:travelin/services/payment_service.dart';
import 'package:travelin/utils/app_logger.dart';
import 'package:travelin/utils/currency_utils.dart';
import 'package:travelin/widgets/button/primary_button.dart';
import 'package:travelin/widgets/date_input_field.dart';

import '../../utils/format_month.dart';
import '../custom_flushbar.dart';
import '../custom_input_field.dart';

enum PaymentDialogType  {
  planning,
  payment
}

class PaymentDialog extends StatefulWidget {
  final TransactionModel transaction;
  final double? remainingAmount;
  final VoidCallback onPaymentSuccess;
  final PaymentDialogType type;

  const PaymentDialog({
    super.key,
    required this.transaction,
    this.remainingAmount,
    required this.onPaymentSuccess,
    this.type = PaymentDialogType.planning,
  });

  @override
  State<PaymentDialog> createState() => _PaymentDialogState();
}

class _PaymentDialogState extends State<PaymentDialog> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _amountController;
  late final TextEditingController _noteController;
  late final TextEditingController _paymentDate;

  bool _isFormattingAmount = false;
  bool _isSubmitting = false;
  String _selectedMethod = 'transfer';
  String? _amountError;
  String? _methodError;

  final TextStyle _labelStyle = TextStyle(
    fontWeight: FontWeight.bold,
    fontSize: 14,
  );

  final TextStyle _infoStyle = const TextStyle(
    color: Colors.black,
    fontSize: 12,
  );

  @override
  void initState() {
    super.initState();
    _amountController = TextEditingController();
    _noteController = TextEditingController();
    _paymentDate = TextEditingController();
  }

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    _paymentDate.dispose();
    super.dispose();
  }

  double _parseAmount() {
    return double.parse(
      _amountController.text.replaceAll(RegExp(r'[^0-9]'), ''),
    );
  }

  Future<void> _handleSubmit() async {
    final isValid = _formKey.currentState!.validate();
    if (!isValid) return;

    final amount = _parseAmount();
    final note = _noteController.text.trim();

    setState(() {
      _isSubmitting = true;
    });

    try {
      await PaymentService.createPayment(
        transactionId: widget.transaction.id,
        amount: amount,
        method: _selectedMethod,
        paidAt: safeDateForApi(_paymentDate.text),
        note: note.isEmpty ? null : note,
      );

      if (!mounted) return;

      widget.onPaymentSuccess();
      Navigator.of(context).pop(true);
    } catch (e, stackTrace) {
      AppLogger.e('Failed to create payment', error: e, stackTrace: stackTrace);

      CustomFlushbar.show(
        context,
        message: "Gagal menyimpan pembayaran",
        type: FlushbarType.error,
      );

      if (!mounted) return;
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  double get _maxPayableAmount {
    if (widget.type == PaymentDialogType.payment) {
      return widget.transaction.outstandingAmount ?? 0;
    }
    return widget.transaction.totalCost ?? 0;
  }

  @override
  Widget build(BuildContext context) {


    return SafeArea(
      child: Padding(
        padding: EdgeInsets.fromLTRB(20, 16, 20, 16),
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildDragHandle(),
                const SizedBox(height: 12),

                const Text(
                  "Detail Kendaraan",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),

                _buildInfoSection(),
                // _infoTransaction(widget.transaction),
                const SizedBox(height: 12),

                _buildAmountField(widget.transaction),
                const SizedBox(height: 12),

                _buildMethodField(),
                const SizedBox(height: 12),

                CustomInputField(
                  label: "Tanggal pembayaran",
                  icon: FontAwesomeIcons.calendarDay,
                  hint: "Masukkan tanggal pembayaran",
                  controller: _paymentDate,
                  type: InputFieldType.date,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Tanggal pembayaran wajib diisi';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),

                _buildNoteField(),
                const SizedBox(height: 12),

                SizedBox(
                  width: double.infinity,
                  child: PrimaryButton(
                    label: 'Simpan',
                    isLoading: _isSubmitting,
                    onPressed: _isSubmitting ? null : _handleSubmit,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDragHandle() {
    return Center(
      child: Container(
        width: 40,
        height: 4,
        decoration: BoxDecoration(
          color: Colors.grey[300],
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    );
  }

  Widget _buildAmountField(TransactionModel transaction) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomInputField(
          label: 'Nominal Pembayaran',
          icon: FontAwesomeIcons.moneyBillWave,
          hint: 'Masukkan nominal pembayaran',
          controller: _amountController,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          inputFormatters: [],
          type: InputFieldType.currency,
          quickAmount: _maxPayableAmount,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Nominal pembayaran tidak boleh kosong';
            }

            final amount = double.tryParse(
              value.replaceAll(RegExp(r'[^0-9]'), ''),
            );

            if (amount == null || amount <= 0) {
              return 'Nominal pembayaran tidak valid';
            }

            if (amount > _maxPayableAmount) {
              return widget.type == PaymentDialogType.payment
                  ? 'Nominal melebihi sisa pembayaran'
                  : 'Nominal melebihi total transaksi';
            }

            return null;
          },
        ),

        if (widget.remainingAmount != null && widget.remainingAmount! > 0)
          Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Text(
              'Sisa Hutang: ${CurrencyUtils.formatCurrencyInDouble(widget.remainingAmount)}',
              style: _infoStyle,
            ),
          ),
      ],
    );
  }

  Widget _buildMethodField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Metode Pembayaran', style: _labelStyle,),
        const SizedBox(height: 6),

        _methodRadioTile(
          value: 'transfer',
          label: 'Transfer',
          icon: FontAwesomeIcons.buildingColumns,
        ),
        const SizedBox(height: 6),
        _methodRadioTile(
          value: 'cash',
          label: 'Cash',
          icon: FontAwesomeIcons.moneyBillWave,
        ),

        if (_methodError != null)
          Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Text(
              _methodError!,
              style: const TextStyle(
                color: Colors.red,
                fontSize: 12,
              ),
            ),
          ),
      ],
    );
  }

  Widget _methodRadioTile({
    required String value,
    required String label,
    required IconData icon,
  }) {

    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: _isSubmitting
          ? null
          : () {
        setState(() {
          _selectedMethod = value;
          _methodError = null;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Colors.grey.shade300,
            width: 1.5,
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 16,
              color: Colors.blue,
            ),
            const SizedBox(width: 12),

            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.black,
                ),
              ),
            ),

            Radio<String>(
              value: value,
              groupValue: _selectedMethod,
              // activeColor: Colors.blue,
              fillColor: MaterialStateProperty.resolveWith<Color>((states) {
                if (states.contains(MaterialState.selected)) {
                  return Colors.blue; // aktif
                }
                return Colors.grey.shade300; // tidak aktif
              }),
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              visualDensity: VisualDensity.compact,
              onChanged: _isSubmitting
                  ? null
                  : (val) {
                if (val != null) {
                  setState(() {
                    _selectedMethod = val;
                    _methodError = null;
                  });
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoteField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomInputField(
          label: 'Catatan (Opsional)',
          icon: FontAwesomeIcons.noteSticky,
          hint: 'Masukkan catatan',
          controller: _noteController,
          type: InputFieldType.note,
        ),
      ],
    );
  }

  // Widget _infoTransaction(TransactionModel transaction) {
  //   return Container(
  //     padding: const EdgeInsets.all(12),
  //     decoration: BoxDecoration(
  //       color: Colors.blue.shade50,
  //       borderRadius: BorderRadius.circular(12),
  //       border: Border.all(color: Colors.blue.shade200),
  //     ),
  //     child: Column(
  //       crossAxisAlignment: CrossAxisAlignment.start,
  //       children: [
  //         Row(
  //           children: [
  //             const Icon(
  //               FontAwesomeIcons.circleInfo,
  //               size: 18,
  //               color: Colors.blue,
  //             ),
  //             const SizedBox(width: 8),
  //             const Text(
  //               "Info Transaksi",
  //               style: TextStyle(fontWeight: FontWeight.bold),
  //             ),
  //           ],
  //         ),
  //         const SizedBox(height: 8),
  //         Text(
  //           "Total: ${CurrencyUtils.formatCurrencyInDouble(transaction.totalCost)}",
  //           style: const TextStyle(fontSize: 12),
  //         ),
  //       ],
  //     ),
  //   );
  // }

  Widget _buildInfoSection() {
    switch (widget.type) {
      case PaymentDialogType.planning:
        return _planningInfo(widget.transaction);
      case PaymentDialogType.payment:
        return _paymentInfo(widget.transaction);
    }
  }

  Widget _planningInfo(TransactionModel transaction) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                FontAwesomeIcons.circleInfo,
                size: 18,
                color: Colors.blue,
              ),
              const SizedBox(width: 8),
              const Text(
                "Info Transaksi",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            "Total: ${CurrencyUtils.formatCurrencyInDouble(transaction.totalCost)}",
            style: const TextStyle(fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _paymentInfo(TransactionModel transaction) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                FontAwesomeIcons.circleInfo,
                size: 18,
                color: Colors.blue,
              ),
              const SizedBox(width: 8),
              const Text(
                "Info Transaksi",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            "Dibayar: ${CurrencyUtils.formatCurrencyInDouble(transaction.paidAmount)}",
            style: const TextStyle(fontSize: 12),
          ),
          const SizedBox(height: 8),
          Text(
            "Sisa: ${CurrencyUtils.formatCurrencyInDouble(transaction.outstandingAmount)}",
            style: const TextStyle(fontSize: 12),
          ),
          const SizedBox(height: 8),
          Text(
            "Total: ${CurrencyUtils.formatCurrencyInDouble(transaction.totalCost)}",
            style: const TextStyle(fontSize: 12),
          ),
        ],
      ),
    );
  }

}
