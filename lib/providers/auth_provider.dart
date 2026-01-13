import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:http_parser/http_parser.dart';
import 'package:flutter/foundation.dart';
import '../services/api_service.dart';

class AuthProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();
  final _storage = const FlutterSecureStorage();

  // --- State Navigasi & UI ---
  int _currentTabIndex = 0;
  bool _showLogin = false;

  // --- State Autentikasi ---
  bool _isLoggedIn = false;
  bool _isLoading = false;
  bool _isApproved = false;

  // --- State Data User (Universal) ---
  String? _userRole;
  String? _userName;
  String? _userEmail;
  String? _userPhone;
  String? _registrationToken;

  // --- State Spesifik Role ---
  String? _userNpsn; // Sekolah
  String? _schoolName; // Sekolah / Siswa
  String? _userNisn; // Siswa
  String? _userNik; // Lansia
  String? _userClass; // Siswa

  // --- Getters ---
  int get currentTabIndex => _currentTabIndex;
  bool get showLogin => _showLogin;
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
  String? get registrationToken => _registrationToken;

  // Helper Ambil Token
  Future<String?> getAuthToken() async {
    return await _storage.read(key: 'auth_token');
  }

  // --- 0. MANAJEMEN UI ---
  void setTabIndex(int index) {
    _currentTabIndex = index;
    notifyListeners();
  }

  void toggleLoginView(bool show) {
    _showLogin = show;
    notifyListeners();
  }

  // --- 1. CEK LOGIN OTOMATIS ---
  Future<void> checkLoginStatus() async {
    _isLoading = true;
    notifyListeners();

    String? token = await getAuthToken();

    if (token != null) {
      try {
        final response = await http
            .get(
              Uri.parse('${ApiService.baseUrl}/check-status'),
              headers: {'Authorization': 'Bearer $token'},
            )
            .timeout(const Duration(seconds: 10));

        if (response.statusCode == 200) {
          _userRole = await _storage.read(key: 'user_role');
          _userName = await _storage.read(key: 'user_name');
          _userEmail = await _storage.read(key: 'user_email');
          _userPhone = await _storage.read(key: 'user_phone');
          _userNpsn = await _storage.read(key: 'user_npsn');
          _schoolName = await _storage.read(key: 'school_name');
          _userNisn = await _storage.read(key: 'user_nisn');
          _userNik = await _storage.read(key: 'user_nik');
          _userClass = await _storage.read(key: 'user_class');
          _registrationToken = await _storage.read(key: 'registration_token');

          String? approved = await _storage.read(key: 'is_approved');
          _isApproved = approved == 'true';
          _isLoggedIn = true;
        } else {
          await logout();
        }
      } catch (e) {
        _isLoggedIn = false;
      }
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
      _registrationToken = userData['registration_token'];
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
      await _storage.write(
        key: 'registration_token',
        value: _registrationToken,
      );
      await _storage.write(key: 'is_approved', value: _isApproved.toString());
    }

    _isLoading = false;
    notifyListeners();
    return result;
  }

  // --- 3. UPDATE PROFIL ---
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
      String? token = await getAuthToken();
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

  // --- 4. KEAMANAN (Password & Email) ---
  Future<Map<String, dynamic>> changePassword(
    String oldPassword,
    String newPassword,
  ) async {
    _isLoading = true;
    notifyListeners();
    try {
      String? token = await getAuthToken();
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
      _isLoading = false;
      notifyListeners();
      return json.decode(response.body);
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      return {"status": "error", "message": e.toString()};
    }
  }

  Future<Map<String, dynamic>> requestChangeEmail(
    String newEmail,
    String password,
  ) async {
    _isLoading = true;
    notifyListeners();
    try {
      String? token = await getAuthToken();
      final response = await http.post(
        Uri.parse('${ApiService.baseUrl}/request-change-email'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({'new_email': newEmail, 'password': password}),
      );
      _isLoading = false;
      notifyListeners();
      return json.decode(response.body);
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      return {"status": "error", "message": e.toString()};
    }
  }

  Future<Map<String, dynamic>> verifyChangeEmail(
    String newEmail,
    String otp,
  ) async {
    _isLoading = true;
    notifyListeners();
    try {
      String? token = await getAuthToken();
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
        _userEmail = newEmail;
        await _storage.write(key: 'user_email', value: newEmail);
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

  // --- 5. LOGOUT (Reset Total) ---
  Future<void> logout() async {
    await _storage.deleteAll();
    _isLoggedIn = false;
    _isApproved = false;
    _userRole = null;
    _userName = null;
    _userEmail = null;
    _userPhone = null;
    _registrationToken = null;
    _userNpsn = null;
    _schoolName = null;
    _userNisn = null;
    _userNik = null;
    _userClass = null;
    _currentTabIndex = 0;
    notifyListeners();
  }

  // --- 6. FITUR TAMBAHAN (Stats, Token, Verifikasi) ---
  Future<bool> refreshApprovalStatus() async {
    _isLoading = true;
    notifyListeners();
    try {
      String? token = await getAuthToken();
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

  Future<Map<String, dynamic>> fetchSchoolStats() async {
    _isLoading = true;
    notifyListeners();
    try {
      String? token = await getAuthToken();
      final response = await http.get(
        Uri.parse('${ApiService.baseUrl}/school/stats'),
        headers: {'Authorization': 'Bearer $token'},
      );
      final result = json.decode(response.body);
      if (result['status'] == 'success') {
        _userNpsn = result['data']['npsn']?.toString();
        _schoolName = result['data']['school_name'];
        _registrationToken = result['data']['registration_token'];
        await _storage.write(
          key: 'registration_token',
          value: _registrationToken,
        );
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

  Future<bool> regenerateSchoolToken() async {
    _isLoading = true;
    notifyListeners();
    try {
      String? token = await getAuthToken();
      final response = await http.post(
        Uri.parse('${ApiService.baseUrl}/school/regenerate-token'),
        headers: {'Authorization': 'Bearer $token'},
      );
      final result = json.decode(response.body);
      if (response.statusCode == 200 && result['status'] == 'success') {
        _registrationToken = result['new_token'];
        await _storage.write(
          key: 'registration_token',
          value: _registrationToken,
        );
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

  Future<Map<String, dynamic>> registerWithFile(
    Map<String, String> f,
    XFile? file,
    String key,
  ) async {
    _isLoading = true;
    notifyListeners();
    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('${ApiService.baseUrl}/register'),
      );
      request.fields.addAll(f);
      if (file != null) {
        request.files.add(
          await http.MultipartFile.fromPath(
            key,
            file.path,
            contentType: MediaType('image', 'jpeg'),
          ),
        );
      }
      var res = await http.Response.fromStream(await request.send());
      _isLoading = false;
      notifyListeners();
      return json.decode(res.body);
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      return {"status": "error", "message": e.toString()};
    }
  }
}
