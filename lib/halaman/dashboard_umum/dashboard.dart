import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../services/api_service.dart';
import '../../models/menu_model.dart';

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
    _loadTodayMenu();
  }

  Future<void> _loadTodayMenu() async {
    if (!mounted) return;
    setState(() => _isLoadingMenu = true);
    
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final token = await auth.getAuthToken();
    
    final menu = await _apiService.fetchMenuByDate(DateTime.now(), token);
    
    if (mounted) {
      setState(() {
        _todayMenu = menu;
        _isLoadingMenu = false;
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
        final String kkalVal = _todayMenu?.kcal ?? "0";
        final String proteinVal = _todayMenu?.nutrisi.prot['v'] ?? "0";
        final String lemakVal = _todayMenu?.nutrisi.lem['v'] ?? "0";

        return Scaffold(
          backgroundColor: Colors.white,
          body: RefreshIndicator(
            onRefresh: _loadTodayMenu,
            child: Stack(
              children: [
                Positioned(
                  top: -70, right: -50,
                  child: Container(
                    width: 280, height: 280,
                    decoration: BoxDecoration(
                      color: const Color(0xFF5D9CEC).withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
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
                        const Text("Ringkasan Nutrisi Hari Ini", 
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            _buildNutritionWidget("Kalori", kkalVal, "Kkal", Icons.bolt, Colors.orange),
                            const SizedBox(width: 12),
                            _buildNutritionWidget("Protein", proteinVal, "gram", Icons.egg_alt, Colors.cyan),
                            const SizedBox(width: 12),
                            _buildNutritionWidget("Lemak", lemakVal, "gram", Icons.water_drop, Colors.green),
                          ],
                        ),
                        const SizedBox(height: 25),
                        const Text("Menu Makan Siang", 
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        const SizedBox(height: 12),
                        _isLoadingMenu 
                          ? const Center(child: Padding(
                              padding: EdgeInsets.all(20.0),
                              child: CircularProgressIndicator(),
                            ))
                          : _buildShortMenuCard(auth), 
                        const SizedBox(height: 25),
                        _buildTipsCard(),
                        const SizedBox(height: 25),
                        _buildRatingSection(),
                        const SizedBox(height: 30),
                        _buildArticleSection(), // Bagian Artikel
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
              Text("Halo, ${_getGreeting()}!", 
                style: const TextStyle(color: Colors.grey, fontSize: 14)),
              Text(auth.userName ?? "Pengguna",
                style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 22, color: Color(0xFF1A237E))),
              Text(auth.schoolName ?? "Sekolah Tidak Terdaftar",
                style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: Colors.black54)),
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
        decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(20)),
        child: const Center(child: Text("Menu belum tersedia untuk hari ini", style: TextStyle(color: Colors.grey))),
      );
    }
    return GestureDetector(
      onTap: () => auth.setTabIndex(1),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: const Color(0xFF1A237E), 
          borderRadius: BorderRadius.circular(20),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 10, offset: const Offset(0, 4))],
        ),
        child: IntrinsicHeight(
          child: Row(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.horizontal(left: Radius.circular(20)),
                child: Image.network(
                  _todayMenu!.image ?? "https://via.placeholder.com/150",
                  width: 100, height: 110, fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(width: 100, color: Colors.grey[300], child: const Icon(Icons.fastfood)),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(_todayMenu!.menu,
                        style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                        maxLines: 1, overflow: TextOverflow.ellipsis),
                      const SizedBox(height: 4),
                      Text("${_todayMenu!.kcal} Kkal • Paket Nutrisi",
                        style: const TextStyle(color: Colors.white70, fontSize: 12)),
                      const SizedBox(height: 10),
                      const Row(
                        children: [
                          Text("Lihat Detail", 
                            style: TextStyle(color: Colors.blueAccent, fontSize: 12, fontWeight: FontWeight.bold)),
                          SizedBox(width: 4),
                          Icon(Icons.chevron_right, color: Colors.blueAccent, size: 16),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNutritionWidget(String title, String value, String unit, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white, borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 8)],
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(height: 8),
            Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
            Text(unit, style: const TextStyle(color: Colors.grey, fontSize: 10)),
          ],
        ),
      ),
    );
  }

  Widget _buildTipsCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: const Color(0xFFE8F5E9), borderRadius: BorderRadius.circular(15)),
      child: const Row(
        children: [
          Icon(Icons.lightbulb_outline_rounded, color: Colors.green, size: 24),
          SizedBox(width: 12),
          Expanded(child: Text("Nutrisi lengkap bantu fokus belajarmu hari ini!", 
            style: TextStyle(color: Colors.green, fontSize: 12, fontWeight: FontWeight.w500))),
        ],
      ),
    );
  }

  Widget _buildRatingSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Bagaimana rasa makanan hari ini?", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _emojiBtn("😋", "Enak"),
            _emojiBtn("😐", "Biasa"),
            _emojiBtn("☹️", "Kurang"),
          ],
        )
      ],
    );
  }

  Widget _emojiBtn(String e, String l) => Column(children: [Text(e, style: const TextStyle(fontSize: 26)), Text(l, style: const TextStyle(fontSize: 10, color: Colors.grey))]);

  // --- ARTIKEL SECTION ---
  Widget _buildArticleSection() {
    // Data dummy untuk navigasi
    const String artTitle = "Pentingnya Protein bagi Pelajar";
    const String artCat = "Nutrisi";
    const String artImg = "https://images.unsplash.com/photo-1490818387583-1baba5e638af?q=80&w=1000";

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text("Artikel Untukmu", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Color(0xFF1A237E))),
            TextButton(onPressed: () {}, child: const Text("Lihat Semua", style: TextStyle(color: Colors.blueAccent, fontSize: 12))),
          ],
        ),
        const SizedBox(height: 10),
        InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const ArticleDetailPage(
                  title: artTitle,
                  category: artCat,
                  imgUrl: artImg,
                ),
              ),
            );
          },
          borderRadius: BorderRadius.circular(15),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey[50], 
              borderRadius: BorderRadius.circular(15),
              border: Border.all(color: Colors.grey.withValues(alpha: 0.1)),
            ),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12), 
                  child: Image.network(artImg, width: 60, height: 60, fit: BoxFit.cover)
                ),
                const SizedBox(width: 15),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start, 
                    children: [
                      Text(artCat, style: TextStyle(color: Colors.blue, fontSize: 10, fontWeight: FontWeight.bold)), 
                      SizedBox(height: 4), 
                      Text(artTitle, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                    ],
                  ),
                ),
                const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: Colors.grey),
              ],
            ),
          ),
        )
      ],
    );
  }

  Widget _buildNotificationButton() {
    return Container(
      width: 45, height: 45,
      decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle, boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.08), blurRadius: 10)]),
      child: const Icon(Icons.notifications_none_rounded, color: Colors.black87),
    );
  }
}

