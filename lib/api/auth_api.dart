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

  // 🔹 Login function (Now clean)
  static Future<bool> login(String email, String password) async {
    final response = await http.post(
      Uri.parse("$baseUrl/login"),
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
