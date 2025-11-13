import 'package:flutter/material.dart';

class ReservasiPage extends StatelessWidget {
  const ReservasiPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
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
            _buildField('Vehicle', Icons.directions_car, 'Select Vehicle'),
            _buildField('Customer', Icons.person, 'Input Customer Name'),

            Row(
              children: [
                Expanded(
                  child: _buildField(
                    'Leave Date',
                    Icons.calendar_today,
                    'Select Date',
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildField(
                    'Return Date',
                    Icons.calendar_today,
                    'Select Date',
                  ),
                ),
              ],
            ),

            _buildField('Trip Category', Icons.category, 'Select Category'),
            _buildField('Destination', Icons.location_on, 'Input Destination'),
            _buildField('Cost', Icons.attach_money, 'Enter Cost'),
            _buildField('Total Cost', Icons.summarize, 'Auto Calculated'),
            _buildField('Notes', Icons.note, 'Additional Notes', maxLines: 3),

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

  // === Custom Input Field Builder ===
  Widget _buildField(
    String label,
    IconData icon,
    String hint, {
    int maxLines = 1,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 6),
          TextField(
            maxLines: maxLines,
            decoration: InputDecoration(
              prefixIcon: Icon(icon, color: Colors.black),
              hintText: hint,
              hintStyle: TextStyle(color: Colors.grey.shade600),
              filled: true,
              fillColor: Colors.grey.shade200,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(
                vertical: 14,
                horizontal: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
