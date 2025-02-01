import 'package:flutter/material.dart';
import '../api/mood_api.dart';

class MoodScreen extends StatefulWidget {
  @override
  _MoodScreenState createState() => _MoodScreenState();
}

class _MoodScreenState extends State<MoodScreen> {
  int selectedMood = 5;
  TextEditingController noteController = TextEditingController();
  List<dynamic> moodHistory = [];
  String aiSuggestion = "";
  bool isLoading = false;  // Added loading state
  bool isLogging = false;  // Prevents multiple clicks on "Log Mood"
  bool isFetchingAI = false; // Prevents multiple clicks on "Get AI Suggestion"

  @override
  void initState() {
    super.initState();
    fetchMoodHistory();
  }

  // 🔹 Fetch Mood History (Now Shows a Loading Indicator)
  void fetchMoodHistory() async {
    setState(() => isLoading = true);
    final moods = await MoodAPI.getMoodHistory();
    setState(() {
      isLoading = false;
      if (moods != null) {
        moodHistory = moods;
      } else {
        print("❌ Failed to fetch mood history.");
      }
    });
  }

  // 🔹 Log Mood (Now Shows Snackbar with Debug Info)
  void logMood() async {
    if (isLogging) return;
    setState(() => isLogging = true);

    print("🔹 Logging Mood: Score = $selectedMood, Note = ${noteController.text}");

    bool success = await MoodAPI.logMood(selectedMood, noteController.text);
    setState(() => isLogging = false);

    if (success) {
      fetchMoodHistory();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("✅ Mood logged successfully")));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("❌ Failed to log mood. Check API logs.")));
    }
  }

  // 🔹 Get AI Suggestion (Now Shows Debug Logs)
  void getAISuggestion() async {
    if (isFetchingAI) return;
    setState(() => isFetchingAI = true);

    print("🔹 Requesting AI Mood Analysis for: Mood Score = $selectedMood");

    final suggestion = await MoodAPI.analyzeMood(selectedMood.toString());

    setState(() {
      isFetchingAI = false;
      aiSuggestion = suggestion ?? "❌ Failed to get AI suggestion.";
    });

    print("🔹 AI Suggestion Received: $aiSuggestion");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Mood Tracking")),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Text("How are you feeling today?", style: TextStyle(fontSize: 18)),
            Slider(
              value: selectedMood.toDouble(),
              min: 1,
              max: 10,
              divisions: 9,
              label: selectedMood.toString(),
              onChanged: (value) {
                setState(() {
                  selectedMood = value.toInt();
                });
              },
            ),
            TextField(controller: noteController, decoration: InputDecoration(labelText: "Notes")),
            SizedBox(height: 10),

            // 🔹 Log Mood Button (Now Prevents Multiple Clicks)
            ElevatedButton(
              onPressed: isLogging ? null : logMood,
              child: isLogging ? CircularProgressIndicator() : Text("Log Mood"),
            ),
            SizedBox(height: 10),

            // 🔹 Get AI Suggestion Button (Now Prevents Multiple Clicks)
            ElevatedButton(
              onPressed: isFetchingAI ? null : getAISuggestion,
              child: isFetchingAI ? CircularProgressIndicator() : Text("Get AI Suggestion"),
            ),

            aiSuggestion.isNotEmpty ? Text("AI Suggestion: $aiSuggestion") : Container(),
            SizedBox(height: 20),

            Text("Mood History:", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),

            // 🔹 Show Loading Indicator While Fetching Moods
            isLoading
                ? CircularProgressIndicator()
                : Expanded(
                    child: ListView.builder(
                      itemCount: moodHistory.length,
                      itemBuilder: (context, index) {
                        final mood = moodHistory[index];
                        return ListTile(
                          title: Text("Mood Score: ${mood['mood_score']}"),
                          subtitle: Text("Note: ${mood['note']}"),
                        );
                      },
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}
