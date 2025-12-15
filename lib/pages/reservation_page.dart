import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:travelin/widgets/custom_input_field.dart';
import 'package:travelin/services/bookings_service.dart';

import '../widgets/date_input_field.dart';

class ReservationPage extends StatefulWidget {
  const ReservationPage({super.key});

  @override
  State<ReservationPage> createState() => _ReservationPageState();
}

class _ReservationPageState extends State<ReservationPage> {
  final vehicleController = TextEditingController();
  final customerController = TextEditingController();
  final leaveDateController = TextEditingController();
  final returnDateController = TextEditingController();
  final tripCategoryController = TextEditingController();
  final destinationController = TextEditingController();
  final costController = TextEditingController();
  final totalCostController = TextEditingController();
  final notesController = TextEditingController();

  @override
  void dispose() {
    vehicleController.dispose();
    customerController.dispose();
    leaveDateController.dispose();
    returnDateController.dispose();
    tripCategoryController.dispose();
    destinationController.dispose();
    costController.dispose();
    totalCostController.dispose();
    notesController.dispose();
    super.dispose();
  }

  DateTime? _parseDate(String text) {
    if (text.isEmpty) return null;
    try {
      return DateFormat('dd MMM yyyy').parseStrict(text);
    } catch (_) {
      // fallback try ISO
      try {
        return DateFormat('yyyy-MM-dd').parseStrict(text);
      } catch (_) {
        return null;
      }
    }
  }

  Future<void> _submitBooking() async {
    // Basic validation
    if (vehicleController.text.trim().isEmpty || customerController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vehicle dan Customer wajib diisi')),
      );
      return;
    }

    final startDate = _parseDate(leaveDateController.text.trim());
    final endDate = _parseDate(returnDateController.text.trim());

    if (startDate == null || endDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pilih tanggal mulai dan selesai yang valid')),
      );
      return;
    }

    // Build payload matching backend transactions format
    final payload = <String, dynamic>{
      'trip_code': 'TR-${DateTime.now().millisecondsSinceEpoch}',
      'customer_name': customerController.text.trim(),
      // If you store vehicle id, put id; otherwise backend may accept string identifier
      'vehicle_id': int.tryParse(vehicleController.text.trim()) ?? vehicleController.text.trim(),
      'start_date': DateFormat('yyyy-MM-dd').format(startDate),
      'end_date': DateFormat('yyyy-MM-dd').format(endDate),
      'price_per_day': double.tryParse(costController.text.trim()) ?? 0,
      'total_cost': double.tryParse(totalCostController.text.trim()) ?? 0,
      'note': notesController.text.trim(),
      // optional extras:
      'trip_category': tripCategoryController.text.trim(),
      'destination': destinationController.text.trim(),
    };

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final response = await BookingService.createBooking(payload);
      if (!mounted) return;
      Navigator.of(context).pop(); // close loading

      String message = 'Booking berhasil dibuat';
      if (response is Map && response['message'] is String && (response['message'] as String).isNotEmpty) {
        message = response['message'] as String;
      } else if (response is Map && response['success'] == true && response['message'] is String) {
        message = response['message'] as String;
      } else if (response is String && response.isNotEmpty) {
        message = response;
      }

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
      // Optionally clear fields:
      // vehicleController.clear();
      // customerController.clear();
      // ...
    } catch (e) {
      if (mounted) Navigator.of(context).pop(); // close loading
      final errText = e.toString();
      final preview = errText.length > 240 ? '${errText.substring(0, 240)}...' : errText;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal membuat booking: $preview')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        scrolledUnderElevation: 0,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(FontAwesomeIcons.angleLeft, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Reservasi',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CustomInputField(
              label: 'Vehicle (id atau kode)',
              icon: FontAwesomeIcons.car,
              hint: 'Masukkan vehicle id atau kode',
              controller: vehicleController,
            ),
            const SizedBox(height: 12),
            CustomInputField(
              label: 'Customer',
              icon: FontAwesomeIcons.person,
              hint: 'Input Customer Name',
              controller: customerController,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: DateInputField(
                    label: 'Leave Date',
                    hint: 'Select Date',
                    icon: FontAwesomeIcons.calendarWeek,
                    controller: leaveDateController,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: DateInputField(
                    label: 'Return Date',
                    hint: 'Select Date',
                    icon: FontAwesomeIcons.calendarWeek,
                    controller: returnDateController,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            CustomInputField(
              label: 'Trip Category',
              icon: FontAwesomeIcons.tags,
              hint: 'Select Category',
              controller: tripCategoryController,
            ),
            const SizedBox(height: 12),
            CustomInputField(
              label: 'Destination',
              icon: FontAwesomeIcons.locationDot,
              hint: 'Input Destination',
              controller: destinationController,
            ),
            const SizedBox(height: 12),
            CustomInputField(
              label: 'Price per day',
              icon: FontAwesomeIcons.moneyBill,
              hint: 'Enter Price per day',
              controller: costController,
            ),
            const SizedBox(height: 12),
            CustomInputField(
              label: 'Total Cost',
              icon: FontAwesomeIcons.calculator,
              hint: 'Auto Calculated or enter manually',
              controller: totalCostController,
            ),
            const SizedBox(height: 12),
            CustomInputField(
              label: 'Notes',
              icon: FontAwesomeIcons.noteSticky,
              hint: 'Additional Notes',
              controller: notesController,
            ),
            const SizedBox(height: 24),
            Center(
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.lightBlue,
                    padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 2,
                  ),
                  onPressed: _submitBooking,
                  child: const Text(
                    'Submit',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}