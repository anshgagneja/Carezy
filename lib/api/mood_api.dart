import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class MoodAPI {
  static const String baseUrl = "http://localhost:5000";
  static final storage = FlutterSecureStorage();

  // 🔹 Log Mood
  static Future<bool> logMood(int moodScore, String note) async {
    final token = await storage.read(key: "token");
    if (token == null) return false;

    final response = await http.post(
      Uri.parse("$baseUrl/moods"),
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json"
      },
      body: jsonEncode({"mood_score": moodScore, "note": note}),
    );

    return response.statusCode == 200;
  }

  // 🔹 Fetch Mood History
  static Future<List<dynamic>?> getMoodHistory() async {
    final token = await storage.read(key: "token");
    if (token == null) return null;

    final response = await http.get(
      Uri.parse("$baseUrl/moods"),
      headers: {
        "Authorization": "Bearer $token"
      },
    );

    return response.statusCode == 200 ? jsonDecode(response.body) : null;
  }

  // 🔹 AI Mood Analysis
  static Future<String?> analyzeMood(String mood) async {
    final token = await storage.read(key: "token");
    if (token == null) return null;

    final response = await http.post(
      Uri.parse("$baseUrl/ai/analyze-mood"),
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json"
      },
      body: jsonEncode({"mood": mood}),
    );

    return response.statusCode == 200 ? jsonDecode(response.body)['suggestion'] : null;
  }
}
