import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:http_parser/http_parser.dart';
import 'package:flutter/foundation.dart';
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

  Timer? _statsTimer;
  String _pendingCount = "0";
  String get pendingCount => _pendingCount;

  List _articles = [];
  List get articles => _articles;

  bool _hasConfirmedToday = false;
  bool get hasConfirmedToday => _hasConfirmedToday;

  // Mulai pengecekan otomatis saat login berhasil
  void startStatsPolling() {
    _statsTimer?.cancel(); // Hentikan timer lama jika ada
    _statsTimer = Timer.periodic(const Duration(seconds: 20), (timer) {
      fetchSchoolStats(); // Panggil fungsi fetch data secara berkala
      fetchArticles("");
    });
  }

  // Hentikan pengecekan saat logout
  void stopStatsPolling() {
    _statsTimer?.cancel();
  }

  List<Map<String, dynamic>> _pendingStudentsList = [];
  List<Map<String, dynamic>> get pendingStudentsList => _pendingStudentsList;

  Future<void> fetchArticles(String _) async {
    try {
      String? token = await getAuthToken();
      final response = await http.get(
        Uri.parse('${ApiService.baseUrl}/articles'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final result = json.decode(response.body);
        _articles = result['data']; // Data baru dari database
        notifyListeners(); // Memicu UI untuk update otomatis tanpa restart
      }
    } catch (e) {
      debugPrint("Update artikel gagal: $e");
    }
  }

  // Modifikasi fetchSchoolStats agar juga mengambil daftar siswa terbaru
  Future<Map<String, dynamic>> fetchSchoolStats() async {
    try {
      String? token = await getAuthToken();
      final statsRes = await http.get(
        Uri.parse('${ApiService.baseUrl}/school/stats'),
        headers: {'Authorization': 'Bearer $token'},
      );

      final listRes = await http.get(
        Uri.parse('${ApiService.baseUrl}/school/pending-students'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (statsRes.statusCode == 200 && listRes.statusCode == 200) {
        final statsData = json.decode(statsRes.body);
        final listData = json.decode(listRes.body);

        if (statsData['status'] == 'success') {
          _pendingCount = statsData['data']['perlu_verifikasi'].toString();
          _hasConfirmedToday =
              statsData['data']['has_confirmed_today'] ?? false;

          if (statsData['data'].containsKey('school_token')) {
            _registrationToken = statsData['data']['school_token'];
            // SIMPAN KE STORAGE agar tidak hilang saat restart
            await _storage.write(
              key: 'registration_token',
              value: _registrationToken,
            );
          }
        }

        if (listData['status'] == 'success') {
          _pendingStudentsList = List<Map<String, dynamic>>.from(
            listData['data'],
          );
        }

        notifyListeners();
        return statsData;
      }
      return {"status": "error"};
    } catch (e) {
      debugPrint("Error Fetch Stats: $e");
      return {"status": "error"};
    }
  }

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

  Future<void> checkLoginStatus() async {
    _isLoading = true;
    notifyListeners();

    String? token = await _storage.read(key: 'auth_token');
    debugPrint("DEBUG: Mengecek Token di Storage: $token");

    if (token != null && token.isNotEmpty && token != "null") {
      // Ambil data lokal dulu agar UI langsung tampil (Instan)
      _userName = await _storage.read(key: 'user_name');
      _schoolName = await _storage.read(key: 'school_name');
      _userRole = await _storage.read(key: 'user_role');
      _isLoggedIn = true;
      notifyListeners();

      try {
        final response = await http
            .get(
              Uri.parse('${ApiService.baseUrl}/check-status'),
              headers: {'Authorization': 'Bearer $token'},
            )
            .timeout(const Duration(seconds: 10));

        if (response.statusCode == 200) {
          final result = json.decode(response.body);
          final userData = result['data'];

          // Sinkronisasi data terbaru dari server
          _userName = userData['name'] ?? _userName;
          _isApproved = result['is_approved'] == true;

          // Cegah penimpaan data null
          if (userData['school_name'] != null) {
            _schoolName = userData['school_name'];
            await _storage.write(key: 'school_name', value: _schoolName);
          }

          startStatsPolling(); // Jalankan update otomatis
        } else {
          await logout();
        }
      } catch (e) {
        debugPrint("Offline Mode: Menggunakan data lokal.");
      }
    }

    _isLoading = false;
    notifyListeners();
  }

  // --- 2. LOGIN ---
  Future<Map<String, dynamic>> login(String phone, String password) async {
    _isLoading = true;
    notifyListeners();

    try {
      final result = await _apiService.login(phone, password);

      // DEBUG: Cek apakah token benar-benar sampai di sini
      debugPrint("DEBUG: Login Response: $result");

      if (result['status'] == 'success') {
        final userData = result['data'];
        final String? tokenValue = result['token'];

        if (tokenValue == null || tokenValue.isEmpty) {
          throw Exception("Token tidak ditemukan dalam respon server");
        }

        // 1. Update State Memori
        _isLoggedIn = true;
        _userRole = userData['role'];
        _userName = userData['name'];
        _userEmail = userData['email'];
        _schoolName =
            userData['school_name']; // Ini yang ditampilkan di Dashboard
        _isApproved = userData['is_approved'] ?? false;
        _registrationToken = userData['registration_token'];

        // 2. Simpan Permanen (Wajib AWAIT semua)
        // --- PERBAIKAN: Ganti Future.wait dengan urutan await satu per satu ---
        try {
          debugPrint("DEBUG: Memulai proses simpan data...");

          await _storage.write(key: 'auth_token', value: tokenValue);
          await _storage.write(key: 'user_role', value: _userRole);
          await _storage.write(key: 'user_name', value: _userName);
          await _storage.write(key: 'school_name', value: _schoolName);
          await _storage.write(
            key: 'registration_token',
            value: _registrationToken,
          );
          await _storage.write(
            key: 'is_approved',
            value: _isApproved.toString(),
          );

          debugPrint("DEBUG: Semua data berhasil disimpan ke Storage.");
        } catch (e) {
          // Menangkap OperationError agar aplikasi tidak crash
          debugPrint(
            "DEBUG: Gagal simpan ke storage (Kemungkinan IndexedDB penuh/terkunci): $e",
          );
        }

        // 3. Verifikasi Storage (Hanya untuk Debug)
        String? savedToken = await _storage.read(key: 'auth_token');
        debugPrint("DEBUG: Berhasil simpan token: ${savedToken != null}");

        notifyListeners(); // Update UI segera setelah data tersimpan
        startStatsPolling(); // Jalankan polling artikel
      }

      _isLoading = false;
      notifyListeners();
      return result;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      debugPrint("DEBUG: Error Login: $e");
      return {"status": "error", "message": e.toString()};
    }
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

  Future<bool> regenerateSchoolToken() async {
    _isLoading = true;
    notifyListeners();

    try {
      String? token = await getAuthToken();

      // Proteksi: Jika token login tidak ditemukan
      if (token == null) {
        _isLoading = false;
        notifyListeners();
        return false;
      }

      final response = await http.post(
        Uri.parse('${ApiService.baseUrl}/school/regenerate-token'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      final result = json.decode(response.body);

      if (response.statusCode == 200 && result['status'] == 'success') {
        _registrationToken = result['new_token'];

        // Simpan agar saat aplikasi dibuka kembali data tetap ada
        await _storage.write(
          key: 'registration_token',
          value: _registrationToken,
        );

        _isLoading = false;
        notifyListeners();
        return true;
      }
    } catch (e) {
      debugPrint("Error regenerate token: $e");
    }

    _isLoading = false;
    notifyListeners();
    return false;
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

  // 2. Update fungsi fetch agar bersifat reaktif
  Future<List<Map<String, dynamic>>> fetchPendingStudents() async {
    try {
      String? token = await getAuthToken();
      final response = await http.get(
        Uri.parse('${ApiService.baseUrl}/school/pending-students'),
        headers: {'Authorization': 'Bearer $token'},
      );

      final result = json.decode(response.body);

      if (result['status'] == 'success') {
        // PENTING: Perbarui variabel global agar UI yang menggunakan
        // context.watch<AuthProvider>().pendingStudentsList bisa mendeteksi perubahan
        _pendingStudentsList = List<Map<String, dynamic>>.from(result['data']);

        // Memicu pembangunan ulang (rebuild) pada UI
        notifyListeners();

        return _pendingStudentsList;
      }
      return [];
    } catch (e) {
      debugPrint("Error fetch pendaftar: $e");
      return [];
    }
  }

  Future<Map<String, dynamic>> verifyStudent(
    int studentId,
    String action,
  ) async {
    try {
      String? token = await getAuthToken();
      final response = await http.post(
        Uri.parse('${ApiService.baseUrl}/school/verify-student'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({'student_id': studentId, 'action': action}),
      );

      return json.decode(response.body);
    } catch (e) {
      return {"status": "error", "message": e.toString()};
    }
  }

  // --- FETCH DAFTAR SISWA AKTIF ---
  Future<List<Map<String, dynamic>>> fetchApprovedStudents() async {
    try {
      String? token = await getAuthToken();
      final response = await http.get(
        Uri.parse('${ApiService.baseUrl}/school/students'),
        headers: {'Authorization': 'Bearer $token'},
      );

      final result = json.decode(response.body);
      if (result['status'] == 'success') {
        // Pastikan setiap data memiliki properti 'selected' untuk UI Flutter
        return List<Map<String, dynamic>>.from(result['data']).map((s) {
          s['selected'] = false;
          return s;
        }).toList();
      }
      return [];
    } catch (e) {
      debugPrint("Error fetch data siswa: $e");
      return [];
    }
  }

  // --- AKSI MASSAL (Hapus, Naik Kelas, dll) ---
  Future<bool> bulkActionStudents(List<int> ids, String action) async {
    try {
      String? token = await getAuthToken();
      final response = await http.post(
        Uri.parse('${ApiService.baseUrl}/school/bulk-action'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({'student_ids': ids, 'action': action}),
      );
      return json.decode(response.body)['status'] == 'success';
    } catch (e) {
      return false;
    }
  }

  Future<bool> uploadArrivalPhoto(Uint8List imageBytes, String fileName) async {
    try {
      String? token = await getAuthToken();
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('${ApiService.baseUrl}/school/confirm-arrival'),
      );

      request.headers.addAll({'Authorization': 'Bearer $token'});

      // Mengirim file dalam bentuk bytes (Aman untuk Web & Mobile)
      request.files.add(
        http.MultipartFile.fromBytes(
          'arrival_photo',
          imageBytes,
          filename: fileName,
          contentType: MediaType('image', 'jpeg'),
        ),
      );

      var streamedResponse = await request.send();
      return streamedResponse.statusCode == 200;
    } catch (e) {
      debugPrint("Error: $e");
      return false;
    }
  }

  // Tambahkan ini di bagian bawah atau atas method lain
  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  // Di dalam class AuthProvider
  Future<Map<String, dynamic>> submitReview({
    required int rating,
    required List<String> tags,
    required String komentar,
  }) async {
    _setLoading(true); // Sekarang sudah tidak error karena helper sudah dibuat
    try {
      final token = await getAuthToken();
      final response = await http.post(
        Uri.parse('${ApiService.baseUrl}/submit-ulasan'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({
          // Gunakan json.encode agar konsisten dengan method lain
          'rating': rating,
          'tags': tags,
          'komentar': komentar,
        }),
      );

      final res = json.decode(response.body);
      return res;
    } catch (e) {
      debugPrint("Submit Review Error: $e");
      return {'status': 'error', 'message': e.toString()};
    } finally {
      _setLoading(false);
    }
  }
}
