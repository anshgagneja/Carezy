import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthAPI {
  static const String baseUrl = "http://localhost:5000";
  static final storage = FlutterSecureStorage();

  // 🔹 Signup function
  static Future<Map<String, dynamic>?> register(String name, String email, String password) async {
    final response = await http.post(
      Uri.parse("$baseUrl/register"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"name": name, "email": email, "password": password}),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }
    return null;
  }

  // 🔹 Login function (Now Stores Token in Secure Storage)
  static Future<bool> login(String email, String password) async {
    final response = await http.post(
      Uri.parse("$baseUrl/login"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"email": email, "password": password}),
    );

    print("🔹 Sending request to: ${Uri.parse("$baseUrl/login")}");
    print("🔹 Login Response Status: ${response.statusCode}");
    print("🔹 Login Response Body: ${response.body}");

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final token = data['token'];
      
      if (token != null) {
        await storage.write(key: "token", value: token);
        print("✅ Token stored successfully: $token");
        return true;
      } else {
        print("❌ Token missing in response");
      }
    } else {
      print("❌ Login failed, status code: ${response.statusCode}");
    }
    return false;
  }

  // 🔹 Retrieve Token for Debugging
  static Future<void> checkStoredToken() async {
    final token = await storage.read(key: "token");
    if (token != null) {
      print("🔍 Retrieved Token from Secure Storage: $token");
    } else {
      print("❌ Token not found in Secure Storage.");
    }
  }

  // 🔹 Logout function (Deletes Token)
  static Future<void> logout() async {
    await storage.delete(key: "token");
    print("✅ Token deleted. User logged out.");
  }
}
