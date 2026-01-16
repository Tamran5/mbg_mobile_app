import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

// Import Provider
import 'providers/auth_provider.dart';

// Import Halaman Auth & Status
import 'halaman/auth/login_page.dart';
import 'halaman/auth/welcome_page.dart';
import 'halaman/waiting_approval_page.dart';

// Import Halaman Dashboard
import 'halaman/dashboard_umum/dashboard.dart';
import 'halaman/dashboard_umum/jadwal.dart';
import 'halaman/dashboard_umum/profil.dart';
import 'halaman/dashboard_umum/ulasan.dart';
import 'halaman/dashboard_umum/chatbot.dart';
import 'halaman/dashboard_sekolah/main_navigation_sekolah.dart';

void main() {
  // Memastikan semua plugin (seperti storage) sudah siap sebelum aplikasi jalan
  WidgetsFlutterBinding.ensureInitialized();
  GoogleFonts.config.allowRuntimeFetching = true;

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          // Menjalankan checkLoginStatus segera setelah Provider dibuat
          create: (_) => AuthProvider()..checkLoginStatus(),
        ),
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
      title: 'MBG System',
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFF8F9FD),
        textTheme: GoogleFonts.interTextTheme(),
        colorScheme: ColorScheme.fromSeed(seedColor: navyColor),
      ),
      home: Consumer<AuthProvider>(
        builder: (context, auth, child) {
          // --- 1. LOGIKA LOADING (PENCEGAH DATA KOSONG) ---
          // Jika aplikasi masih membaca data dari storage (checkLoginStatus belum selesai), 
          // tampilkan loading agar user tidak melihat "Sekolah Tidak Terdaftar".
          if (auth.isLoading) {
            return const Scaffold(
              body: Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(navyColor),
                ),
              ),
            );
          }

          // --- 2. LOGIKA AUTENTIKASI ---
          if (auth.isLoggedIn) {
            if (auth.isApproved) {
              String role = auth.userRole?.trim().toLowerCase() ?? "";
              if (role == 'pengelola_sekolah') return const MainNavigationSekolah();
              
              // Siswa dan Lansia menggunakan Navigasi Umum
              if (role == 'lansia' || role == 'siswa') return const MainNavigationUmum();
            }
            // Jika sudah login tapi belum disetujui admin
            return const WaitingApprovalPage();
          }

          // --- 3. LOGIKA WELCOME/LOGIN ---
          return auth.showLogin ? const LoginPage() : const WelcomePage();
        },
      ),
    );
  }
}

// --- NAVIGASI DASHBOARD UMUM (SISWA & LANSIA) ---
class MainNavigationUmum extends StatelessWidget {
  const MainNavigationUmum({super.key});

  // Daftar halaman yang ditampilkan di IndexedStack
  final List<Widget> _pages = const [
    DashboardPage(),
    JadwalPage(),
    ChatbotPage(),
    UlasanPage(),
    ProfilPage(),
  ];

  @override
  Widget build(BuildContext context) {
    const Color navyColor = Color(0xFF1A237E);

    return Consumer<AuthProvider>(
      builder: (context, auth, child) {
        return Scaffold(
          backgroundColor: Colors.white,
          // IndexedStack menjaga agar halaman tidak reload saat pindah tab
          body: IndexedStack(
            index: auth.currentTabIndex,
            children: _pages,
          ),
          bottomNavigationBar: Container(
            height: 85,
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -5),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavIcon(0, Icons.grid_view_rounded, "Beranda", navyColor, auth),
                _buildNavIcon(1, Icons.calendar_today_rounded, "Jadwal", navyColor, auth),
                _buildNavIcon(2, Icons.smart_toy_rounded, "AI Chat", navyColor, auth),
                _buildNavIcon(3, Icons.chat_bubble_outline_rounded, "Ulasan", navyColor, auth),
                _buildNavIcon(4, Icons.person_outline_rounded, "Profil", navyColor, auth),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildNavIcon(
    int index,
    IconData icon,
    String label,
    Color activeColor,
    AuthProvider auth,
  ) {
    bool isSelected = auth.currentTabIndex == index;
    return GestureDetector(
      onTap: () => auth.setTabIndex(index),
      child: Container(
        color: Colors.transparent,
        width: 65,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isSelected ? activeColor.withOpacity(0.1) : Colors.transparent,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: isSelected ? activeColor : Colors.grey[400],
                size: 26,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected ? activeColor : Colors.grey[400],
              ),
            ),
          ],
        ),
      ),
    );
  }
}