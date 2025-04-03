import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class MoodAPI {
  static const String _baseUrl = "http://192.168.1.7:5000";
  static final FlutterSecureStorage _storage = const FlutterSecureStorage();

  // 🔹 Fetch Mood History (Sorted by `created_at`)
  static Future<List<dynamic>?> getMoodHistory() async {
    final token = await _storage.read(key: "token");
    if (token == null) return null;

    final response = await http.get(
      Uri.parse("$_baseUrl/moods"),
      headers: {"Authorization": "Bearer $token"},
    );

    if (response.statusCode == 200) {
      List<dynamic> moods = jsonDecode(response.body)
          .where((mood) => mood['created_at'] != null) // Remove null `created_at`
          .toList();

      // 🔹 Sort by `created_at`
      moods.sort((a, b) => DateTime.parse(a['created_at'])
          .compareTo(DateTime.parse(b['created_at'])));

      return moods;
    }
    return null;
  }

  // 🔹 Log Mood Entry
  static Future<bool> logMood(int moodScore, String note) async {
    final token = await _storage.read(key: "token");
    if (token == null) return false;

    final response = await http.post(
      Uri.parse("$_baseUrl/moods"),
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
    final token = await _storage.read(key: "token");
    if (token == null) return null;

    final response = await http.post(
      Uri.parse("$_baseUrl/ai/analyze-mood"),
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json"
      },
      body: jsonEncode({"mood_score": moodScore, "note": note}),
    );

    return response.statusCode == 200
        ? jsonDecode(response.body)['suggestion']
        : null;
  }

  // 🔹 Get Music Suggestion Based on Mood
  static Future<Map<String, dynamic>?> getMusicSuggestion(String mood) async {
    final token = await _storage.read(key: "token");
    if (token == null) return null;

    final response = await http.post(
      Uri.parse("$_baseUrl/music-recommendation"),
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json"
      },
      body: jsonEncode({"mood": mood}),
    );

    return response.statusCode == 200 ? jsonDecode(response.body) : null;
  }
}
