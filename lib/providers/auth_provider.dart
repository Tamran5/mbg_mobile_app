import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import '../services/api_service.dart';

class AuthProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();
  final _storage = const FlutterSecureStorage();

  // --- STATE VARIABLES ---
  bool _isLoggedIn = false;
  String? _userRole;
  String? _userName;
  String? _userNpsn;
  bool _isApproved = false;
  bool _isLoading = true;

  // --- GETTERS ---
  bool get isLoggedIn => _isLoggedIn;
  String? get userRole => _userRole;
  String? get userName => _userName;
  String? get userNpsn => _userNpsn;
  bool get isApproved => _isApproved;
  bool get isLoading => _isLoading;

  // --- 1. CEK LOGIN OTOMATIS SAAT STARTUP ---
  Future<void> checkLoginStatus() async {
    _isLoading = true;
    notifyListeners();

    String? token = await _storage.read(key: 'auth_token');
    String? role = await _storage.read(key: 'user_role');
    String? name = await _storage.read(key: 'user_name');
    String? npsn = await _storage.read(key: 'user_npsn');
    String? approved = await _storage.read(key: 'is_approved');

    if (token != null) {
      _isLoggedIn = true;
      _userRole = role;
      _userName = name;
      _userNpsn = npsn;
      _isApproved = approved == 'true';
    } else {
      _isLoggedIn = false;
    }

    _isLoading = false;
    notifyListeners();
  }

  // --- 2. LOGIKA REGISTER (DENGAN FILE UPLOAD) ---
  // Digunakan untuk pendaftaran Pengelola Sekolah (SK) & Lansia (KTP)
  Future<Map<String, dynamic>> registerWithFile(
      Map<String, String> fields, File? file, String fileField) async {
    _isLoading = true;
    notifyListeners();

    try {
      // Membuat MultipartRequest untuk pengiriman data teks & file sekaligus
      var request = http.MultipartRequest(
          'POST', Uri.parse('${ApiService.baseUrl}/api/register'));

      // Menambahkan field teks (nama, phone, role, npsn/nik, dll)
      request.fields.addAll(fields);

      // Menambahkan file dokumen jika tersedia
      if (file != null) {
        request.files.add(await http.MultipartFile.fromPath(
          fileField, // Dinamis: 'file_ktp' atau 'file_sk_operator'
          file.path,
        ));
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

  // --- 3. LOGIKA LOGIN ---
  Future<Map<String, dynamic>> login(String phone, String password) async {
    _isLoading = true;
    notifyListeners();

    final result = await _apiService.login(phone, password);

    if (result['status'] == 'success') {
      final userData = result['data'];
      
      _isLoggedIn = true;
      _userRole = userData['role'];
      _userName = userData['name'];
      _userNpsn = userData['npsn'];
      _isApproved = userData['is_approved'];

      await _storage.write(key: 'auth_token', value: result['token']);
      await _storage.write(key: 'user_role', value: _userRole);
      await _storage.write(key: 'user_name', value: _userName);
      await _storage.write(key: 'user_npsn', value: _userNpsn);
      await _storage.write(key: 'is_approved', value: _isApproved.toString());
    }

    _isLoading = false;
    notifyListeners();
    return result;
  }

  // --- 4. REFRESH STATUS VERIFIKASI ---
  Future<void> refreshApprovalStatus() async {
    try {
      final result = await _apiService.get('/api/check-status'); 
      
      if (result['status'] == 'success') {
        _isApproved = result['is_approved'];
        await _storage.write(key: 'is_approved', value: _isApproved.toString());
        notifyListeners();
      }
    } catch (e) {
      debugPrint("Gagal menyegarkan status: $e");
    }
  }

  // --- 5. LOGOUT ---
  Future<void> logout() async {
    await _storage.deleteAll();
    _isLoggedIn = false;
    _userRole = null;
    _userName = null;
    _userNpsn = null;
    _isApproved = false;
    notifyListeners();
  }
}