import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'providers/auth_provider.dart';
import 'halaman/auth/login_page.dart';

// Import Halaman Auth & Status
import 'halaman/auth/welcome_page.dart';
import 'halaman/waiting_approval_page.dart';
import 'halaman/dashboard_umum/dashboard.dart';
import 'halaman/dashboard_umum/jadwal.dart';
import 'halaman/dashboard_umum/profil.dart';
import 'halaman/dashboard_umum/ulasan.dart';
import 'halaman/dashboard_umum/chatbot.dart';
import 'halaman/dashboard_sekolah/main_navigation_sekolah.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  GoogleFonts.config.allowRuntimeFetching = true;

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
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
        useMaterial3: true, // Pastikan menggunakan Material 3
        scaffoldBackgroundColor: const Color(0xFFF8F9FD),
        textTheme: GoogleFonts.interTextTheme(),
        colorScheme: ColorScheme.fromSeed(seedColor: navyColor),
      ),
      home: Consumer<AuthProvider>(
        builder: (context, auth, child) {
          if (auth.isLoggedIn) {
            if (auth.isApproved) {
              String role = auth.userRole?.trim().toLowerCase() ?? "";
              if (role == 'pengelola_sekolah') return const MainNavigationSekolah();
              if (role == 'lansia' || role == 'siswa') return const MainNavigationUmum();
            }
            return const WaitingApprovalPage();
          }
          return auth.showLogin ? const LoginPage() : const WelcomePage();
        },
      ),
    );
  }
}

// --- NAVIGASI DASHBOARD UMUM (SISWA & LANSIA) ---
class MainNavigationUmum extends StatelessWidget {
  const MainNavigationUmum({super.key});

  // Pindahkan daftar halaman ke sini
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

    // Gunakan Consumer agar tab berpindah saat dipicu dari Dashboard
    return Consumer<AuthProvider>(
      builder: (context, auth, child) {
        return Scaffold(
          backgroundColor: Colors.white, // Mencegah area hitam di belakang navigasi
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
                  color: Colors.black.withValues(alpha: 0.05), // FIX: Gunakan single dot dan withValues
                  blurRadius: 10,
                  offset: const Offset(0, -5),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavIcon(context, 0, Icons.grid_view_rounded, "Beranda", navyColor, auth),
                _buildNavIcon(context, 1, Icons.calendar_today_rounded, "Jadwal", navyColor, auth),
                _buildNavIcon(context, 2, Icons.smart_toy_rounded, "AI Chat", navyColor, auth),
                _buildNavIcon(context, 3, Icons.chat_bubble_outline_rounded, "Ulasan", navyColor, auth),
                _buildNavIcon(context, 4, Icons.person_outline_rounded, "Profil", navyColor, auth),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildNavIcon(
    BuildContext context,
    int index,
    IconData icon,
    String label,
    Color activeColor,
    AuthProvider auth,
  ) {
    bool isSelected = auth.currentTabIndex == index;
    return GestureDetector(
      onTap: () => auth.setTabIndex(index), // Memperbarui index di Provider
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
                color: isSelected
                    ? activeColor.withValues(alpha: 0.1) // Menggunakan withValues
                    : Colors.transparent,
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