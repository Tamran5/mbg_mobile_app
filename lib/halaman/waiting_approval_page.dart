import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';

class WaitingApprovalPage extends StatefulWidget {
  const WaitingApprovalPage({super.key});

  @override
  State<WaitingApprovalPage> createState() => _WaitingApprovalPageState();
}

class _WaitingApprovalPageState extends State<WaitingApprovalPage> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final Color _primaryBlue = const Color(0xFF1A237E);
  final Color _softBlue = const Color(0xFFE8EAF6);

  @override
  void initState() {
    super.initState();
    // Animasi denyut halus agar tidak kaku
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Dekorasi Background Blobs
          Positioned(top: -100, right: -50, child: _buildDecorationCircle(300, _softBlue.withOpacity(0.5))),
          Positioned(bottom: -50, left: -50, child: _buildDecorationCircle(200, _softBlue.withOpacity(0.3))),

          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Logo Verifikasi Berdenyut (Lebih Manusiawi/Administratif)
                  ScaleTransition(
                    scale: Tween(begin: 0.95, end: 1.05).animate(_controller),
                    child: Container(
                      padding: const EdgeInsets.all(30),
                      decoration: BoxDecoration(
                        color: _softBlue,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.fact_check_rounded, // Ikon pemeriksaan dokumen
                        size: 80,
                        color: _primaryBlue,
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),

                  // Judul & Deskripsi
                  Text(
                    "Verifikasi Akun",
                    style: TextStyle(fontSize: 26, fontWeight: FontWeight.w900, color: _primaryBlue),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    "Halo ${authProvider.userName ?? 'User'},\nAdmin kami sedang meninjau dokumen pendaftaran untuk ${authProvider.schoolName ?? 'Anda'}.",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 15, color: Colors.grey[600], height: 1.5),
                  ),
                  const SizedBox(height: 40),

                  // --- STATUS TRACKER (Agar terasa seperti proses nyata) ---
                  _buildStatusTracker(),
                  const SizedBox(height: 50),

                  // Tombol Cek Status
                  authProvider.isLoading
                      ? CircularProgressIndicator(color: _primaryBlue)
                      : _buildActionButton(authProvider),

                  const SizedBox(height: 20),
                  _buildLogoutButton(authProvider),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDecorationCircle(double size, Color color) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }

  Widget _buildStatusTracker() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildStep(Icons.check_circle, "Daftar", true),
        _buildConnector(true),
        _buildStep(Icons.hourglass_empty_rounded, "Tinjau", true),
        _buildConnector(false),
        _buildStep(Icons.verified_user_outlined, "Selesai", false),
      ],
    );
  }

  Widget _buildStep(IconData icon, String label, bool isActive) {
    return Column(
      children: [
        Icon(icon, color: isActive ? _primaryBlue : Colors.grey[300], size: 28),
        const SizedBox(height: 8),
        Text(label, style: TextStyle(fontSize: 12, color: isActive ? _primaryBlue : Colors.grey[400], fontWeight: isActive ? FontWeight.bold : FontWeight.normal)),
      ],
    );
  }

  Widget _buildConnector(bool isActive) {
    return Container(
      width: 40,
      height: 2,
      margin: const EdgeInsets.only(bottom: 20),
      color: isActive ? _primaryBlue : Colors.grey[200],
    );
  }

  Widget _buildActionButton(AuthProvider auth) {
  return SizedBox(
    width: double.infinity,
    height: 56,
    child: ElevatedButton(
      onPressed: () async {
        // Fungsi ini akan menembak endpoint /check-status di Flask
        bool approved = await auth.refreshApprovalStatus();
        
        if (approved && mounted) {
          // TIDAK PERLU Navigator.push karena main.dart sudah memantau isApproved
          _showSnackBar("Akun berhasil diverifikasi! Mengalihkan...");
        } else if (mounted) {
          _showSnackBar("Dokumen Anda masih dalam antrean peninjauan.");
        }
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: _primaryBlue,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        elevation: 0,
      ),
      child: const Text("CEK STATUS", 
        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
    ),
  );
}

  Widget _buildLogoutButton(AuthProvider auth) {
    return TextButton(
      onPressed: () async {
        await auth.logout();
        if (mounted) Navigator.pushReplacementNamed(context, '/login');
      },
      child: const Text("Keluar & Gunakan Akun Lain", style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
    );
  }

  void _showSnackBar(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg), behavior: SnackBarBehavior.floating));
  }
}