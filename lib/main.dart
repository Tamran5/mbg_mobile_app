import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'providers/auth_provider.dart';

// Import Halaman
import 'halaman/dashboard_umum/dashboard.dart'; 
import 'halaman/dashboard_umum/jadwal.dart';
import 'halaman/dashboard_umum/profil.dart';     
import 'halaman/dashboard_umum/ulasan.dart';     
import 'halaman/dashboard_umum/chatbot.dart'; 
import 'halaman/auth/welcome_page.dart'; 
// import 'halaman/auth/waiting_approval_page.dart'; // Buat halaman ini nanti

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  GoogleFonts.config.allowRuntimeFetching = true;
  
  runApp(
    // 1. WAJIB: Daftarkan AuthProvider di puncak aplikasi
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()..checkLoginStatus()),
      ],
      child: const MBGApp(),
    ),
  );
}

class MBGApp extends StatelessWidget {
  const MBGApp({super.key});

  @override
  Widget build(BuildContext context) {
    const Color navyColor = Color(0xFF1A237E);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: const Color(0xFFF8F9FD),
        fontFamily: 'Inter',
        colorScheme: ColorScheme.fromSeed(seedColor: navyColor),
      ),
      // 2. LOGIKA AUTO-ROUTE: Menentukan halaman awal berdasarkan status login
      home: Consumer<AuthProvider>(
        builder: (context, auth, child) {
          // Tampilkan loading saat mengecek storage
          if (auth.isLoading) {
            return const Scaffold(body: Center(child: CircularProgressIndicator()));
          }

          // Cek apakah sudah login?
          if (auth.isLoggedIn) {
            // Cek apakah sudah disetujui oleh Admin Dapur?
            if (auth.isApproved) {
              return const MainNavigation();
            } else {
              // Jika belum disetujui, arahkan ke halaman menunggu (atau buat widget sementara)
              return const WaitingApprovalPlaceholder(); 
            }
          }

          // Jika belum login, tampilkan WelcomePage
          return const WelcomePage();
        },
      ),
    );
  }
}

// --- WIDGET SEMENTARA UNTUK MENUNGGU VERIFIKASI ---
class WaitingApprovalPlaceholder extends StatelessWidget {
  const WaitingApprovalPlaceholder({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.timer_outlined, size: 80, color: Colors.orange),
            const SizedBox(height: 20),
            const Text("Akun Dalam Peninjauan", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            const Padding(
              padding: EdgeInsets.all(30),
              child: Text("Admin Dapur sedang memverifikasi dokumen Anda. Silakan cek kembali nanti.", textAlign: TextAlign.center),
            ),
            ElevatedButton(
              onPressed: () => Provider.of<AuthProvider>(context, listen: false).refreshApprovalStatus(),
              child: const Text("CEK STATUS TERBARU"),
            ),
            TextButton(
              onPressed: () => Provider.of<AuthProvider>(context, listen: false).logout(),
              child: const Text("Keluar / Ganti Akun"),
            )
          ],
        ),
      ),
    );
  }
}

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const DashboardPage(),
    const JadwalPage(),
    const ChatbotPage(),
    const UlasanPage(),
    const ProfilPage()
  ];

  @override
  Widget build(BuildContext context) {
    // Definisi warna Navy Blue agar konsisten
    const Color navyColor = Color(0xFF1A237E);

    return Scaffold(
      body: _pages[_currentIndex], 

      bottomNavigationBar: Container(
        height: 80,
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05), 
              blurRadius: 10, 
              offset: const Offset(0, -5)
            )
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildNavIcon(0, Icons.grid_view_rounded, "Beranda", navyColor),
            _buildNavIcon(1, Icons.calendar_today_rounded, "Jadwal", navyColor),
            _buildNavIcon(2, Icons.smart_toy_rounded, "Chatbot", navyColor), 
            _buildNavIcon(3, Icons.chat_bubble_outline_rounded, "Ulasan", navyColor),
            _buildNavIcon(4, Icons.person_outline_rounded, "Profil", navyColor),
          ],
        ),
      ),
    );
  }

  Widget _buildNavIcon(int index, IconData icon, String label, Color activeColor) {
    bool isSelected = _currentIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _currentIndex = index),
      child: Container(
        color: Colors.transparent,
        width: 65, // Memberi ruang agar teks tidak terpotong
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon, 
              color: isSelected ? activeColor : Colors.grey[300], 
              size: 24
            ),
            const SizedBox(height: 4),
            Text(
              label, 
              style: TextStyle(
                fontSize: 10, 
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected ? activeColor : Colors.grey[300]
              )
            ),
          ],
        ),
      ),
    );
  }
}