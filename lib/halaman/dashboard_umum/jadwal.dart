import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import '../../widgets/mbg_scaffold.dart';
import '../../services/api_service.dart'; // Pastikan import sesuai struktur folder Anda
import '../../models/menu_model.dart';   // Pastikan import sesuai struktur folder Anda

class JadwalPage extends StatefulWidget {
  const JadwalPage({super.key});

  @override
  State<JadwalPage> createState() => _JadwalPageState();
}

class _JadwalPageState extends State<JadwalPage> {
  // Menggunakan DateTime.now() agar otomatis menyesuaikan hari ini
  DateTime _focusedDate = DateTime.now();
  DateTime _selectedDate = DateTime.now();
  
  final ApiService _apiService = ApiService();
  MenuModel? _currentMenu;
  bool _isLoading = true;

  final Color _primaryBlue = const Color(0xFF1A237E);

  @override
  void initState() {
    super.initState();
    initializeDateFormatting('id_ID', null);
    
    // Reset jam ke 00:00 agar perbandingan tanggal di kalender akurat
    _selectedDate = DateTime(_selectedDate.year, _selectedDate.month, _selectedDate.day);
    _focusedDate = _selectedDate;

    _fetchMenu(); 
  }

  // Fungsi mengambil data gizi dari Flask Backend
  Future<void> _fetchMenu() async {
    setState(() => _isLoading = true);
    try {
      // Mengambil menu berdasarkan tanggal yang dipilih
      final menu = await _apiService.fetchMenuByDate(_selectedDate); 
      setState(() {
        _currentMenu = menu;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      debugPrint("Error API: $e");
    }
  }

  // Membuat daftar 6 hari kerja (Senin-Sabtu) berdasarkan tanggal fokus
  List<DateTime> _generateWorkingDays(DateTime focus) {
    DateTime monday = focus.subtract(Duration(days: focus.weekday - 1));
    return List.generate(6, (index) => monday.add(Duration(days: index)));
  }

  @override
  Widget build(BuildContext context) {
    List<DateTime> week = _generateWorkingDays(_focusedDate);

    return MbgScaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildLeftAlignedHeader(),
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Navigasi Tanggal Horizontal
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: _buildHorizontalCalendar(week),
                  ),
                  
                  const SizedBox(height: 25),

                  // Logika Tampilan: Loading -> Konten atau Kosong
                  if (_isLoading)
                    const Center(child: Padding(
                      padding: EdgeInsets.only(top: 100),
                      child: CircularProgressIndicator(),
                    ))
                  else if (_currentMenu == null)
                    _buildEmptyState()
                  else
                    _buildMenuContent(_currentMenu!),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- UI COMPONENTS ---

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        children: [
          const SizedBox(height: 80),
          Icon(Icons.restaurant_menu_rounded, size: 100, color: Colors.grey[200]),
          const SizedBox(height: 16),
          Text("Menu belum tersedia", 
            style: TextStyle(color: Colors.grey[500], fontWeight: FontWeight.bold, fontSize: 16)),
          Text("Dapur belum merilis menu untuk hari ini.", 
            style: TextStyle(color: Colors.grey[400], fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildMenuContent(MenuModel data) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Foto Sajian dari Backend
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Image.network(
              data.image ?? "", 
              height: 220, width: double.infinity, fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                height: 200, color: Colors.grey[100],
                child: const Icon(Icons.fastfood_rounded, size: 50, color: Colors.grey),
              ),
            ),
          ),
          const SizedBox(height: 20),
          
          Text(data.menu, 
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: _primaryBlue)),
          
          const SizedBox(height: 35),
          const Text("Analisis Nutrisi", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          _buildSimpleNutri(data),

          const SizedBox(height: 35),
          const Text("Komponen Piring", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          _buildSimplePlate(data.komponen),
          const SizedBox(height: 50),
        ],
      ),
    );
  }

