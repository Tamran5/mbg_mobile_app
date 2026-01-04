import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../main.dart';
import '../dashboard_sekolah/main_navigation_sekolah.dart';
import 'register_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final Color _primaryBlue = const Color(0xFF1A237E);
  bool _isPasswordVisible = false;

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

          // --- 2. KONTEN UTAMA ---
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 30),
              child: Column(
                children: [
                  const SizedBox(height: 80),

                  // Logo Flat (Tanpa Glow/Animasi)
                  Center(
                    child: Image.asset(
                      'assets/images/logo.png',
                      height: 160,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) => Icon(
                        Icons.fastfood_rounded,
                        size: 100,
                        color: _primaryBlue,
                      ),
                    ),
                  ),

                  const SizedBox(height: 50),

                  Text(
                    "Selamat Datang",
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w900,
                      color: _primaryBlue,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Silakan masuk untuk melanjutkan",
                    style: TextStyle(fontSize: 15, color: Colors.grey[600]),
                  ),

                  const SizedBox(height: 40),

                  // Input Fields
                  _buildTextField(
                    label: "NIK atau Nomor HP",
                    icon: Icons.person_pin_outlined,
                  ),
                  const SizedBox(height: 20),
                  _buildTextField(
                    label: "Kata Sandi",
                    icon: Icons.lock_open_rounded,
                    isPassword: true,
                  ),

                  const SizedBox(height: 10),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () {},
                      child: Text(
                        "Lupa Kata Sandi?",
                        style: TextStyle(
                          color: _primaryBlue,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Tombol Masuk
                  _buildPrimaryButton("Masuk", () {
                    // Navigasi ke MainNavigation agar Navbar muncul
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (_) => const MainNavigationSekolah()),
                    );
                  }),

                  const SizedBox(height: 30),

                  // Pemisah (Divider)
                  Row(
                    children: [
                      Expanded(child: Divider(color: Colors.grey[200])),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 15),
                        child: Text(
                          "Atau masuk dengan",
                          style: TextStyle(color: Colors.grey, fontSize: 12),
                        ),
                      ),
                      Expanded(child: Divider(color: Colors.grey[200])),
                    ],
                  ),

                  const SizedBox(height: 25),

                  // Tombol Google
                  _buildSocialButton(
                    label: "Masuk dengan Google",
                    icon: FontAwesomeIcons.google,
                    color: Colors.redAccent,
                    onPressed: () {
                      // Logika Google Sign In
                    },
                  ),

                  const SizedBox(height: 40),
                  _buildRegisterLink(),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- WIDGET HELPERS ---

  Widget _buildTextField({
    required String label,
    required IconData icon,
    bool isPassword = false,
  }) {
    return TextField(
      obscureText: isPassword && !_isPasswordVisible,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: _primaryBlue, size: 22),
        suffixIcon: isPassword
            ? IconButton(
                icon: Icon(
                  _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                  color: Colors.grey,
                  size: 20,
                ),
                onPressed: () =>
                    setState(() => _isPasswordVisible = !_isPasswordVisible),
              )
            : null,
        filled: true,
        fillColor: Colors.grey[50],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(color: Colors.grey[100]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(color: _primaryBlue, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(vertical: 18),
      ),
    );
  }

  Widget _buildPrimaryButton(String label, VoidCallback onPressed) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: _primaryBlue,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          elevation: 0,
        ),
        onPressed: onPressed,
        child: Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildSocialButton({
    required String label,
    required IconData icon,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: OutlinedButton.icon(
        icon: FaIcon(icon, color: color, size: 18),
        label: Text(
          label,
          style: const TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.w600,
          ),
        ),
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: Colors.grey[200]!),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
        ),
        onPressed: onPressed,
      ),
    );
  }

  Widget _buildRegisterLink() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text("Belum punya akun? ", style: TextStyle(color: Colors.grey[600])),
        GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const RegisterPage()),
            );
          },
          child: Text(
            "Daftar Sekarang",
            style: TextStyle(color: _primaryBlue, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }
}
