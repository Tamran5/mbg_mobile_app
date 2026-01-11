import 'package:flutter/material.dart';
// 1. Import wrapper scaffold yang sudah kita buat sebelumnya
import '../../widgets/mbg_scaffold.dart';

class RekapHarianPage extends StatefulWidget {
  const RekapHarianPage({super.key});

  @override
  State<RekapHarianPage> createState() => _RekapHarianPageState();
}

class _RekapHarianPageState extends State<RekapHarianPage> {
  final Color _navy = const Color(0xFF1A237E);
  final Color _accent = const Color(0xFF5D9CEC);

  // Simulasi data historis bulanan (Nantinya ditarik dari Backend Flask)
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
    // 2. Menggunakan MbgScaffold untuk konsistensi dekorasi pojok kanan atas
    return MbgScaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(context),
          
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildMonthlyFilter(),
                  const SizedBox(height: 10),
                  _buildMonthlyStats(), // Ringkasan total porsi bulan ini
                  
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 20),
                    child: Text(
                      "Riwayat Distribusi", 
                      style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18, color: Color(0xFF2D3436))
                    ),
                  ),

                  // Daftar Riwayat
                  Column(
                    children: _rekapData.map((data) => _buildHistoryCard(data)).toList(),
                  ),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- UI COMPONENTS ---

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 10, 24, 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
            color: _navy,
            onPressed: () => Navigator.pop(context),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 12, top: 10),
            child: Text(
              "Rekap Harian",
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.w900,
                color: _navy,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMonthlyFilter() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          isExpanded: true,
          value: "Januari 2026",
          icon: Icon(Icons.keyboard_arrow_down_rounded, color: _navy),
          style: TextStyle(color: _navy, fontWeight: FontWeight.bold, fontSize: 14),
          items: ["Januari 2026", "Desember 2025", "November 2025"].map((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value),
            );
          }).toList(),
          onChanged: (val) {},
        ),
      ),
    );
  }

  Widget _buildMonthlyStats() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: _navy,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: _navy.withAlpha(77), 
            blurRadius: 15, 
            offset: const Offset(0, 8)
          )
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _statItem("22 Hari", "Pengiriman"),
          Container(width: 1, height: 40, color: Colors.white24),
          _statItem("9.850", "Total Porsi"),
          Container(width: 1, height: 40, color: Colors.white24),
          _statItem("1", "Kendala"),
        ],
      ),
    );
  }

  Widget _statItem(String val, String label) {
    return Column(
      children: [
        Text(val, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 18)),
        const SizedBox(height: 4),
        Text(label, style: TextStyle(color: Colors.white.withAlpha(179), fontSize: 10, fontWeight: FontWeight.bold)),
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
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey[100]!),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(5), 
            blurRadius: 10, 
            offset: const Offset(0, 4)
          )
        ],
      ),
      child: Row(
        children: [
          // Indikator Tanggal
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: _navy.withAlpha(13),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                Text(data['tgl'], style: TextStyle(fontWeight: FontWeight.w900, color: _navy, fontSize: 16)),
                Text(data['hari'], style: TextStyle(color: _navy.withAlpha(153), fontSize: 10, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  data['menu'], 
                  style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14, color: Color(0xFF2D3436)),
                  maxLines: 1, 
                  overflow: TextOverflow.ellipsis
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Icon(Icons.restaurant_rounded, size: 12, color: _accent),
                    const SizedBox(width: 4),
                    Text("${data['porsi']} Porsi", style: const TextStyle(fontSize: 11, color: Colors.grey, fontWeight: FontWeight.w600)),
                    const SizedBox(width: 12),
                    Icon(Icons.access_time_filled_rounded, size: 12, color: _accent),
                    const SizedBox(width: 4),
                    Text(data['waktu'], style: const TextStyle(fontSize: 11, color: Colors.grey, fontWeight: FontWeight.w600)),
                  ],
                ),
              ],
            ),
          ),
          // Tag Status
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: statusColor.withAlpha(26), 
              borderRadius: BorderRadius.circular(10)
            ),
            child: Text(
              data['status'].toUpperCase(), 
              style: TextStyle(color: statusColor, fontSize: 9, fontWeight: FontWeight.w900, letterSpacing: 0.5)
            ),
          ),
        ],
      ),
    );
  }
}