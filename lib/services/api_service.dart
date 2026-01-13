import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import '../models/menu_model.dart';

class ApiService {
  // Gunakan IP Address server Flask Anda
  static const String baseUrl = "http://192.168.100.183:5000/api";
  
  // Durasi timeout untuk mencegah aplikasi "nyangkut" selamanya saat sinyal buruk
  final Duration _timeoutDuration = const Duration(seconds: 10);

  // --- 1. HEADER HELPER ---
  // Token sekarang dikirim dari AuthProvider sebagai parameter
  Map<String, String> _headers(String? token, {bool isMultipart = false}) {
    return {
      if (!isMultipart) "Content-Type": "application/json",
      "Accept": "application/json",
      if (token != null) "Authorization": "Bearer $token",
    };
  }

  // --- 2. FUNGSI LOGIN ---
  Future<Map<String, dynamic>> login(String phone, String password) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/login"),
        headers: _headers(null), // Login tidak butuh token
        body: jsonEncode({"phone": phone, "password": password}),
      ).timeout(_timeoutDuration);

      return _handleResponse(response);
    } catch (e) {
      return {"status": "error", "message": "Gagal terhubung ke server: $e"};
    }
  }

  // --- 3. FUNGSI GET PARTNERS (Untuk Registrasi) ---
  Future<List<Map<String, dynamic>>> getPartners(String role, String district) async {
    try {
      final response = await http.get(
        Uri.parse("$baseUrl/get-partners?role=$role&district=$district"),
      ).timeout(_timeoutDuration);

      if (response.statusCode == 200) {
        final List result = jsonDecode(response.body);
        return List<Map<String, dynamic>>.from(result);
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  // --- 4. FUNGSI AMBIL MENU (DENGAN TOKEN) ---
  Future<MenuModel?> fetchMenuByDate(DateTime selectedDate, String? token) async {
    try {
      String formattedDate = DateFormat('yyyy-MM-dd').format(selectedDate);
      
      final response = await http.get(
        Uri.parse('$baseUrl/v1/menu-hari-ini?date=$formattedDate'),
        headers: _headers(token),
      ).timeout(_timeoutDuration);

      if (response.statusCode == 200) {
        final Map<String, dynamic> result = jsonDecode(response.body);
        if (result['status'] == 'success' && result['data'] != null) {
          return MenuModel.fromJson(result['data']);
        }
      } 
      return null; 
    } catch (e) {
      return null;
    }
  }

  // --- 5. UNIVERSAL RESPONSE HANDLER ---
  // Memastikan aplikasi tidak crash jika server mengirim error HTML (500)
  Map<String, dynamic> _handleResponse(http.Response response) {
    try {
      final contentType = response.headers['content-type'];
      if (contentType != null && contentType.contains('application/json')) {
        return jsonDecode(response.body);
      } else {
        return {
          "status": "error", 
          "message": "Server error (${response.statusCode}). Silakan coba lagi nanti."
        };
      }
    } catch (e) {
      return {"status": "error", "message": "Terjadi kesalahan pengolahan data server."};
    }
  }
}