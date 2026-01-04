import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  // --- TEMA WARNA & DEKORASI ---
  final Color _primaryBlue = const Color(0xFF1A237E);
  final Color _accentBlue = const Color(0xFF5D9CEC);
  final _formKey = GlobalKey<FormState>();
  final ImagePicker _picker = ImagePicker();

  // --- CONTROLLERS UTAMA ---
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  // --- CONTROLLERS WILAYAH ---
  final TextEditingController _provinceController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _districtController = TextEditingController();
  final TextEditingController _villageController = TextEditingController();

  // --- CONTROLLERS DATA SPESIFIK ---
  final TextEditingController _idNumberController = TextEditingController();
  final TextEditingController _schoolNameController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _studentCountController = TextEditingController();

  // --- STATE VARIABLES ---
  String? _selectedRole;
  final List<String> _roles = ['Siswa', 'Lansia', 'Pengelola Sekolah'];
  File? _imageFile;
  double? _lat, _lng;
  bool _isPasswordVisible = false;

  @override
  void dispose() {
    // Membersihkan memori untuk mencegah memory leak
    _nameController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _provinceController.dispose();
    _cityController.dispose();
    _districtController.dispose();
    _villageController.dispose();
    _idNumberController.dispose();
    _schoolNameController.dispose();
    _addressController.dispose();
    _studentCountController.dispose();
    super.dispose();
  }

  // --- FUNGSI AMBIL GAMBAR DOKUMEN ---
  Future<void> _pickImage(ImageSource source) async {
    final pickedFile = await _picker.pickImage(
      source: source,
      imageQuality: 50,
    );
    if (pickedFile != null) {
      setState(() => _imageFile = File(pickedFile.path));
    }
  }

  // --- LOGIKA REGISTER KE BACKEND FLASK ---
  void _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;

    // Validasi Dokumen Wajib (Lansia/Sekolah)
    if ((_selectedRole != 'Siswa') && _imageFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Harap lampirkan foto KTP atau SK Pengelola!"),
        ),
      );
      return;
    }

    final auth = Provider.of<AuthProvider>(context, listen: false);

    // Mapping Data Teks
    Map<String, String> fields = {
      "fullname": _nameController.text,
      "phone": _phoneController.text,
      "password": _passwordController.text,
      "role": _selectedRole == 'Pengelola Sekolah'
          ? 'pengelola_sekolah'
          : _selectedRole!.toLowerCase(),
      "province": _provinceController.text,
      "city": _cityController.text,
      "district": _districtController.text,
      "village": _villageController.text,
    };

    String fileKey = "file_ktp";

    if (_selectedRole == 'Pengelola Sekolah') {
      fields.addAll({
        "npsn": _idNumberController.text,
        "school_name": _schoolNameController.text,
        "address": _addressController.text,
        "student_count": _studentCountController.text,
      });
      fileKey = "file_sk_operator";
    } else if (_selectedRole == 'Lansia') {
      fields.addAll({
        "nik": _idNumberController.text,
        "address": _addressController.text,
        "coordinates": _lat != null ? "$_lat,$_lng" : "",
      });
    }

    // Eksekusi Multipart Request
    final res = await auth.registerWithFile(fields, _imageFile, fileKey);

    if (res['status'] == 'success') {
      _showSuccessDialog();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(res['message'] ?? "Gagal mendaftar"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // --- 1. DEKORASI IDENTIK DENGAN LOGIN ---
          Positioned(
            top: -70,
            right: -50,
            child: Container(
              width: 280,
              height: 280,
              decoration: BoxDecoration(
                color: _accentBlue.withOpacity(0.12),
                shape: BoxShape.circle,
              ),
            ),
          ),

          // --- 2. KONTEN FORM ---
          SafeArea(
            child: Column(
              children: [
                _buildAppBar(),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 28),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 10),
                          Center(
                            child: Image.asset(
                              'assets/images/logo.png',
                              height: 160,
                              fit: BoxFit.contain,
                              errorBuilder: (context, error, stackTrace) =>
                                  Icon(
                                    Icons.fastfood_rounded,
                                    size: 100,
                                    color: _primaryBlue,
                                  ),
                            ),
                          ),
                          const SizedBox(height: 30),

                          _buildSectionHeader("Kategori Pengguna"),
                          _buildRoleDropdown(),

                          const SizedBox(height: 25),
                          _buildSectionHeader("Informasi Pribadi"),
                          _buildTextField(
                            _nameController,
                            Icons.person_outline,
                            "Nama Lengkap Sesuai KTP",
                          ),
                          const SizedBox(height: 15),
                          _buildTextField(
                            _phoneController,
                            Icons.phone_android_outlined,
                            "Nomor WhatsApp",
                            type: TextInputType.phone,
                          ),

                          const SizedBox(height: 25),
                          _buildSectionHeader("Data Wilayah"),
                          _buildTextField(
                            _provinceController,
                            Icons.map_outlined,
                            "Provinsi",
                          ),
                          const SizedBox(height: 15),
                          _buildTextField(
                            _cityController,
                            Icons.location_city_outlined,
                            "Kabupaten / Kota",
                          ),
                          const SizedBox(height: 15),
                          _buildTextField(
                            _districtController,
                            Icons.explore_outlined,
                            "Kecamatan",
                          ),
                          const SizedBox(height: 15),
                          _buildTextField(
                            _villageController,
                            Icons.home_work_outlined,
                            "Desa / Kelurahan",
                          ),

                          if (_selectedRole != null) _buildDynamicFields(),

                          const SizedBox(height: 25),
                          _buildSectionHeader("Keamanan"),
                          _buildPasswordField(),

                          const SizedBox(height: 40),
                          _buildSubmitButton(),
                          const SizedBox(height: 40),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- UI COMPONENTS HELPER ---

  Widget _buildAppBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
      child: Row(
        children: [
          IconButton(
            icon: Icon(Icons.arrow_back_ios_new_rounded, color: _primaryBlue),
            onPressed: () => Navigator.pop(context),
          ),
          Text(
            "Daftar Akun MBG",
            style: TextStyle(
              color: _primaryBlue,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLogoHeader() {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: _primaryBlue.withOpacity(0.05),
          shape: BoxShape.circle,
        ),
        child: Icon(
          Icons.health_and_safety_outlined,
          size: 60,
          color: _primaryBlue,
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w900,
          color: _primaryBlue.withOpacity(0.6),
          letterSpacing: 1.5,
        ),
      ),
    );
  }

  Widget _buildDynamicFields() {
    bool isSchool = _selectedRole == 'Pengelola Sekolah';
    bool isLansia = _selectedRole == 'Lansia';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 25),
        _buildSectionHeader(
          isSchool ? "Data Institusi Sekolah" : "Identitas Penerima",
        ),
        _buildTextField(
          _idNumberController,
          Icons.badge_outlined,
          isSchool ? "NPSN Sekolah" : (isLansia ? "NIK Lansia" : "NISN Siswa"),
        ),
        if (isSchool || isLansia) ...[
          if (isSchool)
            _buildTextField(
              _schoolNameController,
              Icons.school_outlined,
              "Nama Resmi Sekolah",
            ),
          const SizedBox(height: 15),
          _buildTextField(
            _addressController,
            Icons.storefront_outlined,
            "Detail Alamat (Jalan/RT/RW)",
          ),
          if (isSchool) ...[
            const SizedBox(height: 15),
            _buildTextField(
              _studentCountController,
              Icons.groups_outlined,
              "Estimasi Jumlah Siswa",
              type: TextInputType.number,
            ),
          ],
          if (isLansia) _buildLocationPicker(),
          const SizedBox(height: 20),
          _buildUploadBox(
            isSchool ? "Unggah SK Pengelola Sekolah" : "Unggah Foto KTP Lansia",
          ),
        ],
      ],
    );
  }

  Widget _buildUploadBox(String label) {
    return InkWell(
      onTap: () => _pickImage(ImageSource.camera),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey[50],
          borderRadius: BorderRadius.circular(15),
          border: Border.all(
            color: _imageFile != null ? Colors.green : Colors.grey[300]!,
          ),
        ),
        child: Row(
          children: [
            Icon(
              _imageFile != null
                  ? Icons.check_circle
                  : Icons.cloud_upload_outlined,
              color: _imageFile != null ? Colors.green : _primaryBlue,
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLocationPicker() {
    return InkWell(
      onTap: () => setState(() {
        _lat = -7.7512;
        _lng = 110.5956;
      }),
      child: Container(
        margin: const EdgeInsets.only(top: 15),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: _lat != null ? Colors.blue[50] : Colors.grey[50],
          borderRadius: BorderRadius.circular(15),
        ),
        child: Row(
          children: [
            Icon(
              Icons.my_location,
              color: _lat != null ? Colors.red : Colors.grey,
            ),
            const SizedBox(width: 15),
            Text(
              _lat == null
                  ? "Pin Point Lokasi Rumah"
                  : "Lokasi Terkunci: $_lat, $_lng",
              style: const TextStyle(fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController ctrl,
    IconData icon,
    String label, {
    TextInputType? type,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: TextFormField(
        controller: ctrl,
        keyboardType: type,
        decoration: _inputStyle(label, icon),
        validator: (v) => v!.isEmpty ? "Wajib diisi" : null,
      ),
    );
  }

  Widget _buildPasswordField() {
    return TextFormField(
      controller: _passwordController,
      obscureText: !_isPasswordVisible,
      decoration: _inputStyle("Buat Kata Sandi", Icons.lock_outline).copyWith(
        suffixIcon: IconButton(
          icon: Icon(
            _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
            size: 20,
          ),
          onPressed: () =>
              setState(() => _isPasswordVisible = !_isPasswordVisible),
        ),
      ),
      validator: (v) => v!.length < 6 ? "Minimal 6 karakter" : null,
    );
  }

  Widget _buildRoleDropdown() {
    return DropdownButtonFormField<String>(
      decoration: _inputStyle("Pilih Kategori", Icons.category_outlined),
      value: _selectedRole,
      items: _roles
          .map((r) => DropdownMenuItem(value: r, child: Text(r)))
          .toList(),
      onChanged: (v) => setState(() => _selectedRole = v),
      validator: (v) => v == null ? "Pilih kategori" : null,
    );
  }

  Widget _buildSubmitButton() {
    final auth = Provider.of<AuthProvider>(context);
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: _primaryBlue,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
        ),
        onPressed: auth.isLoading ? null : _handleRegister,
        child: auth.isLoading
            ? const CircularProgressIndicator(color: Colors.white)
            : const Text(
                "AJUKAN PENDAFTARAN",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
      ),
    );
  }

  InputDecoration _inputStyle(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: _primaryBlue, size: 20),
      filled: true,
      fillColor: Colors.grey[50],
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: BorderSide.none,
      ),
    );
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (c) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text("Pendaftaran Terkirim"),
        content: const Text(
          "Data Anda telah kami terima. Mohon tunggu verifikasi Admin Dapur dalam 1-3 hari kerja.",
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }
}
