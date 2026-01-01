import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return PopScope(
      canPop: !_isSubmitting,
      onPopInvoked: (didPop) {
        if (!didPop && _isSubmitting) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Sedang memproses reservasi...')),
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
              // Drag handle
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
              // Header
              const Text(
                'Reservasi Kendaraan',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              const SizedBox(height: 16),
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
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                keyboardType: TextInputType.phone,
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
                  onPressed: _isSubmitting ? null : _submitBooking,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    disabledBackgroundColor: Colors.grey[300],
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child:
                      _isSubmitting
                          ? Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.blue[600]!,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              const Text(
                                'MEMPROSES...',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          )
                          : const Text(
                            'KIRIM',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
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

      Navigator.of(context).pop(true);
    } catch (error) {
      // Only reset submitting state on error
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
}
