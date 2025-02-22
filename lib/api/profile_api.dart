import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter/foundation.dart';

class ProfileAPI {
  static final storage = FlutterSecureStorage();

  // 🔹 Determine the Base URL
  static String getBaseUrl() {
    if (kIsWeb) {
      return "http://localhost:5000"; // Web
    } else if (Platform.isAndroid) {
      return "http://10.50.3.207:5000"; // Android Emulator
    } else {
      return "http://localhost:5000"; // iOS & Real Devices
    }
  }

  // 🔹 Fetch User Profile
  static Future<Map<String, dynamic>?> fetchProfile() async {
    final token = await storage.read(key: "token");
    final userId = await storage.read(key: "userId");

    print("🔹 Retrieved Token: $token");
    print("🔹 Retrieved User ID: $userId");

    if (userId == null || token == null) {
      print("❌ User ID or Token missing");
      return null;
    }

    final response = await http.get(
      Uri.parse("${getBaseUrl()}/api/user/$userId"),
      headers: {"Authorization": "Bearer $token"},
    );

    print("🔹 Profile API Response: ${response.body}");

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      print("❌ Profile Fetch Failed: ${response.statusCode}");
    }
    return null;
  }

  // 🔹 Update Profile Name
  static Future<bool> updateProfile(String newName) async {
    final token = await storage.read(key: "token");
    final userId = await storage.read(key: "userId");
    if (userId == null) return false;

    final response = await http.put(
      Uri.parse("${getBaseUrl()}/api/user/update-profile"),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token"
      },
      body: jsonEncode({"userId": userId, "name": newName}), // ✅ Use dynamic user ID
    );

    return response.statusCode == 200;
  }

  // 🔹 Upload Profile Image
  static Future<String?> uploadProfileImage(File imageFile) async {
    final token = await storage.read(key: "token");
    final userId = await storage.read(key: "userId");
    if (userId == null) return null;

    var request = http.MultipartRequest(
      'POST',
      Uri.parse("${getBaseUrl()}/api/user/upload-image"),
    );
    request.headers['Authorization'] = 'Bearer $token';
    request.files.add(await http.MultipartFile.fromPath('profileImage', imageFile.path));

    var response = await request.send();
    final responseData = await response.stream.bytesToString();

    if (response.statusCode == 200) {
      final decodedResponse = jsonDecode(responseData);
      print("✅ Image Uploaded: ${decodedResponse['profile_image']}");
      return decodedResponse['profile_image'];
    } else {
      print("❌ Image Upload Failed: ${response.statusCode} - ${responseData}");
    }
    return null;
  }
}
