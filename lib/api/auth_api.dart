import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter/foundation.dart';
import 'dart:io';

class AuthAPI {
  static final storage = FlutterSecureStorage();

  // 🔹 Determine the Base URL based on the platform
  static String getBaseUrl() {
    if (kIsWeb) {
      return "http://localhost:5000"; // For Web
    } else if (Platform.isAndroid) {
      return "http://192.168.1.5:5000"; // For Android Emulator
    } else {
      return "http://localhost:5000"; // For iOS & real devices
    }
  }

  // 🔹 User Signup
  static Future<Map<String, dynamic>?> signup(
      String name, String email, String password) async {
    final response = await http.post(
      Uri.parse("${getBaseUrl()}/register"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"name": name, "email": email, "password": password}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      await storage.write(key: "token", value: data['token']);
      await storage.write(
          key: "userId",
          value: data['user']['id'].toString()); // ✅ Store User ID
      return data;
    }
    return null;
  }

  // 🔹 User Login
  static Future<bool> login(String email, String password) async {
    final response = await http.post(
      Uri.parse("${getBaseUrl()}/login"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"email": email, "password": password}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final token = data['token'];
      final userId = data['user']['id'].toString(); // ✅ Fetch User ID

      if (token != null && userId != null) {
        await storage.write(key: "token", value: token);
        await storage.write(key: "userId", value: userId); // ✅ Store User ID
        print("✅ Stored User ID: $userId"); // Debug Log
        return true;
      } else {
        print("❌ Login API Response Missing userId or token");
      }
    } else {
      print("❌ Login Failed: ${response.body}");
    }
    return false;
  }

  // 🔹 Retrieve Token
  static Future<String?> getToken() async {
    return await storage.read(key: "token");
  }

  // 🔹 Retrieve User ID
  static Future<String?> getUserId() async {
    return await storage.read(key: "userId");
  }

  // 🔹 Logout function
  static Future<void> logout() async {
    await storage.delete(key: "token");
    await storage.delete(key: "userId"); // ✅ Clear User ID
  }

  // 🔹 Send OTP for Password Reset
  static Future<bool> sendResetOTP(String email) async {
    final response = await http.post(
      Uri.parse("${getBaseUrl()}/send-reset-otp"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"email": email}),
    );

    if (response.statusCode == 200) {
      return true; // ✅ OTP sent successfully
    }
    return false; // ❌ Failed to send OTP
  }

  // 🔹 Reset Password with OTP
  static Future<bool> resetPassword(String email, String otp, String newPassword) async {
    final response = await http.post(
      Uri.parse("${getBaseUrl()}/reset-password"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "email": email,
        "otp": otp,
        "newPassword": newPassword
      }),
    );

    if (response.statusCode == 200) {
      return true; // ✅ Password reset successfully
    }
    return false; // ❌ Failed to reset password
  }
}
