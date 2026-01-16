import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/mbg_scaffold.dart';

class VerifikasiPendaftaranPage extends StatefulWidget {
  const VerifikasiPendaftaranPage({super.key});

  @override
  State<VerifikasiPendaftaranPage> createState() => _VerifikasiPendaftaranPageState();
}

class _VerifikasiPendaftaranPageState extends State<VerifikasiPendaftaranPage> {
  final Color _navy = const Color(0xFF1A237E);
  final TextEditingController _searchController = TextEditingController();
  
  Timer? _debounce;
  String _query = "";

  @override
  void initState() {
    super.initState();
    // Memuat data awal saat halaman dibuka
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<AuthProvider>(context, listen: false).fetchSchoolStats();
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  // --- LOGIKA PENCARIAN (DEBOUNCING) ---
  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce?.cancel();

    _debounce = Timer(const Duration(milliseconds: 300), () {
      if (mounted) {
        setState(() {
          _query = query.toLowerCase();
        });
      }
    });
  }

  // --- LOGIKA VERIFIKASI ---
  Future<void> _handleVerification(int id, String action) async {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final result = await auth.verifyStudent(id, action);

    if (mounted) {
      if (result['status'] == 'success') {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Siswa berhasil ${action == 'approve' ? 'disetujui' : 'ditolak'}"), 
            backgroundColor: Colors.green
          )
        );
        // Refresh data statistik dan list secara global di Provider
        auth.fetchSchoolStats(); 
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final pendaftarRaw = auth.pendingStudentsList;

    final filteredPendaftar = pendaftarRaw.where((s) {
      if (_query.isEmpty) return true;
      final name = s['fullname'].toString().toLowerCase();
      final nisn = s['nisn'].toString();
      final phone = s['phone'].toString();
      return name.contains(_query) || nisn.contains(_query) || phone.contains(_query);
    }).toList();

    return MbgScaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          Expanded(
            child: RefreshIndicator(
              onRefresh: () => auth.fetchSchoolStats(),
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Ketuk kartu untuk melihat detail pendaftaran.", 
                      style: TextStyle(color: Colors.grey, fontSize: 13)),
                    const SizedBox(height: 20),
                    _buildSearchBar(),
                    const Text("PERLU TINDAKAN", 
                      style: TextStyle(color: Colors.grey, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1.2)),
                    const SizedBox(height: 15),

                    if (auth.isLoading && pendaftarRaw.isEmpty)
                      const Center(child: Padding(padding: EdgeInsets.only(top: 50), child: CircularProgressIndicator()))
                    else if (filteredPendaftar.isEmpty)
                      _buildEmptyState()
                    else
                      Column(
                        children: filteredPendaftar
                            .map((data) => _buildVerificationCard(context, data))
                            .toList(),
                      ),
                    
                    const SizedBox(height: 100),
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

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 40, 24, 10),
      child: Text("Verifikasi", style: TextStyle(fontSize: 32, fontWeight: FontWeight.w900, color: _navy)),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Colors.grey[50], 
        borderRadius: BorderRadius.circular(15), 
        border: Border.all(color: Colors.grey[200]!)
      ),
      child: TextField(
        controller: _searchController,
        onChanged: _onSearchChanged,
        decoration: InputDecoration(
          hintText: "Cari nama, NISN, atau telepon...",
          hintStyle: const TextStyle(fontSize: 13, color: Colors.grey),
          prefixIcon: Icon(Icons.search_rounded, color: _navy),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 15),
        ),
      ),
    );
  }

  Widget _buildVerificationCard(BuildContext context, Map<String, dynamic> data) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 12, offset: const Offset(0, 4))],
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: InkWell(
        onTap: () => _showDetailPendaftaran(context, data),
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: CircleAvatar(
                  backgroundColor: _navy.withValues(alpha: 0.08),
                  child: Text(data['fullname'][0].toUpperCase(), 
                    style: TextStyle(color: _navy, fontWeight: FontWeight.bold)),
                ),
                title: Text(data['fullname'], style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15)),
                // Menambahkan No Telepon di Subtitle Kartu
                subtitle: Text("NISN: ${data['nisn']} • Kelas: ${data['class'] ?? '-'}\nTelp: ${data['phone'] ?? '-'}", 
                  style: const TextStyle(fontSize: 12, height: 1.5)),
                trailing: const Icon(Icons.chevron_right_rounded, color: Colors.grey),
              ),
              const Divider(),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => _handleVerification(data['id'], 'reject'), 
                    child: const Text("Tolak", style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () => _handleVerification(data['id'], 'approve'), 
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green, 
                      elevation: 0, 
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))
                    ),
                    child: const Text("Setujui", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  // --- FUNGSI DETAIL PANEL ---

  void _showDetailPendaftaran(BuildContext context, Map<String, dynamic> data) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
        ),
        padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(child: Container(width: 40, height: 5, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(10)))),
            const SizedBox(height: 25),
            Text("Detail Calon Siswa", style: TextStyle(fontWeight: FontWeight.w900, fontSize: 22, color: _navy)),
            const SizedBox(height: 5),
            const Text("Periksa kesesuaian data pendaftar.", style: TextStyle(color: Colors.grey, fontSize: 14)),
            const SizedBox(height: 25),
            
            _buildDetailItem("Nama Lengkap", data['fullname']),
            _buildDetailItem("NISN", data['nisn']),
            _buildDetailItem("Nomor Telepon", data['phone'] ?? "-"), // Menambahkan baris No Telepon
            _buildDetailItem("Pilihan Kelas", data['class'] ?? "-"),
            _buildDetailItem("Email", data['email'] ?? "-"),
            
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(color: Colors.orange.withOpacity(0.08), borderRadius: BorderRadius.circular(15)),
              child: Row(
                children: [
                  const Icon(Icons.info_outline_rounded, color: Colors.orange, size: 20),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      "Harap verifikasi NISN melalui sistem Dapodik sebelum menyetujui pendaftaran ini.",
                      style: TextStyle(color: Colors.orange[800], fontSize: 12, fontWeight: FontWeight.w500),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),
            
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      side: BorderSide(color: Colors.grey.shade300),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text("Tutup", style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.w500)),
          const SizedBox(height: 4),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16, color: Colors.black87)),
          const Divider(height: 20),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.only(top: 60), 
        child: Column(
          children: [
            Icon(Icons.person_search_rounded, size: 50, color: Colors.grey[300]),
            const SizedBox(height: 10),
            Text("Tidak ada pendaftar baru.", 
              style: TextStyle(color: Colors.grey[400], fontStyle: FontStyle.italic)),
          ],
        )
      )
    );
  }
}