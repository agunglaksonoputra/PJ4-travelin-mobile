import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:travelin/services/bookings_service.dart';
import 'package:travelin/widgets/custom_input_field.dart';

import '../models/tariff_model.dart';
import '../models/vehicle_models.dart';
import '../utils/currency_input_utils.dart';
import '../widgets/custom_flushbar.dart';
import '../widgets/date_input_field.dart';
import '../widgets/tariff_dropdown.dart';
import '../widgets/vehicle_dropdown.dart';

class ReservationPage extends StatefulWidget {
  const ReservationPage({super.key});

  @override
  State<ReservationPage> createState() => _ReservationPageState();
}

class _ReservationPageState extends State<ReservationPage> {
  final customerController = TextEditingController();
  final customerPhoneController = TextEditingController();
  final leaveDateController = TextEditingController();
  final returnDateController = TextEditingController();
  final tripCategoryController = TextEditingController();
  final destinationController = TextEditingController();
  final totalCostController = TextEditingController();
  final notesController = TextEditingController();

  final DateFormat _displayDateFormat = DateFormat('dd MMM yyyy');
  final DateFormat _payloadDateFormat = DateFormat('yyyy-MM-dd');
  final NumberFormat _currencyFormatter = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 0,
  );

  VehicleModel? _selectedVehicle;
  TariffModel? _selectedTariff;
  bool _isSubmitting = false;
  bool _totalCostOverridden = false;
  bool _settingTotalProgrammatically = false;
  int _tariffResetToken = 0;

  @override
  void initState() {
    super.initState();
    leaveDateController.addListener(_maybeRecalculateTotalCost);
    returnDateController.addListener(_maybeRecalculateTotalCost);
    totalCostController.addListener(_onTotalCostChangedManually);
  }

  @override
  void dispose() {
    leaveDateController.removeListener(_maybeRecalculateTotalCost);
    returnDateController.removeListener(_maybeRecalculateTotalCost);
    customerController.dispose();
    customerPhoneController.dispose();
    leaveDateController.dispose();
    returnDateController.dispose();
    tripCategoryController.dispose();
    destinationController.dispose();
    totalCostController
      ..removeListener(_onTotalCostChangedManually)
      ..dispose();
    notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F3F3),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        title: const Text(
          'Reservasi',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CustomInputField(
                label: 'Nama Pelanggan',
                icon: FontAwesomeIcons.user,
                hint: 'Masukkan nama pelanggan',
                controller: customerController,
              ),
              const SizedBox(height: 16),
              CustomInputField(
                label: 'Nomor Telepon',
                icon: FontAwesomeIcons.phone,
                hint: 'Masukkan nomor telepon',
                controller: customerPhoneController,
              ),
              const SizedBox(height: 16),
              VehicleDropdown(
                showLabel: true,
                label: 'Kendaraan',
                hintText: 'Pilih kendaraan',
                initialVehicle: _selectedVehicle,
                onChanged: (vehicle) {
                  setState(() {
                    _selectedVehicle = vehicle;
                  });
                },
              ),
              const SizedBox(height: 16),
              TariffDropdown(
                key: ValueKey<String>('tariff-dropdown-$_tariffResetToken'),
                showLabel: true,
                label: 'Tarif',
                hintText: 'Pilih tarif',
                initialTariff: _selectedTariff,
                includeAllItem: false,
                onChanged: (tariff) {
                  setState(() {
                    _selectedTariff = tariff;
                    _totalCostOverridden = false;
                  });
                  _maybeRecalculateTotalCost();
                },
              ),
              const SizedBox(height: 16),
              CustomInputField(
                label: 'Kategori Perjalanan',
                icon: FontAwesomeIcons.list,
                hint: 'Masukkan kategori perjalanan',
                controller: tripCategoryController,
              ),
              const SizedBox(height: 16),
              CustomInputField(
                label: 'Tujuan',
                icon: FontAwesomeIcons.locationDot,
                hint: 'Masukkan tujuan perjalanan',
                controller: destinationController,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: DateInputField(
                      label: 'Tanggal Berangkat',
                      hint: 'Pilih tanggal mulai',
                      controller: leaveDateController,
                      icon: FontAwesomeIcons.calendarDay,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: DateInputField(
                      label: 'Tanggal Kembali',
                      hint: 'Pilih tanggal selesai',
                      controller: returnDateController,
                      icon: FontAwesomeIcons.calendarCheck,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              CustomInputField(
                label: 'Total Biaya',
                icon: FontAwesomeIcons.calculator,
                hint: 'Dihitung otomatis atau isi manual',
                controller: totalCostController,
              ),
              const SizedBox(height: 16),
              CustomInputField(
                label: 'Catatan',
                icon: FontAwesomeIcons.noteSticky,
                hint: 'Catatan tambahan',
                controller: notesController,
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.lightBlue,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 40,
                      vertical: 14,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 2,
                  ),
                  onPressed: _isSubmitting ? null : _submitBooking,
                  child:
                      _isSubmitting
                          ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white,
                              ),
                            ),
                          )
                          : const Text(
                            'Kirim',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              letterSpacing: 0.5,
                            ),
                          ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _maybeRecalculateTotalCost() {
    if (_totalCostOverridden) return;
    final rate = _selectedTariff?.basePrice;
    final start = _parseDisplayedDate(leaveDateController.text);
    final end = _parseDisplayedDate(returnDateController.text);
    if (rate == null || start == null || end == null) return;
    if (end.isBefore(start)) return;
    final days = end.difference(start).inDays + 1;
    final total = rate * days;
    final formatted = _currencyFormatter.format(total);
    if (totalCostController.text == formatted) return;
    _settingTotalProgrammatically = true;
    totalCostController
      ..text = formatted
      ..selection = TextSelection.collapsed(offset: formatted.length);
    _settingTotalProgrammatically = false;
  }

  DateTime? _parseDisplayedDate(String value) {
    if (value.trim().isEmpty) return null;
    try {
      return _displayDateFormat.parseStrict(value.trim());
    } catch (_) {
      return null;
    }
  }

  double? _parseAmount(String value) {
    final cleaned = value.replaceAll(RegExp(r'[^0-9,.-]'), '');
    if (cleaned.isEmpty) return null;
    final normalized = cleaned.replaceAll('.', '').replaceAll(',', '.');
    return double.tryParse(normalized);
  }

  void _onTotalCostChangedManually() {
    if (_settingTotalProgrammatically) return;

    final result = formatCurrencyInput(
      totalCostController.text,
      _currencyFormatter,
    );

    if (result.shouldClear) {
      _settingTotalProgrammatically = true;
      totalCostController.clear();
      _settingTotalProgrammatically = false;
      _totalCostOverridden = false;
      return;
    }

    if (!result.shouldUpdateText) {
      _totalCostOverridden = result.isOverride;
      return;
    }

    final formatted = result.formattedValue;
    if (formatted == null) {
      _totalCostOverridden = false;
      return;
    }

    _settingTotalProgrammatically = true;
    totalCostController
      ..text = formatted
      ..selection = TextSelection.collapsed(offset: formatted.length);
    _settingTotalProgrammatically = false;
    _totalCostOverridden = result.isOverride;
  }

  Future<void> _submitBooking() async {
    final vehicle = _selectedVehicle;
    if (vehicle == null) {
      CustomFlushbar.show(
        context,
        message: 'Pilih kendaraan terlebih dahulu.',
        type: FlushbarType.warning,
      );
      return;
    }

    final tariff = _selectedTariff;
    if (tariff == null) {
      CustomFlushbar.show(
        context,
        message: 'Pilih tarif terlebih dahulu.',
        type: FlushbarType.warning,
      );
      return;
    }

    final customer = customerController.text.trim();
    final tripCategory = tripCategoryController.text.trim();
    final destination = destinationController.text.trim();
    final phoneNumber = customerPhoneController.text.trim();
    final startDate = _parseDisplayedDate(leaveDateController.text);
    final endDate = _parseDisplayedDate(returnDateController.text);
    final pricePerDay = tariff.basePrice;
    final totalCost = _parseAmount(totalCostController.text);
    final notes = notesController.text.trim();

    if (customer.isEmpty) {
      CustomFlushbar.show(
        context,
        message: 'Nama customer wajib diisi.',
        type: FlushbarType.warning,
      );
      return;
    }

    if (phoneNumber.isEmpty) {
      CustomFlushbar.show(
        context,
        message: 'Nomor telepon wajib diisi.',
        type: FlushbarType.warning,
      );
      return;
    }

    if (startDate == null || endDate == null) {
      CustomFlushbar.show(
        context,
        message: 'Tanggal keberangkatan dan kembali wajib diisi.',
        type: FlushbarType.warning,
      );
      return;
    }

    if (endDate.isBefore(startDate)) {
      CustomFlushbar.show(
        context,
        message: 'Tanggal kembali tidak boleh sebelum tanggal berangkat.',
        type: FlushbarType.warning,
      );
      return;
    }

    if (pricePerDay == null) {
      CustomFlushbar.show(
        context,
        message: 'Tarif tidak memiliki harga dasar.',
        type: FlushbarType.warning,
      );
      return;
    }

    final durationDays = endDate.difference(startDate).inDays + 1;
    final computedTotal = totalCost ?? (pricePerDay * durationDays);
    final tripCode = 'TR-${DateTime.now().millisecondsSinceEpoch}';
    final payload = <String, dynamic>{
      'trip_code': tripCode,
      'customer_name': customer,
      'customer_phone': phoneNumber,
      'vehicle_id': vehicle.id,
      'tariff_id': tariff.id,
      'status': 'planning',
      if (tripCategory.isNotEmpty) 'trip_category': tripCategory,
      if (destination.isNotEmpty) 'destination': destination,
      'start_date': _payloadDateFormat.format(startDate),
      'end_date': _payloadDateFormat.format(endDate),
      'duration_days': durationDays,
      'price_per_day': pricePerDay,
      'total_cost': double.parse(computedTotal.toStringAsFixed(0)),
      if (notes.isNotEmpty) 'notes': notes,
    };

    setState(() => _isSubmitting = true);
    try {
      await BookingService.createBooking(payload);
      if (!mounted) return;
      CustomFlushbar.show(
        context,
        message: 'Reservasi berhasil dibuat.',
        type: FlushbarType.success,
      );
      _resetForm();
      Future.delayed(const Duration(milliseconds: 1200), () {
        if (!mounted) return;
        Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
      });
    } catch (e) {
      if (!mounted) return;
      CustomFlushbar.show(
        context,
        message: 'Gagal membuat reservasi: $e',
        type: FlushbarType.error,
      );
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  void _resetForm() {
    setState(() {
      _selectedTariff = null;
      _totalCostOverridden = false;
      _tariffResetToken++;
    });
    customerController.clear();
    customerPhoneController.clear();
    leaveDateController.clear();
    returnDateController.clear();
    tripCategoryController.clear();
    destinationController.clear();
    _settingTotalProgrammatically = true;
    totalCostController.clear();
    _settingTotalProgrammatically = false;
    notesController.clear();
  }
}
