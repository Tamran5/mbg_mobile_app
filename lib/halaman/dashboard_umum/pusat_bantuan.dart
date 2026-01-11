import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart'; // Import untuk fungsi WA/Email
import '../../widgets/mbg_scaffold.dart';

class PusatBantuanPage extends StatefulWidget {
  const PusatBantuanPage({super.key});

  @override
  State<PusatBantuanPage> createState() => _PusatBantuanPageState();
}

class _PusatBantuanPageState extends State<PusatBantuanPage> {
  final Color _primaryBlue = const Color(0xFF1A237E);
  
  // 1. Data FAQ agar bisa difilter
  final List<Map<String, String>> _allFaqs = [
    {
      "q": "Bagaimana cara melihat jadwal menu?",
      "a": "Anda dapat melihat menu harian di Dashboard Utama pada bagian 'Jadwal Makan'. Pastikan sekolah Anda sudah disetujui admin."
    },
    {
      "q": "Mengapa ulasan saya tidak muncul?",
      "a": "Mana saya tau."
    },
    {
      "q": "Cara mengubah foto profil?",
      "a": "Masuk ke Menu Profil > Edit Profil > Klik ikon kamera pada lingkaran foto profil Anda."
    },
    {
      "q": "Informasi gizi tidak akurat?",
      "a": "Data gizi diambil berdasarkan standar Gizi 2025. Jika ada ketidaksesuaian, silakan laporkan melalui Email Dukungan."
    },
  ];

  List<Map<String, String>> _filteredFaqs = [];
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _filteredFaqs = _allFaqs; // Tampilkan semua FAQ di awal
  }

  // 2. Logika Pencarian
  void _filterSearch(String query) {
    setState(() {
      _filteredFaqs = _allFaqs
          .where((faq) => faq['q']!.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  // 3. Fungsi Membuka WhatsApp
  Future<void> _launchWhatsApp() async {
    const phoneNumber = "628123456789"; 
    const message = "Halo Admin MBG, saya butuh bantuan terkait aplikasi...";
    final url = Uri.parse("https://wa.me/$phoneNumber?text=${Uri.encodeComponent(message)}");
    
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      _showError("Tidak dapat membuka WhatsApp");
    }
  }

  // 4. Fungsi Membuka Email
  Future<void> _launchEmail() async {
    final Uri emailLaunchUri = Uri(
      scheme: 'mailto',
      path: 'support@mbg-proyek.com',
      query: 'subject=Bantuan Aplikasi MBG&body=Halo Tim Dukungan...',
    );

    if (!await launchUrl(emailLaunchUri)) {
      _showError("Tidak dapat membuka aplikasi Email");
    }
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    return MbgScaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildBackButton(context),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildTitle(),
                  const SizedBox(height: 30),
                  _buildSearchBar(),
                  const SizedBox(height: 40),
                  
                  const Text(
                    "Pertanyaan Populer",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF2D3436)),
                  ),
                  const SizedBox(height: 15),
                  
                  // Render FAQ yang sudah difilter
                  ..._filteredFaqs.map((faq) => _buildFaqItem(faq['q']!, faq['a']!)).toList(),
                  
                  if (_filteredFaqs.isEmpty)
                    const Center(child: Text("Pertanyaan tidak ditemukan", style: TextStyle(color: Colors.grey))),

                  const SizedBox(height: 40),
                  const Text(
                    "Butuh bantuan lebih lanjut?",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.grey),
                  ),
                  const SizedBox(height: 15),
                  _buildContactCard(Icons.chat_bubble_outline_rounded, "Hubungi via WhatsApp", _launchWhatsApp),
                  _buildContactCard(Icons.email_outlined, "Kirim Email Dukungan", _launchEmail),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- UI WIDGETS ---

  Widget _buildBackButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 10, 0, 0),
      child: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
        color: _primaryBlue,
        onPressed: () => Navigator.pop(context),
      ),
    );
  }

  Widget _buildTitle() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Pusat Bantuan",
          style: TextStyle(fontSize: 32, fontWeight: FontWeight.w900, color: _primaryBlue),
        ),
        const SizedBox(height: 10),
        const Text("Ada yang bisa kami bantu?", style: TextStyle(color: Colors.grey, fontSize: 16)),
      ],
    );
  }

  Widget _buildSearchBar() {
    return TextField(
      controller: _searchController,
      onChanged: _filterSearch,
      decoration: InputDecoration(
        hintText: "Cari bantuan...",
        prefixIcon: const Icon(Icons.search, color: Colors.grey),
        filled: true,
        fillColor: Colors.grey[50],
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
      ),
    );
  }

  Widget _buildFaqItem(String question, String answer) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.grey[100]!),
      ),
      child: ExpansionTile(
        title: Text(question, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Text(answer, style: const TextStyle(color: Colors.grey, fontSize: 13, height: 1.5)),
          ),
        ],
      ),
    );
  }

  Widget _buildContactCard(IconData icon, String title, VoidCallback action) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(color: _primaryBlue.withAlpha(13), borderRadius: BorderRadius.circular(15)),
      child: ListTile(
        leading: Icon(icon, color: _primaryBlue),
        title: Text(title, style: TextStyle(color: _primaryBlue, fontWeight: FontWeight.bold, fontSize: 14)),
        trailing: Icon(Icons.chevron_right_rounded, color: _primaryBlue),
        onTap: action,
      ),
    );
  }
}