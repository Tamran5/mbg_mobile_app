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
        scaffoldBackgroundColor: const Color(0xFFF8F9FD),
        textTheme: GoogleFonts.interTextTheme(),
        colorScheme: ColorScheme.fromSeed(seedColor: navyColor),
      ),
      home: Consumer<AuthProvider>(
        // Di dalam Consumer<AuthProvider> builder:
        // Di dalam Consumer<AuthProvider> builder:
        // Di dalam MBGApp -> Consumer<AuthProvider>
        builder: (context, auth, child) {
          if (auth.isLoggedIn) {
            if (auth.isApproved) {
              String role = auth.userRole?.trim().toLowerCase() ?? "";
              if (role == 'pengelola_sekolah')
                return const MainNavigationSekolah();
              if (role == 'lansia' || role == 'siswa')
                return const MainNavigationUmum();
            }
            return const WaitingApprovalPage();
          }

          // JIKA BELUM LOGIN:
          // Jika tombol mulai sudah ditekan, tampilkan Login. Jika belum, tampilkan Welcome.
          return auth.showLogin ? const LoginPage() : const WelcomePage();
        },
      ),

      // Dan pada bagian routes (jika Anda menggunakan pushNamed)
      routes: {
        '/login': (context) => const WelcomePage(),
        '/dashboard-operator': (context) => MainNavigationSekolah(),
        '/dashboard-umum': (context) => const MainNavigationUmum(),
      },
    );
  }
}

// --- NAVIGASI DASHBOARD UMUM (SISWA & LANSIA) ---
class MainNavigationUmum extends StatefulWidget {
  const MainNavigationUmum({super.key});

  @override
  State<MainNavigationUmum> createState() => _MainNavigationUmumState();
}

class _MainNavigationUmumState extends State<MainNavigationUmum> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const DashboardPage(),
    const JadwalPage(),
    const ChatbotPage(),
    const UlasanPage(),
    const ProfilPage(),
  ];

  @override
  Widget build(BuildContext context) {
    const Color navyColor = Color(0xFF1A237E);

    return Scaffold(
      body: IndexedStack(
        // Menggunakan IndexedStack agar state halaman tidak hilang saat pindah tab
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: Container(
        height: 85,
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black..withAlpha(13),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildNavIcon(0, Icons.grid_view_rounded, "Beranda", navyColor),
            _buildNavIcon(1, Icons.calendar_today_rounded, "Jadwal", navyColor),
            _buildNavIcon(2, Icons.smart_toy_rounded, "AI Chat", navyColor),
            _buildNavIcon(
              3,
              Icons.chat_bubble_outline_rounded,
              "Ulasan",
              navyColor,
            ),
            _buildNavIcon(4, Icons.person_outline_rounded, "Profil", navyColor),
          ],
        ),
      ),
    );
  }

  Widget _buildNavIcon(
    int index,
    IconData icon,
    String label,
    Color activeColor,
  ) {
    bool isSelected = _currentIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _currentIndex = index),
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
                    ? activeColor.withAlpha(26)
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
