import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import '../models/menu_model.dart';

class ApiService {
  // 1. GANTI Alamat IP dengan URL Ngrok Anda (Gunakan HTTPS)
  // Contoh: https://a1b2-c3d4.ngrok-free.app
  static const String rootUrl = "https://toxophilitic-carin-typographically.ngrok-free.dev"; 
  static const String baseUrl = "$rootUrl/api";

  final Duration _timeoutDuration = const Duration(seconds: 15);

  // --- 1. HEADER HELPER ---
  Map<String, String> _headers(String? token, {bool isMultipart = false}) {
    return {
      "Accept": "application/json",
      // PENTING: Header ini untuk melewati halaman peringatan ngrok
      // Tanpa ini, Flutter akan menerima HTML peringatan dan menyebabkan error "Gagal mengolah data"
      "ngrok-skip-browser-warning": "true", 
      
      if (!isMultipart) "Content-Type": "application/json",
      if (token != null && token.isNotEmpty)
        "Authorization": "Bearer ${token.trim()}",
    };
  }

  // --- 2. FUNGSI LOGIN ---
  Future<Map<String, dynamic>> login(String phone, String password) async {
    try {
      final response = await http
          .post(
            Uri.parse("$baseUrl/login"),
            headers: _headers(null), 
            body: jsonEncode({"phone": phone, "password": password}),
          )
          .timeout(_timeoutDuration);

      return _handleResponse(response);
    } catch (e) {
      return {"status": "error", "message": "Gagal terhubung ke server ngrok: $e"};
    }
  }

  // --- 3. FUNGSI GET PARTNERS ---
  Future<List<Map<String, dynamic>>> getPartners(
    String role,
    String district,
  ) async {
    try {
      final response = await http
          .get(
            Uri.parse("$baseUrl/get-partners?role=$role&district=$district"),
            // PENTING: Tambahkan headers di sini juga agar tidak kena blokir ngrok
            headers: _headers(null), 
          )
          .timeout(_timeoutDuration);

      if (response.statusCode == 200) {
        final List result = jsonDecode(response.body);
        return List<Map<String, dynamic>>.from(result);
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  // --- 4. FUNGSI AMBIL MENU ---
  Future<MenuModel?> fetchMenuByDate(
    DateTime selectedDate,
    String? token,
  ) async {
    try {
      String formattedDate = DateFormat('yyyy-MM-dd').format(selectedDate);

      final response = await http
          .get(
            Uri.parse('$baseUrl/v1/menu-hari-ini?date=$formattedDate'),
            headers: _headers(token),
          )
          .timeout(_timeoutDuration);

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
  Map<String, dynamic> _handleResponse(http.Response response) {
    try {
      if (response.statusCode >= 200 && response.statusCode < 300) {
        return jsonDecode(response.body);
      } else {
        final body = jsonDecode(response.body);
        return {
          "status": "error",
          "message": body['message'] ?? "Server error (${response.statusCode})",
        };
      }
    } catch (e) {
      // Jika error terjadi di sini, biasanya karena response bukan JSON (bisa jadi HTML error dari ngrok)
      return {
        "status": "error", 
        "message": "Data tidak valid. Pastikan ngrok masih aktif."
      };
    }
  }
}