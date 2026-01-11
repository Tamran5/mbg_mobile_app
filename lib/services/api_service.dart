import 'dart:convert';
// import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ApiService {
  static const String baseUrl = "http://192.168.56.82:5000/api";
  // static const String baseUrl = "http://10.0.2.2:5000/api";
  
  final _storage = const FlutterSecureStorage();

  // --- 1. HEADER HELPER ---
  // Otomatis mengambil token untuk setiap request yang membutuhkan autentikasi
  Future<Map<String, String>> _getHeaders({bool isMultipart = false}) async {
    String? token = await _storage.read(key: 'auth_token');
    return {
      if (!isMultipart) "Content-Type": "application/json",
      if (token != null) "Authorization": "Bearer $token",
    };
  }

  // --- 2. FUNGSI GET (DENGAN AUTH) ---
  Future<Map<String, dynamic>> get(String endpoint) async {
    try {
      final response = await http.get(
        Uri.parse("$baseUrl$endpoint"),
        headers: await _getHeaders(),
      );
      return jsonDecode(response.body);
    } catch (e) {
      throw Exception("Gagal mengambil data: $e");
    }
  }

  // --- 3. FUNGSI POST (JSON) ---
  Future<Map<String, dynamic>> post(String endpoint, Map<String, dynamic> data) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl$endpoint"),
        headers: await _getHeaders(),
        body: jsonEncode(data),
      );
      return jsonDecode(response.body);
    } catch (e) {
      return {"status": "error", "message": "Koneksi server gagal: $e"};
    }
  }

  // --- 4. DROPDOWN OTOMATIS: AMBIT MITRA (BARU) ---
  // Mengambil daftar Dapur atau Sekolah berdasarkan Kecamatan
  Future<List<Map<String, dynamic>>> getPartners(String role, String district) async {
    try {
      // Endpoint: /get-partners?role=admin_dapur&district=Klojen
      final response = await http.get(
        Uri.parse("$baseUrl/get-partners?role=$role&district=$district"),
        headers: {"Content-Type": "application/json"}, // Publik saat registrasi
      );

      if (response.statusCode == 200) {
        final List result = jsonDecode(response.body);
        return List<Map<String, dynamic>>.from(result);
      }
      return [];
    } catch (e) {
      print("Error getPartners: $e");
      return [];
    }
  }

  // --- 5. LOGIN & STORAGE ---
  Future<Map<String, dynamic>> login(String phone, String password) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/login"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"phone": phone, "password": password}),
      );

      final result = jsonDecode(response.body);

      if (response.statusCode == 200 && result['token'] != null) {
        final userData = result['data'];
        await _storage.write(key: 'auth_token', value: result['token']);
        await _storage.write(key: 'user_role', value: userData['role']);
        await _storage.write(key: 'user_name', value: userData['name']);
        if (userData['npsn'] != null) {
          await _storage.write(key: 'user_npsn', value: userData['npsn']);
        }
        await _storage.write(key: 'is_approved', value: userData['is_approved'].toString());
      }
      return result;
    } catch (e) {
      return {"status": "error", "message": "Gagal terhubung ke server: $e"};
    }
  }

  // --- 6. LOGOUT ---
  Future<void> logout() async {
    await _storage.deleteAll();
  }
}