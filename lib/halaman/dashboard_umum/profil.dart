import 'package:flutter/material.dart';
// Import semua halaman tujuan navigasi
import 'edit_profil.dart';
import 'ubah_password.dart';
import 'riwayat_makan.dart';
import 'ulasan_saya.dart';
import 'tentang_aplikasi.dart';
import 'pusat_bantuan.dart'; 

class ProfilPage extends StatelessWidget {
  const ProfilPage({super.key});

  final Color _primaryBlue = const Color(0xFF1A237E); // Warna Biru Utama

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
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
                color: const Color(0xFF5D9CEC).withOpacity(0.12), // Warna identik dashboard
                shape: BoxShape.circle,
              ),
            ),
          ),

          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),
                  // Judul Profil (Kiri & Besar)
                  const Text(
                    "Profil",
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF1A237E),
                    ),
                  ),
                  const SizedBox(height: 30),

                  // --- 2. HEADER PROFIL (Foto & Nama) ---
                  _buildProfileHeader(),

                  const SizedBox(height: 40),

                  // --- 3. PENGATURAN AKUN (Menu Fungsional) ---
                  const Text(
                    "Pengaturan Akun",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.grey),
                  ),
                  const SizedBox(height: 15),
                  
                  _buildProfileItem(context, Icons.person_outline_rounded, "Data Pribadi", 
                    () => Navigator.push(context, MaterialPageRoute(builder: (context) => const EditProfilPage()))),
                  
                  _buildProfileItem(context, Icons.lock_outline_rounded, "Ubah Password", 
                    () => Navigator.push(context, MaterialPageRoute(builder: (context) => const UbahPasswordPage()))),
                  
                  _buildProfileItem(context, Icons.history_rounded, "Riwayat Makan", 
                    () => Navigator.push(context, MaterialPageRoute(builder: (context) => const RiwayatMakanPage()))),
                  
                  _buildProfileItem(context, Icons.rate_review_outlined, "Ulasan Saya", 
                    () => Navigator.push(context, MaterialPageRoute(builder: (context) => const UlasanSayaPage()))),
                  
                  const SizedBox(height: 25),
                  
                  // --- 4. LAINNYA (Termasuk Pusat Bantuan & Tentang) ---
                  const Text("Lainnya", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.grey)),
                  const SizedBox(height: 15),
                  
                  // Navigasi ke Pusat Bantuan
                  _buildProfileItem(context, Icons.help_outline_rounded, "Pusat Bantuan", 
                    () => Navigator.push(context, MaterialPageRoute(builder: (context) => const PusatBantuanPage()))),
                  
                  _buildProfileItem(context, Icons.info_outline_rounded, "Tentang Aplikasi", 
                    () => Navigator.push(context, MaterialPageRoute(builder: (context) => const TentangAplikasiPage()))),
                  
                  const SizedBox(height: 30),
                  
                  // --- 5. TOMBOL KELUAR ---
                  _buildLogoutButton(),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Center(
      child: Column(
        children: [
          const CircleAvatar(
            radius: 55,
            backgroundColor: Color(0xFFF1F2F6),
            backgroundImage: NetworkImage("https://www.w3schools.com/howto/img_avatar.png"),
          ),
          const SizedBox(height: 15),
          const Text(
            "Bagas Adi Nugroho",
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: Color(0xFF2D3436)),
          ),
          const SizedBox(height: 4),
          const Text(
            "SMAN 01 Jakarta • Kelas 12-A",
            style: TextStyle(fontSize: 14, color: Colors.grey, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileItem(BuildContext context, IconData icon, String title, VoidCallback onTap) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.grey[50], // Gaya template bersih
        borderRadius: BorderRadius.circular(15),
      ),
      child: ListTile(
        leading: Icon(icon, color: _primaryBlue),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
        ),
        trailing: const Icon(Icons.chevron_right_rounded, color: Colors.grey),
        onTap: onTap,
      ),
    );
  }

  Widget _buildLogoutButton() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      width: double.infinity,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.red.withOpacity(0.3)), 
        borderRadius: BorderRadius.circular(15),
      ),
      child: const Center(
        child: Text(
          "Keluar Akun",
          style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 15),
        ),
      ),
    );
  }
}