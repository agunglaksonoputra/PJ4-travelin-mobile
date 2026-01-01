import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../../services/payment_service.dart';
import '../../../utils/currency_input_utils.dart';
import '../../../utils/validator/OnPayment/payment_validator.dart';
import '../../custom_flushbar.dart';

class PaymentDialog extends StatefulWidget {
  const PaymentDialog({
    super.key,
    required this.transactionId,
    this.remainingAmount,
    required this.onPaymentSuccess,
  });

  final int transactionId;
  final double? remainingAmount;
  final VoidCallback onPaymentSuccess;

  @override
  State<PaymentDialog> createState() => _PaymentDialogState();
}

class _PaymentDialogState extends State<PaymentDialog> {
  late final TextEditingController _amountController;
  late final TextEditingController _noteController;

  final NumberFormat _dialogCurrencyFormat = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 0,
  );

  bool _isFormattingAmount = false;
  bool _isSubmitting = false;
  String _selectedMethod = 'cash';
  String? _amountError;
  String? _methodError;

  final TextStyle _labelStyle = const TextStyle(
    fontWeight: FontWeight.bold,
    fontSize: 15,
  );
  final TextStyle _infoStyle = const TextStyle(
    color: Colors.black54,
    fontSize: 13,
  );

  @override
  void initState() {
    super.initState();
    _amountController = TextEditingController(
      text:
          widget.remainingAmount != null && widget.remainingAmount! > 0
              ? _dialogCurrencyFormat.format(widget.remainingAmount!)
              : '',
    );
    _noteController = TextEditingController();
  }

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  void _handleAmountChanged(String value) {
    if (_isFormattingAmount) return;

    final result = formatCurrencyInput(value, _dialogCurrencyFormat);

    if (result.shouldClear) {
      _isFormattingAmount = true;
      _amountController
        ..text = ''
        ..selection = const TextSelection.collapsed(offset: 0);
      _isFormattingAmount = false;
      setState(() => _amountError = null);
      return;
    }

    if (!result.shouldUpdateText) {
      setState(() => _amountError = null);
      return;
    }

    final formatted = result.formattedValue;
    if (formatted == null) {
      setState(() => _amountError = null);
      return;
    }

    _isFormattingAmount = true;
    _amountController
      ..text = formatted
      ..selection = TextSelection.collapsed(offset: formatted.length);
    _isFormattingAmount = false;
    setState(() => _amountError = null);
  }

  Future<void> _handleSubmit() async {
    if (_isSubmitting) return;

    final amountText = _amountController.text.trim();
    final amount = parseCurrencyToDouble(amountText);

    // Validate form using PaymentValidator
    final validationResult = PaymentValidator.validatePaymentForm(
      amount: amount,
      method: _selectedMethod,
      remainingBalance: widget.remainingAmount,
    );

    if (!validationResult.isValid) {
      setState(() {
        _amountError = validationResult.amountError;
        _methodError = validationResult.methodError;
      });
      return;
    }

    setState(() {
      _isSubmitting = true;
      _amountError = null;
      _methodError = null;
    });

    try {
      await PaymentService.createPayment(
        transactionId: widget.transactionId,
        amount: amount!,
        method: _selectedMethod,
        note:
            _noteController.text.trim().isEmpty
                ? null
                : _noteController.text.trim(),
      );

      if (!mounted) return;
      Navigator.of(context).pop(true);
      widget.onPaymentSuccess();
    } catch (error) {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }

      if (!mounted) return;
      CustomFlushbar.show(
        context,
        message: error.toString(),
        type: FlushbarType.error,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return PopScope(
      canPop: !_isSubmitting,
      onPopInvoked: (didPop) {
        if (!didPop && _isSubmitting) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Mohon tunggu, sedang memproses pembayaran...'),
              duration: Duration(seconds: 2),
            ),
          );
        }
      },
      child: Padding(
        padding: EdgeInsets.fromLTRB(20, 16, 20, bottomInset + 20),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              _buildHeader(),
              const SizedBox(height: 16),
              _buildAmountField(),
              const SizedBox(height: 16),
              _buildMethodField(),
              const SizedBox(height: 16),
              _buildNoteField(),
              const SizedBox(height: 20),
              _buildActionButtons(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return const Text(
      'Tambah Pembayaran',
      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
    );
  }

  Widget _buildAmountField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Nominal Pembayaran', style: _labelStyle),
        if (widget.remainingAmount != null && widget.remainingAmount! > 0)
          Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Text(
              'Sisa Hutang: Rp ${(widget.remainingAmount! / 1).toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (match) => '${match.group(1)}.')}',
              style: _infoStyle,
            ),
          ),
        const SizedBox(height: 6),
        TextField(
          controller: _amountController,
          decoration: InputDecoration(
            hintText: 'Masukkan nominal pembayaran',
            filled: true,
            fillColor: Colors.grey[200],
            prefixIcon: const Icon(FontAwesomeIcons.moneyBillWave),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide.none,
            ),
            errorText: _amountError,
          ),
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          onChanged: _handleAmountChanged,
        ),
      ],
    );
  }

  Widget _buildMethodField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Metode Pembayaran', style: _labelStyle),
        const SizedBox(height: 4),
        DropdownButtonFormField<String>(
          value: _selectedMethod,
          items: const [
            DropdownMenuItem(value: 'cash', child: Text('Cash')),
            DropdownMenuItem(value: 'transfer', child: Text('Transfer')),
          ],
          onChanged:
              _isSubmitting
                  ? null
                  : (value) {
                    if (value != null) {
                      setState(() {
                        _selectedMethod = value;
                        _methodError = null;
                      });
                    }
                  },
          dropdownColor: Colors.white,
          decoration: InputDecoration(
            hintText: 'Pilih metode pembayaran',
            filled: true,
            fillColor: Colors.grey[200],
            prefixIcon: const Icon(FontAwesomeIcons.wallet),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide.none,
            ),
            errorText: _methodError,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 4,
            ),
          ),
          isExpanded: true,
        ),
      ],
    );
  }

  Widget _buildNoteField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Catatan (Opsional)', style: _labelStyle),
        const SizedBox(height: 4),
        TextField(
          controller: _noteController,
          maxLines: 3,
          decoration: InputDecoration(
            hintText: 'Masukkan catatan',
            filled: true,
            fillColor: Colors.grey[200],
            prefixIcon: const Icon(FontAwesomeIcons.noteSticky),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide.none,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _isSubmitting ? null : _handleSubmit,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blue,
          disabledBackgroundColor: Colors.grey,
          padding: const EdgeInsets.symmetric(vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        child:
            _isSubmitting
                ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation(Colors.white),
                  ),
                )
                : const Text(
                  'SIMPAN',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
      ),
    );
  }
}
