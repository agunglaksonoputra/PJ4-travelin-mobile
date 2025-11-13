import 'package:flutter/material.dart';

class PlanningTable extends StatelessWidget {
  const PlanningTable({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      // Bungkus utama
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.grey.shade300, blurRadius: 4)],
      ),
      child: Column(
        children: [
          // === Header Table ===
          Container(
            decoration: const BoxDecoration(
              color: Color(0xFF00BFA6),
              borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
            ),
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _HeaderText('TRAVEL'),
                _HeaderText('LAST MONTH'),
                _HeaderText('THIS MONTH'),
                _HeaderText('NEXT MONTH'),
                _HeaderText('TOTAL'),
              ],
            ),
          ),

          // === Isi tabel, scrollable & fleksibel ===
          Expanded( // 🔹 Ganti SizedBox jadi Expanded agar menyesuaikan tinggi parent
            child: SingleChildScrollView(
              child: Column(
                children: List.generate(
                  8,
                  (index) => Container(
                    color: index.isEven
                        ? Colors.grey.shade200
                        : Colors.white, // 🔹 Baris abu muda selang-seling
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Text('A', style: TextStyle(color: Colors.black)),
                        Text('15 Trip', style: TextStyle(color: Colors.black)),
                        Text('14 Trip', style: TextStyle(color: Colors.black)),
                        Text('10 Trip', style: TextStyle(color: Colors.black)),
                        Text('14jt', style: TextStyle(color: Colors.black)),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _HeaderText extends StatelessWidget {
  final String text;
  const _HeaderText(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontWeight: FontWeight.bold,
        color: Colors.white,
      ),
    );
  }
}
