import 'package:flutter/material.dart';
// 1. Import wrapper scaffold yang sudah kita buat sebelumnya
import '../../widgets/mbg_scaffold.dart';

class VerifikasiPendaftaranPage extends StatefulWidget {
  const VerifikasiPendaftaranPage({super.key});

  @override
  State<VerifikasiPendaftaranPage> createState() => _VerifikasiPendaftaranPageState();
}

class _VerifikasiPendaftaranPageState extends State<VerifikasiPendaftaranPage> {
  final Color _navy = const Color(0xFF1A237E);
  final TextEditingController _searchController = TextEditingController();

  // Data asli pendaftar
  final List<Map<String, String>> _allPendaftar = const [
    {"nama": "Budi Santoso", "nisn": "0012345678", "kelas": "1A", "tgl": "04 Jan"},
    {"nama": "Siti Aminah", "nisn": "0098765432", "kelas": "1B", "tgl": "03 Jan"},
    {"nama": "Andi Wijaya", "nisn": "0055667788", "kelas": "1A", "tgl": "02 Jan"},
  ];

  // List untuk menampung hasil filter pencarian
  List<Map<String, String>> _filteredPendaftar = [];

  @override
  void initState() {
    super.initState();
    _filteredPendaftar = _allPendaftar; // Inisialisasi awal
  }

  void _filterSearch(String query) {
    setState(() {
      _filteredPendaftar = _allPendaftar
          .where((s) =>
              s['nama']!.toLowerCase().contains(query.toLowerCase()) ||
              s['nisn']!.contains(query))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return MbgScaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header tanpa tombol kembali
          _buildHeader(),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Siswa baru yang mengajukan bergabung.",
                    style: TextStyle(color: Colors.grey, fontSize: 14),
                  ),
                  const SizedBox(height: 20),

                  // --- FITUR SEARCH BAR ---
                  _buildSearchBar(),

                  const SizedBox(height: 10),
                  const Text(
                    "PERLU TINDAKAN", 
                    style: TextStyle(
                      color: Colors.grey, 
                      fontSize: 10, 
                      fontWeight: FontWeight.w900, 
                      letterSpacing: 1.2
                    )
                  ),
                  const SizedBox(height: 15),

                  // Daftar Kartu Verifikasi
                  _filteredPendaftar.isEmpty 
                    ? _buildEmptyState()
                    : Column(
                        children: _filteredPendaftar
                            .map((data) => _buildVerificationCard(context, data))
                            .toList(),
                      ),
                  
                  const SizedBox(height: 40),
                ],
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
      child: Text(
        "Verifikasi",
        style: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.w900,
          color: _navy,
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: TextField(
        controller: _searchController,
        onChanged: _filterSearch,
        decoration: InputDecoration(
          hintText: "Cari nama atau NISN...",
          hintStyle: const TextStyle(fontSize: 13, color: Colors.grey),
          prefixIcon: Icon(Icons.search_rounded, color: _navy),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 15),
        ),
      ),
    );
  }

  Widget _buildVerificationCard(BuildContext context, Map<String, String> data) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03), 
            blurRadius: 12, 
            offset: const Offset(0, 4)
          )
        ],
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () => _showDetailPendaftaran(context, data),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: CircleAvatar(
                  backgroundColor: _navy.withOpacity(0.08),
                  child: Text(
                    data['nama']![0], 
                    style: TextStyle(color: _navy, fontWeight: FontWeight.bold)
                  ),
                ),
                title: Text(
                  data['nama']!, 
                  style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15)
                ),
                subtitle: Text(
                  "NISN: ${data['nisn']} • Kelas ${data['kelas']}",
                  style: const TextStyle(fontSize: 12),
                ),
                trailing: Text(
                  data['tgl']!, 
                  style: const TextStyle(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.bold)
                ),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 8.0),
                child: Divider(height: 1),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () {}, 
                    child: const Text(
                      "Tolak", 
                      style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () {}, 
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    child: const Text(
                      "Setujui", 
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.only(top: 40),
        child: Text(
          "Tidak ada pendaftar yang cocok.",
          style: TextStyle(color: Colors.grey[400], fontStyle: FontStyle.italic),
        ),
      ),
    );
  }

  void _showDetailPendaftaran(BuildContext context, Map<String, String> data) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(30))
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40, height: 5, 
                decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(10))
              )
            ),
            const SizedBox(height: 25),
            Text(
              "Detail Calon Penerima", 
              style: TextStyle(fontWeight: FontWeight.w900, fontSize: 20, color: _navy)
            ),
            const SizedBox(height: 20),
            _detailItem("Nama Lengkap", data['nama']!),
            _detailItem("Nomor Induk (NISN)", data['nisn']!),
            _detailItem("Pilihan Kelas", data['kelas']!),
            _detailItem("Tanggal Daftar", data['tgl']!),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.05),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Text(
                "*Mohon verifikasi NISN dengan data Dapodik sebelum menyetujui pendaftaran.",
                style: TextStyle(color: Colors.orange, fontSize: 11, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _detailItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.w500)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w800)),
        ],
      ),
    );
  }
}