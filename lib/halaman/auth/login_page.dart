import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import 'register_page.dart';
import '../waiting_approval_page.dart';
import '../../widgets/mbg_scaffold.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final Color _primaryBlue = const Color(0xFF1A237E);
  bool _isPasswordVisible = false;

  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  void _handleLogin() async {
  final authProvider = Provider.of<AuthProvider>(context, listen: false);

  if (_phoneController.text.isEmpty || _passwordController.text.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Nomor HP dan Password wajib diisi")),
    );
    return;
  }

  // 1. Jalankan proses login
  final res = await authProvider.login(
    _phoneController.text,
    _passwordController.text,
  );

  // 2. CEK APAKAH WIDGET MASIH AKTIF
  // Ini untuk mencegah error "widget has been unmounted"
  if (!mounted) return;

  if (res['status'] != 'success') {
    // 3. Tampilkan pesan error hanya jika widget masih ada di layar
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(res['message'] ?? "Login Gagal"),
        backgroundColor: Colors.red,
      ),
    );
  }
}

  @override
  void dispose() {
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    // 2. Ganti Scaffold dengan MbgScaffold
    return MbgScaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 30),
        child: Column(
          children: [
            const SizedBox(height: 60),

            // Logo
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

            const SizedBox(height: 40),

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
              label: "Nomor WhatsApp",
              icon: Icons.phone_android_outlined,
              controller: _phoneController,
              type: TextInputType.phone,
            ),
            const SizedBox(height: 20),
            _buildTextField(
              label: "Kata Sandi",
              icon: Icons.lock_open_rounded,
              controller: _passwordController,
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
            _buildPrimaryButton(
              authProvider.isLoading ? "Mohon Tunggu..." : "Masuk",
              authProvider.isLoading ? null : _handleLogin,
            ),

            const SizedBox(height: 30),

            // Divider
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

            _buildSocialButton(
              label: "Masuk dengan Google",
              icon: FontAwesomeIcons.google,
              color: Colors.redAccent,
              onPressed: () {},
            ),

            const SizedBox(height: 40),
            _buildRegisterLink(),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // --- WIDGET HELPERS (Tetap sama) ---

  Widget _buildTextField({
    required String label,
    required IconData icon,
    required TextEditingController controller,
    bool isPassword = false,
    TextInputType type = TextInputType.text,
  }) {
    return TextField(
      controller: controller,
      keyboardType: type,
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

  Widget _buildPrimaryButton(String label, VoidCallback? onPressed) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: onPressed == null ? Colors.grey : _primaryBlue,
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
