import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart'; // Pastikan path benar
import '../auth/login_page.dart';
import 'edit_profil.dart';
import 'ubah_password.dart';
import 'pusat_bantuan.dart';
import 'tentang_aplikasi.dart';

class ProfilPage extends StatelessWidget {
  const ProfilPage({super.key});

  final Color _primaryBlue = const Color(0xFF1A237E);

  @override
  Widget build(BuildContext context) {
    // Mengakses AuthProvider untuk mengambil data user terupdate
    final authProvider = Provider.of<AuthProvider>(context);

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
                  const Text(
                    "Profil",
                    style: TextStyle(
                      fontSize: 32, 
                      fontWeight: FontWeight.w900, 
                      color: Color(0xFF1A237E)
                    ),
                  ),
                  const SizedBox(height: 30),

                  // 1. Header Profil (Foto, Nama, & Sekolah/Role)
                  _buildProfileHeader(authProvider),

                  const SizedBox(height: 40),
                  const Text(
                    "Pengaturan Akun",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.grey),
                  ),
                  const SizedBox(height: 15),
                  
                  // Menu Item Fungsional
                  _buildProfileItem(context, Icons.person_outline_rounded, "Data Pribadi", () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => const EditProfilPage()));
                  }),
                  _buildProfileItem(context, Icons.lock_outline_rounded, "Ubah Password", () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => const UbahPasswordPage()));
                  }),
                  
                  // 2. Menu Riwayat hanya muncul untuk Siswa/Lansia
                  if (authProvider.userRole == 'siswa' || authProvider.userRole == 'lansia')
                    _buildProfileItem(context, Icons.history_rounded, "Riwayat Makan", () {}),

                  const SizedBox(height: 25),
                  const Text("Lainnya", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.grey)),
                  const SizedBox(height: 15),
                  _buildProfileItem(context, Icons.help_outline_rounded, "Pusat Bantuan", () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => const PusatBantuanPage()));
                  }),
                  _buildProfileItem(context, Icons.info_outline_rounded, "Tentang Aplikasi", () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => const TentangAplikasiPage()));
                  }),
                  
                  const SizedBox(height: 30),
                  
                  // 3. Tombol Logout
                  _buildLogoutButton(context, authProvider),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- WIDGET HELPERS ---

  Widget _buildProfileHeader(AuthProvider auth) {
    // Logika penentuan subtitle berdasarkan Role & Nama Sekolah
    String subtitle = "";
    if (auth.userRole == 'pengelola_sekolah') {
      subtitle = "Operator • ${auth.schoolName ?? 'Sekolah'}"; 
    } else if (auth.userRole == 'siswa') {
      subtitle = "${auth.schoolName ?? 'Sekolah'} • Siswa";
    } else if (auth.userRole == 'lansia') {
      subtitle = "Lansia • Penerima Manfaat";
    } else {
      subtitle = auth.userRole ?? "Kategori Tidak Diketahui";
    }

    return Center(
      child: Column(
        children: [
          CircleAvatar(
            radius: 55,
            backgroundColor: const Color(0xFFF1F2F6),
            child: Text(
              auth.userName != null ? auth.userName![0].toUpperCase() : "?",
              style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold, color: _primaryBlue),
            ),
          ),
          const SizedBox(height: 15),
          Text(
            auth.userName ?? "Nama Tidak Tersedia",
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: Color(0xFF2D3436)),
          ),
          const SizedBox(height: 4),
          Text(
            auth.userEmail ?? "", // Menampilkan email jika ada
            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 14, color: Colors.grey, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  Widget _buildLogoutButton(BuildContext context, AuthProvider auth) {
    return InkWell(
      onTap: () => _showLogoutDialog(context, auth),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        width: double.infinity,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.red.withAlpha(77)), 
          borderRadius: BorderRadius.circular(15),
        ),
        child: const Center(
          child: Text(
            "Keluar Akun",
            style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 15),
          ),
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context, AuthProvider auth) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text("Keluar Akun"),
        content: const Text("Apakah Anda yakin ingin keluar dari aplikasi?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context), 
            child: const Text("Batal")
          ),
          TextButton(
            onPressed: () {
              auth.logout(); // Menghapus token & data lokal
              Navigator.pushAndRemoveUntil(
                context, 
                MaterialPageRoute(builder: (context) => const LoginPage()), 
                (route) => false
              );
            }, 
            child: const Text("Keluar", style: TextStyle(color: Colors.red))
          ),
        ],
      ),
    );
  }

  // Dekorasi Latar Belakang
  Widget _buildBackgroundDecoration() => Positioned(
    top: -70, 
    right: -50, 
    child: Container(
      width: 280, 
      height: 280, 
      decoration: BoxDecoration(
        color: const Color(0xFF5D9CEC).withAlpha(31), 
        shape: BoxShape.circle
      )
    )
  );
  
  // Widget Item Menu Reusable
  Widget _buildProfileItem(BuildContext context, IconData icon, String title, VoidCallback onTap) => Container(
    margin: const EdgeInsets.only(bottom: 12), 
    decoration: BoxDecoration(
      color: Colors.grey[50], 
      borderRadius: BorderRadius.circular(15)
    ), 
    child: ListTile(
      leading: Icon(icon, color: _primaryBlue), 
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15)), 
      trailing: const Icon(Icons.chevron_right_rounded, color: Colors.grey), 
      onTap: onTap
    )
  );
}