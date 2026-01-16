import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../services/api_service.dart'; // Import ApiService
import '../../models/menu_model.dart';   // Import MenuModel

class UlasanPage extends StatefulWidget {
  const UlasanPage({super.key});

  @override
  State<UlasanPage> createState() => _UlasanPageState();
}

class _UlasanPageState extends State<UlasanPage> {
  final Color _primaryBlue = const Color(0xFF1A237E);
  final ApiService _apiService = ApiService(); // Inisialisasi API
  
  int _selectedRating = 0;
  MenuModel? _todayMenu; // Variabel penampung menu
  bool _isLoadingMenu = true; 

  final TextEditingController _commentController = TextEditingController();
  final List<String> _tags = ["Rasa Enak", "Porsi Cukup", "Sangat Bergizi", "Kebersihan Oke", "Segar"];
  final List<String> _selectedTags = [];

  @override
  void initState() {
    super.initState();
    _loadMenu(); // Panggil data menu saat halaman dibuka
  }

  // Fungsi mengambil data menu hari ini
  Future<void> _loadMenu() async {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    setState(() => _isLoadingMenu = true);
    
    try {
      final token = await auth.getAuthToken();
      // Mengambil menu berdasarkan tanggal hari ini
      final menu = await _apiService.fetchMenuByDate(DateTime.now(), token);
      if (mounted) {
        setState(() {
          _todayMenu = menu;
          _isLoadingMenu = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoadingMenu = false);
    }
  }

  Future<void> _handleSendReview() async {
    final auth = Provider.of<AuthProvider>(context, listen: false);

    if (_selectedRating == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Silakan berikan rating bintang terlebih dahulu")),
      );
      return;
    }

    final res = await auth.submitReview(
      rating: _selectedRating,
      tags: _selectedTags,
      komentar: _commentController.text,
    );

    if (mounted) {
      if (res['status'] == 'success') {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Terima kasih! Ulasan berhasil dikirim"), backgroundColor: Colors.green),
        );
        setState(() {
          _selectedRating = 0;
          _selectedTags.clear();
          _commentController.clear();
        });
        auth.setTabIndex(0);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(res['message'] ?? "Gagal mengirim ulasan"), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          Positioned(
            top: -70, right: -50,
            child: Container(
              width: 280, height: 280,
              decoration: BoxDecoration(
                color: const Color(0xFF5D9CEC).withOpacity(0.12),
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
                  const Text("Ulasan Makan", style: TextStyle(fontSize: 32, fontWeight: FontWeight.w900, color: Color(0xFF1A237E))),
                  const Text("Berikan pendapatmu tentang menu hari ini", style: TextStyle(color: Colors.grey, fontSize: 14)),
                  const SizedBox(height: 30),

                  // --- BAGIAN MENU DINAMIS ---
                  _isLoadingMenu 
                  ? const Center(child: CircularProgressIndicator()) 
                  : _buildMenuSummary(),

                  const SizedBox(height: 40),
                  const Center(child: Text("Bagaimana rasa makanannya?", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16))),
                  const SizedBox(height: 15),
                  
                  // Rating Bintang
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
                  const Text("Apa yang paling kamu suka?", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 15),
                  
                  // Tag Chips
                  Wrap(
                    spacing: 8, runSpacing: 8,
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
                          child: Text(tag, style: TextStyle(color: isSelected ? Colors.white : Colors.grey[600], fontSize: 13, fontWeight: FontWeight.w600)),
                        ),
                      );
                    }).toList(),
                  ),

                  const SizedBox(height: 40),
                  const Text("Komentar Tambahan", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 12),
                  
                  TextField(
                    controller: _commentController,
                    maxLines: 4,
                    decoration: InputDecoration(
                      hintText: "Tulis pendapatmu di sini...",
                      filled: true,
                      fillColor: Colors.grey[50],
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
                    ),
                  ),

                  const SizedBox(height: 40),
                  
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: auth.isLoading ? null : _handleSendReview,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _primaryBlue,
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                        elevation: 0,
                      ),
                      child: Text(
                        auth.isLoading ? "MENGIRIM..." : "Kirim Ulasan",
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                      ),
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

  // Widget Helper untuk Ringkasan Menu
  Widget _buildMenuSummary() {
    if (_todayMenu == null) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(20)),
        child: const Center(child: Text("Menu hari ini tidak ditemukan", style: TextStyle(color: Colors.grey))),
      );
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.grey[50], borderRadius: BorderRadius.circular(20)),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.network(
              _todayMenu!.image ?? "", 
              width: 60, height: 60, fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => const Icon(Icons.fastfood, color: Colors.grey),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("MENU HARI INI", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.cyan, fontSize: 10)),
                Text(
                  _todayMenu!.menu, // Nama menu asli dari database
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF1A237E)),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}