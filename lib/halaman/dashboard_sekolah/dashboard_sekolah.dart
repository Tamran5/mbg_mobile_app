import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import 'laporan_kendala.dart';
import 'rekap_harian.dart';

class DashboardSekolah extends StatelessWidget {
  final Function(int) onTapMenu; 

  const DashboardSekolah({super.key, required this.onTapMenu});

  // Tema warna Navy Blue dan Light Blue konsisten proyek MBG
  final Color _primaryBlue = const Color(0xFF1A237E); 
  final Color _accentBlue = const Color(0xFF5D9CEC);  

  @override
  Widget build(BuildContext context) {
    // Mengambil data dari AuthProvider secara reaktif
    return Consumer<AuthProvider>(
      builder: (context, auth, child) {
        return Scaffold(
          backgroundColor: Colors.white,
          body: Stack(
            children: [
              _buildBackgroundDecoration(),
              SafeArea(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 20),
                      _buildHeader(auth), // Dinamis berdasarkan data login
                      const SizedBox(height: 25),
                      _buildSummaryCard(), 
                      const SizedBox(height: 25),
                      _buildTokenCard(context, auth), // Token Registrasi Sekolah
                      const SizedBox(height: 25),
                      const Text("Konfirmasi Kedatangan Makanan", 
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      const SizedBox(height: 12),
                      _buildArrivalConfirmationCard(), 
                      const SizedBox(height: 25),
                      const Text("Aksi Cepat", 
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      const SizedBox(height: 12),
                      _buildActionGrid(context),
                      const SizedBox(height: 30),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // Dekorasi Latar Belakang
  Widget _buildBackgroundDecoration() {
    return Positioned(
      top: -70,
      right: -50,
      child: Container(
        width: 280, height: 280,
        decoration: BoxDecoration(
          color: _accentBlue.withOpacity(0.12),
          shape: BoxShape.circle,
        ),
      ),
    );
  }

  // Header Dashboard dengan Data Dinamis
  Widget _buildHeader(AuthProvider auth) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Dashboard", 
              style: TextStyle(color: Colors.grey, fontSize: 14, fontWeight: FontWeight.w500)),
            Text(auth.userName ?? "Admin Sekolah", 
              style: TextStyle(fontWeight: FontWeight.w900, fontSize: 22, color: _primaryBlue)),
            Text("NPSN: ${auth.userNpsn ?? '-'}", 
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15, color: Color(0xFF2D3436))),
          ],
        ),
        _buildNotificationIcon(),
      ],
    );
  }

  // Ringkasan Statistik
  Widget _buildSummaryCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: _primaryBlue,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: _primaryBlue.withOpacity(0.3), blurRadius: 15, offset: const Offset(0, 8))],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem("450", "Siswa Aktif"),
          Container(width: 1, height: 40, color: Colors.white24),
          _buildStatItem("12", "Perlu Verifikasi"),
        ],
      ),
    );
  }

  // Widget Token Registrasi (Digunakan Siswa untuk mendaftar di sekolah ini)
  Widget _buildTokenCard(BuildContext context, AuthProvider auth) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFE8EAF6),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _primaryBlue.withOpacity(0.1)),
      ),
      child: Row(
        children: [
          Icon(Icons.vpn_key_rounded, color: _primaryBlue),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Token Registrasi Sekolah", 
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                Text(auth.userNpsn != null ? "TOKEN-${auth.userNpsn}" : "MEMUAT...", 
                  style: TextStyle(color: _primaryBlue, fontWeight: FontWeight.w900, fontSize: 18, letterSpacing: 1.5)),
              ],
            ),
          ),
          IconButton(
            onPressed: () {
              // TODO: Implementasi refresh token via API Flask
            },
            icon: Icon(Icons.refresh_rounded, color: _primaryBlue),
          ),
        ],
      ),
    );
  }

  // Konfirmasi Foto (Jembatan ke fitur Digital Image Processing MBG)
  Widget _buildArrivalConfirmationCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          Container(
            height: 140,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(15),
              border: Border.all(color: Colors.grey.shade300, style: BorderStyle.solid),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.add_a_photo_outlined, color: _primaryBlue.withOpacity(0.4), size: 40),
                const SizedBox(height: 10),
                Text("Ambil Foto Makanan Sampai", style: TextStyle(color: Colors.grey[600], fontSize: 12)),
              ],
            ),
          ),
          const SizedBox(height: 15),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              child: const Text("KONFIRMASI KEDATANGAN", 
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionGrid(BuildContext context) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 15,
      mainAxisSpacing: 15,
      childAspectRatio: 1.3,
      children: [
        _buildActionItem("Data Siswa", Icons.groups_rounded, Colors.blue, () => onTapMenu(1)),
        _buildActionItem("Verifikasi Siswa", Icons.how_to_reg_rounded, Colors.orange, () => onTapMenu(2)),
        _buildActionItem("Laporan Kendala", Icons.report_problem_rounded, Colors.red, () {
          Navigator.push(context, MaterialPageRoute(builder: (context) => const LaporanKendalaPage()));
        }),
        _buildActionItem("Rekap Harian", Icons.bar_chart_rounded, Colors.teal, () {
          Navigator.push(context, MaterialPageRoute(builder: (context) => const RekapHarianPage()));
        }),
      ],
    );
  }

  // Widget Pembantu
  Widget _buildActionItem(String title, IconData icon, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.grey.shade100),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4))],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 10),
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String value, String label) {
    return Column(
      children: [
        Text(value, style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(color: Colors.white70, fontSize: 12)),
      ],
    );
  }

  Widget _buildNotificationIcon() {
    return Container(
      width: 48, height: 48,
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 10)],
      ),
      child: const Icon(Icons.notifications_none_rounded),
    );
  }
}