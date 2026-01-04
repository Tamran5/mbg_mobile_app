import 'package:flutter/material.dart';

class PusatBantuanPage extends StatelessWidget {
  const PusatBantuanPage({super.key});

  final Color _primaryBlue = const Color(0xFF1A237E); // Biru Utama

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: _primaryBlue,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
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

          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // --- 2. JUDUL HALAMAN (Kiri & Besar) ---
                  const Text(
                    "Pusat Bantuan",
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF1A237E),
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    "Ada yang bisa kami bantu?",
                    style: TextStyle(color: Colors.grey, fontSize: 16),
                  ),
                  const SizedBox(height: 30),

                  // --- 3. SEARCH BAR MINIMALIS ---
                  TextField(
                    decoration: InputDecoration(
                      hintText: "Cari bantuan...",
                      prefixIcon: const Icon(Icons.search, color: Colors.grey),
                      filled: true,
                      fillColor: Colors.grey[50],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),

                  // --- 4. DAFTAR FAQ (Frequently Asked Questions) ---
                  const Text(
                    "Pertanyaan Populer",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF2D3436)),
                  ),
                  const SizedBox(height: 15),
                  _buildFaqItem("Bagaimana cara melihat jadwal menu?"),
                  _buildFaqItem("Mengapa ulasan saya tidak muncul?"),
                  _buildFaqItem("Cara mengubah foto profil?"),
                  _buildFaqItem("Informasi kandungan gizi tidak akurat?"),
                  
                  const SizedBox(height: 40),

                  // --- 5. HUBUNGI KAMI (Support) ---
                  const Text(
                    "Butuh bantuan lebih lanjut?",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.grey),
                  ),
                  const SizedBox(height: 15),
                  _buildContactCard(Icons.chat_bubble_outline_rounded, "Hubungi via WhatsApp"),
                  _buildContactCard(Icons.email_outlined, "Kirim Email Dukungan"),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFaqItem(String question) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.grey[100]!),
      ),
      child: ExpansionTile(
        title: Text(
          question,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF2D3436)),
        ),
        iconColor: _primaryBlue,
        collapsedIconColor: Colors.grey,
        children: const [
          Padding(
            padding: EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Text(
              "Anda dapat melihat langkah-langkah detail mengenai pertanyaan ini di buku panduan aplikasi atau menghubungi admin sekolah Anda.",
              style: TextStyle(color: Colors.grey, fontSize: 13, height: 1.5),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactCard(IconData icon, String title) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: _primaryBlue.withOpacity(0.05),
        borderRadius: BorderRadius.circular(15),
      ),
      child: ListTile(
        leading: Icon(icon, color: _primaryBlue),
        title: Text(
          title,
          style: TextStyle(color: _primaryBlue, fontWeight: FontWeight.bold, fontSize: 14),
        ),
        trailing: Icon(Icons.chevron_right_rounded, color: _primaryBlue),
        onTap: () {
          // Logika eksternal (buka WA atau Email)
        },
      ),
    );
  }
}