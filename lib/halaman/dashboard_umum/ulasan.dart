import 'package:flutter/material.dart';

class UlasanPage extends StatefulWidget {
  const UlasanPage({super.key});

  @override
  State<UlasanPage> createState() => _UlasanPageState();
}

class _UlasanPageState extends State<UlasanPage> {
  final Color _primaryBlue = const Color(0xFF1A237E);
  int _selectedRating = 0; // Untuk menyimpan nilai bintang

  // Tag ulasan cepat untuk memudahkan siswa
  final List<String> _tags = ["Rasa Enak", "Porsi Cukup", "Sangat Bergizi", "Kebersihan Oke", "Segar"];
  final List<String> _selectedTags = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // --- 1. DEKORASI BULAT BIRU (Style Dashboard) ---
          Positioned(
            top: -70,
            right: -50,
            child: Container(
              width: 280,
              height: 280,
              decoration: BoxDecoration(
                color: const Color(0xFF5D9CEC).withAlpha(31),
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
                  const SizedBox(height: 20),
                  // --- 2. JUDUL HALAMAN (Kiri & Besar) ---
                  const Text(
                    "Ulasan Makan",
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF1A237E),
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    "Berikan pendapatmu tentang menu hari ini",
                    style: TextStyle(color: Colors.grey, fontSize: 14),
                  ),
                  const SizedBox(height: 30),

                  // --- 3. RINGKASAN MENU HARI INI ---
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.network(
                            "https://media.suara.com/pictures/653x366/2025/01/16/94698-cuitan-warganet-soal-menu-makan-bergizi-gratis-hari-ke-7.jpg",
                            width: 60, height: 60, fit: BoxFit.cover,
                          ),
                        ),
                        const SizedBox(width: 16),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("Paket A", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.cyan, fontSize: 12)),
                              Text(
                                "Nasi, Ayam Goreng, Sayur Lodeh, & Buah",
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF1A237E)),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 40),
                  // --- 4. RATING BINTANG ---
                  const Center(
                    child: Text("Bagaimana rasa makanannya?", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  ),
                  const SizedBox(height: 15),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(5, (index) {
                      return IconButton(
                        icon: Icon(
                          index < _selectedRating ? Icons.star_rounded : Icons.star_outline_rounded,
                          color: Colors.orangeAccent,
                          size: 45,
                        ),
                        onPressed: () => setState(() => _selectedRating = index + 1),
                      );
                    }),
                  ),

                  const SizedBox(height: 40),
                  // --- 5. PILIHAN TAG CEPAT ---
                  const Text("Apa yang paling kamu suka?", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 15),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _tags.map((tag) {
                      bool isSelected = _selectedTags.contains(tag);
                      return GestureDetector(
                        onTap: () => setState(() {
                          isSelected ? _selectedTags.remove(tag) : _selectedTags.add(tag);
                        }),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: isSelected ? _primaryBlue : Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: isSelected ? _primaryBlue : Colors.grey[200]!),
                          ),
                          child: Text(
                            tag,
                            style: TextStyle(
                              color: isSelected ? Colors.white : Colors.grey[600],
                              fontSize: 13, fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),

                  const SizedBox(height: 40),
                  // --- 6. KOLOM KOMENTAR ---
                  const Text("Komentar Tambahan", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 12),
                  TextField(
                    maxLines: 4,
                    decoration: InputDecoration(
                      hintText: "Tulis pendapatmu di sini...",
                      filled: true,
                      fillColor: Colors.grey[50],
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
                    ),
                  ),

                  const SizedBox(height: 40),
                  // --- 7. TOMBOL KIRIM ---
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        // Logika kirim ulasan
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Terima kasih atas ulasanmu!")));
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _primaryBlue,
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                        elevation: 0,
                      ),
                      child: const Text("Kirim Ulasan", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                    ),
                  ),
                  const SizedBox(height: 50),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}