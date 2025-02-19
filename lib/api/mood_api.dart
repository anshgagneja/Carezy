import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class MoodAPI {
  static const String baseUrl = "http://10.50.2.180:5000";

  static final storage = FlutterSecureStorage();

  // 🔹 Fetch Mood History (Uses `created_at` Instead of `timestamp`)
  static Future<List<dynamic>?> getMoodHistory() async {
    final token = await storage.read(key: "token");
    if (token == null) return null;

    final response = await http.get(
      Uri.parse("$baseUrl/moods"),
      headers: {
        "Authorization": "Bearer $token"
      },
    );

    if (response.statusCode == 200) {
      List<dynamic> moods = jsonDecode(response.body);

      // 🔹 Remove entries where `created_at` is null
      moods.removeWhere((mood) => mood['created_at'] == null);

      // 🔹 Sort moods by `created_at`
      moods.sort((a, b) {
        String timestampA = a['created_at'] ?? "2000-01-01T00:00:00Z";  
        String timestampB = b['created_at'] ?? "2000-01-01T00:00:00Z";

        return DateTime.parse(timestampA).compareTo(DateTime.parse(timestampB));
      });

      return moods;
    }
    return null;
  }

  // 🔹 Log Mood Entry
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

  // 🔹 AI Mood Analysis
    static Future<String?> analyzeMood(int moodScore, String note) async {
    final token = await storage.read(key: "token");
    if (token == null) return null;

    final response = await http.post(
      Uri.parse("$baseUrl/ai/analyze-mood"),
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json"
      },
      body: jsonEncode({
        "mood_score": moodScore, // 🔹 Now correctly sending mood_score
        "note": note // 🔹 Now correctly sending the note
      }),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body)['suggestion'];
    }
    return null;
  }

  static Future<Map<String, dynamic>?> getMusicSuggestion(String mood) async {
    final token = await storage.read(key: "token");
    if (token == null) return null;

    final response = await http.post(
      Uri.parse("$baseUrl/music-recommendation"),
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json"
      },
      body: jsonEncode({"mood": mood}),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }
    return null;
  }
}