  Widget _buildHorizontalCalendar(List<DateTime> week) {
    return SizedBox(
      height: 80,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: week.length,
        itemBuilder: (context, i) {
          bool isSel = DateFormat('yyyy-MM-dd').format(_selectedDate) == DateFormat('yyyy-MM-dd').format(week[i]);
          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedDate = week[i];
                _fetchMenu(); // Setiap ganti tanggal, ambil data baru
              });
            },
            child: Container(
              width: 58,
              margin: const EdgeInsets.only(right: 12),
              decoration: BoxDecoration(
                color: isSel ? _primaryBlue : Colors.white,
                borderRadius: BorderRadius.circular(15),
                border: isSel ? null : Border.all(color: Colors.grey[100]!),
                boxShadow: [if (isSel) BoxShadow(color: _primaryBlue.withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 5))],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(DateFormat('EEE', 'id_ID').format(week[i]), 
                    style: TextStyle(color: isSel ? Colors.white70 : Colors.grey, fontSize: 12)),
                  Text(DateFormat('d').format(week[i]), 
                    style: TextStyle(color: isSel ? Colors.white : Colors.black, fontWeight: FontWeight.bold, fontSize: 18)),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSimpleNutri(MenuModel data) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white, borderRadius: BorderRadius.circular(25),
        border: Border.all(color: Colors.grey[50]!),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 20, offset: const Offset(0, 10))],
      ),
      child: Row(
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 85, height: 85,
                child: CircularProgressIndicator(
                  value: 0.35, strokeWidth: 9, 
                  backgroundColor: Colors.grey[100], color: Colors.cyan[400],
                ),
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(data.kcal, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18)),
                  Text("Kkal", style: TextStyle(fontSize: 10, color: Colors.cyan[700], fontWeight: FontWeight.bold)),
                ],
              ),
            ],
          ),
          const SizedBox(width: 30),
          Expanded(
            child: Column(
              children: [
                _nutriRow("Karbohidrat (${data.nutrisi.karbo['p']})", data.nutrisi.karbo['b']!),
                _nutriRow("Protein (${data.nutrisi.prot['p']})", data.nutrisi.prot['b']!),
                _nutriRow("Lemak (${data.nutrisi.lem['p']})", data.nutrisi.lem['b']!),
                const Divider(height: 20),
                _nutriRow("Serat", data.nutrisi.serat),
                _nutriRow("Zat Besi", data.nutrisi.zatBesi),
                _nutriRow("Kalsium", data.nutrisi.kalsium),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _nutriRow(String label, String val) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.w600)),
          Text(val, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.black87)),
        ],
      ),
    );
  }

  Widget _buildSimplePlate(List<KomponenPiring> items) {
    return Column(
      children: items.map((item) => Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(color: Colors.grey[50], borderRadius: BorderRadius.circular(18)),
        child: Row(
          children: [
            Container(width: 12, height: 12, 
              decoration: BoxDecoration(
                color: Color(int.parse(item.c.replaceFirst('#', '0xff'))), 
                shape: BoxShape.circle
              )),
            const SizedBox(width: 18),
            Expanded(child: Text(item.n, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700))),
            Text(item.b, style: const TextStyle(color: Colors.blueGrey, fontSize: 12, fontWeight: FontWeight.w800)),
          ],
        ),
      )).toList(),
    );
  }

  Widget _buildLeftAlignedHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 25, 15, 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Menu Harian", style: TextStyle(fontSize: 32, fontWeight: FontWeight.w900, color: _primaryBlue)),
          const SizedBox(height: 5),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(DateFormat('MMMM yyyy', 'id_ID').format(_focusedDate),
                style: TextStyle(color: _primaryBlue.withOpacity(0.7), fontWeight: FontWeight.w800, fontSize: 18)),
              Row(
                children: [
                  _buildNavButton(Icons.chevron_left, () => setState(() => _focusedDate = _focusedDate.subtract(const Duration(days: 7)))),
                  const SizedBox(width: 10),
                  _buildNavButton(Icons.chevron_right, () => setState(() => _focusedDate = _focusedDate.add(const Duration(days: 7)))),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNavButton(IconData icon, VoidCallback onPressed) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: Colors.white, borderRadius: BorderRadius.circular(10),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
        ),
        child: Icon(icon, color: _primaryBlue, size: 22),
      ),
    );
  }
}