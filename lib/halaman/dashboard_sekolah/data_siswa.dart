import 'package:flutter/material.dart';
import '../../widgets/mbg_scaffold.dart';

class DataSiswaPage extends StatefulWidget {
  const DataSiswaPage({super.key});

  @override
  State<DataSiswaPage> createState() => _DataSiswaPageState();
}

class _DataSiswaPageState extends State<DataSiswaPage> {
  final Color _navy = const Color(0xFF1A237E);
  final TextEditingController _searchController = TextEditingController();
  
  bool _selectAll = false;
  
  final List<Map<String, dynamic>> _allStudents = [
    {"nama": "Budi Santoso", "nisn": "0012345678", "kelas": "4A", "selected": false},
    {"nama": "Siti Aminah", "nisn": "0098765432", "kelas": "1B", "selected": false},
    {"nama": "Rizky Fauzi", "nisn": "0055667788", "kelas": "6C", "selected": false},
    {"nama": "Dewi Lestari", "nisn": "0022334455", "kelas": "3D", "selected": false},
  ];

  @override
  Widget build(BuildContext context) {
    return MbgScaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header tanpa tombol kembali
          _buildHeader(),
          
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 10),
                  _buildSearchBar(),
                  _buildSelectionControl(),

                  Column(
                    children: _allStudents.map((siswa) => _buildStudentCard(siswa)).toList(),
                  ),
                  
                  const SizedBox(height: 100), 
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: _allStudents.any((s) => s['selected']) 
          ? FloatingActionButton.extended(
              onPressed: () => _showBulkActions(),
              backgroundColor: _navy,
              label: const Text("Aksi Massal", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              icon: const Icon(Icons.flash_on, color: Colors.white),
            )
          : null,
    );
  }

  // --- UI COMPONENTS ---

  Widget _buildHeader() {
    return Padding(
      // Padding atas ditambah (40) agar tidak terlalu mepet ke status bar 
      // karena sudah tidak ada IconButton di atasnya
      padding: const EdgeInsets.fromLTRB(24, 40, 24, 10), 
      child: Text(
        "Data Siswa",
        style: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.w900,
          color: _navy,
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: "Cari berdasarkan NISN atau Nama...",
          hintStyle: const TextStyle(fontSize: 13, color: Colors.grey),
          prefixIcon: Icon(Icons.search, color: _navy),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 15),
        ),
      ),
    );
  }

  Widget _buildSelectionControl() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text("DAFTAR SISWA AKTIF", 
            style: TextStyle(color: Colors.grey, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1.2)),
          Row(
            children: [
              const Text("Pilih Semua", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
              const SizedBox(width: 8),
              SizedBox(
                height: 24, width: 24,
                child: Checkbox(
                  value: _selectAll,
                  activeColor: _navy,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                  onChanged: (val) {
                    setState(() {
                      _selectAll = val!;
                      for (var s in _allStudents) { s['selected'] = val; }
                    });
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStudentCard(Map<String, dynamic> student) {
    bool isSelected = student['selected'];
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isSelected ? _navy : Colors.grey[100]!, 
          width: isSelected ? 1.5 : 1
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(isSelected ? 13 : 5), 
            blurRadius: 10, 
            offset: const Offset(0, 4)
          )
        ],
      ),
      child: Theme(
        data: ThemeData(checkboxTheme: CheckboxThemeData(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5))
        )),
        child: CheckboxListTile(
          activeColor: _navy,
          value: isSelected,
          onChanged: (val) {
            setState(() {
              student['selected'] = val!;
              _selectAll = _allStudents.every((s) => s['selected']);
            });
          },
          title: Text(student['nama'], 
            style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15, color: isSelected ? _navy : Colors.black87)),
          subtitle: Text("Kelas ${student['kelas']} • NISN: ${student['nisn']}", 
            style: const TextStyle(fontSize: 12, color: Colors.grey)),
          secondary: CircleAvatar(
            backgroundColor: isSelected ? _navy : _navy.withAlpha(13),
            child: Text(student['nama'][0], 
              style: TextStyle(color: isSelected ? Colors.white : _navy, fontWeight: FontWeight.bold)),
          ),
          controlAffinity: ListTileControlAffinity.trailing,
        ),
      ),
    );
  }

  void _showBulkActions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(30))),
      builder: (context) => Padding(
        padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(width: 40, height: 5, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(10))),
            const SizedBox(height: 25),
            const Text("Aksi untuk Siswa Terpilih", style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18)),
            const SizedBox(height: 20),
            _buildActionTile(Icons.trending_up_rounded, "Naikkan Kelas", Colors.blue),
            _buildActionTile(Icons.school_rounded, "Luluskan Siswa", Colors.orange),
            _buildActionTile(Icons.delete_outline_rounded, "Hapus Data", Colors.red),
          ],
        ),
      ),
    );
  }

  Widget _buildActionTile(IconData icon, String title, Color color) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(color: color.withAlpha(26), shape: BoxShape.circle),
        child: Icon(icon, color: color),
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
      onTap: () {},
      trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: Colors.grey),
    );
  }
}