import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter/foundation.dart'; // Import to check if running on web

class AuthAPI {
  static final storage = FlutterSecureStorage();

  // 🔹 Determine the Base URL based on the platform
  static String getBaseUrl() {
    if (kIsWeb) {
      return "http://localhost:5000"; // For Web
    } else if (Platform.isAndroid) {
      return "http://10.86.2.237:5000"; // For Android Emulator
    } else {
      return "http://localhost:5000"; // For iOS & real devices
    }
  }

  // 🔹 User Signup
  static Future<Map<String, dynamic>?> signup(
      String name, String email, String password) async {
    final response = await http.post(
      Uri.parse("${getBaseUrl()}/register"),
      headers: {
        "Content-Type": "application/json",
      },
      body: jsonEncode({
        "name": name,
        "email": email,
        "password": password,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      await storage.write(key: "token", value: data['token']);
      return data;
    }
    return null;
  }

  // 🔹 Login function
  static Future<bool> login(String email, String password) async {
    final response = await http.post(
      Uri.parse("${getBaseUrl()}/login"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"email": email, "password": password}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final token = data['token'];

      if (token != null) {
        await storage.write(key: "token", value: token);
        return true;
      }
    }
    return false;
  }

  // 🔹 Retrieve Token
  static Future<void> checkStoredToken() async {
    await storage.read(key: "token");
  }

  // 🔹 Logout function
  static Future<void> logout() async {
    await storage.delete(key: "token");
  }
}
