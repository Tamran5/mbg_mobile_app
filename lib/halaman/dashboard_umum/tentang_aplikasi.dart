import 'package:flutter/material.dart';
import '../../widgets/mbg_scaffold.dart';

class TentangAplikasiPage extends StatelessWidget {
  const TentangAplikasiPage({super.key});

  final Color _primaryBlue = const Color(0xFF1A237E);

  @override
  Widget build(BuildContext context) {
    return MbgScaffold(
      body: Column(
        children: [
          _buildHeader(context),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 30),

                  // LOGO ASLI MBG
                  Center(
                    child: Image.asset(
                      'assets/images/logo.png',
                      height: 180,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) => Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.grey[50],
                          shape: BoxShape.circle,
                        ),
                        child: Icon(Icons.fastfood_rounded, size: 80, color: _primaryBlue),
                      ),
                    ),
                  ),

                  const SizedBox(height: 30),

                  
                  Text(
                    "Program Makan Bergizi Gratis",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                      color: _primaryBlue,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    "Versi 1.0.0",
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 40),

                  // --- INFO SECTIONS ---
                  _buildInfoSection(
                    "Apa itu MBG?", 
                    "Makan Bergizi Gratis (MBG) adalah program pemerintah untuk memastikan setiap siswa mendapatkan asupan nutrisi seimbang setiap hari sekolah guna mendukung pertumbuhan fisik dan fokus belajar yang optimal."
                  ),
                  
                  _buildInfoSection(
                    "Tujuan Aplikasi", 
                    "Aplikasi ini membantu ekosistem sekolah memantau jadwal menu, melihat analisis gizi harian, serta memberikan ulasan langsung untuk menjaga kualitas layanan makanan."
                  ),
                  
                  _buildInfoSection(
                    "Standar Gizi 2025", 
                    "Setiap menu dirancang secara ilmiah sesuai Standar Gizi 2025 oleh ahli diet profesional untuk memenuhi AKG (Angka Kecukupan Gizi) harian anak sekolah."
                  ),

                  const SizedBox(height: 40),
                  
                  const Text(
                    "© 2026 Tim Pengembang MBG",
                    style: TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.w600),
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

  // --- UI COMPONENTS ---

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(10, 10, 10, 0),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
            color: _primaryBlue,
            onPressed: () => Navigator.pop(context),
          ),
          const Expanded(
            child: Text(
              "Tentang Aplikasi",
              style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(width: 48), // Penyeimbang IconButton agar teks tetap di tengah
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
            style: const TextStyle(
              fontSize: 16, 
              fontWeight: FontWeight.w800, 
              color: Color(0xFF2D3436)
            ),
          ),
          const SizedBox(height: 10),
          Text(
            content,
            textAlign: TextAlign.justify,
            style: const TextStyle(
              fontSize: 14, 
              color: Colors.black54, 
              height: 1.6,
              fontWeight: FontWeight.w500
            ),
          ),
          const SizedBox(height: 15),
          Divider(color: Colors.grey.withOpacity(0.1), thickness: 1.5),
        ],
      ),
    );
  }
}