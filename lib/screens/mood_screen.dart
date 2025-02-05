import 'package:flutter/material.dart';
import '../api/mood_api.dart';
import '../widgets/mood_slider.dart';
import '../widgets/mood_graph.dart';
import '../widgets/ai_suggestion.dart';

class MoodScreen extends StatefulWidget {
  @override
  _MoodScreenState createState() => _MoodScreenState();
}

class _MoodScreenState extends State<MoodScreen> {
  int selectedMood = 5;
  TextEditingController noteController = TextEditingController();
  List<dynamic> moodHistory = [];
  String aiSuggestion = "";
  bool isLoading = false;
  bool isLogging = false;
  bool isFetchingAI = false;

  @override
  void initState() {
    super.initState();
    fetchMoodHistory();
  }

  // 🔹 Fetch Mood History
  void fetchMoodHistory() async {
    setState(() => isLoading = true);
    final moods = await MoodAPI.getMoodHistory();
    setState(() {
      isLoading = false;
      if (moods != null) {
        moodHistory = moods;
      }
    });
  }

  // 🔹 Log Mood Entry
  void logMood() async {
    if (isLogging) return;
    setState(() => isLogging = true);

    bool success = await MoodAPI.logMood(selectedMood, noteController.text);
    setState(() => isLogging = false);

    if (success) {
      fetchMoodHistory();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("✅ Mood logged successfully")),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("❌ Failed to log mood")),
      );
    }
  }

  // 🔹 AI Mood Analysis (Now Uses Both Mood Score & User's Note)
  void getAISuggestion() async {
    if (isFetchingAI) return;
    setState(() => isFetchingAI = true);

    final suggestion = await MoodAPI.analyzeMood(selectedMood, noteController.text);
    setState(() {
      isFetchingAI = false;
      aiSuggestion = suggestion ?? "❌ Failed to get AI suggestion.";
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Mood Tracking")),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("How are you feeling today?", style: TextStyle(fontSize: 18)),

              // 🔹 Mood Selector
              MoodSlider(
                value: selectedMood.toDouble(),
                onChanged: (value) {
                  setState(() {
                    selectedMood = value.toInt();
                  });
                },
              ),

              TextField(
                controller: noteController,
                decoration: InputDecoration(
                  labelText: "Add a Note (Optional)",
                  border: OutlineInputBorder(),
                ),
              ),

              SizedBox(height: 10),

              // 🔹 Log Mood Button
              ElevatedButton(
                onPressed: isLogging ? null : logMood,
                child: isLogging ? CircularProgressIndicator() : Text("Log Mood"),
              ),

              SizedBox(height: 10),

              // 🔹 Get AI Suggestion Button
              ElevatedButton(
                onPressed: isFetchingAI ? null : getAISuggestion,
                child: isFetchingAI ? CircularProgressIndicator() : Text("Get AI Suggestion"),
              ),

              // 🔹 Display AI Suggestion
              AISuggestionWidget(aiSuggestion: aiSuggestion),

              SizedBox(height: 20),

              Text("Your Mood Trends", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              SizedBox(height: 20),

              // 🔹 Mood Tracking Graph 📊
              isLoading
                  ? Center(child: CircularProgressIndicator())
                  : MoodGraph(moodHistory: moodHistory),
            ],
          ),
        ),
      ),
    );
  }
}
