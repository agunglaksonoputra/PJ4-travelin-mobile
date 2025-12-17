import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../utils/currency_input_utils.dart';
import '../../../services/report_service.dart';
import '../../../utils/validator/OnReport/report_validator.dart';

class ReportDialog extends StatefulWidget {
  final dynamic transaction;
  final VoidCallback onReportSuccess;

  const ReportDialog({
    super.key,
    required this.transaction,
    required this.onReportSuccess,
  });

  @override
  State<ReportDialog> createState() => _ReportDialogState();
}

class _ReportDialogState extends State<ReportDialog> {
  late final TextEditingController driverNameController;
  late final TextEditingController kmStartController;
  late final TextEditingController kmEndController;
  late final TextEditingController driverFeeController;
  late final TextEditingController gasolineController;
  late final TextEditingController tollCostController;
  late final TextEditingController parkingCostController;
  late final TextEditingController othersController;
  late final TextEditingController notesController;

  bool _isFormattingDriverFee = false;
  bool _isFormattingGasoline = false;
  bool _isFormattingToll = false;
  bool _isFormattingParking = false;
  bool _isFormattingOthers = false;
  bool _isSubmitting = false;

  String? _driverNameError;
  String? _kmStartError;
  String? _kmEndError;
  String? _driverFeeError;
  String? _gasolineError;
  String? _tollCostError;
  String? _parkingCostError;
  String? _othersError;

