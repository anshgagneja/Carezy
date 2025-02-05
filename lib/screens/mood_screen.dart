import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
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

  void logMood() async {
    if (isLogging) return;
    setState(() => isLogging = true);

    bool success = await MoodAPI.logMood(selectedMood, noteController.text);
    setState(() => isLogging = false);

    if (success) {
      fetchMoodHistory();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Mood logged successfully")));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Failed to log mood")));
    }
  }

  void getAISuggestion() async {
    if (isFetchingAI) return;
    setState(() => isFetchingAI = true);

    final suggestion = await MoodAPI.analyzeMood(selectedMood.toString());

    setState(() {
      isFetchingAI = false;
      aiSuggestion = suggestion ?? "Failed to get AI suggestion.";
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

              MoodSlider(
                value: selectedMood.toDouble(),
                onChanged: (value) {
                  setState(() {
                    selectedMood = value.toInt();
                  });
                },
              ),

              TextField(controller: noteController, decoration: InputDecoration(labelText: "Notes")),
              SizedBox(height: 10),

              ElevatedButton(onPressed: logMood, child: Text("Log Mood")),
              SizedBox(height: 10),

              ElevatedButton(onPressed: getAISuggestion, child: Text("Get AI Suggestion")),

              AISuggestionWidget(aiSuggestion: aiSuggestion),

              SizedBox(height: 20),

              Text("Your Mood Trends", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              SizedBox(height: 20),

              isLoading ? CircularProgressIndicator() : MoodGraph(moodHistory: moodHistory),
            ],
          ),
        ),
      ),
    );
  }
}
