import 'package:flutter/material.dart';

class VerifikasiPendaftaranPage extends StatelessWidget {
  const VerifikasiPendaftaranPage({super.key});

  final Color _navy = const Color(0xFF1A237E);
  final Color _accent = const Color(0xFF5D9CEC);

  // Simulasi data pendaftar baru
  final List<Map<String, String>> _pendaftar = const [
    {"nama": "Budi Santoso", "nisn": "0012345678", "kelas": "1A", "tgl": "04 Jan"},
    {"nama": "Siti Aminah", "nisn": "0098765432", "kelas": "1B", "tgl": "03 Jan"},
    {"nama": "Andi Wijaya", "nisn": "0055667788", "kelas": "1A", "tgl": "02 Jan"},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          _buildCircleDecoration(), // Dekorasi lingkaran biru tetap ada
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader("Verifikasi Pendaftaran"),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24),
                  child: Text(
                    "Siswa baru yang mengajukan bergabung.",
                    style: TextStyle(color: Colors.grey, fontSize: 13),
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(24),
                    itemCount: _pendaftar.length,
                    itemBuilder: (context, index) => _buildVerificationCard(context, _pendaftar[index]),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 25, left: 24, bottom: 10),
      child: Text(
        title,
        style: TextStyle(fontWeight: FontWeight.w900, fontSize: 22, color: _navy),
      ),
    );
  }

  Widget _buildCircleDecoration() {
    return Positioned(
      top: -70,
      right: -50,
      child: Container(
        width: 280,
        height: 280,
        decoration: BoxDecoration(color: _accent.withOpacity(0.12), shape: BoxShape.circle),
      ),
    );
  }

  // Update: Widget Kartu yang Sekarang Bisa Diklik
  Widget _buildVerificationCard(BuildContext context, Map<String, String> data) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 12)],
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () => _showDetailPendaftaran(context, data), // Aksi saat kartu diklik
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: CircleAvatar(
                    backgroundColor: _navy.withOpacity(0.1),
                    child: Text(data['nama']![0], style: TextStyle(color: _navy, fontWeight: FontWeight.bold)),
                  ),
                  title: Text(data['nama']!, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text("NISN: ${data['nisn']} • Kelas ${data['kelas']}"),
                  trailing: Text(data['tgl']!, style: const TextStyle(fontSize: 10, color: Colors.grey)),
                ),
                const Divider(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () {}, // Logika Tolak
                      child: const Text("Tolak", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: () {}, // Logika Setujui
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      child: const Text("Setujui", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Fungsi untuk Memunculkan Detail Pendaftaran
  void _showDetailPendaftaran(BuildContext context, Map<String, String> data) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(25))),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(10)))),
            const SizedBox(height: 20),
            Text("Detail Calon Penerima MBG", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: _navy)),
            const SizedBox(height: 20),
            _detailItem("Nama Lengkap", data['nama']!),
            _detailItem("Nomor Induk (NISN)", data['nisn']!),
            _detailItem("Pilihan Kelas", data['kelas']!),
            _detailItem("Tanggal Daftar", data['tgl']!),
            const SizedBox(height: 20),
            const Text(
              "*Pastikan data pendaftar sudah sesuai dengan data resmi sekolah sebelum disetujui.",
              style: TextStyle(fontStyle: FontStyle.italic, color: Colors.grey, fontSize: 11),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _detailItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}