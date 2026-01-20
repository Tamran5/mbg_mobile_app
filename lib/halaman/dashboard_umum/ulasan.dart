import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../services/api_service.dart';
import '../../models/menu_model.dart';
import 'dart:convert';

class UlasanPage extends StatefulWidget {
  const UlasanPage({super.key});

  @override
  State<UlasanPage> createState() => _UlasanPageState();
}

class _UlasanPageState extends State<UlasanPage> {
  // Tema Warna
  final Color _primaryBlue = const Color(0xFF1A237E);
  final Color _accentCyan = const Color(0xFF00BCD4);

  final ApiService _apiService = ApiService();
  final TextEditingController _commentController = TextEditingController();

  // State Variables
  int _selectedRating = 0;
  MenuModel? _todayMenu;
  bool _isLoadingMenu = true;
  final List<String> _selectedTags = [];

  // Pilihan Tag Cepat
  final List<String> _availableTags = [
    "Rasa Enak",
    "Porsi Cukup",
    "Sangat Bergizi",
    "Kebersihan Oke",
    "Masih Hangat",
    "Segar",
  ];

  @override
  void initState() {
    super.initState();
    _loadMenu();
  }

  // Mengambil menu hari ini agar siswa tahu apa yang mereka ulas
  Future<void> _loadMenu() async {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    setState(() => _isLoadingMenu = true);

    try {
      final token = await auth.getAuthToken();
      // Mengambil menu berdasarkan tanggal sistem saat ini
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

  // Fungsi Utama Mengirim Ulasan ke Backend Flask
  Future<void> _handleSendReview() async {
    final auth = Provider.of<AuthProvider>(context, listen: false);

    if (_selectedRating == 0) {
      _showSnackBar("Silakan pilih rating bintang dulu ya!", Colors.orange);
      return;
    }

    final res = await auth.submitReview(
      rating: _selectedRating,
      tags: _selectedTags,
      komentar: _commentController.text,
    );

    if (mounted) {
      if (res['status'] == 'success') {
        _showSnackBar("Ulasan berhasil dikirim! Terima kasih.", Colors.green);

        _showSuccessDialog(); 
        _resetForm();
      } else {
        _showSnackBar(
          res['message'] ?? "Gagal mengirim ulasan",
          Colors.redAccent,
        );
      }
    }
  }

  void _resetForm() {
    setState(() {
      _selectedRating = 0;
      _selectedTags.clear();
      _commentController.clear();
    });
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.check_circle_outline,
              color: Colors.green,
              size: 80,
            ),
            const SizedBox(height: 20),
            const Text(
              "Terima Kasih!",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            const Text(
              "Ulasanmu sangat membantu kami meningkatkan kualitas makanan.",
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 25),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  Provider.of<AuthProvider>(
                    context,
                    listen: false,
                  ).setTabIndex(0);
                },
                style: ElevatedButton.styleFrom(backgroundColor: _primaryBlue),
                child: const Text(
                  "KEMBALI KE BERANDA",
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
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
      appBar: AppBar(
        title: const Text(
          "Berikan Ulasan",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        foregroundColor: _primaryBlue,
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 10),
            _buildMenuHeader(),
            const SizedBox(height: 30),

            const Center(
              child: Text(
                "Bagaimana rasa makanan hari ini?",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ),
            const SizedBox(height: 15),
            _buildStarRating(),

            const SizedBox(height: 40),
            const Text(
              "Apa yang kamu suka dari menu ini?",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 15),
            _buildTagChips(),

            const SizedBox(height: 40),
            const Text(
              "Tulis komentar (opsional)",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 12),
            _buildCommentField(),

            const SizedBox(height: 40),
            _buildSubmitButton(auth),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuHeader() {
    if (_isLoadingMenu) return const Center(child: LinearProgressIndicator());
    if (_todayMenu == null)
      return const Text("Tidak ada menu yang aktif hari ini.");

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.blue.withOpacity(0.1)),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.network(
              _todayMenu!.image ?? "",
              width: 70,
              height: 70,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) =>
                  Icon(Icons.restaurant, color: _primaryBlue, size: 40),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "MENU HARI INI",
                  style: TextStyle(
                    color: _accentCyan,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                  ),
                ),
                Text(
                  _todayMenu!.menu,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: _primaryBlue,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStarRating() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(5, (index) {
        return IconButton(
          onPressed: () => setState(() => _selectedRating = index + 1),
          icon: Icon(
            index < _selectedRating
                ? Icons.star_rounded
                : Icons.star_outline_rounded,
            color: index < _selectedRating ? Colors.orange : Colors.grey[300],
            size: 48,
          ),
        );
      }),
    );
  }

  Widget _buildTagChips() {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: _availableTags.map((tag) {
        bool isSelected = _selectedTags.contains(tag);
        return FilterChip(
          label: Text(tag),
          selected: isSelected,
          onSelected: (val) {
            setState(() {
              val ? _selectedTags.add(tag) : _selectedTags.remove(tag);
            });
          },
          selectedColor: _primaryBlue.withOpacity(0.2),
          checkmarkColor: _primaryBlue,
          labelStyle: TextStyle(
            color: isSelected ? _primaryBlue : Colors.grey[700],
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildCommentField() {
    return TextField(
      controller: _commentController,
      maxLines: 4,
      decoration: InputDecoration(
        hintText: "Contoh: Nasinya pulen dan ayamnya bumbunya meresap...",
        filled: true,
        fillColor: Colors.grey[50],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  Widget _buildSubmitButton(AuthProvider auth) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: auth.isLoading ? null : _handleSendReview,
        style: ElevatedButton.styleFrom(
          backgroundColor: _primaryBlue,
          padding: const EdgeInsets.symmetric(vertical: 18),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          elevation: 0,
        ),
        child: auth.isLoading
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
            : const Text(
                "KIRIM ULASAN",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
      ),
    );
  }
}
