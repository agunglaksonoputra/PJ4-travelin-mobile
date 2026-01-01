import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../../models/transaction_models.dart';
import '../../../services/transaction_service.dart';
import '../../../utils/currency_input_utils.dart';
import '../../../utils/validator/OnPlanning/payment_validator.dart';
import '../../custom_flushbar.dart';

class PaymentDialog extends StatefulWidget {
  final TransactionModel transaction;
  final VoidCallback onPaymentSuccess;

  const PaymentDialog({
    super.key,
    required this.transaction,
    required this.onPaymentSuccess,
  });

  @override
  State<PaymentDialog> createState() => _PaymentDialogState();
}

class _PaymentDialogState extends State<PaymentDialog> {
  late final TextEditingController _amountController;
  late final TextEditingController _dateController;
  late final TextEditingController _noteController;

  final NumberFormat _currencyFormat = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 2,
  );

  final NumberFormat _dialogCurrencyFormat = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 0,
  );

  bool _isFormattingAmount = false;
  String? _selectedMethod;
  String? _selectedPaymentType;
  String? _amountError;
  String? _methodError;
  String? _dateError;
  String? _paymentTypeError;
  bool _isSubmitting = false;

  final TextStyle _infoStyle = const TextStyle(
    color: Colors.black54,
    fontSize: 13,
  );

  double get _existingPaidAmount =>
      widget.transaction.paidAmount?.toDouble() ?? 0;
  double get _totalCost => widget.transaction.totalCost?.toDouble() ?? 0;
  double get _remainingBalance =>
      _totalCost > _existingPaidAmount ? _totalCost - _existingPaidAmount : 0.0;

  @override
  void initState() {
    super.initState();
    _amountController = TextEditingController();
    _dateController = TextEditingController();
    _noteController = TextEditingController();
    _selectedMethod = widget.transaction.paymentPlanMethod;
  }

  @override
  void dispose() {
    _amountController.dispose();
    _dateController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  String _formatCurrency(double? value) {
    final amount = value ?? 0;
    return _currencyFormat.format(amount);
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

  void _handleMethodChanged(String? value) {
    setState(() {
      _selectedMethod = value;
      _methodError = null;

      if (value == 'cash') {
        final double targetAmount =
            _remainingBalance > 0 ? _remainingBalance : _totalCost;
        if (targetAmount > 0) {
          _amountController.text =
              targetAmount % 1 == 0
                  ? targetAmount.toStringAsFixed(0)
                  : targetAmount.toStringAsFixed(2);
        } else {
          _amountController.clear();
        }
        _amountError = null;
      }
    });
  }

  Future<void> _handleDateTap() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      setState(() {
        _dateController.text = DateFormat('dd/MM/yyyy').format(picked);
        _dateError = null;
      });
    }
  }

  Future<void> _handleSubmit() async {
    // Prevent multiple submissions - check if already submitting
    if (_isSubmitting) return;

    final method = _selectedMethod;
    final amountText = _amountController.text.trim();
    final dateText = _dateController.text.trim();
    final parsedAmount = parseCurrencyToDouble(amountText);

    // Validate form using PaymentValidator
    final validationResult = PaymentValidator.validatePaymentForm(
      amount: parsedAmount,
      method: method,
      remainingBalance: _remainingBalance,
      dateText: dateText,
      paymentType: _selectedPaymentType,
    );

    if (!validationResult.isValid) {
      setState(() {
        _amountError = validationResult.amountError;
        _methodError = validationResult.methodError;
        _dateError = validationResult.dateError;
        _paymentTypeError = validationResult.paymentTypeError;
      });
      return;
    }

    setState(() {
      _isSubmitting = true;
      _amountError = null;
      _methodError = null;
      _dateError = null;
      _paymentTypeError = null;
    });

    try {
      final payload = <String, dynamic>{
        'payment_plan_method': method,
        'paid_amount': parsedAmount,
      };

      // Include optional dialog fields so backend can create TransactionPayment
      if (_selectedPaymentType != null && _selectedPaymentType!.isNotEmpty) {
        payload['payment_type'] = _selectedPaymentType!.toLowerCase();
      }

      if (dateText.isNotEmpty) {
        // Send as dd/MM/yyyy; backend handles parsing
        payload['paid_at'] = dateText;
      }

      if (_noteController.text.trim().isNotEmpty) {
        payload['note'] = _noteController.text.trim();
      }

      await TransactionService.setPaymentPlan(widget.transaction.id, payload);

      if (!mounted) return;

      Navigator.of(context).pop(true);
      widget.onPaymentSuccess();
    } catch (error) {
      // Only reset submitting state on error
      // On success, dialog is closed so no need to reset
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
              _buildTransactionInfo(),
              const SizedBox(height: 14),
              _buildAmountField(),
              const SizedBox(height: 12),
              _buildPaymentMethodField(),
              const SizedBox(height: 12),
              _buildPaymentTypeField(),
              const SizedBox(height: 12),
              _buildDateField(),
              const SizedBox(height: 12),
              _buildNoteField(),
              const SizedBox(height: 18),
              _buildActionButtons(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return const Text(
      "Detail Pembayaran",
      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
    );
  }

  Widget _buildTransactionInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Perjalanan: ${widget.transaction.tripCode}', style: _infoStyle),
        const SizedBox(height: 4),
        Text(
          'Pelanggan: ${widget.transaction.customerName}',
          style: _infoStyle,
        ),
      ],
    );
  }

  Widget _buildAmountField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Jumlah Pembayaran",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
        ),
        if (_existingPaidAmount > 0)
          Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Text(
              'Sudah dibayar: ${_formatCurrency(_existingPaidAmount)}',
              style: _infoStyle,
            ),
          ),
        if (_totalCost > 0)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              'Total Biaya: ${_formatCurrency(_totalCost)}',
              style: _infoStyle,
            ),
          ),
        const SizedBox(height: 6),
        TextField(
          controller: _amountController,
          decoration: InputDecoration(
            hintText: "Masukkan jumlah pembayaran",
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

  Widget _buildPaymentMethodField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Metode Pembayaran",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
        ),
        const SizedBox(height: 4),
        DropdownButtonFormField<String>(
          value: _selectedMethod,
          items: const [
            DropdownMenuItem(value: 'cash', child: Text('Cash')),
            DropdownMenuItem(value: 'credit', child: Text('Credit')),
          ],
          onChanged: _handleMethodChanged,
          dropdownColor: Colors.white,
          decoration: InputDecoration(
            hintText: "Pilih metode pembayaran",
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

  Widget _buildPaymentTypeField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Tipe Pembayaran",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
        ),
        const SizedBox(height: 4),
        Container(
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(10),
          ),
          child: DropdownButtonFormField<String>(
            value: _selectedPaymentType,
            dropdownColor: Colors.white,
            decoration: InputDecoration(
              border: InputBorder.none,
              prefixIcon: const Icon(FontAwesomeIcons.creditCard),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 12,
              ),
              errorText: _paymentTypeError,
            ),
            hint: const Text("Pilih tipe pembayaran"),
            items: const [
              DropdownMenuItem(value: "Cash", child: Text("Cash")),
              DropdownMenuItem(value: "Transfer", child: Text("Transfer")),
            ],
            onChanged: (value) {
              setState(() {
                _selectedPaymentType = value;
                _paymentTypeError = null;
              });
            },
            isExpanded: true,
          ),
        ),
      ],
    );
  }

  Widget _buildDateField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Tanggal Pembayaran",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
        ),
        const SizedBox(height: 4),
        TextField(
          controller: _dateController,
          readOnly: true,
          decoration: InputDecoration(
            hintText: "Pilih tanggal pembayaran",
            filled: true,
            fillColor: Colors.grey[200],
            prefixIcon: const Icon(FontAwesomeIcons.calendarDays),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide.none,
            ),
            errorText: _dateError,
          ),
          onTap: _handleDateTap,
        ),
      ],
    );
  }

  Widget _buildNoteField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Catatan (Opsional)",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
        ),
        const SizedBox(height: 4),
        TextField(
          controller: _noteController,
          maxLines: 4,
          decoration: InputDecoration(
            hintText: "Masukkan catatan",
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
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
                : const Text(
                  "SIMPAN",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
      ),
    );
  }
}
