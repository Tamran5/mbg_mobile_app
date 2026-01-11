import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import '../../widgets/mbg_scaffold.dart';

class UlasanSayaPage extends StatefulWidget {
  const UlasanSayaPage({super.key});

  @override
  State<UlasanSayaPage> createState() => _UlasanSayaPageState();
}

class _UlasanSayaPageState extends State<UlasanSayaPage> {
  final Color _primaryBlue = const Color(0xFF1A237E);

  @override
  void initState() {
    super.initState();
    initializeDateFormatting('id_ID', null); 
  }

  // Data Dummy Ulasan (Nantinya diintegrasikan dengan Backend Flask)
  final List<Map<String, dynamic>> _ulasanData = [
    {
      "tanggal": "2026-01-02",
      "menu": "Nasi Merah & Ikan Nila Goreng",
      "rating": 5,
      "komentar": "Ikan nila gorengnya sangat renyah, nasi merahnya juga empuk. Enak sekali!",
      "img": "https://thumb.viva.co.id/media/frontend/thumbs3/2024/07/26/66a347102e3b1-uji-coba-makan-siang-gratis-di-sdn-04-cideng_1265_711.jpg"
    },
    {
      "tanggal": "2025-12-31",
      "menu": "Nasi Putih & Ayam Bakar Madu",
      "rating": 4,
      "komentar": "Ayam bakarnya enak, tapi sayurnya sedikit kurang asin menurut saya.",
      "img": "https://media.suara.com/pictures/653x366/2025/01/16/94698-cuitan-warganet-soal-menu-makan-bergizi-gratis-hari-ke-7.jpg"
    }
  ];

  @override
  Widget build(BuildContext context) {
    // 2. Menggunakan MbgScaffold untuk konsistensi dekorasi pojok kanan atas
    return MbgScaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Kustom
          _buildHeader(context),

          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
              itemCount: _ulasanData.length,
              itemBuilder: (context, index) {
                var item = _ulasanData[index];
                DateTime date = DateTime.parse(item['tanggal']!);
                
                return _buildReviewCard(item, date);
              },
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
            color: _primaryBlue,
            onPressed: () => Navigator.pop(context),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 12, top: 10),
            child: Text(
              "Ulasan Saya",
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.w900,
                color: _primaryBlue,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReviewCard(Map<String, dynamic> item, DateTime date) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey[100]!),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(5), 
            blurRadius: 10, 
            offset: const Offset(0, 5)
          )
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // Thumbnail Menu
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    item['img']!, 
                    width: 60, height: 60, fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      width: 60, height: 60, color: Colors.grey[100],
                      child: const Icon(Icons.fastfood, color: Colors.grey),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        DateFormat('EEEE, d MMMM yyyy', 'id_ID').format(date),
                        style: const TextStyle(
                          fontSize: 10, 
                          color: Colors.grey, 
                          fontWeight: FontWeight.bold
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        item['menu']!,
                        style: TextStyle(
                          fontSize: 14, 
                          fontWeight: FontWeight.bold, 
                          color: _primaryBlue
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Divider(height: 1),
            ),
            // Rating Bintang
            Row(
              children: List.generate(5, (starIndex) {
                return Icon(
                  starIndex < item['rating'] 
                      ? Icons.star_rounded 
                      : Icons.star_outline_rounded,
                  color: Colors.orangeAccent,
                  size: 20,
                );
              }),
            ),
            const SizedBox(height: 10),
            // Teks Komentar
            Text(
              item['komentar']!,
              style: const TextStyle(
                fontSize: 13, 
                color: Color(0xFF2D3436), 
                height: 1.5, 
                fontStyle: FontStyle.italic
              ),
            ),
          ],
        ),
      ),
    );
  }
}