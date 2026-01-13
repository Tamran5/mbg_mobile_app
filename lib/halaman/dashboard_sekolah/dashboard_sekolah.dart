import 'dart:io';
import 'package:flutter/foundation.dart'; 
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // WAJIB untuk fitur salin (Clipboard)
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/mbg_scaffold.dart';

class DashboardSekolah extends StatefulWidget {
  final Function(int) onTapMenu;
  const DashboardSekolah({super.key, required this.onTapMenu});

  @override
  State<DashboardSekolah> createState() => _DashboardSekolahState();
}

class _DashboardSekolahState extends State<DashboardSekolah> {
  final Color _primaryBlue = const Color(0xFF1A237E);
  final ImagePicker _picker = ImagePicker();
  XFile? _imageFile;

  // State untuk data statistik
  String _totalSiswa = "0";
  String _perluVerifikasi = "0";
  bool _isStatsLoading = true;
  bool _isTokenLoading = false; 

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  // --- LOGIKA DATA ---

  Future<void> _loadDashboardData() async {
    if (!mounted) return;
    setState(() => _isStatsLoading = true);
    await _fetchStats();
    if (mounted) setState(() => _isStatsLoading = false);
  }

  // Fungsi untuk memperbarui token melalui backend
  Future<void> _handleRegenerateToken() async {
    if (!mounted) return;
    setState(() => _isTokenLoading = true);
    
    final auth = Provider.of<AuthProvider>(context, listen: false);
    // Memanggil fungsi yang sudah kita buat di AuthProvider
    final success = await auth.regenerateSchoolToken(); 
    
    if (mounted) {
      setState(() => _isTokenLoading = false);
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Token baru berhasil dibuat!"), backgroundColor: Colors.green)
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Gagal memperbarui token"), backgroundColor: Colors.red)
        );
      }
    }
  }

  Future<void> _fetchStats() async {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final stats = await auth.fetchSchoolStats();
    if (mounted && stats['status'] == 'success') {
      setState(() {
        _totalSiswa = stats['data']['total_siswa'].toString();
        _perluVerifikasi = stats['data']['perlu_verifikasi'].toString();
      });
    }
  }

  // --- LOGIKA KAMERA ---
  Future<void> _pickImage() async {
    final XFile? selected = await _picker.pickImage(source: ImageSource.camera, imageQuality: 50);
    if (selected != null) setState(() => _imageFile = selected);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, auth, child) {
        return MbgScaffold(
          body: RefreshIndicator(
            onRefresh: _loadDashboardData,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),
                  _buildHeader(auth),
                  const SizedBox(height: 25),
                  _buildSummaryCard(),
                  const SizedBox(height: 25),
                  _buildTokenCard(auth), // Menampilkan Token dari Database
                  const SizedBox(height: 30),
                  const Text("Konfirmasi Kedatangan", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 12),
                  _buildArrivalCard(), 
                  const SizedBox(height: 30),
                  const Text("Menu Administrasi", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 12),
                  _buildActionGrid(context),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // --- UI COMPONENTS ---

  Widget _buildHeader(AuthProvider auth) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Selamat Datang,", style: TextStyle(color: Colors.grey, fontSize: 14)),
              Text(auth.userName ?? "Admin Sekolah", style: TextStyle(fontWeight: FontWeight.w900, fontSize: 22, color: _primaryBlue)),
              Text(auth.schoolName ?? "Institusi Belum Terdaftar", style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: Colors.black54)),
            ],
          ),
        ),
        _buildNotificationIcon(),
      ],
    );
  }

  Widget _buildSummaryCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(color: _primaryBlue, borderRadius: BorderRadius.circular(20)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem(_totalSiswa, "Siswa Aktif"),
          Container(width: 1, height: 40, color: Colors.white24),
          _buildStatItem(_perluVerifikasi, "Perlu Verifikasi"),
        ],
      ),
    );
  }

  Widget _buildTokenCard(AuthProvider auth) {
    // Mengambil token asli dari state AuthProvider (hasil dari DB Flask)
    String tokenCode = auth.registrationToken ?? "BELUM ADA";

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FA), 
        borderRadius: BorderRadius.circular(12), 
        border: Border.all(color: Colors.grey.shade300)
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("TOKEN REGISTRASI SISWA", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey)),
                  const SizedBox(height: 4),
                  // Menggunakan SelectableText agar user bisa menyorot teks jika ingin
                  SelectableText(tokenCode, style: TextStyle(color: _primaryBlue, fontWeight: FontWeight.w900, fontSize: 20)),
                ],
              ),
              Row(
                children: [
                  // Tombol Salin
                  IconButton(
                    icon: const Icon(Icons.copy_rounded, color: Colors.grey, size: 20),
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: tokenCode));
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Token disalin ke clipboard!"))
                      );
                    },
                  ),
                  // Tombol Regenerate
                  _isTokenLoading 
                    ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2))
                    : IconButton(
                        onPressed: _handleRegenerateToken,
                        icon: Icon(Icons.sync_rounded, color: _primaryBlue, size: 28),
                      ),
                ],
              ),
            ],
          ),
          const Divider(height: 24),
          const Text(
            "Pesan: Berikan kode ini kepada siswa sekolah Anda agar mereka dapat mendaftar. Token ini mencegah pendaftar ilegal.",
            style: TextStyle(fontSize: 11, color: Colors.black54, fontStyle: FontStyle.italic, height: 1.4),
          ),
        ],
      ),
    );
  }

  Widget _buildArrivalCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15), border: Border.all(color: Colors.grey.shade200)),
      child: Column(
        children: [
          GestureDetector(
            onTap: _pickImage,
            child: Container(
              height: 150,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(12),
                image: _imageFile != null 
                  ? DecorationImage(
                      image: kIsWeb 
                        ? NetworkImage(_imageFile!.path)
                        : FileImage(File(_imageFile!.path)) as ImageProvider,
                      fit: BoxFit.cover
                    ) 
                  : null,
              ),
              child: _imageFile == null ? Icon(Icons.camera_enhance_rounded, color: _primaryBlue.withOpacity(0.3), size: 40) : null,
            ),
          ),
          const SizedBox(height: 15),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _imageFile == null ? null : () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green, 
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))
              ),
              child: const Text("KONFIRMASI SEKARANG", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionGrid(BuildContext context) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 15,
      mainAxisSpacing: 15,
      childAspectRatio: 1.4,
      children: [
        _buildActionItem("Data Siswa", Icons.groups_rounded, Colors.blue, () => widget.onTapMenu(1)),
        _buildActionItem("Verifikasi", Icons.how_to_reg_rounded, Colors.orange, () => widget.onTapMenu(2)),
        _buildActionItem("Laporan", Icons.report_problem_rounded, Colors.red, () {}),
        _buildActionItem("Rekap", Icons.view_list_rounded, Colors.teal, () {}),
      ],
    );
  }

  // --- HELPERS ---

  Widget _buildStatItem(String value, String label) {
    return Column(
      children: [
        _isStatsLoading
            ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
            : Text(value, style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(color: Colors.white70, fontSize: 12)),
      ],
    );
  }

  Widget _buildActionItem(String title, IconData icon, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(15),
      child: Container(
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15), border: Border.all(color: Colors.grey.shade100)),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 8),
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationIcon() {
    return Container(
      width: 45, height: 45,
      decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle, boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)]),
      child: const Icon(Icons.notifications_none_rounded, color: Colors.black87),
    );
  }
}