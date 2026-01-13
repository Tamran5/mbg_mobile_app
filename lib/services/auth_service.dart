import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:image_picker/image_picker.dart'; 
import 'package:http_parser/http_parser.dart'; 
import 'api_service.dart';

class AuthService {
  final ApiService _apiService = ApiService();
  final _storage = const FlutterSecureStorage();

  // --- 1. LOGIKA PENDAFTARAN (KOMPATIBEL WEB & MOBILE) ---
  Future<Map<String, dynamic>> registerUser(
      Map<String, String> fields, XFile? file, String fileField) async {
    try {
      var request = http.MultipartRequest(
          'POST', Uri.parse('${ApiService.baseUrl}/register'));

      request.fields.addAll(fields);

      if (file != null) {
        // SOLUSI: Baca bytes file agar diizinkan browser
        final List<int> bytes = await file.readAsBytes();
        
        request.files.add(http.MultipartFile.fromBytes(
          fileField,
          bytes,
          filename: file.name,
          contentType: MediaType('image', 'jpeg'), // Pastikan sesuai format SK/KTP
        ));
      }

      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);
      
      // Validasi apakah respon benar-benar JSON
      if (!response.body.startsWith('{')) {
        return {"status": "error", "message": "Server error (Bukan JSON)"};
      }
      
      return json.decode(response.body);
    } catch (e) {
      return {"status": "error", "message": "Gagal mendaftarkan akun: $e"};
    }
  }

Future<Map<String, dynamic>> loginUser(String phone, String password) async {
  try {
    // 1. Panggil mesin login dari ApiService
    final result = await _apiService.login(phone, password);

    // 2. Jika sukses dari server, simpan semua detail ke Storage di sini
    if (result['status'] == 'success' && result['token'] != null) {
      final userData = result['data'];

      await _storage.write(key: 'auth_token', value: result['token']);
      await _storage.write(key: 'user_role', value: userData['role']);
      await _storage.write(key: 'user_name', value: userData['name']);
      
      if (userData['npsn'] != null) {
        await _storage.write(key: 'user_npsn', value: userData['npsn'].toString());
      }
      
      await _storage.write(key: 'is_approved', value: userData['is_approved'].toString());
    }
    
    return result;
  } catch (e) {
    return {"status": "error", "message": "Terjadi kesalahan sistem: $e"};
  }
}

  // --- 3. LOGOUT ---
  Future<void> logoutUser() async {
    await _storage.deleteAll();
  }

  // --- 4. VALIDASI STATUS VERIFIKASI ---
  Future<bool> checkLocalApproval() async {
    String? status = await _storage.read(key: 'is_approved');
    return status == 'true' || status == '1'; 
  }
}