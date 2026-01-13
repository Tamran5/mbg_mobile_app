import 'package:flutter/material.dart';

class ArticleDetailPage extends StatelessWidget {
  final String title;
  final String category;
  final String imgUrl;
  final String? date;
  final String? author;

  const ArticleDetailPage({
    super.key,
    required this.title,
    required this.category,
    required this.imgUrl,
    this.date = "13 Januari 2026",
    this.author = "Tim Ahli Gizi MBG",
  });

  @override
  Widget build(BuildContext context) {
    const Color navyColor = Color(0xFF1A237E);

    return Scaffold(
      backgroundColor: Colors.white,
      // Menggunakan CustomScrollView agar gambar bisa memudar saat di-scroll (Sliver)
      body: CustomScrollView(
        slivers: [
          // Header dengan Gambar yang bisa menciut
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            backgroundColor: navyColor,
            leading: CircleAvatar(
              backgroundColor: Colors.white.withValues(alpha: 0.2),
              child: IconButton(
                icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 18),
                onPressed: () => Navigator.pop(context),
              ),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Image.network(
                    imgUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(color: Colors.grey[300], child: const Icon(Icons.broken_image)),
                  ),
                  // Gradasi agar teks kategori terlihat
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withValues(alpha: 0.5),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Konten Artikel
          SliverToBoxAdapter(
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Label Kategori
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: navyColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      category.toUpperCase(),
                      style: const TextStyle(color: navyColor, fontWeight: FontWeight.bold, fontSize: 11),
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Judul Besar
                  Text(
                    title,
                    style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w900, color: navyColor, height: 1.2),
                  ),
                  const SizedBox(height: 12),
                  
                  // Info Penulis & Tanggal
                  Row(
                    children: [
                      const Icon(Icons.person_outline_rounded, size: 16, color: Colors.grey),
                      const SizedBox(width: 4),
                      Text(author!, style: const TextStyle(color: Colors.grey, fontSize: 12)),
                      const SizedBox(width: 15),
                      const Icon(Icons.access_time_rounded, size: 16, color: Colors.grey),
                      const SizedBox(width: 4),
                      Text(date!, style: const TextStyle(color: Colors.grey, fontSize: 12)),
                    ],
                  ),
                  const Divider(height: 40, thickness: 1, color: Color(0xFFF1F1F1)),
                  
                  // Isi Artikel
                  const Text(
                    "Mengapa Protein Penting?",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    "Protein adalah blok bangunan utama bagi tubuh manusia. Bagi pelajar, asupan protein yang cukup sangat krusial karena mendukung perkembangan kognitif dan konsentrasi selama di kelas. Dalam program Makan Bergizi Gratis, kami memastikan setiap porsi mengandung protein berkualitas tinggi seperti telur, ayam, atau ikan.",
                    style: TextStyle(fontSize: 16, color: Colors.black54, height: 1.6),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    "Manfaat Untuk Fokus Belajar",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    "Studi menunjukkan bahwa siswa yang mengonsumsi sarapan atau makan siang tinggi protein memiliki tingkat kewaspadaan yang lebih baik dibandingkan mereka yang hanya mengonsumsi karbohidrat sederhana. Protein membantu menstabilkan kadar gula darah, sehingga mencegah rasa kantuk setelah makan (food coma).",
                    style: TextStyle(fontSize: 16, color: Colors.black54, height: 1.6),
                  ),
                  const SizedBox(height: 30),
                  
                  // Tombol Bagikan atau Suka (Opsional)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildActionButton(Icons.share_outlined, "Bagikan"),
                      const SizedBox(width: 20),
                      _buildActionButton(Icons.bookmark_border_rounded, "Simpan"),
                    ],
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

  Widget _buildActionButton(IconData icon, String label) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Icon(icon, color: Colors.black54, size: 22),
        ),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
      ],
    );
  }
}