import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/mbg_scaffold.dart';
import 'request_email_change_page.dart';

class EditProfilPage extends StatefulWidget {
  const EditProfilPage({super.key});

  @override
  State<EditProfilPage> createState() => _EditProfilPageState();
}

class _EditProfilPageState extends State<EditProfilPage> {
  final Color _primaryBlue = const Color(0xFF1A237E);
  final _formKey = GlobalKey<FormState>();

  // Controller Universal
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;

  // Controller Spesifik Role
  late TextEditingController _npsnController;
  late TextEditingController _schoolController;
  late TextEditingController _nisnController;
  late TextEditingController _nikController;
  late TextEditingController _classController;

  @override
  void initState() {
    super.initState();
    final auth = Provider.of<AuthProvider>(context, listen: false);

    // Inisialisasi Data Dasar
    _nameController = TextEditingController(text: auth.userName);
    _emailController = TextEditingController(text: auth.userEmail);
    _phoneController = TextEditingController(text: auth.userPhone);

    // Inisialisasi Data Spesifik Role
    _npsnController = TextEditingController(text: auth.userNpsn);
    _schoolController = TextEditingController(text: auth.schoolName);
    _nisnController = TextEditingController(text: auth.userNisn);
    _nikController = TextEditingController(text: auth.userNik);
    _classController = TextEditingController(text: auth.userClass);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _npsnController.dispose();
    _schoolController.dispose();
    _nisnController.dispose();
    _nikController.dispose();
    _classController.dispose();
    super.dispose();
  }

  void _saveChanges(AuthProvider auth) {
    if (!_formKey.currentState!.validate()) return;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text(
            "Konfirmasi",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: const Text("Simpan perubahan profil Anda?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Batal", style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                _executeUpdate(auth);
              },
              style: ElevatedButton.styleFrom(backgroundColor: _primaryBlue),
              child: const Text(
                "Ya, Simpan",
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }

  void _executeUpdate(AuthProvider auth) async {
    // Kirim data secara dinamis berdasarkan role
    bool success = await auth.updateProfile(
      name: _nameController.text,
      email: _emailController.text,
      phone: _phoneController.text,
      npsn: auth.userRole == 'pengelola_sekolah' ? _npsnController.text : null,
      schoolName: auth.userRole == 'pengelola_sekolah'
          ? _schoolController.text
          : null,
      nisn: auth.userRole == 'siswa' ? _nisnController.text : null,
      studentClass: auth.userRole == 'siswa' ? _classController.text : null,
      nik: auth.userRole == 'penerima_lansia' ? _nikController.text : null,
    );

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            success
                ? "Profil berhasil diperbarui!"
                : "Gagal memperbarui profil",
          ),
          backgroundColor: success ? Colors.green : Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
      if (success) Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    return MbgScaffold(
      body: Column(
        children: [
          _buildHeader(context),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    const SizedBox(height: 20),
                    _buildProfilePicture(),
                    const SizedBox(height: 30),

                    // Field Dasar
                    _buildInputField(
                      "Nama Lengkap",
                      _nameController,
                      Icons.person_outline,
                    ),

                    // Email dibuat Read-Only (Disarankan melalui menu Ganti Email khusus)
                    // Di dalam Column di build method
                    _buildInputField(
                      "Alamat Email",
                      _emailController,
                      Icons.email_outlined,
                      isReadOnly: true,
                    ),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  const RequestEmailChangePage(),
                            ),
                          );
                        },
                        child: const Text(
                          "Ganti Email melalui Verifikasi OTP",
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),

                    _buildInputField(
                      "Nomor Telepon",
                      _phoneController,
                      Icons.phone_android_outlined,
                      isPhone: true,
                    ),

                    // Field Dinamis Berdasarkan Role
                    if (auth.userRole == 'pengelola_sekolah') ...[
                      _buildInputField(
                        "NPSN Sekolah",
                        _npsnController,
                        Icons.pin_outlined,
                      ),
                      _buildInputField(
                        "Nama Sekolah",
                        _schoolController,
                        Icons.school_outlined,
                      ),
                    ],

                    if (auth.userRole == 'siswa') ...[
                      _buildInputField(
                        "NISN Siswa",
                        _nisnController,
                        Icons.badge_outlined,
                      ),
                      _buildInputField(
                        "Kelas",
                        _classController,
                        Icons.class_outlined,
                      ),
                    ],

                    if (auth.userRole == 'penerima_lansia') ...[
                      _buildInputField(
                        "NIK Lansia",
                        _nikController,
                        Icons.credit_card_outlined,
                      ),
                    ],

                    const SizedBox(height: 30),
                    _buildSaveButton(auth),
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

  // --- WIDGET COMPONENTS ---

  Widget _buildInputField(
    String label,
    TextEditingController controller,
    IconData icon, {
    bool isReadOnly = false,
    bool isPhone = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: controller,
            readOnly: isReadOnly,
            keyboardType: isPhone ? TextInputType.phone : TextInputType.text,
            validator: (val) =>
                val == null || val.isEmpty ? "Bidang ini wajib diisi" : null,
            decoration: InputDecoration(
              prefixIcon: Icon(icon, color: _primaryBlue.withOpacity(0.5)),
              filled: true,
              fillColor: isReadOnly ? Colors.grey[200] : Colors.grey[50],
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: BorderSide(color: Colors.grey.withAlpha(26)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // (Widget _buildHeader, _buildProfilePicture, dan _buildSaveButton tetap sama seperti sebelumnya)
  // ... (Gunakan widget lama Anda di sini) ...
  Widget _buildSaveButton(AuthProvider auth) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: auth.isLoading ? null : () => _saveChanges(auth),
        style: ElevatedButton.styleFrom(
          backgroundColor: _primaryBlue,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
        ),
        child: auth.isLoading
            ? const CircularProgressIndicator(color: Colors.white)
            : const Text(
                "SIMPAN PERUBAHAN",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(10, 10, 10, 0),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded),
            onPressed: () => Navigator.pop(context),
          ),
          const Expanded(
            child: Text(
              "Edit Profil",
              style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(width: 48),
        ],
      ),
    );
  }

  Widget _buildProfilePicture() {
    return Center(
      child: Stack(
        alignment: Alignment.bottomRight,
        children: [
          const CircleAvatar(
            radius: 60,
            backgroundColor: Color(0xFFF1F2F6),
            backgroundImage: NetworkImage(
              "https://www.w3schools.com/howto/img_avatar.png",
            ),
          ),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: _primaryBlue,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 2),
            ),
            child: const Icon(
              Icons.camera_alt_rounded,
              color: Colors.white,
              size: 20,
            ),
          ),
        ],
      ),
    );
  }
}
