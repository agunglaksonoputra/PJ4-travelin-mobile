import 'package:flutter/material.dart';

class SummaryCard extends StatelessWidget {
  final Color color; // warna background
  final String title;
  final String amount;
  final IconData icon;

  const SummaryCard({
    super.key,
    required this.color,
    required this.title,
    required this.amount,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.all(6),
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
        decoration: BoxDecoration(
          color: color, // 🔹 warna background utama
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.shade400,
              blurRadius: 4,
              offset: const Offset(2, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween, // 🔹 teks kiri, ikon kanan
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // 🔹 Bagian kiri: teks
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white, // 🔹 teks putih
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  amount,
                  style: const TextStyle(
                    color: Colors.white, // 🔹 teks putih
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),

            // 🔹 Bagian kanan: ikon putih
            const SizedBox(width: 6),
            Icon(
              icon,
              color: Colors.black, // 🔹 ikon putih
              size: 40,
            ),
          ],
        ),
      ),
    );
  }
}
