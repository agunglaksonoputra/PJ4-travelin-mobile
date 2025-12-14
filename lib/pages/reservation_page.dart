import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:travelin/widgets/custom_input_field.dart';

import '../widgets/date_input_field.dart';

class ReservationPage extends StatefulWidget {
  const ReservationPage({super.key});

  @override
  State<ReservationPage> createState() => _ReservationPageState();
}

class _ReservationPageState extends State<ReservationPage> {
  final customerController = TextEditingController();
  final leaveDateController = TextEditingController();
  final returnDateController = TextEditingController();

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
            // === Input Fields ===
            CustomInputField(
                label: 'Vehicle',
                icon: FontAwesomeIcons.car,
                hint: 'Select Vehicle',
                controller: customerController
            ),
            const SizedBox(height: 12),
            CustomInputField(
                label: 'Customer',
                icon: FontAwesomeIcons.person,
                hint: 'Input Customer Name',
                controller: customerController
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
                controller: customerController
            ),
            const SizedBox(height: 12),
            CustomInputField(
                label: 'Destination',
                icon: FontAwesomeIcons.locationDot,
                hint: 'Input Destination',
                controller: customerController
            ),
            const SizedBox(height: 12),
            CustomInputField(
                label: 'Cost',
                icon: FontAwesomeIcons.moneyBill,
                hint: 'Enter Cost',
                controller: customerController
            ),
            const SizedBox(height: 12),
            CustomInputField(
                label: 'Total Cost',
                icon: FontAwesomeIcons.calculator,
                hint: 'Auto Calculated',
                controller: customerController
            ),
            const SizedBox(height: 12),
            CustomInputField(
                label: 'Notes',
                icon: FontAwesomeIcons.noteSticky,
                hint: 'Additional Notes',
                controller: customerController
            ),

            const SizedBox(height: 24),

            // === Submit Button ===
            Center(
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.lightBlue,
                    padding:
                    const EdgeInsets.symmetric(horizontal: 40, vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 2,
                  ),
                  onPressed: () {
                    // TODO: Add submit logic here
                  },
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