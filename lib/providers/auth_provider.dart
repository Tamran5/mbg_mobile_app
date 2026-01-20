import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import '../services/api_service.dart';
import 'dart:async';

class AuthProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();
  final _storage = const FlutterSecureStorage(
    webOptions: WebOptions(dbName: 'MBege_App_V2', publicKey: 'mbg_auth_key'),
  );

  // --- State Navigasi & UI ---
  int _currentTabIndex = 0;
  bool _showLogin = false;

  // --- State Autentikasi ---
  bool _isLoggedIn = false;
  bool _isLoading = false;
  bool _isApproved = false;

  // --- State Data User ---
  String? _userRole;
  String? _userName;
  String? _userEmail;
  String? _userPhone;
  String? _registrationToken;
  String? _schoolName;
  String? _userNpsn;
  String? _userNisn;
  String? _userNik;
  String? _userClass;

  // --- State List & Polling ---
  Timer? _statsTimer;
  String _pendingCount = "0";
  List _articles = [];
  bool _hasConfirmedToday = false;
  List<Map<String, dynamic>> _pendingStudentsList = [];

  // --- Getters ---
  int get currentTabIndex => _currentTabIndex;
  bool get showLogin => _showLogin;
  bool get isLoggedIn => _isLoggedIn;
  bool get isLoading => _isLoading;
  bool get isApproved => _isApproved;
  String? get userRole => _userRole;
  String? get userName => _userName;
  String? get userPhone => _userPhone;
  String? get userNpsn => _userNpsn;
  String? get userNisn => _userNisn;
  String? get userNik => _userNik;
  String? get userClass => _userClass;
  String? get userEmail => _userEmail;
  String? get schoolName => _schoolName;
  String? get registrationToken => _registrationToken;
  String get pendingCount => _pendingCount;
  List get articles => _articles;
  bool get hasConfirmedToday => _hasConfirmedToday;
  List<Map<String, dynamic>> get pendingStudentsList => _pendingStudentsList;

  // --- HELPER METHODS ---
  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void toggleLoginView(bool show) {
    _showLogin = show;
    notifyListeners();
  }

  Future<String?> getAuthToken() async {
    return await _storage.read(key: 'auth_token');
  }

  void setTabIndex(int index) {
    _currentTabIndex = index;
    notifyListeners();
  }

  // --- POLLING LOGIC ---
  void startStatsPolling() {
    _statsTimer?.cancel();
    _statsTimer = Timer.periodic(const Duration(seconds: 20), (timer) {
      fetchSchoolStats();
      fetchArticles();
    });
  }

  void stopStatsPolling() {
    _statsTimer?.cancel();
  }

  // --- 1. AUTHENTICATION (Login & Status) ---

  Future<void> checkLoginStatus() async {
    _setLoading(true);
    String? token = await getAuthToken();

    if (token != null && token.isNotEmpty && token != "null") {
      // Load data lokal instan
      _userName = await _storage.read(key: 'user_name');
      _schoolName = await _storage.read(key: 'school_name');
      _userRole = await _storage.read(key: 'user_role');
      _isLoggedIn = true;
      notifyListeners();

      final res = await _apiService.get("check-status", token);
      if (res['status'] == 'success') {
        final userData = res['data'];
        _userName = userData['name'] ?? _userName;
        _isApproved = res['is_approved'] == true;

        if (userData['school_name'] != null) {
          _schoolName = userData['school_name'];
          await _storage.write(key: 'school_name', value: _schoolName);
        }
        startStatsPolling();
      } else {
        await logout();
      }
    }
    _setLoading(false);
  }

  Future<Map<String, dynamic>> login(String phone, String password) async {
    _setLoading(true);

    try {
      // Gunakan trim() untuk menghindari spasi tak sengaja
      final result = await _apiService.login(phone.trim(), password);

      if (result['status'] == 'success') {
        final userData = result['data'];
        final token = result['token'];

        // 1. Simpan SEMUA data ke Storage agar sinkron saat refresh
        await _storage.write(key: 'auth_token', value: token);
        await _storage.write(key: 'user_role', value: userData['role']);
        await _storage.write(key: 'user_name', value: userData['name']);
        await _storage.write(
          key: 'school_name',
          value: userData['school_name'],
        );
        await _storage.write(
          key: 'is_approved',
          value: userData['is_approved'].toString(),
        );
        await _storage.write(
          key: 'registration_token',
          value: userData['registration_token'],
        );

        // 2. Update variabel memori
        _userRole = userData['role'];
        _userName = userData['name'];
        _schoolName = userData['school_name'];
        _isApproved = userData['is_approved'] ?? false;
        _registrationToken = userData['registration_token'];
        _isLoggedIn = true;

        startStatsPolling();

        _isLoading = false;
        notifyListeners();

        return result;
      } else {
        _setLoading(false);
        return result;
      }
    } catch (e) {
      _setLoading(false);
      return {"status": "error", "message": "Terjadi kesalahan sistem."};
    }
  }

  Future<void> logout() async {
    stopStatsPolling();

    await _storage.deleteAll();

    _isLoggedIn = false;
    _isApproved = false;
    _userRole = null;
    _userName = null;
    _userEmail = null;
    _userPhone = null;
    _schoolName = null;
    _registrationToken = null;
    _currentTabIndex = 0;

    notifyListeners();
  }

  // --- 2. DATA FETCHING (Stats & Articles) ---

  Future<void> fetchArticles() async {
    final token = await getAuthToken();
    final res = await _apiService.get("articles", token);
    if (res['status'] == 'success') {
      _articles = res['data'];
      notifyListeners();
    }
  }

  Future<Map<String, dynamic>> fetchSchoolStats() async {
    final token = await getAuthToken();

    // 1. Ambil data statistik (untuk status konfirmasi & token)
    final res = await _apiService.fetchSchoolStats(token);

    // 2. Ambil data list siswa terbaru (untuk sinkronisasi badge)
    final listRes = await _apiService.get("school/pending-students", token);

    if (res['status'] == 'success' && listRes['status'] == 'success') {
      // Simpan daftar siswa ke state
      _pendingStudentsList = List<Map<String, dynamic>>.from(listRes['data']);

      _pendingCount = _pendingStudentsList.length.toString();

      _hasConfirmedToday = res['data']['has_confirmed_today'] ?? false;
      _registrationToken = res['data']['school_token'];

      notifyListeners();
    }
    return res;
  }

  // --- 3. STUDENT MANAGEMENT ---

  Future<void> fetchPendingStudents() async {
    final token = await getAuthToken();
    final res = await _apiService.get("school/pending-students", token);
    if (res['status'] == 'success') {
      _pendingStudentsList = List<Map<String, dynamic>>.from(res['data']);
      notifyListeners();
    }
  }

  Future<Map<String, dynamic>> verifyStudent(
    int studentId,
    String action,
  ) async {
    final token = await getAuthToken();
    return await _apiService.post("school/verify-student", {
      'student_id': studentId,
      'action': action,
    }, token);
  }

  // --- 4. REVIEW & FEEDBACK (BERT AI) ---

  Future<Map<String, dynamic>> submitReview({
    required int rating,
    required List<String> tags,
    required String komentar,
  }) async {
    _setLoading(true);
    final token = await getAuthToken();
    final res = await _apiService.submitReview(rating, tags, komentar, token);
    _setLoading(false);
    return res;
  }

  // --- 5. PROFILE & SECURITY ---

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
    _setLoading(true);
    final token = await getAuthToken();
    final res = await _apiService.post("update-profile", {
      'name': name,
      'email': email,
      'phone': phone,
      if (npsn != null) 'npsn': npsn,
      if (schoolName != null) 'school_name': schoolName,
      if (nisn != null) 'nisn': nisn,
      if (nik != null) 'nik': nik,
      if (studentClass != null) 'class': studentClass,
    }, token);

    if (res['status'] == 'success') {
      _userName = name;
      await _storage.write(key: 'user_name', value: name);
      notifyListeners();
      _setLoading(false);
      return true;
    }
    _setLoading(false);
    return false;
  }

  Future<Map<String, dynamic>> changePassword(
    String oldPass,
    String newPass,
  ) async {
    _setLoading(true);
    final token = await getAuthToken();
    final res = await _apiService.post("change-password", {
      'old_password': oldPass,
      'new_password': newPass,
    }, token);
    _setLoading(false);
    return res;
  }

  // --- 1. EMAIL MANAGEMENT ---

  Future<Map<String, dynamic>> requestChangeEmail(
    String newEmail,
    String password,
  ) async {
    _setLoading(true);
    final token = await getAuthToken();
    final res = await _apiService.post("request-change-email", {
      'new_email': newEmail,
      'password': password,
    }, token);
    _setLoading(false);
    return res;
  }

  Future<Map<String, dynamic>> verifyChangeEmail(
    String newEmail,
    String otp,
  ) async {
    _setLoading(true);
    final token = await getAuthToken();
    final res = await _apiService.post("verify-change-email", {
      'new_email': newEmail,
      'otp': otp,
    }, token);

    if (res['status'] == 'success') {
      _userEmail = newEmail;
      await _storage.write(key: 'user_email', value: newEmail);
      notifyListeners();
    }
    _setLoading(false);
    return res;
  }

  // --- 2. STATUS & TOKEN MANAGEMENT ---

  Future<bool> refreshApprovalStatus() async {
    _setLoading(true);
    final token = await getAuthToken();
    final res = await _apiService.get("check-status", token);

    if (res['status'] == 'success') {
      _isApproved = res['is_approved'];
      await _storage.write(key: 'is_approved', value: _isApproved.toString());
      notifyListeners();
    }
    _setLoading(false);
    return _isApproved;
  }

  Future<bool> regenerateSchoolToken() async {
    _setLoading(true);
    final token = await getAuthToken();
    if (token == null) {
      _setLoading(false);
      return false;
    }

    final res = await _apiService.post("school/regenerate-token", {}, token);

    if (res['status'] == 'success') {
      _registrationToken = res['new_token'];
      await _storage.write(
        key: 'registration_token',
        value: _registrationToken,
      );
      notifyListeners();
      _setLoading(false);
      return true;
    }
    _setLoading(false);
    return false;
  }

  // --- 3. SCHOOL OPERATIONS (STUDENTS & PHOTOS) ---

  Future<List<Map<String, dynamic>>> fetchApprovedStudents() async {
    final token = await getAuthToken();
    final res = await _apiService.get("school/students", token);

    if (res['status'] == 'success') {
      return List<Map<String, dynamic>>.from(res['data']).map((s) {
        s['selected'] = false;
        return s;
      }).toList();
    }
    return [];
  }

  Future<bool> bulkActionStudents(List<int> ids, String action) async {
    final token = await getAuthToken();
    final res = await _apiService.post("school/bulk-action", {
      'student_ids': ids,
      'action': action,
    }, token);
    return res['status'] == 'success';
  }

  Future<bool> uploadArrivalPhoto(Uint8List imageBytes, String fileName) async {
    _setLoading(true);
    final token = await getAuthToken();
    final success = await _apiService.uploadArrivalPhoto(
      imageBytes,
      fileName,
      token,
    );

    if (success) {
      _hasConfirmedToday = true;
      notifyListeners();
    }
    _setLoading(false);
    return success;
  }

  // --- 6. REGISTRATION WITH FILE ---

  Future<Map<String, dynamic>> registerWithFile(
    Map<String, String> fields,
    XFile? file,
    String key,
  ) async {
    _setLoading(true);
    final res = await _apiService.registerWithFile(fields, file, key);
    _setLoading(false);
    return res;
  }
}
