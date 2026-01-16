import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/mbg_scaffold.dart';

class DataSiswaPage extends StatefulWidget {
  const DataSiswaPage({super.key});

  @override
  State<DataSiswaPage> createState() => _DataSiswaPageState();
}

class _DataSiswaPageState extends State<DataSiswaPage> {
  final Color _navy = const Color(0xFF1A237E);
  final TextEditingController _searchController = TextEditingController();
  
  List<Map<String, dynamic>> _allStudents = [];
  List<Map<String, dynamic>> _filteredStudents = [];
  bool _isLoading = true;
  bool _selectAll = false;
  Timer? _debounce;
  String _query = "";

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  // --- LOGIKA DATA ---

  Future<void> _loadData() async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final data = await auth.fetchApprovedStudents();
    
    if (mounted) {
      setState(() {
        _allStudents = data;
        _applyFilter();
        _isLoading = false;
        _selectAll = false;
      });
    }
  }

  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      if (mounted) {
        setState(() {
          _query = query.toLowerCase();
          _applyFilter();
        });
      }
    });
  }

  void _applyFilter() {
    _filteredStudents = _allStudents.where((s) {
      final name = s['fullname'].toString().toLowerCase();
      final nisn = s['nisn'].toString();
      final phone = s['phone'].toString();
      return name.contains(_query) || nisn.contains(_query) || phone.contains(_query);
    }).toList();
  }

  Future<void> _executeBulkAction(String action) async {
    final selectedIds = _allStudents
        .where((s) => s['selected'] == true)
        .map((s) => s['id'] as int)
        .toList();

    if (selectedIds.isEmpty) return;

    if (action == 'delete') {
      bool confirm = await _showConfirmDialog();
      if (!confirm) return;
    }

    final auth = Provider.of<AuthProvider>(context, listen: false);
    final success = await auth.bulkActionStudents(selectedIds, action);

    if (mounted && success) {
      Navigator.pop(context); 
      _loadData();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Aksi $action berhasil diterapkan"), backgroundColor: Colors.green)
      );
    }
  }

  Future<bool> _showConfirmDialog() async {
    return await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Hapus Data?"),
        content: const Text("Data siswa yang dihapus tidak dapat dikembalikan."),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("Batal")),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text("Hapus", style: TextStyle(color: Colors.red))),
        ],
      ),
    ) ?? false;
  }

  @override
  Widget build(BuildContext context) {
    bool hasSelection = _allStudents.any((s) => s['selected'] == true);

    return MbgScaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          _buildPadding(child: _buildSearchBar()),
          _buildPadding(child: _buildSelectionControl()),
          
          Expanded(
            child: _isLoading 
              ? const Center(child: CircularProgressIndicator())
              : RefreshIndicator(
                  onRefresh: _loadData,
                  child: _filteredStudents.isEmpty 
                    ? _buildEmptyState()
                    : ListView.builder(
                        padding: const EdgeInsets.fromLTRB(24, 0, 24, 100),
                        itemCount: _filteredStudents.length,
                        itemBuilder: (context, index) => _buildStudentCard(_filteredStudents[index]),
                      ),
                ),
          ),
        ],
      ),
      floatingActionButton: hasSelection 
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

  Widget _buildPadding({required Widget child}) => Padding(padding: const EdgeInsets.symmetric(horizontal: 24), child: child);

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 40, 24, 10), 
      child: Text("Data Siswa", style: TextStyle(fontSize: 32, fontWeight: FontWeight.w900, color: _navy)),
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
        onChanged: _onSearchChanged,
        decoration: InputDecoration(
          hintText: "Cari NISN, Nama, atau Telepon...",
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
    bool isSelected = student['selected'] ?? false;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: isSelected ? _navy : Colors.grey[100]!, width: isSelected ? 1.5 : 1),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: ListTile(
        onTap: () => _showDetailSiswa(student),
        leading: CircleAvatar(
          backgroundColor: isSelected ? _navy : _navy.withValues(alpha: 0.1),
          child: Text(student['fullname'][0].toUpperCase(), 
            style: TextStyle(color: isSelected ? Colors.white : _navy, fontWeight: FontWeight.bold)),
        ),
        title: Text(student['fullname'] ?? "Siswa", 
          style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15, color: isSelected ? _navy : Colors.black87)),
        // Menambahkan No Telepon di Subtitle Kartu
        subtitle: Text(
          "Kelas ${student['class'] ?? '-'} • NISN: ${student['nisn'] ?? '-'}\nTelp: ${student['phone'] ?? '-'}", 
          style: const TextStyle(fontSize: 11, color: Colors.grey, height: 1.5)
        ),
        isThreeLine: true,
        trailing: Checkbox(
          activeColor: _navy,
          value: isSelected,
          onChanged: (val) {
            setState(() {
              student['selected'] = val!;
              _selectAll = _allStudents.every((s) => s['selected'] == true);
            });
          },
        ),
      ),
    );
  }

  void _showDetailSiswa(Map<String, dynamic> data) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(30))),
        padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(child: Container(width: 40, height: 5, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(10)))),
            const SizedBox(height: 25),
            Text("Profil Siswa", style: TextStyle(fontWeight: FontWeight.w900, fontSize: 22, color: _navy)),
            const Divider(height: 30),
            _buildDetailRow("Nama Lengkap", data['fullname']),
            _buildDetailRow("NISN", data['nisn']),
            _buildDetailRow("Kelas Saat Ini", data['class'] ?? "-"),
            _buildDetailRow("Nomor Telepon", data['phone'] ?? "-"), // Menambahkan baris No Telepon
            _buildDetailRow("Email", data['email'] ?? "-"),
            const SizedBox(height: 20),
            SizedBox(width: double.infinity, child: ElevatedButton(onPressed: () => Navigator.pop(context), child: const Text("Tutup"))),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return const Center(child: Padding(padding: EdgeInsets.only(top: 100), child: Text("Data tidak ditemukan.", style: TextStyle(color: Colors.grey))));
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
            const Text("Aksi Massal", style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18)),
            const SizedBox(height: 20),
            _buildActionTile(Icons.trending_up_rounded, "Naikkan Kelas", Colors.blue, () => _executeBulkAction('promote')),
            _buildActionTile(Icons.school_rounded, "Luluskan Siswa", Colors.orange, () => _executeBulkAction('graduate')),
            _buildActionTile(Icons.delete_outline_rounded, "Hapus Data", Colors.red, () => _executeBulkAction('delete')),
          ],
        ),
      ),
    );
  }

  Widget _buildActionTile(IconData icon, String title, Color color, VoidCallback onTap) {
    return ListTile(
      leading: Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: color.withValues(alpha: 0.1), shape: BoxShape.circle), child: Icon(icon, color: color)),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
      onTap: onTap,
      trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: Colors.grey),
    );
  }
}