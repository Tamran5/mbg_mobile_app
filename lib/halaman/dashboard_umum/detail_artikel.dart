import 'package:flutter/material.dart';
import '../../services/api_service.dart';

class ArticleDetailPage extends StatelessWidget {
  final Map<String, dynamic> article;

  const ArticleDetailPage({super.key, required this.article});

  @override
  Widget build(BuildContext context) {
    const Color navyColor = Color(0xFF1A237E);
    
    // Parsing data riil dari Map
    final String title = article['judul'] ?? "Tanpa Judul";
    final String content = article['konten'] ?? "Konten tidak tersedia.";
    final String category = (article['target'] ?? "Edukasi").toString().toUpperCase();
    final String date = article['tanggal'] ?? "-";
    final String fileName = article['foto'] ?? "";
    final String imgUrl = "${ApiService.rootUrl}/static/uploads/articles/$fileName";

    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 280,
            pinned: true,
            backgroundColor: navyColor,
            elevation: 0,
            flexibleSpace: FlexibleSpaceBar(
              background: Image.network(
                imgUrl, fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(color: Colors.grey[300], child: const Icon(Icons.broken_image)),
              ),
            ),
            leading: Padding(
              padding: const EdgeInsets.all(8.0),
              child: CircleAvatar(
                backgroundColor: Colors.black.withOpacity(0.2),
                child: IconButton(
                  icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 18),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(color: navyColor.withOpacity(0.1), borderRadius: BorderRadius.circular(6)),
                    child: Text(category, style: const TextStyle(color: navyColor, fontWeight: FontWeight.bold, fontSize: 10)),
                  ),
                  const SizedBox(height: 16),
                  Text(title, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: navyColor, height: 1.2)),
                  const SizedBox(height: 12),
                  Row(children: [const Icon(Icons.access_time_rounded, size: 14, color: Colors.grey), const SizedBox(width: 4), Text(date, style: const TextStyle(color: Colors.grey, fontSize: 12)), const SizedBox(width: 15), const Icon(Icons.verified_user_rounded, size: 14, color: Colors.green), const SizedBox(width: 4), const Text("Terverifikasi MBG", style: TextStyle(color: Colors.grey, fontSize: 12))]),
                  const Divider(height: 40, thickness: 1, color: Color(0xFFF5F5F5)),
                  
                  // Menggunakan konten asli dari database
                  Text(
                    content,
                    style: const TextStyle(fontSize: 16, height: 1.8, color: Colors.black87, letterSpacing: 0.2),
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