import 'dart:io';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'api_service.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class AuthService {
  final ApiService _apiService = ApiService();
  final _storage = const FlutterSecureStorage();

  // --- 1. LOGIKA PENDAFTARAN (Mendukung File KTP/SK) ---
  // Ditambahkan parameter file dan fileField agar sesuai dengan RegisterPage
  Future<Map<String, dynamic>> registerUser(
      Map<String, String> fields, File? file, String fileField) async {
    try {
      var request = http.MultipartRequest(
          'POST', Uri.parse('${ApiService.baseUrl}/register'));

      // Tambahkan field teks
      request.fields.addAll(fields);

      // Tambahkan file dokumen jika ada (KTP untuk Lansia / SK untuk Operator)
      if (file != null) {
        request.files.add(await http.MultipartFile.fromPath(fileField, file.path));
      }

      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);
      return json.decode(response.body);
    } catch (e) {
      return {"status": "error", "message": "Gagal mendaftarkan akun: $e"};
    }
  }

  // --- 2. LOGIKA LOGIN & MANAJEMEN SESI ---
  Future<Map<String, dynamic>> loginUser(String phone, String password) async {
    try {
      final result = await _apiService.login(phone, password);

      if (result['status'] == 'success') {
        final userData = result['data']; // Mengambil data nested dari Flask

        // Simpan sesi secara aman
        await _storage.write(key: 'auth_token', value: result['token']);
        await _storage.write(key: 'user_role', value: userData['role']);
        await _storage.write(key: 'user_name', value: userData['name']);
        
        // Simpan NPSN jika login sebagai Operator Sekolah
        if (userData['npsn'] != null) {
          await _storage.write(key: 'user_npsn', value: userData['npsn']);
        }
        
        // Simpan status is_approved untuk verifikasi berjenjang
        await _storage.write(key: 'is_approved', value: userData['is_approved'].toString());
      }
      return result;
    } catch (e) {
      return {"status": "error", "message": "Terjadi kesalahan saat login: $e"};
    }
  }

  // --- 3. AMBIL DATA PENGGUNA LOKAL ---
  Future<Map<String, String?>> getSavedAuthData() async {
    return {
      "token": await _storage.read(key: 'auth_token'),
      "role": await _storage.read(key: 'user_role'),
      "name": await _storage.read(key: 'user_name'),
      "npsn": await _storage.read(key: 'user_npsn'), // Tambahkan NPSN
      "is_approved": await _storage.read(key: 'is_approved'),
    };
  }

  // --- 4. LOGOUT ---
  Future<void> logoutUser() async {
    await _storage.deleteAll(); // Menghapus seluruh sesi
  }

  // --- 5. VALIDASI STATUS VERIFIKASI ---
  Future<bool> checkLocalApproval() async {
    String? status = await _storage.read(key: 'is_approved');
    return status == 'true';
  }
}