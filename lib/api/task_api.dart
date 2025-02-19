import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class TaskAPI {
  static const String baseUrl = "http://10.50.2.180:5000";
  static final storage = FlutterSecureStorage();

  // 🔹 Fetch All Tasks
  static Future<List<dynamic>?> getTasks() async {
    final token = await storage.read(key: "token");
    if (token == null) return null;

    final response = await http.get(
      Uri.parse("$baseUrl/tasks"),
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json"
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }
    return null;
  }

  // 🔹 Add a New Task
  static Future<bool> addTask(String title, String description) async {
    final token = await storage.read(key: "token");
    if (token == null) return false;

    final response = await http.post(
      Uri.parse("$baseUrl/tasks"),
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
    final token = await storage.read(key: "token");
    if (token == null) return false;

    final response = await http.put(
      Uri.parse("$baseUrl/tasks/$taskId"),
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
    final token = await storage.read(key: "token");
    if (token == null) return false;

    final response = await http.delete(
      Uri.parse("$baseUrl/tasks/$taskId"),
      headers: {
        "Authorization": "Bearer $token",
      },
    );

    return response.statusCode == 200;
  }
}
