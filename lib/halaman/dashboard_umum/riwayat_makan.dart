import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';

class RiwayatMakanPage extends StatefulWidget {
  const RiwayatMakanPage({super.key});

  @override
  State<RiwayatMakanPage> createState() => _RiwayatMakanPageState();
}

class _RiwayatMakanPageState extends State<RiwayatMakanPage> {
  final Color _primaryBlue = const Color(0xFF1A237E);

  @override
  void initState() {
    super.initState();
    initializeDateFormatting('id_ID', null); // Lokalisasi Indonesia
  }

  // Data Dummy Riwayat Makan
  final List<Map<String, String>> _riwayatData = [
    {
      "tanggal": "2026-01-02",
      "menu": "Nasi Merah & Ikan Nila Goreng",
      "kcal": "540 Kkal",
      "status": "Selesai",
      "img": "https://media.suara.com/pictures/653x366/2025/01/16/94698-cuitan-warganet-soal-menu-makan-bergizi-gratis-hari-ke-7.jpg"
    },
    {
      "tanggal": "2025-12-31",
      "menu": "Nasi Putih & Ayam Bakar Madu",
      "kcal": "565 Kkal",
      "status": "Selesai",
      "img": "https://media.suara.com/pictures/653x366/2025/01/16/94698-cuitan-warganet-soal-menu-makan-bergizi-gratis-hari-ke-7.jpg"
    },
    {
      "tanggal": "2025-12-30",
      "menu": "Soto Ayam & Jeruk Peras",
      "kcal": "480 Kkal",
      "status": "Selesai",
      "img": "https://media.suara.com/pictures/653x366/2025/01/16/94698-cuitan-warganet-soal-menu-makan-bergizi-gratis-hari-ke-7.jpg"
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Riwayat Makan", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: _primaryBlue,
      ),
      body: Stack(
        children: [
          // --- 1. DEKORASI BULAT BIRU (Style Dashboard) ---
          Positioned(
            top: -70,
            right: -50,
            child: Container(
              width: 280,
              height: 280,
              decoration: BoxDecoration(
                color: const Color(0xFF5D9CEC).withOpacity(0.12),
                shape: BoxShape.circle,
              ),
            ),
          ),

          // --- 2. DAFTAR RIWAYAT ---
          ListView.builder(
            padding: const EdgeInsets.all(24),
            itemCount: _riwayatData.length,
            itemBuilder: (context, index) {
              var item = _riwayatData[index];
              DateTime date = DateTime.parse(item['tanggal']!);
              
              return Container(
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.grey[100]!),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 5))
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      // Thumbnail Makanan
                      ClipRRect(
                        borderRadius: BorderRadius.circular(15),
                        child: Image.network(item['img']!, width: 85, height: 85, fit: BoxFit.cover),
                      ),
                      const SizedBox(width: 16),
                      // Detail Informasi
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              DateFormat('EEEE, d MMMM yyyy', 'id_ID').format(date),
                              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.cyan),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              item['menu']!,
                              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: _primaryBlue),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(item['kcal']!, style: const TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.w600)),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(color: Colors.green[50], borderRadius: BorderRadius.circular(8)),
                                  child: const Text("Selesai", style: TextStyle(color: Colors.green, fontSize: 10, fontWeight: FontWeight.bold)),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}