// --- HALAMAN DETAIL ARTIKEL ---
class ArticleDetailPage extends StatelessWidget {
  final String title;
  final String category;
  final String imgUrl;

  const ArticleDetailPage({
    super.key,
    required this.title,
    required this.category,
    required this.imgUrl,
  });

  @override
  Widget build(BuildContext context) {
    const Color navyColor = Color(0xFF1A237E);

    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 250,
            pinned: true,
            backgroundColor: navyColor,
            flexibleSpace: FlexibleSpaceBar(
              background: Image.network(imgUrl, fit: BoxFit.cover),
            ),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(category.toUpperCase(), 
                    style: const TextStyle(color: Colors.blue, fontWeight: FontWeight.bold, fontSize: 12)),
                  const SizedBox(height: 10),
                  Text(title, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: navyColor)),
                  const SizedBox(height: 8),
                  const Text("13 Jan 2026 • Oleh Tim Gizi MBG", style: TextStyle(color: Colors.grey, fontSize: 12)),
                  const Divider(height: 40),
                  const Text(
                    "Protein merupakan salah satu komponen paling vital dalam asupan gizi harian pelajar. "
                    "Sebagai zat pembangun, protein bertanggung jawab atas pertumbuhan sel-sel baru dan perbaikan sel yang rusak.\n\n"
                    "Bagi pelajar, konsumsi protein yang cukup saat makan siang sangat membantu menjaga tingkat konsentrasi. "
                    "Protein memicu pelepasan asam amino yang menjaga otak tetap waspada dan aktif selama sesi pembelajaran di sore hari. "
                    "Oleh karena itu, program Makan Bergizi Gratis selalu menyertakan porsi protein seimbang seperti daging, telur, atau kacang-kacangan dalam setiap menunya.",
                    style: TextStyle(fontSize: 16, height: 1.6, color: Colors.black87),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}