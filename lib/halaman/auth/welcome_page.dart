import 'package:flutter/material.dart';
import 'login_page.dart'; // Pastikan file ini sudah ada

class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});

  // Warna Biru Utama (Navy) dari Logo
  final Color _primaryBlue = const Color(0xFF1A237E);
  // Warna Biru Muda untuk Aksen/Dekorasi
  final Color _accentBlue = const Color(0xFF5D9CEC);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // --- 1. DEKORASI LATAR BELAKANG ---
          // Lingkaran besar di pojok atas
          Positioned(
            top: -100,
            right: -80,
            child: CircleAvatar(
              radius: 150,
              backgroundColor: _accentBlue.withOpacity(0.1),
            ),
          ),
          // Lingkaran kecil di tengah kiri untuk variasi visual
          Positioned(
            top: MediaQuery.of(context).size.height * 0.4,
            left: -30,
            child: CircleAvatar(
              radius: 40,
              backgroundColor: _accentBlue.withOpacity(0.1),
            ),
          ),

          // --- 2. KONTEN UTAMA ---
          SafeArea(
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Column(
                children: [
                  const Spacer(flex: 2),
                  
                  // LOGO MBG (Ditambahkan hero animation jika diperlukan nanti)
                  Hero(
                    tag: 'app_logo',
                    child: Image.asset(
                      'assets/images/logo.png', 
                      height: 200,
                      fit: BoxFit.contain,
                    ),
                  ),

                  const SizedBox(height: 40),

                  // JUDUL (Tipografi yang lebih kuat)
                  Text(
                    'Selamat Datang di FOR MBG',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w900,
                      color: _primaryBlue,
                      letterSpacing: -0.5,
                    ),
                  ),

                  const SizedBox(height: 16),

                  // DESKRIPSI (Padding ditambahkan agar teks tidak terlalu lebar)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Text(
                      'Monitoring program Makan Bergizi Gratis jadi lebih mudah, transparan, dan terintegrasi dalam satu genggaman.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 15,
                        height: 1.5,
                        color: Colors.blueGrey[400],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),

                  const Spacer(flex: 3),

                  // --- 3. TOMBOL MULAI ---
                  Column(
                    children: [
                      SizedBox(
                        width: double.infinity,
                        height: 60,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _primaryBlue,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18),
                            ),
                            elevation: 8,
                            shadowColor: _primaryBlue.withOpacity(0.4),
                          ),
                          onPressed: () {
                            // Berpindah ke LoginPage
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(builder: (_) => const LoginPage()),
                            );
                          },
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Mulai Sekarang',
                                style: TextStyle(
                                  fontSize: 17, 
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(width: 12),
                              Icon(Icons.arrow_forward_rounded, size: 22),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      // Tambahan teks kecil di bawah tombol
                      Text(
                        'Versi 1.0.0',
                        style: TextStyle(color: Colors.grey[400], fontSize: 12),
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}