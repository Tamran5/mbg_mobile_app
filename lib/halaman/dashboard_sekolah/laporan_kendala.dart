import 'package:flutter/material.dart';

class LaporanKendalaPage extends StatefulWidget {
  const LaporanKendalaPage({super.key});

  @override
  State<LaporanKendalaPage> createState() => _LaporanKendalaPageState();
}

class _LaporanKendalaPageState extends State<LaporanKendalaPage> {
  final Color _navy = const Color(0xFF1A237E);
  final Color _accent = const Color(0xFF5D9CEC);

  // Controller untuk input laporan
  final TextEditingController _detailController = TextEditingController();
  String? _selectedIssue;

  // Daftar kategori kendala yang sering terjadi
  final List<String> _issueCategories = [
    "Jumlah Porsi Kurang",
    "Makanan Rusak / Basi",
    "Keterlambatan Pengiriman",
    "Menu Tidak Sesuai",
    "Lainnya"
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Dekorasi lingkaran biru di pojok kanan atas agar desain seragam
          Positioned(
            top: -70,
            right: -50,
            child: Container(
              width: 280,
              height: 280,
              decoration: BoxDecoration(
                color: _accent.withOpacity(0.12),
                shape: BoxShape.circle,
              ),
            ),
          ),

          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(context),
                  const SizedBox(height: 20),
                  
                  const Text("Apa kendala yang Anda temukan?", 
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 15),

                  // --- 1. PILIH KATEGORI KENDALA ---
                  _buildIssueDropdown(),

                  const SizedBox(height: 25),
                  const Text("Detail Laporan", 
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 10),

                  // --- 2. INPUT DESKRIPSI MASALAH ---
                  _buildDescriptionField(),

                  const SizedBox(height: 25),
                  const Text("Lampiran Foto Bukti", 
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 10),

                  // --- 3. AREA UNGGAH FOTO KENDALA ---
                  _buildPhotoUploadArea(),

                  const SizedBox(height: 40),

                  // --- 4. TOMBOL KIRIM LAPORAN ---
                  _buildSubmitButton(),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 20),
      child: Row(
        children: [
          IconButton(
            padding: EdgeInsets.zero,
            alignment: Alignment.centerLeft,
            icon: Icon(Icons.arrow_back_ios_new_rounded, color: _navy),
            onPressed: () => Navigator.pop(context),
          ),
          Text(
            "Laporan Kendala",
            style: TextStyle(fontWeight: FontWeight.w900, fontSize: 22, color: _navy),
          ),
        ],
      ),
    );
  }

  Widget _buildIssueDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FD),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          isExpanded: true,
          hint: const Text("Pilih jenis kendala", style: TextStyle(fontSize: 14)),
          value: _selectedIssue,
          items: _issueCategories.map((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value, style: const TextStyle(fontSize: 14)),
            );
          }).toList(),
          onChanged: (newValue) {
            setState(() => _selectedIssue = newValue);
          },
        ),
      ),
    );
  }

  Widget _buildDescriptionField() {
    return TextField(
      controller: _detailController,
      maxLines: 4,
      decoration: InputDecoration(
        hintText: "Jelaskan detail masalah (contoh: Porsi kelas 3 kurang 5 box)...",
        hintStyle: const TextStyle(fontSize: 13, color: Colors.grey),
        filled: true,
        fillColor: const Color(0xFFF8F9FD),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(color: Colors.grey.shade200),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(color: Colors.grey.shade200),
        ),
      ),
    );
  }

  Widget _buildPhotoUploadArea() {
    return InkWell(
      onTap: () {}, // Logika kamera
      child: Container(
        height: 120,
        width: double.infinity,
        decoration: BoxDecoration(
          color: const Color(0xFFF8F9FD),
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: Colors.grey.shade300, style: BorderStyle.solid),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.camera_alt_outlined, color: _navy.withOpacity(0.5), size: 30),
            const SizedBox(height: 8),
            const Text("Unggah Bukti Kendala", 
              style: TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      height: 55,
      child: ElevatedButton(
        onPressed: () {
          // Logika pengiriman laporan ke server
          _showSuccessDialog();
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: _navy,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          elevation: 0,
        ),
        child: const Text("KIRIM LAPORAN", 
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, letterSpacing: 1)),
      ),
    );
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.check_circle, color: Colors.green, size: 60),
            const SizedBox(height: 15),
            const Text("Laporan Terkirim", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            const SizedBox(height: 10),
            const Text("Tim Admin Dapur akan segera menindaklanjuti laporan Anda.", 
              textAlign: TextAlign.center, style: TextStyle(fontSize: 13, color: Colors.grey)),
          ],
        ),
        actions: [
          Center(
            child: TextButton(
              onPressed: () {
                Navigator.pop(context); // Tutup Dialog
                Navigator.pop(context); // Kembali ke Dashboard
              },
              child: const Text("KEMBALI KE BERANDA", style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }
}