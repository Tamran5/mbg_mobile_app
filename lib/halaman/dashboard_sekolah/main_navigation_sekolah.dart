import 'package:flutter/material.dart';
import 'dashboard_sekolah.dart'; 
import 'verifikasi_siswa.dart'; // Berisi VerifikasiPendaftaranPage
import 'data_siswa.dart';      // Berisi DataSiswaPage dengan Search Bar
import '../dashboard_umum/jadwal.dart'; 
import '../dashboard_umum/profil.dart'; 

class MainNavigationSekolah extends StatefulWidget {
  const MainNavigationSekolah({super.key});

  @override
  State<MainNavigationSekolah> createState() => _MainNavigationSekolahState();
}

class _MainNavigationSekolahState extends State<MainNavigationSekolah> {
  int _currentIndex = 0;

  // Fungsi callback untuk berpindah halaman tanpa menghilangkan Bottom Bar
  void _jumpToTab(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    const Color navyColor = Color(0xFF1A237E); // Warna Navy Blue Konsisten

    // List halaman didefinisikan di dalam build agar dapat menerima fungsi _jumpToTab
    final List<Widget> _pages = [
      DashboardSekolah(onTapMenu: _jumpToTab), // Index 0: Dashboard Utama
      const DataSiswaPage(),                  // Index 1: Manajemen Massal & Search
      const VerifikasiPendaftaranPage(),      // Index 2: Verifikasi Pendaftaran Baru
      const JadwalPage(),                     // Index 3: Jadwal Program MBG
      const ProfilPage(),                     // Index 4: Profil Sekolah
    ];

    return Scaffold(
      // Body akan berubah sesuai index namun Scaffold (termasuk Bottom Bar) tetap menetap
      body: _pages[_currentIndex],
      bottomNavigationBar: Container(
        height: 80,
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, -5),
            )
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildNavIcon(0, Icons.grid_view_rounded, "Beranda", navyColor),
            _buildNavIcon(1, Icons.groups_rounded, "Data Siswa", navyColor),
            _buildNavIcon(2, Icons.how_to_reg_rounded, "Verifikasi", navyColor),
            _buildNavIcon(3, Icons.calendar_today_rounded, "Jadwal", navyColor),
            _buildNavIcon(4, Icons.person_outline_rounded, "Profil", navyColor),
          ],
        ),
      ),
    );
  }

  // Widget Helper untuk membangun ikon navigasi
  Widget _buildNavIcon(int index, IconData icon, String label, Color activeColor) {
    bool isSelected = _currentIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _currentIndex = index),
      child: Container(
        color: Colors.transparent,
        width: 65,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon, 
              color: isSelected ? activeColor : Colors.grey[300], 
              size: 24
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 9,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected ? activeColor : Colors.grey[300],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}