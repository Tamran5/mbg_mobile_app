import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../services/api_service.dart';
import 'detail_artikel.dart';

class ListArtikelPage extends StatelessWidget {
  const ListArtikelPage({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Semua Artikel Edukasi", 
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF1A237E),
        elevation: 0,
      ),
      body: auth.articles.isEmpty
          ? const Center(child: Text("Belum ada artikel tersedia."))
          : ListView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: auth.articles.length,
              itemBuilder: (context, index) {
                final art = auth.articles[index];
                final String imgUrl = "${ApiService.rootUrl}/static/uploads/articles/${art['foto']}";

                return Container(
                  margin: const EdgeInsets.only(bottom: 15),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [
                      BoxShadow(
                        // FIX: Gunakan .withValues sesuai versi Flutter Anda
                        color: Colors.black.withValues(alpha: 0.05), 
                        blurRadius: 10,
                      )
                    ],
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(10),
                    leading: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.network(
                        imgUrl, 
                        width: 70, height: 70, fit: BoxFit.cover,
                        // FIX: Penulisan errorBuilder yang benar
                        errorBuilder: (_, __, ___) => Container(
                          width: 70, height: 70, 
                          color: Colors.grey[200], 
                          child: const Icon(Icons.image, color: Colors.grey),
                        ),
                      ),
                    ),
                    title: Text(art['judul'] ?? "Tanpa Judul", 
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                      maxLines: 2, overflow: TextOverflow.ellipsis),
                    subtitle: Text(art['target']?.toString().toUpperCase() ?? "EDUKASI", 
                      style: const TextStyle(color: Colors.blue, fontSize: 10, fontWeight: FontWeight.bold)),
                    trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => ArticleDetailPage(article: art)),
                      );
                    },
                  ),
                );
              },
            ),
    );
  }
}