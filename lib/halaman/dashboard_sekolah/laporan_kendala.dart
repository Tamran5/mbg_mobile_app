import 'package:flutter/material.dart';
import '../../widgets/mbg_scaffold.dart';

class LaporanKendalaPage extends StatefulWidget {
  const LaporanKendalaPage({super.key});

  @override
  State<LaporanKendalaPage> createState() => _LaporanKendalaPageState();
}

class _LaporanKendalaPageState extends State<LaporanKendalaPage> {
  final Color _navy = const Color(0xFF1A237E);
  final TextEditingController _detailController = TextEditingController();
  String? _selectedIssue;

  // Daftar kategori kendala
  final List<String> _issueCategories = [
    "Jumlah Porsi Kurang",
    "Makanan Rusak / Basi",
    "Keterlambatan Pengiriman",
    "Menu Tidak Sesuai",
    "Lainnya"
  ];

  @override
  void dispose() {
    _detailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // 2. Menggunakan MbgScaffold untuk konsistensi dekorasi pojok kanan atas
    return MbgScaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(context),
          
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),
                  const Text(
                    "Apa kendala yang Anda temukan?", 
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF2D3436))
                  ),
                  const SizedBox(height: 15),

                  // --- 1. PILIH KATEGORI KENDALA ---
                  _buildIssueDropdown(),

                  const SizedBox(height: 25),
                  const Text(
                    "Detail Laporan", 
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF2D3436))
                  ),
                  const SizedBox(height: 10),

                  // --- 2. INPUT DESKRIPSI MASALAH ---
                  _buildDescriptionField(),

                  const SizedBox(height: 25),
                  const Text(
                    "Lampiran Foto Bukti", 
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF2D3436))
                  ),
                  const SizedBox(height: 10),

                  // --- 3. AREA UNGGAH FOTO ---
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

  // --- UI COMPONENTS ---

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 10, 24, 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
            color: _navy,
            onPressed: () => Navigator.pop(context),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 12, top: 10),
            child: Text(
              "Laporan Kendala",
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.w900,
                color: _navy,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIssueDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          isExpanded: true,
          hint: const Text("Pilih jenis kendala", style: TextStyle(fontSize: 14)),
          value: _selectedIssue,
          icon: Icon(Icons.keyboard_arrow_down_rounded, color: _navy),
          items: _issueCategories.map((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
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
        fillColor: Colors.grey[50],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(color: Colors.grey[200]!),
        ),
      ),
    );
  }

  Widget _buildPhotoUploadArea() {
    return InkWell(
      onTap: () {
        // TODO: Integrasi image_picker untuk bukti kendala
      },
      borderRadius: BorderRadius.circular(15),
      child: Container(
        height: 140,
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.grey[50],
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: Colors.grey[300]!, style: BorderStyle.solid),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: _navy.withAlpha(13),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.add_a_photo_rounded, color: _navy, size: 30),
            ),
            const SizedBox(height: 12),
            const Text(
              "Unggah Bukti Kendala", 
              style: TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.bold)
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: () {
          // Logika pengiriman laporan ke server Flask Anda
          _showSuccessDialog();
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: _navy,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          elevation: 0,
        ),
        child: const Text(
          "KIRIM LAPORAN", 
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, letterSpacing: 1)
        ),
      ),
    );
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
        content: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.check_circle_rounded, color: Colors.green, size: 70),
              const SizedBox(height: 20),
              const Text(
                "Laporan Terkirim", 
                style: TextStyle(fontWeight: FontWeight.w900, fontSize: 20)
              ),
              const SizedBox(height: 12),
              const Text(
                "Tim Admin Dapur akan segera menindaklanjuti laporan Anda melalui dashboard pusat.", 
                textAlign: TextAlign.center, 
                style: TextStyle(fontSize: 14, color: Colors.grey, height: 1.5)
              ),
            ],
          ),
        ),
        actions: [
          Center(
            child: TextButton(
              onPressed: () {
                Navigator.pop(context); // Tutup Dialog
                Navigator.pop(context); // Kembali ke Dashboard
              },
              child: Text(
                "KEMBALI KE BERANDA", 
                style: TextStyle(color: _navy, fontWeight: FontWeight.bold)
              ),
            ),
          ),
        ],
      ),
    );
  }
}