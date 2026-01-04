import 'package:flutter/material.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  // Fungsi untuk mendapatkan sapaan otomatis berdasarkan waktu
  String _getGreeting() {
    var hour = DateTime.now().hour;
    if (hour < 11) return "Selamat Pagi";
    if (hour < 15) return "Selamat Siang";
    if (hour < 19) return "Selamat Sore";
    return "Selamat Malam";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // --- 1. DEKORASI BULAT BIRU (Identik dengan Dashboard) ---
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
                  const SizedBox(height: 20),
                  
                  // --- 2. HEADER: SAPAAN, NAMA USER, & NAMA SEKOLAH ---
                  _buildHeader(),

                  const SizedBox(height: 25),

                  // --- 3. ANALISIS GIZI HARI INI ---
                  const Text("Analisis Gizi Hari Ini", 
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      _buildNutritionWidget("Kalori", "580", "Kkal", Icons.bolt, Colors.orange),
                      const SizedBox(width: 12),
                      _buildNutritionWidget("Protein", "25.2", "gram", Icons.egg_alt, Colors.cyan),
                      const SizedBox(width: 12),
                      _buildNutritionWidget("Lemak", "12.5", "gram", Icons.water_drop, Colors.green),
                    ],
                  ),

                  const SizedBox(height: 25),

                  // --- 4. KARTU MENU UTAMA ---
                  const Text("Menu Makan Siang", 
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 12),
                  _buildFeaturedMenuCard(),

                  const SizedBox(height: 25),

                  // --- 5. TIPS HARI INI ---
                  _buildTipsCard(),

                  const SizedBox(height: 25),

                  // --- 6. RATING RASA ---
                  const Text("Bagaimana rasa makanan hari ini?", 
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 12),
                  _buildRatingSection(),

                  const SizedBox(height: 30),

                  // --- 7. ARTIKEL UNTUKMU ---
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text("Artikel Untukmu", 
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Color(0xFF1A237E))),
                      const Text("Lihat Semua", 
                        style: TextStyle(color: Colors.blueAccent, fontSize: 12, fontWeight: FontWeight.w600)),
                    ],
                  ),
                  const SizedBox(height: 15),
                  _buildArticleItem(
                    "Pentingnya Protein bagi Pelajar",
                    "Nutrisi",
                    "https://images.unsplash.com/photo-1490818387583-1baba5e638af?q=80&w=1000",
                  ),
                  const SizedBox(height: 40), 
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Sapaan otomatis berdasarkan waktu
            Text("Halo, ${_getGreeting()}!", 
              style: const TextStyle(color: Colors.grey, fontSize: 14, fontWeight: FontWeight.w500)),
            // Nama Lengkap Siswa
            const Text("Bagas Adi Nugroho", 
              style: TextStyle(fontWeight: FontWeight.w900, fontSize: 22, color: Color(0xFF1A237E))),
            // Nama Sekolah Tetap Ada
            const Text("SMAN 01 Jakarta", 
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15, color: Color(0xFF2D3436))),
          ],
        ),
        // Tombol Notifikasi
        Container(
          width: 48, height: 48,
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 10, offset: const Offset(0, 4))],
          ),
          child: const Icon(Icons.notifications_none_rounded, color: Colors.black87),
        ),
      ],
    );
  }

  Widget _buildNutritionWidget(String title, String value, String unit, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 8)],
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(height: 8),
            Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            Text(unit, style: const TextStyle(color: Colors.grey, fontSize: 10)),
          ],
        ),
      ),
    );
  }

  Widget _buildFeaturedMenuCard() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFF1A237E), 
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            child: Image.network(
              "https://media.suara.com/pictures/653x366/2025/01/16/94698-cuitan-warganet-soal-menu-makan-bergizi-gratis-hari-ke-7.jpg", 
              height: 160, width: double.infinity, fit: BoxFit.cover,
            ),
          ),
          const Padding(
            padding: EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("PAKET A", style: TextStyle(color: Colors.white60, fontSize: 12, fontWeight: FontWeight.bold)),
                SizedBox(height: 4),
                Text("Nasi, Ayam Goreng, Sayur Lodeh, & Buah",
                  style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                SizedBox(height: 12),
                Text("Terverifikasi Ahli Gizi", style: TextStyle(color: Colors.white70, fontSize: 11)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTipsCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: const Color(0xFFE8F5E9), borderRadius: BorderRadius.circular(20)),
      child: Row(
        children: [
          const Icon(Icons.lightbulb_outline_rounded, color: Colors.green, size: 28),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Tips Hari Ini", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green)),
                Text("Nutrisi lengkap bantu fokus belajarmu!", style: TextStyle(color: Colors.green[800], fontSize: 12)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRatingSection() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildEmojiButton("😋", "Enak"),
        _buildEmojiButton("😐", "Biasa"),
        _buildEmojiButton("☹️", "Kurang"),
      ],
    );
  }

  Widget _buildEmojiButton(String emoji, String label) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white, borderRadius: BorderRadius.circular(15), 
          border: Border.all(color: Colors.grey.withOpacity(0.1))
        ),
        child: Column(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 22)),
            Text(label, style: const TextStyle(fontSize: 11, color: Colors.grey)),
          ],
        ),
      ),
    );
  }

  Widget _buildArticleItem(String title, String category, String imgUrl) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(16), 
            child: Image.network(imgUrl, width: 75, height: 75, fit: BoxFit.cover)
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(category.toUpperCase(), 
                  style: const TextStyle(color: Color(0xFF1A237E), fontSize: 10, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14), maxLines: 2),
                const SizedBox(height: 6),
                const Text("5 Menit Baca", style: TextStyle(color: Colors.grey, fontSize: 11)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}