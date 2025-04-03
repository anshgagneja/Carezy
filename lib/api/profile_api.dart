import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter/foundation.dart';

class ProfileAPI {
  static final FlutterSecureStorage _storage = const FlutterSecureStorage();

  // 🔹 Determine Base URL
  static String getBaseUrl() {
    if (kIsWeb) return "http://192.168.1.7:5000"; // Web
    return Platform.isAndroid ? "http://192.168.1.7:5000" : "http://localhost:5000";
  }

  // 🔹 Fetch User Profile
  static Future<Map<String, dynamic>?> fetchProfile() async {
    final token = await _storage.read(key: "token");
    final userId = await _storage.read(key: "userId");

    if (userId == null || token == null) return null;

    final response = await http.get(
      Uri.parse("${getBaseUrl()}/api/user/$userId"),
      headers: {"Authorization": "Bearer $token"},
    );

    return response.statusCode == 200 ? jsonDecode(response.body) : null;
  }

  // 🔹 Update Profile Name
  static Future<bool> updateProfile(String newName) async {
    final token = await _storage.read(key: "token");
    final userId = await _storage.read(key: "userId");
    if (userId == null) return false;

    final response = await http.put(
      Uri.parse("${getBaseUrl()}/api/user/update-profile"),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token"
      },
      body: jsonEncode({"userId": userId, "name": newName}),
    );

    return response.statusCode == 200;
  }

  // 🔹 Upload Profile Image
  static Future<String?> uploadProfileImage(File imageFile) async {
    final token = await _storage.read(key: "token");
    final userId = await _storage.read(key: "userId");
    if (userId == null) return null;

    var request = http.MultipartRequest(
      'POST',
      Uri.parse("${getBaseUrl()}/api/user/upload-image"),
    )
      ..headers['Authorization'] = 'Bearer $token'
      ..files.add(await http.MultipartFile.fromPath('profileImage', imageFile.path));

    var response = await request.send();
    final responseData = await response.stream.bytesToString();

    return response.statusCode == 200 ? jsonDecode(responseData)['profile_image'] : null;
  }
}