  final NumberFormat _currencyFormat = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 0,
  );

  @override
  void initState() {
    super.initState();
    driverNameController = TextEditingController();
    kmStartController = TextEditingController();
    kmEndController = TextEditingController();
    driverFeeController = TextEditingController();
    gasolineController = TextEditingController();
    tollCostController = TextEditingController();
    parkingCostController = TextEditingController();
    othersController = TextEditingController();
    notesController = TextEditingController();
  }

  @override
  void dispose() {
    driverNameController.dispose();
    kmStartController.dispose();
    kmEndController.dispose();
    driverFeeController.dispose();
    gasolineController.dispose();
    tollCostController.dispose();
    parkingCostController.dispose();
    othersController.dispose();
    notesController.dispose();
    super.dispose();
  }

  Future<void> _saveReport() async {
    if (_isSubmitting) return;

    if (widget.transaction == null ||
        widget.transaction is! Map ||
        widget.transaction['id'] == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Transaction data tidak valid')),
      );
      return;
    }

    final transactionId = int.tryParse(widget.transaction['id'].toString());
    if (transactionId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Transaction ID tidak valid')),
      );
      return;
    }

    final driverName = driverNameController.text.trim();
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
    final tollDigits = tollCostController.text.trim().replaceAll(
      RegExp(r'[^0-9]'),
      '',
    );
    final parkingDigits = parkingCostController.text.trim().replaceAll(
      RegExp(r'[^0-9]'),
      '',
    );
    final miscDigits = othersController.text.trim().replaceAll(
      RegExp(r'[^0-9]'),
      '',
    );

    final driverFee = double.tryParse(driverFeeDigits) ?? 0;
    final gasolineCost = double.tryParse(gasolineDigits) ?? 0;
    final tollCost = double.tryParse(tollDigits) ?? 0;
    final parkingCost = double.tryParse(parkingDigits) ?? 0;
    final miscCost = double.tryParse(miscDigits) ?? 0;

    // Validate form using ReportValidator
    final validationResult = ReportValidator.validateReportForm(
      driverName: driverName,
      kmStart: kmStart,
      kmEnd: kmEnd,
      driverFee: driverFee,
      gasoline: gasolineCost,
      tollCost: tollCost,
      parkingCost: parkingCost,
      others: miscCost,
    );

    if (!validationResult.isValid) {
      setState(() {
        _driverNameError = validationResult.driverNameError;
        _kmStartError = validationResult.kmStartError;
        _kmEndError = validationResult.kmEndError;
        _driverFeeError = validationResult.driverFeeError;
        _gasolineError = validationResult.gasolineError;
        _tollCostError = validationResult.tollCostError;
        _parkingCostError = validationResult.parkingCostError;
        _othersError = validationResult.othersError;
      });
      return;
    }

    // Clear errors on successful validation
    setState(() {
      _isSubmitting = true;
      _driverNameError = null;
      _kmStartError = null;
      _kmEndError = null;
      _driverFeeError = null;
      _gasolineError = null;
      _tollCostError = null;
      _parkingCostError = null;
      _othersError = null;
    });

    final totalOperational =
        driverFee + gasolineCost + tollCost + parkingCost + miscCost;

    if (!mounted) return;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    final payload = <String, dynamic>{
      'transaction_id': transactionId,
      'report_date': DateFormat('yyyy-MM-dd').format(DateTime.now()),
      'driver_name': driverName,
      'km_start': kmStart,
      'km_end': kmEnd,
      'driver_fee': driverFee,
      'gasoline_cost': gasolineCost,
      'toll_cost': tollCost,
      'parking_cost': parkingCost,
      'misc_cost': miscCost,
      'notes': notesController.text.trim(),
      'total_operational_cost': totalOperational,
    };

    try {
      final response = await ReportService.createReport(payload);
      if (!mounted) return;
      Navigator.of(context).pop(); // close loading
      Navigator.of(context).pop(); // close dialog

      String message = 'Report berhasil disimpan';
      if (response is Map && response['message'] is String) {
        message = response['message'] as String;
      }

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));

      widget.onReportSuccess();
    } catch (e) {
      if (mounted) Navigator.of(context).pop();
      setState(() => _isSubmitting = false);

      final preview = e.toString();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal menyimpan report: $preview')),
      );
    }
  }

  Widget _buildInputField(
    String label,
    String hint,
    TextEditingController controller, {
    void Function(String)? onChanged,
    TextInputType? keyboardType,
    String? errorText,
    int? maxLines,
    String? suffixText,
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
            maxLines: maxLines ?? 1,
            onChanged: onChanged,
            decoration: InputDecoration(
              hintText: hint,
              suffixText: suffixText,
              filled: true,
              fillColor: Colors.grey[200],
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide.none,
              ),
              errorText: errorText,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final transactionId =
        (widget.transaction is Map && widget.transaction['id'] != null)
            ? widget.transaction['id'].toString()
            : '-';
    final tripCode =
        (widget.transaction is Map &&
                (widget.transaction['trip_code'] ??
                        widget.transaction['tripCode']) !=
                    null)
            ? (widget.transaction['trip_code'] ??
                    widget.transaction['tripCode'])
                .toString()
            : '-';
    final customer =
        (widget.transaction is Map &&
                widget.transaction['customer_name'] != null)
            ? widget.transaction['customer_name'].toString()
            : '-';

    return PopScope(
      canPop: !_isSubmitting,
      onPopInvoked: (didPop) {
        if (!didPop && _isSubmitting) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Sedang menyimpan report...')),
          );
        }
      },
      child: AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 16,
        ),
        content: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 440),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(),
                const SizedBox(height: 16),
                _buildTransactionInfo(transactionId, tripCode, customer),
                const SizedBox(height: 16),
                _buildInputField(
                  "Nama Driver",
                  "Masukkan nama driver",
                  driverNameController,
                  errorText: _driverNameError,
                ),
                _buildInputField(
                  "KM Awal",
                  "Masukkan KM awal",
                  kmStartController,
                  errorText: _kmStartError,
                  suffixText: "km",
                ),
                _buildInputField(
                  "KM Akhir",
                  "Masukkan KM akhir",
                  kmEndController,
                  errorText: _kmEndError,
                  suffixText: "km",
                ),
                _buildInputField(
                  "Biaya Driver",
                  "Input nominal",
                  driverFeeController,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  errorText: _driverFeeError,
                  onChanged: (value) {
                    if (_isFormattingDriverFee) return;

                    final result = formatCurrencyInput(value, _currencyFormat);

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
                  "Bensin",
                  "Input nominal",
                  gasolineController,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  errorText: _gasolineError,
                  onChanged: (value) {
                    if (_isFormattingGasoline) return;

                    final result = formatCurrencyInput(value, _currencyFormat);

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
                  "Biaya Tol",
                  "Input nominal",
                  tollCostController,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  errorText: _tollCostError,
                  onChanged: (value) {
                    if (_isFormattingToll) return;

                    final result = formatCurrencyInput(value, _currencyFormat);

                    if (!result.shouldUpdateText) return;

                    _isFormattingToll = true;

                    if (result.shouldClear) {
                      tollCostController.clear();
                    } else if (result.isOverride &&
                        result.formattedValue != null) {
                      final currentOffset =
                          tollCostController.selection.baseOffset;
                      final oldLength = tollCostController.text.length;
                      final newText = result.formattedValue!;
                      final newLength = newText.length;
                      final diff = newLength - oldLength;
                      final newOffset = (currentOffset + diff).clamp(
                        0,
                        newLength,
                      );

                      tollCostController
                          .value = tollCostController.value.copyWith(
                        text: newText,
                        selection: TextSelection.collapsed(offset: newOffset),
                      );
                    }

                    _isFormattingToll = false;
                  },
                ),
                _buildInputField(
                  "Biaya Parkir",
                  "Input nominal",
                  parkingCostController,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  errorText: _parkingCostError,
                  onChanged: (value) {
                    if (_isFormattingParking) return;

                    final result = formatCurrencyInput(value, _currencyFormat);

                    if (!result.shouldUpdateText) return;

                    _isFormattingParking = true;

                    if (result.shouldClear) {
                      parkingCostController.clear();
                    } else if (result.isOverride &&
                        result.formattedValue != null) {
                      final currentOffset =
                          parkingCostController.selection.baseOffset;
                      final oldLength = parkingCostController.text.length;
                      final newText = result.formattedValue!;
                      final newLength = newText.length;
                      final diff = newLength - oldLength;
                      final newOffset = (currentOffset + diff).clamp(
                        0,
                        newLength,
                      );

                      parkingCostController
                          .value = parkingCostController.value.copyWith(
                        text: newText,
                        selection: TextSelection.collapsed(offset: newOffset),
                      );
                    }

                    _isFormattingParking = false;
                  },
                ),
                _buildInputField(
                  "Biaya Lainnya",
                  "Input nominal",
                  othersController,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  errorText: _othersError,
                  onChanged: (value) {
                    if (_isFormattingOthers) return;

                    final result = formatCurrencyInput(value, _currencyFormat);

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

                      othersController.value = othersController.value.copyWith(
                        text: newText,
                        selection: TextSelection.collapsed(offset: newOffset),
                      );
                    }

                    _isFormattingOthers = false;
                  },
                ),
                _buildInputField(
                  "Catatan",
                  "Masukkan catatan",
                  notesController,
                  maxLines: 4,
                ),
                const SizedBox(height: 20),
                _buildActionButtons(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return const Text(
      "Form Laporan Perjalanan",
      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
    );
  }

  Widget _buildTransactionInfo(
    String transactionId,
    String tripCode,
    String customer,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.blue.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.info_outline, size: 18, color: Colors.blue),
              const SizedBox(width: 8),
              const Text(
                "Info Transaksi",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text("ID: $transactionId", style: const TextStyle(fontSize: 13)),
          Text("Trip Code: $tripCode", style: const TextStyle(fontSize: 13)),
          Text("Customer: $customer", style: const TextStyle(fontSize: 13)),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: TextButton(
            onPressed: _isSubmitting ? null : () => Navigator.of(context).pop(),
            child: const Text("CANCEL"),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton(
            onPressed: _isSubmitting ? null : _saveReport,
            child:
                _isSubmitting
                    ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                    : const Text("SAVE"),
          ),
        ),
      ],
    );
  }
}
