import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/mbg_scaffold.dart';

class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});

  // Warna Konsisten Proyek MBG
  final Color _primaryBlue = const Color(0xFF1A237E);

  @override
  Widget build(BuildContext context) {
    // Menggunakan MbgScaffold agar background dan struktur halaman seragam
    return MbgScaffold(
      body: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          children: [
            const Spacer(flex: 2),
            
            // LOGO MBG dengan Hero animation untuk transisi mulus ke LoginPage
            Hero(
              tag: 'app_logo',
              child: Image.asset(
                'assets/images/logo.png', 
                height: 200,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) => Icon(
                  Icons.fastfood_rounded,
                  size: 100,
                  color: _primaryBlue,
                ),
              ),
            ),

            const SizedBox(height: 40),

            // JUDUL
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

            // DESKRIPSI
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

            // TOMBOL MULAI
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
                      shadowColor: _primaryBlue.withAlpha(102),
                    ),
                    onPressed: () {
                      Provider.of<AuthProvider>(context, listen: false).toggleLoginView(true);
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
    );
  }
}