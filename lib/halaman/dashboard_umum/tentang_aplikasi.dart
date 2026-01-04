import 'package:flutter/material.dart';

class TentangAplikasiPage extends StatelessWidget {
  const TentangAplikasiPage({super.key});

  // Warna Biru Utama Aplikasi
  final Color _primaryBlue = const Color(0xFF1A237E);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Tentang Aplikasi", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF1A237E),
      ),
      body: Stack(
        children: [
          // --- 1. DEKORASI BULAT BIRU (Konsisten dengan Dashboard) ---
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

          // --- 2. KONTEN EDUKASI MBG ---
          SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 20),
                // Logo Program dengan perbaikan penulisan Ikon
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.fastfood_rounded, size: 80, color: _primaryBlue),
                ),
                const SizedBox(height: 24),
                const Text(
                  "Program Makan Bergizi Gratis",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: Color(0xFF1A237E)),
                ),
                const SizedBox(height: 10),
                const Text(
                  "Versi 1.0.0",
                  style: TextStyle(color: Colors.grey, fontSize: 13, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 30),
                
                // Deskripsi Program
                _buildInfoSection(
                  "Apa itu MBG?", 
                  "Makan Bergizi Gratis (MBG) adalah program pemerintah untuk memastikan setiap siswa mendapatkan asupan nutrisi seimbang setiap hari sekolah guna mendukung pertumbuhan dan fokus belajar."
                ),
                
                _buildInfoSection(
                  "Tujuan Aplikasi", 
                  "Aplikasi ini membantu siswa memantau jadwal menu mingguan, melihat analisis nutrisi harian, dan memberikan ulasan langsung terhadap makanan yang disajikan."
                ),
                
                _buildInfoSection(
                  "Standar Gizi 2025", 
                  "Setiap menu dirancang oleh ahli gizi profesional dengan standar kalori yang disesuaikan untuk kebutuhan energi siswa di sekolah."
                ),

                const SizedBox(height: 40),
                const Text(
                  "© 2026 Tim Pengembang MBG",
                  style: TextStyle(color: Colors.grey, fontSize: 12),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoSection(String title, String content) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF2D3436)),
          ),
          const SizedBox(height: 8),
          Text(
            content,
            textAlign: TextAlign.justify,
            style: const TextStyle(fontSize: 14, color: Colors.grey, height: 1.6),
          ),
          const Divider(height: 30),
        ],
      ),
    );
  }
}