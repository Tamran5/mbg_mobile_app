import 'package:flutter/material.dart';

class DataSiswaPage extends StatefulWidget {
  const DataSiswaPage({super.key});

  @override
  State<DataSiswaPage> createState() => _DataSiswaPageState();
}

class _DataSiswaPageState extends State<DataSiswaPage> {
  final Color _navy = const Color(0xFF1A237E);
  final Color _accent = const Color(0xFF5D9CEC);

  // Controller untuk fitur pencarian
  final TextEditingController _searchController = TextEditingController();
  
  bool _selectAll = false;
  
  // Simulasi data siswa
  final List<Map<String, dynamic>> _allStudents = [
    {"nama": "Budi Santoso", "nisn": "0012345678", "kelas": "4A", "selected": false},
    {"nama": "Siti Aminah", "nisn": "0098765432", "kelas": "1B", "selected": false},
    {"nama": "Rizky Fauzi", "nisn": "0055667788", "kelas": "6C", "selected": false},
    {"nama": "Dewi Lestari", "nisn": "0022334455", "kelas": "3D", "selected": false},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      // Floating Action Button muncul jika ada siswa yang terpilih
      floatingActionButton: _allStudents.any((s) => s['selected']) 
          ? FloatingActionButton.extended(
              onPressed: () => _showBulkActions(),
              backgroundColor: _navy,
              label: const Text("Aksi Massal", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              icon: const Icon(Icons.flash_on, color: Colors.white),
            )
          : null,
      body: Stack(
        children: [
          _buildCircleDecoration(), // Dekorasi lingkaran biru tetap ada
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(),
                
                // --- FITUR SEARCH BAR ---
                _buildSearchBar(),

                _buildSelectionControl(),

                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    itemCount: _allStudents.length,
                    itemBuilder: (context, index) => _buildStudentCard(_allStudents[index]),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Header Halaman
  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.only(top: 25, left: 24, right: 24, bottom: 5),
      child: Text(
        "Data Siswa",
        style: TextStyle(fontWeight: FontWeight.w900, fontSize: 24, color: _navy),
      ),
    );
  }

  // Widget Search Bar Modern
  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 15),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFFF8F9FD),
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: Colors.grey.shade200),
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
          onChanged: (value) {
            // Logika pencarian bisa ditambahkan di sini
          },
        ),
      ),
    );
  }

  // Kontrol untuk Pilih Semua
  Widget _buildSelectionControl() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text("Daftar Siswa Aktif", style: TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.w500)),
          Row(
            children: [
              const Text("Pilih Semua", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
              Checkbox(
                value: _selectAll,
                activeColor: _navy,
                onChanged: (val) {
                  setState(() {
                    _selectAll = val!;
                    for (var s in _allStudents) { s['selected'] = val; }
                  });
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Kartu Manajemen Siswa
  Widget _buildStudentCard(Map<String, dynamic> student) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: student['selected'] ? _navy : Colors.grey.shade100, width: student['selected'] ? 1.5 : 1),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 8)],
      ),
      child: CheckboxListTile(
        activeColor: _navy,
        value: student['selected'],
        onChanged: (val) {
          setState(() {
            student['selected'] = val!;
            _selectAll = _allStudents.every((s) => s['selected']);
          });
        },
        title: Text(student['nama'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
        subtitle: Text("Kelas ${student['kelas']} • NISN: ${student['nisn']}", style: const TextStyle(fontSize: 12)),
        secondary: CircleAvatar(
          backgroundColor: _navy.withOpacity(0.1),
          child: Text(student['nama'][0], style: TextStyle(color: _navy, fontWeight: FontWeight.bold)),
        ),
      ),
    );
  }

  // Modal Aksi Massal
  void _showBulkActions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(25))),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(10))),
            const SizedBox(height: 20),
            ListTile(leading: const Icon(Icons.trending_up, color: Colors.blue), title: const Text("Naikkan Kelas"), onTap: () {}),
            ListTile(leading: const Icon(Icons.school_outlined, color: Colors.orange), title: const Text("Luluskan Siswa"), onTap: () {}),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  Widget _buildCircleDecoration() {
    return Positioned(
      top: -70, right: -50,
      child: Container(
        width: 280, height: 280,
        decoration: BoxDecoration(color: _accent.withOpacity(0.12), shape: BoxShape.circle),
      ),
    );
  }
}