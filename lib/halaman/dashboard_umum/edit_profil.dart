import 'package:flutter/material.dart';

class EditProfilPage extends StatefulWidget {
  const EditProfilPage({super.key});

  @override
  State<EditProfilPage> createState() => _EditProfilPageState();
}

class _EditProfilPageState extends State<EditProfilPage> {
  // Warna Biru Utama Aplikasi
  final Color _primaryBlue = const Color(0xFF1A237E);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          "Edit Profil",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF1A237E),
      ),
      body: Stack(
        children: [
          // --- 1. DEKORASI BULAT BIRU (Style Dashboard) ---
          Positioned(
            top: -70,
            right: -50,
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                color: const Color(0xFF5D9CEC).withOpacity(0.12),
                shape: BoxShape.circle,
              ),
            ),
          ),

          SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 30),
                
                // --- 2. FOTO PROFIL EDITABLE ---
                Center(
                  child: Stack(
                    alignment: Alignment.bottomRight,
                    children: [
                      const CircleAvatar(
                        radius: 60,
                        backgroundColor: Color(0xFFF1F2F6),
                        backgroundImage: NetworkImage("https://www.w3schools.com/howto/img_avatar.png"),
                      ),
                      GestureDetector(
                        onTap: () {
                          // Logika pilih gambar dari galeri
                        },
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: _primaryBlue,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2),
                          ),
                          child: const Icon(Icons.edit_rounded, color: Colors.white, size: 20),
                        ),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 40),

                // --- 3. FORM INPUT DATA ---
                _buildInputField("Nama Lengkap", "Bagas Adi Nugroho"),
                _buildInputField("Sekolah", "SMAN 01 Jakarta"),
                _buildInputField("Kelas", "12-A"),
                _buildInputField("Email", "bagas.adi@email.com"),
                _buildInputField("Nomor Telepon", "+62 812 3456 7890"),

                const SizedBox(height: 40),

                // --- 4. TOMBOL SIMPAN ---
                _buildSaveButton(),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputField(String label, String initialValue) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.grey),
          ),
          const SizedBox(height: 8),
          TextFormField(
            initialValue: initialValue,
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.grey[50],
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: BorderSide(color: Colors.grey.withOpacity(0.1)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {
          Navigator.pop(context); // Kembali ke profil setelah simpan
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: _primaryBlue,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          elevation: 0,
        ),
        child: const Text(
          "Simpan Perubahan",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
        ),
      ),
    );
  }
}