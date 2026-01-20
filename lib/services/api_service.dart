import 'dart:convert';
import 'dart:async';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:http_parser/http_parser.dart';
import 'package:image_picker/image_picker.dart';
import '../models/menu_model.dart';

class ApiService {
  static const String rootUrl =
      "https://toxophilitic-carin-typographically.ngrok-free.dev";
  static const String baseUrl = "$rootUrl/api";
  final Duration _timeoutDuration = const Duration(seconds: 15);

  // --- 1. HEADER HELPER (Sentralisasi Bypass Ngrok & Auth) ---
  Map<String, String> _headers(String? token, {bool isMultipart = false}) {
    return {
      "Accept": "application/json",
      "ngrok-skip-browser-warning": "true", // Bypass halaman peringatan Ngrok
      if (!isMultipart) "Content-Type": "application/json",
      if (token != null && token.isNotEmpty)
        "Authorization": "Bearer ${token.trim()}",
    };
  }

  // --- 2. BASE REQUEST METHODS ---

  Future<dynamic> get(String endpoint, String? token) async {
    try {
      final response = await http
          .get(Uri.parse("$baseUrl/$endpoint"), headers: _headers(token))
          .timeout(_timeoutDuration);
      return _handleResponse(response);
    } catch (e) {
      return {"status": "error", "message": "Koneksi gagal: $e"};
    }
  }

  Future<Map<String, dynamic>> post(
    String endpoint,
    Map<String, dynamic> body,
    String? token,
  ) async {
    try {
      final response = await http
          .post(
            Uri.parse("$baseUrl/$endpoint"),
            headers: _headers(token),
            body: jsonEncode(body),
          )
          .timeout(_timeoutDuration);
      return _handleResponse(response);
    } catch (e) {
      return {"status": "error", "message": "Koneksi gagal: $e"};
    }
  }

  // --- 3. AUTH & PROFILE FUNCTIONS ---

  Future<Map<String, dynamic>> login(String phone, String password) async {
    return await post("login", {"phone": phone, "password": password}, null);
  }

  Future<Map<String, dynamic>> requestChangeEmail(
    String email,
    String pass,
    String? token,
  ) async {
    return await post("request-change-email", {
      "new_email": email,
      "password": pass,
    }, token);
  }

  Future<Map<String, dynamic>> verifyChangeEmail(
    String email,
    String otp,
    String? token,
  ) async {
    return await post("verify-change-email", {
      "new_email": email,
      "otp": otp,
    }, token);
  }

  // --- 4. SCHOOL & STUDENT OPERATIONS ---

  Future<Map<String, dynamic>> fetchSchoolStats(String? token) async {
    return await get("school/stats", token);
  }

  Future<Map<String, dynamic>> fetchPendingStudents(String? token) async {
    return await get("school/pending-students", token);
  }

  Future<Map<String, dynamic>> fetchApprovedStudents(String? token) async {
    return await get("school/students", token);
  }

  Future<Map<String, dynamic>> bulkActionStudents(
    List<int> ids,
    String action,
    String? token,
  ) async {
    return await post("school/bulk-action", {
      "student_ids": ids,
      "action": action,
    }, token);
  }

  Future<Map<String, dynamic>> regenerateSchoolToken(String? token) async {
    return await post("school/regenerate-token", {}, token);
  }

  // --- 5. MULTIPART REQUESTS (Unggah Gambar) ---

  // Unggah Foto Kedatangan (Gunakan Bytes agar aman di Web/Mobile)
  Future<bool> uploadArrivalPhoto(
    Uint8List imageBytes,
    String fileName,
    String? token,
  ) async {
    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/school/confirm-arrival'),
      );
      request.headers.addAll(_headers(token, isMultipart: true));

      request.files.add(
        http.MultipartFile.fromBytes(
          'arrival_photo',
          imageBytes,
          filename: fileName,
          contentType: MediaType('image', 'jpeg'),
        ),
      );

      var streamedResponse = await request.send().timeout(_timeoutDuration);
      return streamedResponse.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  // Registrasi dengan file (Path-based untuk Mobile)
  Future<Map<String, dynamic>> registerWithFile(
    Map<String, String> fields,
    XFile? file,
    String fileKey,
  ) async {
    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/register'),
      );
      request.headers.addAll(_headers(null, isMultipart: true));
      request.fields.addAll(fields);

      if (file != null) {
        request.files.add(
          await http.MultipartFile.fromPath(
            fileKey,
            file.path,
            contentType: MediaType('image', 'jpeg'),
          ),
        );
      }

      var streamedResponse = await request.send().timeout(_timeoutDuration);
      var response = await http.Response.fromStream(streamedResponse);
      return _handleResponse(response);
    } catch (e) {
      return {"status": "error", "message": "Gagal registrasi: $e"};
    }
  }

  // --- 6. REVIEW & MENU FUNCTIONS ---

  Future<Map<String, dynamic>> submitReview(
    int rating,
    List<String> tags,
    String komentar,
    String? token,
  ) async {
    return await post("submit-ulasan", {
      'rating': rating,
      'tags': tags,
      'komentar': komentar,
    }, token);
  }

  Future<MenuModel?> fetchMenuByDate(
    DateTime selectedDate,
    String? token,
  ) async {
    try {
      String dateStr = DateFormat('yyyy-MM-dd').format(selectedDate);
      final res = await get("v1/menu-hari-ini?date=$dateStr", token);
      if (res['status'] == 'success' && res['data'] != null) {
        return MenuModel.fromJson(res['data']);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  // Tambahkan di dalam class ApiService
  Future<List<Map<String, dynamic>>> getPartners(
    String role,
    String district,
  ) async {
    try {
      // Menggunakan helper 'get' yang sudah kita buat
      final res = await get("get-partners?role=$role&district=$district", null);

      // Karena getPartners mengembalikan List, kita perlu sedikit penyesuaian
      // Jika res adalah Map yang berisi List data:
      if (res is List) return List<Map<String, dynamic>>.from(res);
      if (res['status'] == 'error') return [];

      return List<Map<String, dynamic>>.from(res as Iterable);
    } catch (e) {
      return [];
    }
  }

  // --- 7. RESPONSE HANDLER (Pencegah Crash FormatException) ---

  dynamic _handleResponse(http.Response response) {
    // Jika server error (HTML), tetap kembalikan Map agar loading berhenti
    if (response.body.contains("<!DOCTYPE html>")) {
      return {
        "status": "error",
        "message": "Server sedang bermasalah (404/500)",
      };
    }

    try {
      final decoded = jsonDecode(response.body);
      if (response.statusCode >= 200 && response.statusCode < 300) {
        return decoded;
      } else {
        // Pastikan selalu ada 'message' agar UI bisa menampilkan pesan
        return {
          "status": "error",
          "message": decoded is Map
              ? (decoded['message'] ?? "Terjadi kesalahan")
              : "Error",
        };
      }
    } catch (e) {
      return {"status": "error", "message": "Gagal membaca data dari server"};
    }
  }
}
