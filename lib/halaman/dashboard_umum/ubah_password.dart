import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../widgets/mbg_scaffold.dart';
import '../../providers/auth_provider.dart';

class UbahPasswordPage extends StatefulWidget {
  const UbahPasswordPage({super.key});

  @override
  State<UbahPasswordPage> createState() => _UbahPasswordPageState();
}

class _UbahPasswordPageState extends State<UbahPasswordPage> {
  final Color _primaryBlue = const Color(0xFF1A237E);
  
  // 1. Inisialisasi Form Key dan Controller
  final _formKey = GlobalKey<FormState>();
  final _oldPassController = TextEditingController();
  final _newPassController = TextEditingController();
  final _confirmPassController = TextEditingController();

  // State untuk visibilitas password
  bool _obsOld = true;
  bool _obsNew = true;
  bool _obsConfirm = true;
  bool _isLoading = false;

  // 2. Logika Submit ke API
  // --- LOGIKA SUBMIT DENGAN KONFIRMASI ---
  void _handleUpdatePassword() {
    // 1. Validasi Form terlebih dahulu
    if (!_formKey.currentState!.validate()) return;

    // 2. Munculkan Dialog Konfirmasi
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text("Konfirmasi Perubahan", 
            style: TextStyle(fontWeight: FontWeight.bold)),
          content: const Text("Apakah Anda benar-benar yakin ingin mengubah password akun Anda?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context), // Tutup dialog
              child: const Text("Batal", style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context); // Tutup dialog
                _executeUpdate(); // Jalankan proses update ke API
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: _primaryBlue,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: const Text("Ya, Ubah", style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  // --- EKSEKUSI UPDATE KE API ---
  void _executeUpdate() async {
    setState(() => _isLoading = true);
    
    final auth = Provider.of<AuthProvider>(context, listen: false);
    
    final response = await auth.changePassword(
      _oldPassController.text,
      _newPassController.text,
    );

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (response['status'] == 'success') {
      // Munculkan Pesan Berhasil
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Row(
            children: [
              Icon(Icons.check_circle, color: Colors.white),
              SizedBox(width: 10),
              Text("Password berhasil diperbarui!"),
            ],
          ),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
        ),
      );
      
      // Beri jeda sedikit agar user bisa melihat SnackBar sebelum kembali
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) Navigator.pop(context);
      });
      
    } else {
      // Munculkan Pesan Gagal
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(response['message'] ?? "Gagal memperbarui password"),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }
  
  @override
  void dispose() {
    _oldPassController.dispose();
    _newPassController.dispose();
    _confirmPassController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MbgScaffold(
      body: Column(
        children: [
          _buildHeader(context),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Form( // 3. Bungkus dengan Form
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 20),
                    const Text(
                      "Ubah Password",
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF1A237E),
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      "Masukkan password lama dan password baru Anda di bawah ini.",
                      style: TextStyle(color: Colors.grey, fontSize: 14),
                    ),
                    const SizedBox(height: 40),

                    // Password Lama
                    _buildPasswordField(
                      "Password Lama", 
                      _oldPassController,
                      _obsOld, 
                      () => setState(() => _obsOld = !_obsOld),
                      (val) => val == null || val.isEmpty ? "Masukkan password lama" : null,
                    ),

                    // Password Baru
                    _buildPasswordField(
                      "Password Baru", 
                      _newPassController,
                      _obsNew, 
                      () => setState(() => _obsNew = !_obsNew),
                      (val) {
                        if (val == null || val.isEmpty) return "Masukkan password baru";
                        if (val.length < 6) return "Password minimal 6 karakter";
                        return null;
                      },
                    ),

                    // Konfirmasi Password Baru
                    _buildPasswordField(
                      "Konfirmasi Password Baru", 
                      _confirmPassController,
                      _obsConfirm, 
                      () => setState(() => _obsConfirm = !_obsConfirm),
                      (val) {
                        if (val != _newPassController.text) return "Password tidak cocok";
                        return null;
                      },
                    ),

                    const SizedBox(height: 40),
                    _buildSubmitButton(),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- UI COMPONENTS ---

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(10, 10, 10, 0),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
            color: _primaryBlue,
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  Widget _buildPasswordField(
    String label, 
    TextEditingController controller,
    bool isObscure, 
    VoidCallback toggle,
    String? Function(String?)? validator
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label, 
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey)
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: controller,
            obscureText: isObscure,
            validator: validator,
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.grey[50],
              suffixIcon: IconButton(
                icon: Icon(
                  isObscure ? Icons.visibility_off_rounded : Icons.visibility_rounded, 
                  color: Colors.grey,
                  size: 20,
                ), 
                onPressed: toggle
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15), 
                borderSide: BorderSide.none
              ),
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

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _handleUpdatePassword,
        style: ElevatedButton.styleFrom(
          backgroundColor: _primaryBlue,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          elevation: 0,
        ),
        child: _isLoading 
          ? const CircularProgressIndicator(color: Colors.white)
          : const Text(
              "PERBARUI PASSWORD",
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
            ),
      ),
    );
  }
}