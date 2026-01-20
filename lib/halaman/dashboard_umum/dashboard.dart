import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../services/api_service.dart';
import '../../models/menu_model.dart';
import 'detail_artikel.dart';
import 'ListArtikelPage.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  final ApiService _apiService = ApiService();
  MenuModel? _todayMenu;
  bool _isLoadingMenu = true;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  // Perbaikan: Memuat data tanpa parameter string kosong
  Future<void> _loadInitialData() async {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    if (mounted) setState(() => _isLoadingMenu = true);

    // Menjalankan fetch menu dan artikel secara paralel
    await Future.wait([
      _loadTodayMenu(),
      auth.fetchArticles(), // Perbaikan: Tanpa argumen ""
    ]);

    if (mounted) setState(() => _isLoadingMenu = false);
  }

  Future<void> _loadTodayMenu() async {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final token = await auth.getAuthToken();
    final menu = await _apiService.fetchMenuByDate(DateTime.now(), token);
    if (mounted) {
      setState(() {
        _todayMenu = menu;
      });
    }
  }

  String _getGreeting() {
    var hour = DateTime.now().hour;
    if (hour < 11) return "Selamat Pagi";
    if (hour < 15) return "Selamat Siang";
    if (hour < 19) return "Selamat Sore";
    return "Selamat Malam";
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, auth, child) {
        // Null safety untuk data nutrisi
        final String kkalVal = _todayMenu?.kcal ?? "0";
        final String proteinVal =
            _todayMenu?.nutrisi.prot['v']?.toString() ?? "0";
        final String lemakVal = _todayMenu?.nutrisi.lem['v']?.toString() ?? "0";

        return Scaffold(
          backgroundColor: Colors.white,
          body: RefreshIndicator(
            onRefresh: _loadInitialData,
            color: const Color(0xFF1A237E),
            child: Stack(
              children: [
                _buildBackgroundCircle(),
                SafeArea(
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 20),
                        _buildHeader(auth),
                        const SizedBox(height: 25),
                        const Text(
                          "Ringkasan Nutrisi Hari Ini",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 12),
                        _buildNutritionRow(kkalVal, proteinVal, lemakVal),
                        const SizedBox(height: 25),
                        const Text(
                          "Menu Makan Siang",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 12),
                        _isLoadingMenu
                            ? const Center(child: CircularProgressIndicator())
                            : _buildShortMenuCard(auth),
                        const SizedBox(height: 25),
                        _buildTipsCard(),
                        const SizedBox(height: 25),
                        _buildRatingSection(auth), // Tambahkan parameter auth
                        const SizedBox(height: 30),
                        _buildArticleSection(auth),
                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader(AuthProvider auth) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Halo, ${_getGreeting()}!",
                style: const TextStyle(color: Colors.grey, fontSize: 14),
              ),
              Text(
                auth.userName ?? "Pengguna",
                style: const TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 22,
                  color: Color(0xFF1A237E),
                ),
              ),
              Text(
                auth.schoolName ?? "Sekolah Tidak Terdaftar",
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                  color: Colors.black54,
                ),
              ),
            ],
          ),
        ),
        _buildNotificationButton(),
      ],
    );
  }

  Widget _buildShortMenuCard(AuthProvider auth) {
    if (_todayMenu == null) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.grey[300]!),
        ),
        child: const Text(
          "Menu belum tersedia untuk hari ini",
          textAlign: TextAlign.center,
        ),
      );
    }

    // Pastikan URL gambar lengkap
    String imageUrl = _todayMenu!.image ?? "";
    if (!imageUrl.startsWith('http')) {
      imageUrl = "${ApiService.rootUrl}$imageUrl";
    }

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFF1A237E),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.horizontal(
              left: Radius.circular(20),
            ),
            child: Image.network(
              imageUrl,
              width: 100,
              height: 110,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) =>
                  const Icon(Icons.fastfood, color: Colors.white, size: 40),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(15),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _todayMenu!.menu,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    "${_todayMenu!.kcal} Kkal",
                    style: const TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Artikel section tetap sama, hanya pastikan URL gambar benar
  Widget _buildArticleSection(AuthProvider auth) {
    if (auth.articles.isEmpty) return const SizedBox.shrink();

    final latestArt = auth.articles[0];
    final String artImg =
        "${ApiService.rootUrl}/static/uploads/articles/${latestArt['foto']}";

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              "Artikel Untukmu",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: Color(0xFF1A237E),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ListArtikelPage()),
              ),
              child: const Text("Lihat Semua"),
            ),
          ],
        ),
        _buildArticleCard(latestArt, artImg),
      ],
    );
  }

  // Modifikasi Rating Section agar mengarah ke Halaman Ulasan
  Widget _buildRatingSection(AuthProvider auth) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Bagaimana rasa makanan hari ini?",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 15),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildEmojiBtn("😋", "Enak", auth),
              _buildEmojiBtn("😐", "Biasa", auth),
              _buildEmojiBtn("☹️", "Kurang", auth),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmojiBtn(String emoji, String label, AuthProvider auth) {
    return InkWell(
      onTap: () => auth.setTabIndex(3), // Perbaikan: Arahkan ke tab ulasan
      child: Column(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 28)),
          const SizedBox(height: 5),
          Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        ],
      ),
    );
  }

  // Widget pendukung (Background, NutritionWidget, dll) tetap dipertahankan...
  // (Pastikan fungsi _buildNutritionWidget, _buildTipsCard, dll tetap ada di bawah)

  Widget _buildBackgroundCircle() => Positioned(
    top: -70,
    right: -50,
    child: Container(
      width: 280,
      height: 280,
      decoration: BoxDecoration(
        color: const Color(0xFF5D9CEC).withOpacity(0.12),
        shape: BoxShape.circle,
      ),
    ),
  );

  Widget _buildNutritionRow(String kkal, String protein, String lemak) {
    return Row(
      children: [
        _buildNutritionWidget(
          "Kalori",
          kkal,
          "Kkal",
          Icons.bolt,
          Colors.orange,
        ),
        const SizedBox(width: 12),
        _buildNutritionWidget(
          "Protein",
          protein,
          "gram",
          Icons.egg_alt,
          Colors.cyan,
        ),
        const SizedBox(width: 12),
        _buildNutritionWidget(
          "Lemak",
          lemak,
          "gram",
          Icons.water_drop,
          Colors.green,
        ),
      ],
    );
  }

  Widget _buildNutritionWidget(
    String t,
    String v,
    String u,
    IconData i,
    Color c,
  ) => Expanded(
    child: Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8),
        ],
      ),
      child: Column(
        children: [
          Icon(i, color: c, size: 20),
          const SizedBox(height: 8),
          Text(
            v,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
          ),
          Text(u, style: const TextStyle(color: Colors.grey, fontSize: 10)),
        ],
      ),
    ),
  );

  Widget _buildTipsCard() => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: const Color(0xFFE8F5E9),
      borderRadius: BorderRadius.circular(15),
    ),
    child: const Row(
      children: [
        Icon(Icons.lightbulb_outline, color: Colors.green),
        SizedBox(width: 12),
        Expanded(
          child: Text(
            "Nutrisi lengkap bantu fokus belajarmu!",
            style: TextStyle(color: Colors.green, fontSize: 12),
          ),
        ),
      ],
    ),
  );

  Widget _buildNotificationButton() => Container(
    width: 45,
    height: 45,
    decoration: const BoxDecoration(
      color: Colors.white,
      shape: BoxShape.circle,
    ),
    child: const Icon(Icons.notifications_none),
  );

  Widget _buildArticleCard(Map<String, dynamic> art, String imgUrl) {
    return InkWell(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => ArticleDetailPage(article: art)),
      ),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.grey[50],
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: Colors.grey.withOpacity(0.1)),
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                imgUrl,
                width: 60,
                height: 60,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) =>
                    const Icon(Icons.image, color: Colors.grey),
              ),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    art['target']?.toString().toUpperCase() ?? "EDUKASI",
                    style: const TextStyle(
                      color: Colors.blue,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    art['judul'] ?? "Tanpa Judul",
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios_rounded,
              size: 14,
              color: Colors.grey,
            ),
          ],
        ),
      ),
    );
  }
}
