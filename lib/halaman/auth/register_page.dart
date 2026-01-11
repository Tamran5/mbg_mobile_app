import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart'; 
import 'package:provider/provider.dart';
import 'package:dropdown_search/dropdown_search.dart'; 
import '../../providers/auth_provider.dart';
import '../../services/api_service.dart';
import '../waiting_approval_page.dart';
import '../../widgets/mbg_scaffold.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final Color _primaryBlue = const Color(0xFF1A237E);
  final _formKey = GlobalKey<FormState>();
  final ImagePicker _picker = ImagePicker();

  // --- CONTROLLERS ---
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _idNumberController = TextEditingController();
  final TextEditingController _schoolNameController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _studentCountController = TextEditingController();
  final TextEditingController _villageController = TextEditingController();

  // --- STATE VARIABLES ---
  RegionManager? _regionManager;
  String? _selectedProv, _selectedCity, _selectedDist;
  String? _selectedRole;
  String? _selectedPartnerId; 
  List<Map<String, dynamic>> _availablePartners = []; 
  
  final List<String> _roles = ['Siswa', 'Lansia', 'Pengelola Sekolah'];
  XFile? _imageFile;
  bool _isPasswordVisible = false;
  double? _lat, _lng;

  @override
  void initState() {
    super.initState();
    _loadRegionData();
  }

  Future<void> _loadRegionData() async {
    try {
      String jsonString = await DefaultAssetBundle.of(context).loadString("assets/data/regions_master.json");
      setState(() {
        _regionManager = RegionManager(jsonDecode(jsonString));
      });
    } catch (e) {
      debugPrint("Gagal memuat JSON wilayah: $e");
    }
  }

  void _fetchPartners(String district) async {
    if (_selectedRole == null) return;
    String targetRole = _selectedRole == 'Siswa' ? 'pengelola_sekolah' : 'admin_dapur'; 
    final api = ApiService();
    final result = await api.getPartners(targetRole, district);
    
    setState(() {
      _availablePartners = result;
      _selectedPartnerId = null; 
    });
  }

  @override
  void dispose() {
    _nameController.dispose(); 
    _phoneController.dispose(); 
    _emailController.dispose();
    _passwordController.dispose();
    _idNumberController.dispose(); 
    _schoolNameController.dispose();
    _addressController.dispose(); 
    _studentCountController.dispose();
    _villageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // 2. Gunakan MbgScaffold untuk konsistensi latar belakang
    return MbgScaffold(
      body: Column(
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
                    _buildLogoHeader(),
                    const SizedBox(height: 30),
                    _buildSectionHeader("Kategori Pengguna"),
                    _buildRoleDropdown(),
                    const SizedBox(height: 25),
                    _buildSectionHeader("Informasi Pribadi"),
                    _buildTextField(_nameController, Icons.person_outline, "Nama Lengkap Sesuai KTP"),
                    _buildTextField(_phoneController, Icons.phone_android_outlined, "Nomor WhatsApp", type: TextInputType.phone),
                    _buildTextField(_emailController, Icons.email_outlined, "Alamat Email", type: TextInputType.emailAddress),
                    
                    const SizedBox(height: 25),
                    _buildRegionSelection(), 

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
    );
  }

  // --- UI COMPONENTS ---

  Widget _buildAppBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded),
            onPressed: () => Navigator.pop(context),
          ),
          const Text(
            "Daftar Akun MBG",
            style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18),
          )
        ],
      ),
    );
  }

  Widget _buildRegionSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader("Data Wilayah"),
        _buildSearchDropdown(
          label: "Pilih Provinsi",
          icon: Icons.map_outlined,
          items: _regionManager?.getProvinces() ?? [],
          selectedItem: _selectedProv,
          onChanged: (val) => setState(() {
            _selectedProv = val; _selectedCity = null; _selectedDist = null;
            _availablePartners = [];
          }),
        ),
        const SizedBox(height: 15),
        _buildSearchDropdown(
          label: "Pilih Kabupaten / Kota",
          icon: Icons.location_city_outlined,
          items: _selectedProv != null ? _regionManager!.getCities(_selectedProv!) : [],
          selectedItem: _selectedCity,
          enabled: _selectedProv != null,
          onChanged: (val) => setState(() {
            _selectedCity = val; _selectedDist = null;
            _availablePartners = [];
          }),
        ),
        const SizedBox(height: 15),
        _buildSearchDropdown(
          label: "Pilih Kecamatan",
          icon: Icons.explore_outlined,
          items: (_selectedProv != null && _selectedCity != null) 
              ? _regionManager!.getDistricts(_selectedProv!, _selectedCity!) : [],
          selectedItem: _selectedDist,
          enabled: _selectedCity != null,
          onChanged: (val) {
            setState(() => _selectedDist = val);
            if (val != null) _fetchPartners(val);
          },
        ),
        const SizedBox(height: 15),
        _buildTextField(_villageController, Icons.home_work_outlined, "Desa / Kelurahan"),
      ],
    );
  }

  Widget _buildDynamicFields() {
    bool isSchool = _selectedRole == 'Pengelola Sekolah';
    bool isStudent = _selectedRole == 'Siswa';
    bool isLansia = _selectedRole == 'Lansia';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 25),
        _buildSectionHeader(isSchool ? "Data Institusi Sekolah" : "Identitas Penerima"),
        _buildTextField(_idNumberController, Icons.badge_outlined, isSchool ? "NPSN Sekolah" : (isLansia ? "NIK Lansia" : "NISN Siswa")),
        
        const SizedBox(height: 15),
        _buildSectionHeader(isStudent ? "Pilih Sekolah" : "Pilih Mitra Dapur"),
        
        DropdownButtonFormField<String>(
          decoration: _inputStyle(isStudent ? "Daftar Sekolah" : "Daftar Dapur Pelaksana", Icons.handshake_outlined),
          value: _selectedPartnerId,
          items: _availablePartners.map((p) => DropdownMenuItem(
            value: p['id'].toString(), 
            child: Text(p['name'].toString()),
          )).toList(),
          onChanged: _availablePartners.isEmpty ? null : (val) => setState(() => _selectedPartnerId = val),
          validator: (val) => val == null ? "Wajib pilih mitra" : null,
        ),

        if (_availablePartners.isEmpty && _selectedDist != null) _buildPartnerAlert(),

        if (isSchool || isLansia) ...[
          const SizedBox(height: 15),
          if (isSchool) _buildTextField(_schoolNameController, Icons.school_outlined, "Nama Resmi Sekolah"),
          _buildTextField(_addressController, Icons.storefront_outlined, "Detail Alamat (Jalan/RT/RW)"),
          if (isSchool) _buildTextField(_studentCountController, Icons.groups_outlined, "Estimasi Jumlah Siswa", type: TextInputType.number),
          if (isLansia) _buildLocationPicker(),
          const SizedBox(height: 20),
          _buildUploadBox(isSchool ? "Unggah SK Pengelola Sekolah" : "Unggah Foto KTP Lansia"),
        ]
      ],
    );
  }

  // --- LOGIC ---

  void _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;

    if ((_selectedRole != 'Siswa') && _imageFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Unggah dokumen pendukung!")));
      return;
    }

    final auth = Provider.of<AuthProvider>(context, listen: false);
    
    Map<String, String> fields = {
      "fullname": _nameController.text,
      "phone": _phoneController.text,
      "email": _emailController.text,
      "password": _passwordController.text,
      "role": _selectedRole == 'Pengelola Sekolah' ? 'pengelola_sekolah' : _selectedRole!.toLowerCase(),
      "province": _selectedProv ?? "",
      "city": _selectedCity ?? "",
      "district": _selectedDist ?? "",
      "village": _villageController.text,
    };

    String fileKey = _selectedRole == 'Pengelola Sekolah' ? "file_sk_operator" : "file_ktp";

    if (_selectedRole == 'Pengelola Sekolah') {
      fields.addAll({
        "npsn": _idNumberController.text,
        "school_name": _schoolNameController.text,
        "address": _addressController.text,
        "student_count": _studentCountController.text,
        "dapur_id": _selectedPartnerId ?? ""
      });
    } else if (_selectedRole == 'Lansia') {
      fields.addAll({
        "nik": _idNumberController.text, 
        "coordinates": "${_lat ?? 0},${_lng ?? 0}", 
        "dapur_id": _selectedPartnerId ?? ""
      });
    } else if (_selectedRole == 'Siswa') {
      fields.addAll({
        "nisn": _idNumberController.text, 
        "sekolah_id": _selectedPartnerId ?? ""
      });
    }

    final res = await auth.registerWithFile(fields, _imageFile, fileKey);
    
    if (res['status'] == 'success') {
      if (context.mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const WaitingApprovalPage()),
          (route) => false,
        );
      }
    } else {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(res['message'] ?? "Gagal"), backgroundColor: Colors.red)
        );
      }
    }
  }

  // --- HELPERS ---

  Widget _buildSubmitButton() {
    final auth = Provider.of<AuthProvider>(context);
    bool isDisabled = (_selectedRole == 'Pengelola Sekolah' && _availablePartners.isEmpty) || auth.isLoading;

    return SizedBox(width: double.infinity, height: 56,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: isDisabled ? Colors.grey[400] : _primaryBlue, 
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          elevation: 0,
        ),
        onPressed: isDisabled ? null : _handleRegister,
        child: auth.isLoading 
          ? const CircularProgressIndicator(color: Colors.white) 
          : const Text("AJUKAN PENDAFTARAN", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );
  }

  InputDecoration _inputStyle(String label, IconData icon) => InputDecoration(
    labelText: label, 
    prefixIcon: Icon(icon, color: _primaryBlue, size: 20), 
    filled: true, 
    fillColor: Colors.grey[50],
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
    contentPadding: const EdgeInsets.symmetric(vertical: 16),
  );

  Widget _buildTextField(TextEditingController ctrl, IconData icon, String label, {TextInputType? type}) => Padding(
    padding: const EdgeInsets.only(bottom: 15),
    child: TextFormField(
      controller: ctrl, 
      keyboardType: type, 
      decoration: _inputStyle(label, icon), 
      validator: (v) => v!.isEmpty ? "Wajib diisi" : null,
    ),
  );

  Widget _buildPasswordField() => TextFormField(
    controller: _passwordController, 
    obscureText: !_isPasswordVisible,
    decoration: _inputStyle("Buat Kata Sandi", Icons.lock_outline).copyWith(
      suffixIcon: IconButton(
        icon: Icon(_isPasswordVisible ? Icons.visibility : Icons.visibility_off, size: 20),
        onPressed: () => setState(() => _isPasswordVisible = !_isPasswordVisible)),
    ),
    validator: (v) => v!.length < 6 ? "Minimal 6 karakter" : null,
  );

  Widget _buildRoleDropdown() => DropdownButtonFormField<String>(
    decoration: _inputStyle("Pilih Kategori", Icons.category_outlined), 
    value: _selectedRole,
    items: _roles.map((r) => DropdownMenuItem(value: r, child: Text(r))).toList(),
    onChanged: (v) => setState(() { _selectedRole = v; _selectedPartnerId = null; if (_selectedDist != null) _fetchPartners(_selectedDist!); }),
    validator: (v) => v == null ? "Pilih kategori" : null,
  );

  Widget _buildSearchDropdown({required String label, required IconData icon, required List<String> items, String? selectedItem, bool enabled = true, required Function(String?) onChanged}) {
    return DropdownSearch<String>(
      items: (filter, loadProps) => items, 
      enabled: enabled, 
      selectedItem: selectedItem,
      decoratorProps: DropDownDecoratorProps(decoration: _inputStyle(label, icon)),
      popupProps: const PopupProps.menu(showSearchBox: true),
      onChanged: onChanged, 
      validator: (v) => v == null ? "Wajib diisi" : null,
    );
  }

  Widget _buildLogoHeader() => Center(
    child: Image.asset(
      'assets/images/logo.png', 
      height: 110, 
      errorBuilder: (c, e, s) => Icon(Icons.fastfood, size: 80, color: _primaryBlue),
    ),
  );

  Widget _buildSectionHeader(String t) => Padding(
    padding: const EdgeInsets.only(bottom: 10, top: 5), 
    child: Text(t.toUpperCase(), style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: _primaryBlue.withAlpha(153))),
  );
  
  Widget _buildUploadBox(String l) => InkWell(
    onTap: () => _pickImage(ImageSource.camera), 
    child: Container(
      padding: const EdgeInsets.all(16), 
      decoration: BoxDecoration(
        color: Colors.grey[50], 
        borderRadius: BorderRadius.circular(15), 
        border: Border.all(color: _imageFile != null ? Colors.green : Colors.grey[300]!)
      ), 
      child: Row(
        children: [
          Icon(_imageFile != null ? Icons.check_circle : Icons.cloud_upload, color: _imageFile != null ? Colors.green : _primaryBlue), 
          const SizedBox(width: 15), 
          Expanded(child: Text(l, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13))),
        ],
      ),
    ),
  );

  Widget _buildLocationPicker() => InkWell(
    onTap: () => setState(() { _lat = -7.7512; _lng = 110.5956; }), 
    child: Container(
      margin: const EdgeInsets.only(top: 15), 
      padding: const EdgeInsets.all(16), 
      decoration: BoxDecoration(
        color: _lat != null ? Colors.blue[50] : Colors.grey[50], 
        borderRadius: BorderRadius.circular(15)
      ), 
      child: Row(
        children: [
          const Icon(Icons.my_location, color: Colors.red), 
          const SizedBox(width: 15), 
          Text(_lat == null ? "Pin Point Lokasi" : "Lokasi: $_lat, $_lng"),
        ],
      ),
    ),
  );

  Widget _buildPartnerAlert() => Container(
    margin: const EdgeInsets.only(top: 12), 
    padding: const EdgeInsets.all(12), 
    decoration: BoxDecoration(
      color: Colors.blue[50], 
      borderRadius: BorderRadius.circular(12), 
      border: Border.all(color: Colors.blue[200]!)
    ), 
    child: Text("Dapur MBG belum tersedia di wilayah $_selectedDist.", style: TextStyle(color: Colors.blue[800], fontSize: 12)),
  );

  Future<void> _pickImage(ImageSource source) async {
    final XFile? pickedFile = await _picker.pickImage(source: source, imageQuality: 50);
    if (pickedFile != null) setState(() => _imageFile = pickedFile); 
  }
}

// --- MODEL HELPER ---
class RegionManager {
  final Map<String, dynamic> data;
  RegionManager(this.data);

  List<String> getProvinces() => data.keys.toList();
  List<String> getCities(String prov) => (data[prov] as Map<String, dynamic>).keys.toList();
  List<String> getDistricts(String prov, String city) => List<String>.from(data[prov][city]);
}