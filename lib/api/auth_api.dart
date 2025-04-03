import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter/foundation.dart';
import 'dart:io';

class AuthAPI {
  static final FlutterSecureStorage _storage = const FlutterSecureStorage();

  // 🔹 Determine Base URL
  static String getBaseUrl() {
    if (kIsWeb) {
      return "http://localhost:5000"; // Web
    } else if (Platform.isAndroid) {
      return "http://192.168.1.7:5000"; // Android Emulator
    } else {
      return "http://localhost:5000"; // iOS & real devices
    }
  }

  // 🔹 User Signup
  static Future<Map<String, dynamic>?> signup(String name, String email, String password) async {
    final response = await http.post(
      Uri.parse("${getBaseUrl()}/register"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"name": name, "email": email, "password": password}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      await _storage.write(key: "token", value: data['token']);
      await _storage.write(key: "userId", value: data['user']['id'].toString());
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
      if (data['token'] != null) {
        await _storage.write(key: "token", value: data['token']);
        await _storage.write(key: "userId", value: data['user']['id'].toString());
        return true;
      }
    }
    return false;
  }

  // 🔹 Retrieve Token
  static Future<String?> getToken() async => await _storage.read(key: "token");

  // 🔹 Retrieve User ID
  static Future<String?> getUserId() async => await _storage.read(key: "userId");

  // 🔹 Logout function
  static Future<void> logout() async {
    await _storage.delete(key: "token");
    await _storage.delete(key: "userId");
  }

  // 🔹 Send OTP for Password Reset
  static Future<bool> sendResetOTP(String email) async {
    final response = await http.post(
      Uri.parse("${getBaseUrl()}/send-reset-otp"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"email": email}),
    );

    return response.statusCode == 200;
  }

  // 🔹 Reset Password with OTP
  static Future<bool> resetPassword(String email, String otp, String newPassword) async {
    final response = await http.post(
      Uri.parse("${getBaseUrl()}/reset-password"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"email": email, "otp": otp, "newPassword": newPassword}),
    );

    return response.statusCode == 200;
  }
}
