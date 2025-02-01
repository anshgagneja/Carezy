import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class MoodAPI {
  static const String baseUrl = "http://localhost:5000";
  static final storage = FlutterSecureStorage();

  // 🔹 Log Mood Entry (Now Handles Errors Properly)
  static Future<bool> logMood(int moodScore, String note) async {
    final token = await storage.read(key: "token");
    
    if (token == null) {
      print("❌ Token is null! Cannot log mood.");
      return false;
    }

    print("🔹 Sending Mood Log: Token = $token");

    try {
      final response = await http.post(
        Uri.parse("$baseUrl/moods"),
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json"
        },
        body: jsonEncode({"mood_score": moodScore, "note": note}),
      );

      print("🔹 Mood Logging Response Status: ${response.statusCode}");
      print("🔹 Mood Logging Response Body: ${response.body}");

      if (response.statusCode == 200) {
        return true;
      } else {
        print("❌ Failed to log mood. Status: ${response.statusCode}");
        return false;
      }
    } catch (e) {
      print("❌ Exception in logMood(): $e");
      return false;
    }
  }

  // 🔹 Fetch Mood History (Now Logs Errors)
  static Future<List<dynamic>?> getMoodHistory() async {
    final token = await storage.read(key: "token");

    if (token == null) {
      print("❌ Token is null! Cannot fetch mood history.");
      return null;
    }

    try {
      final response = await http.get(
        Uri.parse("$baseUrl/moods"),
        headers: {
          "Authorization": "Bearer $token"
        },
      );

      print("🔹 Fetch Mood History Status: ${response.statusCode}");
      print("🔹 Fetch Mood History Body: ${response.body}");

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        print("❌ Failed to fetch mood history. Status: ${response.statusCode}");
        return null;
      }
    } catch (e) {
      print("❌ Exception in getMoodHistory(): $e");
      return null;
    }
  }

  // 🔹 AI Mood Analysis (Now Handles Errors & Logs Response)
  static Future<String?> analyzeMood(String mood) async {
    final token = await storage.read(key: "token");

    if (token == null) {
      print("❌ Token is null! Cannot analyze mood.");
      return null;
    }

    print("🔹 Sending AI Mood Analysis Request: Mood = $mood");

    try {
      final response = await http.post(
        Uri.parse("$baseUrl/ai/analyze-mood"),
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json"
        },
        body: jsonEncode({"mood": mood}),
      );

      print("🔹 AI Mood Analysis Response Status: ${response.statusCode}");
      print("🔹 AI Mood Analysis Response Body: ${response.body}");

      if (response.statusCode == 200) {
        return jsonDecode(response.body)['suggestion'];
      } else {
        print("❌ Failed to get AI mood suggestion. Status: ${response.statusCode}");
        return null;
      }
    } catch (e) {
      print("❌ Exception in analyzeMood(): $e");
      return null;
    }
  }
}
