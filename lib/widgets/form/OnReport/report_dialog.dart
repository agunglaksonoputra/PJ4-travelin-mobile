import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:travelin/models/transaction_report_model.dart';
import 'package:travelin/services/report_service.dart';
import 'package:travelin/utils/app_logger.dart';
import 'package:travelin/utils/format_month.dart';

import '../../../models/transaction_models.dart';
import '../../../utils/currency_utils.dart';
import '../../button/primary_button.dart';
import '../../custom_flushbar.dart';
import '../../custom_input_field.dart';

class ReportDialog extends StatefulWidget {

  final TransactionModel transaction;
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
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController reportDateController;
  late final TextEditingController driverNameController;
  late final TextEditingController kmStartController;
  late final TextEditingController kmEndController;
  late final TextEditingController driverFeeController;
  late final TextEditingController gasolineController;
  late final TextEditingController tollCostController;
  late final TextEditingController parkingCostController;
  late final TextEditingController othersController;
  late final TextEditingController noteController;

  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    reportDateController = TextEditingController();
    driverNameController = TextEditingController();
    kmStartController = TextEditingController();
    kmEndController = TextEditingController();
    driverFeeController = TextEditingController();
    gasolineController = TextEditingController();
    tollCostController = TextEditingController();
    parkingCostController = TextEditingController();
    othersController = TextEditingController();
    noteController = TextEditingController();
  }

  @override
  void dispose() {
    reportDateController.dispose();
    driverNameController.dispose();
    kmStartController.dispose();
    kmEndController.dispose();
    driverFeeController.dispose();
    gasolineController.dispose();
    tollCostController.dispose();
    parkingCostController.dispose();
    othersController.dispose();
    noteController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    final isValid = _formKey.currentState!.validate();
    if (!isValid) return;

    setState(() {
      _isSubmitting = true;
    });

    try {
      double _parseCurrency(String v) =>
          double.tryParse(v.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;

      final driverFee = _parseCurrency(driverFeeController.text);
      final gasoline = _parseCurrency(gasolineController.text);
      final toll = _parseCurrency(tollCostController.text);
      final parking = _parseCurrency(parkingCostController.text);
      final misc = _parseCurrency(othersController.text);

      final totalOperational =
          driverFee + gasoline + toll + parking + misc;

      final report = TransactionReport(
        transactionId: widget.transaction.id!,
        driverName: driverNameController.text.trim(),
        kmStart: int.tryParse(kmStartController.text) ?? 0,
        kmEnd: int.tryParse(kmEndController.text) ?? 0,
        driverFee: driverFee,
        gasolineCost: gasoline,
        tollCost: toll,
        parkingCost: parking,
        miscCost: misc,
        totalOperationalCost: totalOperational,
        notes: noteController.text.trim().isEmpty
            ? null
            : noteController.text.trim(),
        reportDate: safeParseDate(reportDateController.text),
      );

      final payload = report.toJson();

      AppLogger.d('REPORT PAYLOAD => $payload');

      await ReportService.createReport(payload);

      if (!mounted) return;

      widget.onReportSuccess();
      Navigator.of(context).pop(true);
    } catch (e, stackTrace) {
      AppLogger.e('Failed to create report', error: e, stackTrace: stackTrace);

      CustomFlushbar.show(
        context,
        message: "Gagal menyimpan report",
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

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding:  EdgeInsets.fromLTRB(20, 16, 20, 16),
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
                  "Form Report",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),

                _reportInfo(widget.transaction),
                const SizedBox(height: 12),

                CustomInputField(
                  label: "Nama Driver",
                  icon: FontAwesomeIcons.driversLicense,
                  hint: "Masukkan nama driver",
                  controller: driverNameController,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Wajib diisi';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),

                CustomInputField(
                  label: "Tanggal report",
                  icon: FontAwesomeIcons.calendarDay,
                  hint: "Masukkan tanggal report",
                  controller: reportDateController,
                  type: InputFieldType.date,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Wajib diisi';
                    }

                    return null;
                  },
                ),
                const SizedBox(height: 12),

                Row(
                  children: [
                    Expanded(
                      child: CustomInputField(
                        label: "KM Awal",
                        icon: FontAwesomeIcons.gaugeHigh,
                        hint: "KM awal",
                        keyboardType: TextInputType.number,
                        controller: kmStartController,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Wajib diisi';
                          }

                          final km = int.tryParse(value);
                          if (km == null || km < 0) {
                            return 'Tidak valid';
                          }

                          return null;
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: CustomInputField(
                        label: "KM Akhir",
                        icon: FontAwesomeIcons.gaugeHigh,
                        hint: "KM akhir",
                        keyboardType: TextInputType.number,
                        controller: kmEndController,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Wajib diisi';
                          }

                          final kmEnd = int.tryParse(value);
                          final kmStart = int.tryParse(kmStartController.text);

                          if (kmEnd == null || kmEnd < 0) {
                            return 'Tidak valid';
                          }

                          if (kmStart != null && kmEnd <= kmStart) {
                            return 'KM akhir harus lebih besar dari KM awal';
                          }

                          return null;
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                CustomInputField(
                  label: "Biaya Driver",
                  icon: FontAwesomeIcons.moneyBill1Wave,
                  hint: "Masukkan biaya driver",
                  type: InputFieldType.currency,
                  controller: driverFeeController,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Wajib diisi';
                    }

                    final digits = value.replaceAll(RegExp(r'[^0-9]'), '');
                    final amount = double.tryParse(digits);

                    if (amount == null || amount <= 0) {
                      return 'Harus lebih dari 0';
                    }

                    return null;

                  },
                ),
                const SizedBox(height: 12),

                CustomInputField(
                  label: "Biaya Bahan Bakar",
                  icon: FontAwesomeIcons.gasPump,
                  hint: "Masukkan biaya bahan bakar",
                  type: InputFieldType.currency,
                  controller: gasolineController,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Wajib diisi';
                    }

                    final digits = value.replaceAll(RegExp(r'[^0-9]'), '');
                    final amount = double.tryParse(digits);

                    if (amount == null || amount <= 0) {
                      return 'Harus lebih dari 0';
                    }

                    return null;

                  },
                ),
                const SizedBox(height: 12),

                CustomInputField(
                  label: "Biaya Tol (Opsional)",
                  icon: FontAwesomeIcons.gaugeHigh,
                  hint: "Masukkan biaya toll",
                  type: InputFieldType.currency,
                  controller: tollCostController,
                ),
                const SizedBox(height: 12),

                CustomInputField(
                  label: "Biaya Parkir (Opsional)",
                  icon: FontAwesomeIcons.gaugeHigh,
                  hint: "Masukkan biaya parkir",
                  type: InputFieldType.currency,
                  controller: parkingCostController,
                ),
                const SizedBox(height: 12),

                CustomInputField(
                  label: "Biaya Lainnya (Opsional)",
                  icon: FontAwesomeIcons.gaugeHigh,
                  hint: "Masukkan lainnya",
                  type: InputFieldType.currency,
                  controller: othersController,
                ),
                const SizedBox(height: 12),

                CustomInputField(
                  label: 'Catatan (Opsional)',
                  icon: FontAwesomeIcons.noteSticky,
                  hint: 'Masukkan catatan',
                  controller: noteController,
                  type: InputFieldType.note,
                ),
                const SizedBox(height: 12),

                SizedBox(
                  width: double.infinity,
                  child: PrimaryButton(
                    label: 'Simpan',
                    isLoading: _isSubmitting,
                    onPressed: _isSubmitting ? null : _handleSubmit,
                  ),
                ),
                const SizedBox(height: 12),
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

  Widget _reportInfo(TransactionModel transaction) {
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
}