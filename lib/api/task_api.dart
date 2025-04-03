import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class TaskAPI {
  static const String _baseUrl = "http://192.168.1.7:5000";
  static final FlutterSecureStorage _storage = const FlutterSecureStorage();

  // 🔹 Fetch All Tasks
  static Future<List<dynamic>> getTasks() async {
    final token = await _storage.read(key: "token");
    if (token == null) return [];

    final response = await http.get(
      Uri.parse("$_baseUrl/tasks"),
      headers: {"Authorization": "Bearer $token"},
    );

    return response.statusCode == 200 ? jsonDecode(response.body) ?? [] : [];
  }

  // 🔹 Add a New Task
  static Future<bool> addTask(String title, String description) async {
    final token = await _storage.read(key: "token");
    if (token == null) return false;

    final response = await http.post(
      Uri.parse("$_baseUrl/tasks"),
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json"
      },
      body: jsonEncode({
        "title": title,
        "description": description,
        "due_date": DateTime.now().toIso8601String()
      }),
    );

    return response.statusCode == 200;
  }

  // 🔹 Update Task Status
  static Future<bool> updateTaskStatus(int taskId, String status) async {
    final token = await _storage.read(key: "token");
    if (token == null) return false;

    final response = await http.put(
      Uri.parse("$_baseUrl/tasks/$taskId"),
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json"
      },
      body: jsonEncode({"status": status}),
    );

    return response.statusCode == 200;
  }

  // 🔹 Delete Task
  static Future<bool> deleteTask(int taskId) async {
    final token = await _storage.read(key: "token");
    if (token == null) return false;

    final response = await http.delete(
      Uri.parse("$_baseUrl/tasks/$taskId"),
      headers: {"Authorization": "Bearer $token"},
    );

    return response.statusCode == 200;
  }
}
