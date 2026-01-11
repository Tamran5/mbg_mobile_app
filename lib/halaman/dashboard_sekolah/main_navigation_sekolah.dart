import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // Tambahkan provider
import '../../providers/auth_provider.dart';
import 'dashboard_sekolah.dart';
import 'verifikasi_siswa.dart';
import 'data_siswa.dart';
import '../dashboard_umum/jadwal.dart';
import '../dashboard_umum/profil.dart';

class MainNavigationSekolah extends StatefulWidget {
  const MainNavigationSekolah({super.key});

  @override
  State<MainNavigationSekolah> createState() => _MainNavigationSekolahState();
}

class _MainNavigationSekolahState extends State<MainNavigationSekolah> {
  // PENTING: _currentIndex sekarang dikelola sepenuhnya oleh AuthProvider
  // agar tidak reset saat rebuild global.

  @override
  Widget build(BuildContext context) {
    // Memantau status dari AuthProvider
    final auth = Provider.of<AuthProvider>(context);
    const Color navyColor = Color(0xFF1A237E);

    // List halaman tetap sama
    final List<Widget> _pages = [
      DashboardSekolah(onTapMenu: (index) => auth.setTabIndex(index)),
      const DataSiswaPage(),
      const VerifikasiPendaftaranPage(),
      const JadwalPage(),
      const ProfilPage(),
    ];

    return Scaffold(
      // 1. Menggunakan IndexedStack agar status scroll/input di tiap halaman tidak hilang
      body: IndexedStack(
        index: auth.currentTabIndex,
        children: _pages,
      ),
      bottomNavigationBar: Container(
        height: 85,
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildNavIcon(0, Icons.grid_view_rounded, "Beranda", navyColor, auth),
            _buildNavIcon(1, Icons.groups_rounded, "Siswa", navyColor, auth),
            _buildNavIcon(2, Icons.how_to_reg_rounded, "Verifikasi", navyColor, auth),
            _buildNavIcon(3, Icons.calendar_today_rounded, "Jadwal", navyColor, auth),
            _buildNavIcon(4, Icons.person_outline_rounded, "Profil", navyColor, auth),
          ],
        ),
      ),
    );
  }

  // 2. Widget Helper yang sudah disinkronkan dengan AuthProvider
  Widget _buildNavIcon(
    int index,
    IconData icon,
    String label,
    Color activeColor,
    AuthProvider auth,
  ) {
    bool isSelected = auth.currentTabIndex == index;

    return GestureDetector(
      onTap: () => auth.setTabIndex(index), // Update index ke provider
      child: Container(
        color: Colors.transparent,
        width: 65,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Efek background bulat pada ikon aktif (Sesuai tema MBG)
            AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isSelected ? activeColor.withOpacity(0.1) : Colors.transparent,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: isSelected ? activeColor : Colors.grey[300],
                size: 26,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected ? activeColor : Colors.grey[400],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}