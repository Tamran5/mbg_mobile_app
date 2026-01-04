import 'package:flutter/material.dart';

class RiwayatPage extends StatelessWidget {
  const RiwayatPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Capaian & Riwayat Gizi", style: TextStyle(fontWeight: FontWeight.bold)), centerTitle: true),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Standar Gizi MBG vs Aktual", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 20),
            _buildGiziBar("Energi", 580, 600, Colors.orange), //
            _buildGiziBar("Protein", 25.2, 28, Colors.cyan),
            _buildGiziBar("Lemak", 12.5, 15, Colors.green),
            const SizedBox(height: 30),
            const Text("Riwayat Menu Bulan Lalu", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 15),
            _buildHistoryItem("31 Des", "Nasi Putih, Ikan Goreng, Capcay"),
            _buildHistoryItem("30 Des", "Nasi Kuning, Telur Balado, Orek"),
          ],
        ),
      ),
    );
  }

  Widget _buildGiziBar(String label, double actual, double target, Color col) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
              Text("${actual.toInt()}/${target.toInt()}", style: const TextStyle(fontSize: 12, color: Colors.grey)),
            ],
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(value: actual / target, backgroundColor: col.withOpacity(0.1), color: col, minHeight: 8),
        ],
      ),
    );
  }

  Widget _buildHistoryItem(String date, String menu) {
    return ListTile(
      leading: Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: const Color(0xFFF0F2F8), borderRadius: BorderRadius.circular(8)), child: Text(date, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold))),
      title: Text(menu, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
      trailing: const Icon(Icons.chevron_right, size: 16),
    );
  }
}