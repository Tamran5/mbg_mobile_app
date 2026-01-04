import 'package:flutter/material.dart';

class UbahPasswordPage extends StatefulWidget {
  const UbahPasswordPage({super.key});

  @override
  State<UbahPasswordPage> createState() => _UbahPasswordPageState();
}

class _UbahPasswordPageState extends State<UbahPasswordPage> {
  final Color _primaryBlue = const Color(0xFF1A237E);
  bool _obsOld = true;
  bool _obsNew = true;
  bool _obsConfirm = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Ubah Password", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF1A237E),
      ),
      body: Stack(
        children: [
          // Dekorasi Bulat Biru
          Positioned(
            top: -70, right: -50,
            child: Container(
              width: 250, height: 250,
              decoration: BoxDecoration(color: const Color(0xFF5D9CEC).withOpacity(0.12), shape: BoxShape.circle),
            ),
          ),

          SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 30),
                const Text("Masukkan password lama dan password baru Anda di bawah ini.", style: TextStyle(color: Colors.grey, fontSize: 14)),
                const SizedBox(height: 40),

                _buildPasswordField("Password Lama", _obsOld, () => setState(() => _obsOld = !_obsOld)),
                _buildPasswordField("Password Baru", _obsNew, () => setState(() => _obsNew = !_obsNew)),
                _buildPasswordField("Konfirmasi Password Baru", _obsConfirm, () => setState(() => _obsConfirm = !_obsConfirm)),

                const SizedBox(height: 40),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _primaryBlue,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                      elevation: 0,
                    ),
                    child: const Text("Perbarui Password", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPasswordField(String label, bool isObscure, VoidCallback toggle) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.grey)),
          const SizedBox(height: 8),
          TextFormField(
            obscureText: isObscure,
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.grey[50], // Gaya template bersih
              suffixIcon: IconButton(icon: Icon(isObscure ? Icons.visibility_off_rounded : Icons.visibility_rounded, color: Colors.grey), onPressed: toggle),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide(color: Colors.grey.withOpacity(0.1))),
            ),
          ),
        ],
      ),
    );
  }
}