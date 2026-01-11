import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/mbg_scaffold.dart';
import 'otp_verification_page.dart';

class RequestEmailChangePage extends StatefulWidget {
  const RequestEmailChangePage({super.key});

  @override
  State<RequestEmailChangePage> createState() => _RequestEmailChangePageState();
}

class _RequestEmailChangePageState extends State<RequestEmailChangePage> {
  final Color _primaryBlue = const Color(0xFF1A237E);
  final _formKey = GlobalKey<FormState>();
  
  final _newEmailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isObscure = true;

  @override
  void dispose() {
    _newEmailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleRequestOtp() async {
    if (!_formKey.currentState!.validate()) return;

    final auth = Provider.of<AuthProvider>(context, listen: false);
    
    // 1. Panggil API request-change-email
    final res = await auth.requestChangeEmail(
      _newEmailController.text, 
      _passwordController.text
    );

    if (mounted) {
      if (res['status'] == 'success') {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Kode OTP telah dikirim ke email baru Anda"), backgroundColor: Colors.green),
        );
        
        // 2. Navigasi ke Halaman Verifikasi OTP
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => OtpVerificationPage(newEmail: _newEmailController.text),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(res['message'] ?? "Gagal mengirim OTP"), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    
    return MbgScaffold(
      body: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 20),
                    const Text(
                      "Ganti Email",
                      style: TextStyle(fontSize: 32, fontWeight: FontWeight.w900, color: Color(0xFF1A237E)),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      "Demi keamanan, masukkan password Anda dan alamat email baru yang ingin digunakan.",
                      style: TextStyle(color: Colors.grey, fontSize: 14),
                    ),
                    const SizedBox(height: 40),

                    // Input Email Baru
                    _buildInputField(
                      label: "Email Baru",
                      controller: _newEmailController,
                      icon: Icons.email_outlined,
                      hint: "Masukkan email baru",
                      validator: (val) => val != null && val.contains('@') ? null : "Email tidak valid",
                    ),

                    // Input Password Konfirmasi
                    _buildInputField(
                      label: "Password Saat Ini",
                      controller: _passwordController,
                      icon: Icons.lock_outline,
                      hint: "Masukkan password untuk verifikasi",
                      isPassword: true,
                      validator: (val) => val != null && val.isNotEmpty ? null : "Password wajib diisi",
                    ),

                    const SizedBox(height: 40),
                    _buildSubmitButton(auth),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(10, 10, 10, 0),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  Widget _buildInputField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    required String hint,
    bool isPassword = false,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey)),
          const SizedBox(height: 8),
          TextFormField(
            controller: controller,
            obscureText: isPassword ? _isObscure : false,
            validator: validator,
            decoration: InputDecoration(
              prefixIcon: Icon(icon, color: _primaryBlue.withOpacity(0.5)),
              hintText: hint,
              hintStyle: const TextStyle(color: Colors.grey, fontSize: 14),
              suffixIcon: isPassword 
                ? IconButton(
                    icon: Icon(_isObscure ? Icons.visibility_off : Icons.visibility),
                    onPressed: () => setState(() => _isObscure = !_isObscure),
                  )
                : null,
              filled: true,
              fillColor: Colors.grey[50],
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15), 
                borderSide: BorderSide(color: Colors.grey.withAlpha(26))
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubmitButton(AuthProvider auth) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: auth.isLoading ? null : _handleRequestOtp,
        style: ElevatedButton.styleFrom(
          backgroundColor: _primaryBlue,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        ),
        child: auth.isLoading 
          ? const CircularProgressIndicator(color: Colors.white)
          : const Text("KIRIM KODE VERIFIKASI", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );
  }
}