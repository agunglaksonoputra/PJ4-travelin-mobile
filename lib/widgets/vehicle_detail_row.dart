import 'package:flutter/material.dart';

class VehicleDetailRow extends StatelessWidget {
  final String label;
  final dynamic value;

  const VehicleDetailRow({
    super.key,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final displayValue =
    (value == null || (value is String && value.trim().isEmpty))
        ? "-"
        : value.toString();

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(
            width: 120,
            child: Text(
              '',
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(child: Text(displayValue)),
        ],
      ),
    );
  }
}
