import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';

class JadwalPage extends StatefulWidget {
  const JadwalPage({super.key});

  @override
  State<JadwalPage> createState() => _JadwalPageState();
}

class _JadwalPageState extends State<JadwalPage> {
  DateTime _focusedDate = DateTime(2026, 1, 12);
  DateTime _selectedDate = DateTime(2026, 1, 12);

  // Warna Biru Utama Aplikasi untuk Teks & Elemen Aktif
  final Color _primaryBlue = const Color(0xFF1A237E);

  @override
  void initState() {
    super.initState();
    // Inisialisasi lokalisasi Bahasa Indonesia
    initializeDateFormatting('id_ID', null); 
  }

  // Database Menu Minimalis (Senin - Sabtu)
  late final Map<String, Map<String, dynamic>> _menuDatabase = {
    "2026-01-12": {
      "image": "https://media.suara.com/pictures/653x366/2025/01/16/94698-cuitan-warganet-soal-menu-makan-bergizi-gratis-hari-ke-7.jpg",
      "menu": "Nasi Putih, Ayam Goreng Serundeng, Sayur Capcay, Anggur & Susu UHT",
      "kcal": "580",
      "nutrisi": {
        "karbo": {"b": "226g", "p": "39%"},
        "prot": {"b": "226g", "p": "39%"},
        "lem": {"b": "127g", "p": "22%"},
      },
      "komponen": [
        {"n": "Nasi Putih", "b": "160 g", "c": _primaryBlue},
        {"n": "Ayam Goreng", "b": "120 g", "c": _primaryBlue},
        {"n": "Sayur Capcay", "b": "82 g", "c": _primaryBlue},
        {"n": "Buah Anggur", "b": "50 g", "c": _primaryBlue},
        {"n": "Susu UHT", "b": "125 ml", "c": _primaryBlue},
      ]
    },
  };

  List<DateTime> _generateWorkingDays(DateTime focus) {
    DateTime monday = focus.subtract(Duration(days: focus.weekday - 1));
    return List.generate(6, (index) => monday.add(Duration(days: index)));
  }

  @override
  Widget build(BuildContext context) {
    List<DateTime> week = _generateWorkingDays(_focusedDate);
    String key = DateFormat('yyyy-MM-dd').format(_selectedDate);
    var data = _menuDatabase[key] ?? _menuDatabase["2026-01-12"]!;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // --- 1. DEKORASI BULAT BIRU (Warna Identik Dashboard) ---
          Positioned(
            top: -70,
            right: -50,
            child: Container(
              width: 280,
              height: 280,
              decoration: BoxDecoration(
                // Menggunakan warna spesifik dari dashboard Anda
                color: const Color(0xFF5D9CEC).withOpacity(0.12), 
                shape: BoxShape.circle,
              ),
            ),
          ),
          
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // --- 2. HEADER: Teks Menu & Bulan di Kiri, Tombol di Kanan ---
                _buildLeftAlignedHeader(),

                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // --- 3. KALENDER HORIZONTAL SENIN-SABTU ---
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          child: _buildHorizontalCalendar(week),
                        ),

                        const SizedBox(height: 25),
                        // --- 4. KONTEN MENU UTAMA ---
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(15),
                                child: Image.network(data['image'], height: 200, width: double.infinity, fit: BoxFit.cover),
                              ),
                              const SizedBox(height: 16),
                              Text(data['menu'], style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: _primaryBlue)),
                              
                              const SizedBox(height: 30),
                              const Text("Analisis Nutrisi", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                              const SizedBox(height: 16),
                              _buildSimpleNutri(data),

                              const SizedBox(height: 30),
                              const Text("Komponen Piring", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                              const SizedBox(height: 12),
                              _buildSimplePlate(data['komponen']),
                              const SizedBox(height: 40),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLeftAlignedHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 20, 12, 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Judul Menu Diperbesar (Kiri)
          Text(
            "Menu",
            style: TextStyle(
              fontSize: 32, 
              fontWeight: FontWeight.w900, 
              color: _primaryBlue,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Bulan & Tahun (Kiri)
              Text(
                DateFormat('MMMM yyyy', 'id_ID').format(_focusedDate),
                style: TextStyle(
                  color: _primaryBlue, 
                  fontWeight: FontWeight.w700, 
                  fontSize: 18,
                ),
              ),
              // Tombol Navigasi Slide (Kanan)
              Row(
                children: [
                  _buildNavButton(Icons.chevron_left, () {
                    setState(() => _focusedDate = _focusedDate.subtract(const Duration(days: 7)));
                  }),
                  const SizedBox(width: 8),
                  _buildNavButton(Icons.chevron_right, () {
                    setState(() => _focusedDate = _focusedDate.add(const Duration(days: 7)));
                  }),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNavButton(IconData icon, VoidCallback onPressed) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: _primaryBlue, size: 24),
      ),
    );
  }

  Widget _buildHorizontalCalendar(List<DateTime> week) {
    return SizedBox(
      height: 80,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: week.length,
        itemBuilder: (context, i) {
          bool isSel = DateFormat('yyyy-MM-dd').format(_selectedDate) == DateFormat('yyyy-MM-dd').format(week[i]);
          return GestureDetector(
            onTap: () => setState(() => _selectedDate = week[i]),
            child: Container(
              width: 55,
              margin: const EdgeInsets.only(right: 12),
              decoration: BoxDecoration(
                color: isSel ? _primaryBlue : Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(DateFormat('EEE', 'id_ID').format(week[i]), style: TextStyle(color: isSel ? Colors.white70 : Colors.grey, fontSize: 12)),
                  Text(DateFormat('d').format(week[i]), style: TextStyle(color: isSel ? Colors.white : Colors.black, fontWeight: FontWeight.bold, fontSize: 18)),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSimpleNutri(Map<String, dynamic> data) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.grey[100]!),
      ),
      child: Row(
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 80, height: 80,
                child: CircularProgressIndicator(
                  value: 0.8, strokeWidth: 8, 
                  backgroundColor: Colors.grey[100], color: Colors.cyan,
                ),
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(data['kcal'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                  const Text("Kkal", style: TextStyle(fontSize: 10, color: Colors.cyan, fontWeight: FontWeight.bold)),
                ],
              ),
            ],
          ),
          const SizedBox(width: 30),
          Expanded(
            child: Column(
              children: [
                _nutriRow("Karbohidrat", data['nutrisi']['karbo']['b']),
                const Divider(height: 16),
                _nutriRow("Protein", data['nutrisi']['prot']['b']),
                const Divider(height: 16),
                _nutriRow("Lemak", data['nutrisi']['lem']['b']),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _nutriRow(String label, String val) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 13, fontWeight: FontWeight.w500)),
        Text(val, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
      ],
    );
  }

  Widget _buildSimplePlate(List<dynamic> items) {
    return Column(
      children: items.map((item) => Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.grey[50],
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(width: 10, height: 10, decoration: BoxDecoration(color: item['c'], shape: BoxShape.circle)),
            const SizedBox(width: 16),
            Expanded(child: Text(item['n'], style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600))),
            Text(item['b'], style: const TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.bold)),
          ],
        ),
      )).toList(),
    );
  }
}