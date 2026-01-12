import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:http_parser/http_parser.dart';
import '../services/api_service.dart';
import 'package:flutter/foundation.dart';

class AuthProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();
  final _storage = const FlutterSecureStorage();

  // --- State Navigasi ---
  int _currentTabIndex = 0;

  // --- State Autentikasi ---
  bool _isLoggedIn = false;
  bool _isLoading = false;
  bool _isApproved = false;

  // --- State Data User (Universal) ---
  String? _userRole;
  String? _userName;
  String? _userEmail;
  String? _userPhone;

  // --- State Spesifik Role ---
  String? _userNpsn; // Sekolah
  String? _schoolName; // Sekolah / Siswa
  String? _userNisn; // Siswa
  String? _userNik; // Lansia
  String? _userClass; // Siswa

  // --- Getters ---
  int get currentTabIndex => _currentTabIndex;
  bool get isLoggedIn => _isLoggedIn;
  bool get isLoading => _isLoading;
  bool get isApproved => _isApproved;

  String? get userRole => _userRole;
  String? get userName => _userName;
  String? get userEmail => _userEmail;
  String? get userPhone => _userPhone;
  String? get userNpsn => _userNpsn;
  String? get schoolName => _schoolName;
  String? get userNisn => _userNisn;
  String? get userNik => _userNik;
  String? get userClass => _userClass;

  // --- Helper: Ambil Token ---
  Future<String?> get _token async => await _storage.read(key: 'auth_token');

  // --- 0. MANAJEMEN NAVIGASI ---
  void setTabIndex(int index) {
    _currentTabIndex = index;
    notifyListeners();
  }

  // --- 1. CEK LOGIN OTOMATIS ---
  Future<void> checkLoginStatus() async {
    _isLoading = true;
    notifyListeners();

    String? token = await _storage.read(key: 'auth_token');
    _userRole = await _storage.read(key: 'user_role');

    // --- GLOBAL GATEKEEPER ---
    if (kIsWeb && token != null && !kDebugMode) {
      List<String> mobileRoles = ['pengelola_sekolah', 'siswa', 'lansia'];

      if (mobileRoles.contains(_userRole)) {
        await _storage.deleteAll();
        _isLoggedIn = false;
        _isLoading = false;
        notifyListeners();
        return;
      }
    }

    if (token != null) {
      try {
        // 2. Validasi Token ke Server Flask (Endpoint: /check-status)
        final response = await http.get(
          Uri.parse('${ApiService.baseUrl}/check-status'),
          headers: {'Authorization': 'Bearer $token'},
        );

        if (response.statusCode == 200) {
          // 3. Jika Valid, muat semua data profil ke state
          _userName = await _storage.read(key: 'user_name');
          _userEmail = await _storage.read(key: 'user_email');
          _userPhone = await _storage.read(key: 'user_phone');
          _userNpsn = await _storage.read(key: 'user_npsn');
          _schoolName = await _storage.read(key: 'school_name');
          _userNisn = await _storage.read(key: 'user_nisn');
          _userNik = await _storage.read(key: 'user_nik');
          _userClass = await _storage.read(key: 'user_class');

          String? approved = await _storage.read(key: 'is_approved');
          _isApproved = approved == 'true';
          _isLoggedIn = true;
        } else {
          // Jika token expired atau unauthorized di Flask, hapus sesi
          await logout();
        }
      } catch (e) {
        // Jika error jaringan, tetap izinkan masuk (offline mode sementara)
        // atau set _isLoggedIn = false untuk keamanan tinggi
        _isLoggedIn = false;
      }
    } else {
      _isLoggedIn = false;
    }

    _isLoading = false;
    notifyListeners();
  }

  // --- 2. LOGIN ---
  Future<Map<String, dynamic>> login(String phone, String password) async {
    _isLoading = true;
    notifyListeners();

    final result = await _apiService.login(phone, password);

    if (result['status'] == 'success') {
      final userData = result['data'];

      _isLoggedIn = true;
      _userRole = userData['role'];
      _userName = userData['name'];
      _userEmail = userData['email'];
      _userPhone = userData['phone']?.toString();
      _userNpsn = userData['npsn']?.toString(); 
      _schoolName = userData['school_name'];
      _userNisn = userData['nisn']?.toString();
      _userNik = userData['nik']?.toString();
      _userClass = userData['class']?.toString();
      _isApproved = userData['is_approved'] ?? false;

      await _storage.write(key: 'auth_token', value: result['token']);
      await _storage.write(key: 'user_role', value: _userRole);
      await _storage.write(key: 'user_name', value: _userName);
      await _storage.write(key: 'user_email', value: _userEmail);
      await _storage.write(key: 'user_phone', value: _userPhone);
      await _storage.write(key: 'user_npsn', value: _userNpsn);
      await _storage.write(key: 'school_name', value: _schoolName);
      await _storage.write(key: 'user_nisn', value: _userNisn);
      await _storage.write(key: 'user_nik', value: _userNik);
      await _storage.write(key: 'user_class', value: _userClass);
      await _storage.write(key: 'is_approved', value: _isApproved.toString());
    }

    _isLoading = false;
    notifyListeners();
    return result;
  }

  // --- 3. REGISTRASI DENGAN BERKAS ---
  Future<Map<String, dynamic>> registerWithFile(
    Map<String, String> fields,
    XFile? file,
    String fileField,
  ) async {
    _isLoading = true;
    notifyListeners();

    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('${ApiService.baseUrl}/register'),
      );

      request.fields.addAll(fields);

      if (file != null) {
        final List<int> bytes = await file.readAsBytes();
        request.files.add(
          http.MultipartFile.fromBytes(
            fileField,
            bytes,
            filename: file.name,
            contentType: MediaType('image', 'jpeg'),
          ),
        );
      }

      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);
      final result = json.decode(response.body);

      _isLoading = false;
      notifyListeners();
      return result;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      return {"status": "error", "message": "Gagal menghubungi server: $e"};
    }
  }

  // --- 4. UPDATE PROFIL (Kondisional) ---
  Future<bool> updateProfile({
    required String name,
    required String email,
    required String phone,
    String? npsn,
    String? schoolName,
    String? nisn,
    String? nik,
    String? studentClass,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      String? token = await _token;

      final response = await http.post(
        Uri.parse('${ApiService.baseUrl}/update-profile'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({
          'name': name,
          'email': email,
          'phone': phone,
          if (npsn != null) 'npsn': npsn,
          if (schoolName != null) 'school_name': schoolName,
          if (nisn != null) 'nisn': nisn,
          if (nik != null) 'nik': nik,
          if (studentClass != null) 'class': studentClass,
        }),
      );

      final result = json.decode(response.body);

      if (response.statusCode == 200 && result['status'] == 'success') {
        _userName = name;
        _userEmail = email;
        _userPhone = phone;
        if (npsn != null) _userNpsn = npsn;
        if (schoolName != null) _schoolName = schoolName;
        if (nisn != null) _userNisn = nisn;
        if (nik != null) _userNik = nik;
        if (studentClass != null) _userClass = studentClass;

        await _storage.write(key: 'user_name', value: name);
        await _storage.write(key: 'user_email', value: email);
        await _storage.write(key: 'user_phone', value: phone);
        if (npsn != null) await _storage.write(key: 'user_npsn', value: npsn);
        if (schoolName != null)
          await _storage.write(key: 'school_name', value: schoolName);
        if (nisn != null) await _storage.write(key: 'user_nisn', value: nisn);
        if (nik != null) await _storage.write(key: 'user_nik', value: nik);
        if (studentClass != null)
          await _storage.write(key: 'user_class', value: studentClass);

        _isLoading = false;
        notifyListeners();
        return true;
      }
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // --- 5. UBAH PASSWORD (INTEGRASI BARU) ---
  Future<Map<String, dynamic>> changePassword(
    String oldPassword,
    String newPassword,
  ) async {
    _isLoading = true;
    notifyListeners();

    try {
      String? token = await _token;
      final response = await http.post(
        Uri.parse('${ApiService.baseUrl}/change-password'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({
          'old_password': oldPassword,
          'new_password': newPassword,
        }),
      );

      final result = json.decode(response.body);
      _isLoading = false;
      notifyListeners();
      return result;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      return {"status": "error", "message": "Gagal terhubung ke server: $e"};
    }
  }

  // --- 6. LOGOUT ---
  Future<void> logout() async {
    await _storage.deleteAll();
    _isLoggedIn = false;
    _isApproved = false;
    _currentTabIndex = 0;
    notifyListeners();
  }

  // --- 7. REFRESH STATUS VERIFIKASI ---
  Future<bool> refreshApprovalStatus() async {
    _isLoading = true;
    notifyListeners();
    try {
      String? token = await _token;
      final response = await http.get(
        Uri.parse('${ApiService.baseUrl}/check-status'),
        headers: {'Authorization': 'Bearer $token'},
      );

      final result = json.decode(response.body);
      if (result['status'] == 'success') {
        _isApproved = result['is_approved'];
        await _storage.write(key: 'is_approved', value: _isApproved.toString());
      }

      _isLoading = false;
      notifyListeners();
      return _isApproved;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Di dalam class AuthProvider
  bool _showLogin = false;
  bool get showLogin => _showLogin;

  void toggleLoginView(bool show) {
    _showLogin = show;
    notifyListeners();
  }

  // --- 8. REQUEST GANTI EMAIL (Kirim OTP) ---
  Future<Map<String, dynamic>> requestChangeEmail(
    String newEmail,
    String password,
  ) async {
    _isLoading = true;
    notifyListeners();

    try {
      String? token = await _token;
      final response = await http.post(
        Uri.parse('${ApiService.baseUrl}/request-change-email'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({'new_email': newEmail, 'password': password}),
      );

      final result = json.decode(response.body);
      _isLoading = false;
      notifyListeners();
      return result;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      return {"status": "error", "message": "Gagal terhubung ke server: $e"};
    }
  }

  // --- 9. VERIFIKASI GANTI EMAIL (Submit OTP) ---
  Future<Map<String, dynamic>> verifyChangeEmail(
    String newEmail,
    String otp,
  ) async {
    _isLoading = true;
    notifyListeners();

    try {
      String? token = await _token;
      final response = await http.post(
        Uri.parse('${ApiService.baseUrl}/verify-change-email'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({'new_email': newEmail, 'otp': otp}),
      );

      final result = json.decode(response.body);

      if (response.statusCode == 200 && result['status'] == 'success') {
        // Update email di state lokal dan storage
        _userEmail = newEmail;
        await _storage.write(key: 'user_email', value: newEmail);
      }

      _isLoading = false;
      notifyListeners();
      return result;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      return {"status": "error", "message": "Verifikasi gagal: $e"};
    }
  }

  Future<Map<String, dynamic>> fetchSchoolStats() async {
    _isLoading = true;
    notifyListeners();

    try {
      String? token = await _storage.read(key: 'auth_token');
      final response = await http.get(
        Uri.parse('${ApiService.baseUrl}/school/stats'),
        headers: {'Authorization': 'Bearer $token'},
      );

      final result = json.decode(response.body);

      if (result['status'] == 'success') {
        _userNpsn = result['data']['npsn'].toString();
        _schoolName = result['data']['school_name'];

        // Simpan ke storage agar saat aplikasi dibuka kembali, token tetap ada
        await _storage.write(key: 'user_npsn', value: _userNpsn);
        await _storage.write(key: 'school_name', value: _schoolName);
      }

      _isLoading = false;
      notifyListeners();
      return result;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      return {"status": "error", "message": e.toString()};
    }
  }

  Future<String?> getToken() async {
    return await _storage.read(key: 'auth_token');
  }

  Future<Map<String, dynamic>> confirmArrival(XFile image) async {
    _isLoading = true;
    notifyListeners();
    try {
      String? token = await _token;
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('${ApiService.baseUrl}/confirm-arrival'),
      );

      request.headers['Authorization'] = 'Bearer $token';
      request.files.add(
        await http.MultipartFile.fromPath(
          'file', // Key 'file' harus cocok dengan request.files['file'] di Flask
          image.path,
          contentType: MediaType('image', 'jpeg'),
        ),
      );

      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);
      _isLoading = false;
      notifyListeners();
      return json.decode(response.body);
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      return {"status": "error", "message": "Gagal mengirim bukti: $e"};
    }
  }
}
