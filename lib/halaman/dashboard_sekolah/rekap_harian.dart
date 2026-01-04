import 'package:flutter/material.dart';

class RekapHarianPage extends StatefulWidget {
  const RekapHarianPage({super.key});

  @override
  State<RekapHarianPage> createState() => _RekapHarianPageState();
}

class _RekapHarianPageState extends State<RekapHarianPage> {
  final Color _navy = const Color(0xFF1A237E);
  final Color _accent = const Color(0xFF5D9CEC);

  // Simulasi data historis bulanan
  final List<Map<String, dynamic>> _rekapData = [
    {
      "tgl": "05 Jan",
      "hari": "Senin",
      "menu": "Nasi Ayam Teriyaki + Apel",
      "porsi": "450/450",
      "waktu": "10:15 WIB",
      "status": "Sukses"
    },
    {
      "tgl": "04 Jan",
      "hari": "Minggu",
      "menu": "Libur Akhir Pekan",
      "porsi": "-",
      "waktu": "-",
      "status": "Libur"
    },
    {
      "tgl": "03 Jan",
      "hari": "Sabtu",
      "menu": "Libur Akhir Pekan",
      "porsi": "-",
      "waktu": "-",
      "status": "Libur"
    },
    {
      "tgl": "02 Jan",
      "hari": "Jumat",
      "menu": "Nasi Ikan Goreng + Sayur Lodeh",
      "porsi": "445/450",
      "waktu": "10:45 WIB",
      "status": "Kendala"
    },
    {
      "tgl": "01 Jan",
      "hari": "Kamis",
      "menu": "Libur Tahun Baru",
      "porsi": "-",
      "waktu": "-",
      "status": "Libur"
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Dekorasi lingkaran konsisten dengan tema MBG
          Positioned(
            top: -70,
            right: -50,
            child: Container(
              width: 280,
              height: 280,
              decoration: BoxDecoration(
                color: _accent.withOpacity(0.12),
                shape: BoxShape.circle,
              ),
            ),
          ),
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(context),
                _buildMonthlyFilter(),
                const SizedBox(height: 10),
                _buildMonthlyStats(), // Ringkasan total porsi bulan ini
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24, vertical: 15),
                  child: Text("Riwayat Distribusi", 
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                ),
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    itemCount: _rekapData.length,
                    itemBuilder: (context, index) => _buildHistoryCard(_rekapData[index]),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 20, left: 10, right: 24),
      child: Row(
        children: [
          IconButton(
            icon: Icon(Icons.arrow_back_ios_new_rounded, color: _navy),
            onPressed: () => Navigator.pop(context),
          ),
          Text(
            "Rekap Harian",
            style: TextStyle(fontWeight: FontWeight.w900, fontSize: 22, color: _navy),
          ),
        ],
      ),
    );
  }

  // Filter untuk melihat histori per bulan
  Widget _buildMonthlyFilter() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        decoration: BoxDecoration(
          color: const Color(0xFFF8F9FD),
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            value: "Januari 2026",
            icon: Icon(Icons.keyboard_arrow_down, color: _navy),
            items: ["Januari 2026", "Desember 2025", "November 2025"].map((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              );
            }).toList(),
            onChanged: (val) {},
          ),
        ),
      ),
    );
  }

  Widget _buildMonthlyStats() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: _navy,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [BoxShadow(color: _navy.withOpacity(0.2), blurRadius: 10, offset: const Offset(0, 5))],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _statItem("22 Hari", "Pengiriman"),
            Container(width: 1, height: 30, color: Colors.white24),
            _statItem("9.850", "Total Porsi"),
            Container(width: 1, height: 30, color: Colors.white24),
            _statItem("1", "Kendala"),
          ],
        ),
      ),
    );
  }

  Widget _statItem(String val, String label) {
    return Column(
      children: [
        Text(val, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
        Text(label, style: const TextStyle(color: Colors.white70, fontSize: 10)),
      ],
    );
  }

  Widget _buildHistoryCard(Map<String, dynamic> data) {
    Color statusColor = data['status'] == "Sukses" ? Colors.green 
                     : data['status'] == "Kendala" ? Colors.red 
                     : Colors.grey;

    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.grey.shade100),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 8)],
      ),
      child: Row(
        children: [
          // Indikator Tanggal
          Column(
            children: [
              Text(data['tgl'], style: TextStyle(fontWeight: FontWeight.bold, color: _navy, fontSize: 16)),
              Text(data['hari'], style: const TextStyle(color: Colors.grey, fontSize: 10)),
            ],
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(data['menu'], 
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                  maxLines: 1, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.restaurant, size: 12, color: _accent),
                    const SizedBox(width: 4),
                    Text("Porsi: ${data['porsi']}", style: const TextStyle(fontSize: 11, color: Colors.grey)),
                    const SizedBox(width: 12),
                    Icon(Icons.access_time, size: 12, color: _accent),
                    const SizedBox(width: 4),
                    Text(data['waktu'], style: const TextStyle(fontSize: 11, color: Colors.grey)),
                  ],
                ),
              ],
            ),
          ),
          // Tag Status
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(color: statusColor.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
            child: Text(data['status'], style: TextStyle(color: statusColor, fontSize: 10, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}