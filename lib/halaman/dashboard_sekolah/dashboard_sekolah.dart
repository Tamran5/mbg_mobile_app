import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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

  // Data gambar dalam Bytes (Aman untuk Web & Mobile)
  Uint8List? _imageBytes;
  String? _imageName;

  String _totalSiswa = "0";
  String _perluVerifikasi = "0";
  bool _isStatsLoading = true;
  bool _isTokenLoading = false;
  bool _isConfirming = false;
  bool _hasConfirmedToday = false; // Status pembatasan harian

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final auth = Provider.of<AuthProvider>(context, listen: false);
      auth.startStatsPolling(); // Memulai pemantauan notifikasi otomatis
      _loadDashboardData();
    });
  }

  // --- LOGIKA DATA ---

  Future<void> _loadDashboardData() async {
    if (!mounted) return;
    setState(() => _isStatsLoading = true);
    await _fetchStats();
    if (mounted) setState(() => _isStatsLoading = false);
  }

  Future<void> _fetchStats() async {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final stats = await auth.fetchSchoolStats();
    if (mounted && stats['status'] == 'success') {
      setState(() {
        _totalSiswa = stats['data']['total_siswa']?.toString() ?? "0";
        _perluVerifikasi = stats['data']['perlu_verifikasi']?.toString() ?? "0";
        // Sinkronisasi status konfirmasi dari server
        _hasConfirmedToday = stats['data']['has_confirmed_today'] ?? false;
      });
    }
  }

  Future<void> _pickImage() async {
    // Membuka kamera langsung (bukan galeri)
    final XFile? selected = await _picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 50,
    );

    if (selected != null) {
      final bytes = await selected.readAsBytes(); // Membaca file tanpa dart:io
      setState(() {
        _imageBytes = bytes;
        _imageName = selected.name;
      });
    }
  }

  Future<void> _handleConfirmArrival() async {
    if (_imageBytes == null) return;

    setState(() => _isConfirming = true);
    final auth = Provider.of<AuthProvider>(context, listen: false);

    // Mengirim data gambar ke backend Flask
    bool success = await auth.uploadArrivalPhoto(_imageBytes!, _imageName!);

    if (mounted) {
      setState(() {
        _isConfirming = false;
        if (success) {
          _imageBytes = null;
          _hasConfirmedToday = true; // Langsung kunci akses setelah berhasil
        }
      });

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Kedatangan berhasil dikonfirmasi!"),
            backgroundColor: Colors.green,
          ),
        );
      }
    }
  }

  Future<void> _handleRegenerateToken() async {
    setState(() => _isTokenLoading = true);
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final success = await auth.regenerateSchoolToken();
    if (mounted) setState(() => _isTokenLoading = false);
  }

  // --- UI COMPONENTS ---

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
                  _buildTokenCard(auth),
                  const SizedBox(height: 30),
                  const Text(
                    "Konfirmasi Kedatangan",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 12),
                  _buildArrivalCard(), // Card yang berubah status secara dinamis
                  const SizedBox(height: 30),
                  const Text(
                    "Menu Administrasi",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 12),
                  _buildActionGrid(context, auth),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildArrivalCard() {
    // Tampilan jika sudah melakukan konfirmasi hari ini
    if (_hasConfirmedToday) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.green.shade50,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: Colors.green.shade200),
        ),
        child: Column(
          children: [
            const Icon(
              Icons.check_circle_rounded,
              color: Colors.green,
              size: 50,
            ),
            const SizedBox(height: 10),
            const Text(
              "Laporan Hari Ini Selesai",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
            Text(
              "Bukti kedatangan telah terekam di sistem.",
              style: TextStyle(fontSize: 12, color: Colors.green.shade700),
            ),
          ],
        ),
      );
    }

    // Tampilan kamera jika belum konfirmasi
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          GestureDetector(
            onTap: _isConfirming ? null : _pickImage,
            child: Container(
              height: 150,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(12),
                image: _imageBytes != null
                    ? DecorationImage(
                        image: MemoryImage(_imageBytes!),
                        fit: BoxFit.cover,
                      )
                    : null,
              ),
              child: _imageBytes == null
                  ? Icon(
                      Icons.camera_enhance_rounded,
                      color: _primaryBlue.withOpacity(0.3),
                      size: 40,
                    )
                  : null,
            ),
          ),
          const SizedBox(height: 15),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: (_imageBytes == null || _isConfirming)
                  ? null
                  : _handleConfirmArrival,
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
              child: _isConfirming
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : const Text(
                      "KONFIRMASI SEKARANG",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(AuthProvider auth) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Selamat Datang,",
                style: TextStyle(color: Colors.grey, fontSize: 14),
              ),
              Text(
                auth.userName ?? "Admin Sekolah",
                style: TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 22,
                  color: _primaryBlue,
                ),
              ),
              Text(
                auth.schoolName ?? "Institusi Memuat...",
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                  color: Colors.black54,
                ),
              ),
            ],
          ),
        ),
        _buildNotificationIcon(auth),
      ],
    );
  }

  Widget _buildNotificationIcon(AuthProvider auth) {
    return GestureDetector(
      onTap: () => _showNotificationCenter(context, auth),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: 45,
            height: 45,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.notifications_none_rounded,
              color: Colors.black87,
            ),
          ),
          if (auth.pendingCount != "0")
            Positioned(
              right: -2,
              top: -2,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                ),
                child: Text(
                  auth.pendingCount,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  void _showNotificationCenter(BuildContext context, AuthProvider auth) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: "NotificationCenter",
      barrierColor: Colors.black54, // Latar belakang redup
      transitionDuration: const Duration(milliseconds: 400),
      pageBuilder: (context, anim1, anim2) {
        return Align(
          alignment: Alignment.topCenter,
          child: Container(
            width: double.infinity,
            // Membatasi tinggi agar tidak menutupi seluruh layar
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.7,
            ),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(30)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 20,
                  offset: Offset(0, 10),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: SafeArea(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(height: 15),
                    const Text(
                      "Pemberitahuan Terbaru",
                      style: TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 18,
                        color: Color(0xFF1A237E),
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      "${auth.pendingStudentsList.length} pendaftar perlu ditinjau",
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                    const SizedBox(height: 15),
                    if (auth.pendingStudentsList.isEmpty)
                      const Padding(
                        padding: EdgeInsets.all(40),
                        child: Text(
                          "Tidak ada notifikasi baru.",
                          style: TextStyle(color: Colors.grey),
                        ),
                      )
                    else
                      Flexible(
                        child: ListView.separated(
                          shrinkWrap: true,
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: auth.pendingStudentsList.length,
                          separatorBuilder: (context, index) =>
                              const SizedBox(height: 10),
                          itemBuilder: (context, index) {
                            final siswa = auth.pendingStudentsList[index];

                            // Ambil detail waktu dari backend (asumsi ada field 'created_at')
                            // Contoh format: "10 menit lalu" atau "14:20"
                            String waktu = siswa['waktu_daftar'] ?? "Baru saja";

                            return Container(
                              decoration: BoxDecoration(
                                color: Colors.blue.shade50.withOpacity(0.5),
                                borderRadius: BorderRadius.circular(15),
                              ),
                              child: ListTile(
                                leading: CircleAvatar(
                                  backgroundColor: Colors.blue.shade100,
                                  child: const Icon(
                                    Icons.person_add_rounded,
                                    color: Color(0xFF1A237E),
                                    size: 20,
                                  ),
                                ),
                                title: Text(
                                  siswa['fullname'] ?? "Siswa Baru",
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                                subtitle: Text(
                                  "Mendaftar sebagai siswa baru",
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey.shade700,
                                  ),
                                ),
                                trailing: Text(
                                  waktu,
                                  style: const TextStyle(
                                    fontSize: 10,
                                    color: Colors.blueGrey,
                                  ),
                                ),
                                onTap: () {
                                  Navigator.pop(context);
                                  widget.onTapMenu(
                                    2,
                                  ); // Pindah ke tab verifikasi
                                },
                              ),
                            );
                          },
                        ),
                      ),
                    const SizedBox(height: 15),
                    // Handle Bar untuk menutup (Slide up)
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          vertical: 10,
                          horizontal: 40,
                        ),
                        child: Container(
                          width: 50,
                          height: 5,
                          decoration: BoxDecoration(
                            color: Colors.grey[300],
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
      transitionBuilder: (context, anim1, anim2, child) {
        // Efek Slide-Down dari atas layar
        return SlideTransition(
          position: Tween(
            begin: const Offset(0, -1),
            end: const Offset(0, 0),
          ).animate(CurvedAnimation(parent: anim1, curve: Curves.easeOutCirc)),
          child: child,
        );
      },
    );
  }

  Widget _buildSummaryCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: _primaryBlue,
        borderRadius: BorderRadius.circular(20),
      ),
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
    String tokenCode = auth.registrationToken ?? "BELUM ADA";
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FA),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.grey.shade300),
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
                  const Text(
                    "TOKEN REGISTRASI SISWA",
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey,
                      letterSpacing: 1.1,
                    ),
                  ),
                  const SizedBox(height: 6),
                  SelectableText(
                    tokenCode,
                    style: TextStyle(
                      color: _primaryBlue,
                      fontWeight: FontWeight.w900,
                      fontSize: 22,
                    ),
                  ),
                ],
              ),
              // Tombol untuk memperbarui token jika diperlukan
              IconButton(
                onPressed: _handleRegenerateToken,
                icon: const Icon(Icons.sync_rounded, color: Colors.blueAccent),
                tooltip: "Perbarui Token",
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(height: 1),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(
                Icons.info_outline_rounded,
                size: 16,
                color: Colors.orange,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  "Berikan kode ini kepada siswa baru agar saat mendaftar mereka otomatis terhubung ke sekolah Anda.",
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey.shade700,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionGrid(BuildContext context, AuthProvider auth) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 15,
      mainAxisSpacing: 15,
      childAspectRatio: 1.4,
      children: [
        _buildActionItem(
          "Data Siswa",
          Icons.groups_rounded,
          Colors.blue,
          () => widget.onTapMenu(1),
        ),
        _buildActionItem(
          "Verifikasi",
          Icons.how_to_reg_rounded,
          Colors.orange,
          () => widget.onTapMenu(2),
          badge: auth.pendingCount,
        ),
        _buildActionItem(
          "Laporan",
          Icons.report_problem_rounded,
          Colors.red,
          () {},
        ),
        _buildActionItem("Rekap", Icons.view_list_rounded, Colors.teal, () {}),
      ],
    );
  }

  Widget _buildActionItem(
    String title,
    IconData icon,
    Color color,
    VoidCallback onTap, {
    String? badge,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(15),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),
              border: Border.all(color: Colors.grey.shade100),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, color: color, size: 28),
                const SizedBox(height: 8),
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          if (badge != null && badge != "0")
            Positioned(
              right: 12,
              top: 12,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.orange,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  badge,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String value, String label) {
    return Column(
      children: [
        _isStatsLoading
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
            : Text(
                value,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(color: Colors.white70, fontSize: 12),
        ),
      ],
    );
  }
}
