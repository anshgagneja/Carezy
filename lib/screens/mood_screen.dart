import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import '../api/mood_api.dart';
import '../widgets/mood_slider.dart';
import '../widgets/mood_graph.dart';
import '../widgets/ai_suggestion.dart';
import 'music_screen.dart';

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
      moodHistory = moods ?? [];
    });
  }

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

  void getAISuggestion() async {
    if (isFetchingAI) return;
    setState(() => isFetchingAI = true);

    final suggestion =
        await MoodAPI.analyzeMood(selectedMood, noteController.text);
    setState(() {
      isFetchingAI = false;
      aiSuggestion = suggestion ?? "❌ Failed to get AI suggestion.";
    });
  }

  void getMusicSuggestion() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MusicScreen(mood: selectedMood.toString()),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, // 🔥 Full Dark Theme
      appBar: AppBar(
        title: Text(
          "Mood Tracking",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        centerTitle: true,
        elevation: 5,
        backgroundColor: Colors.black.withOpacity(0.9),
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.all(20.0),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.black, Colors.black87],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 🔹 Mood Animation (Minimal)
              Center(
                child: Lottie.asset(
                  'assets/animations/mood_animation.json',
                  width: 120,
                  height: 120,
                ),
              ),
              SizedBox(height: 20),

              // 🔹 Title
              Text(
                "How are you feeling today?",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 10),

              // 🔹 Mood Slider
              MoodSlider(
                value: selectedMood.toDouble(),
                onChanged: (value) {
                  setState(() {
                    selectedMood = value.toInt();
                  });
                },
              ),

              // 🔹 Note Input (FIXED: No White Background)
              Container(
                decoration: BoxDecoration(
                  color: Colors.grey.shade800.withOpacity(0.6), // Dark, Blended with Background
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white24),
                ),
                child: TextField(
                  controller: noteController,
                  style: TextStyle(color: Colors.black), // ✅ White Text
                  decoration: InputDecoration(
                    labelText: "Add a Note", // ✅ No "(Optional)"
                    labelStyle: TextStyle(color: Colors.deepPurpleAccent),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                    prefixIcon: Icon(Icons.edit, color: const Color.fromARGB(179, 121, 152, 255)),
                  ),
                ),
              ),

              SizedBox(height: 20),

              // 🔹 Action Buttons (Gradient Buttons)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: isLogging ? null : logMood,
                      child: isLogging
                          ? CircularProgressIndicator(color: Colors.white)
                          : Text("Log Mood", style: TextStyle(fontWeight: FontWeight.bold)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepPurpleAccent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        padding: EdgeInsets.symmetric(vertical: 15),
                      ),
                    ),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: isFetchingAI ? null : getAISuggestion,
                      child: isFetchingAI
                          ? CircularProgressIndicator(color: Colors.white)
                          : Text("Get AI Suggestion", style: TextStyle(fontWeight: FontWeight.bold)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.purpleAccent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        padding: EdgeInsets.symmetric(vertical: 15),
                      ),
                    ),
                  ),
                ],
              ),

              SizedBox(height: 20),

              // 🔹 Music Suggestion Button (Sleek Glass Effect)
              ElevatedButton(
                onPressed: getMusicSuggestion,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white.withOpacity(0.1),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: EdgeInsets.symmetric(vertical: 15),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.music_note, size: 20, color: Colors.tealAccent),
                    SizedBox(width: 8),
                    Text(
                      "Get Mood-Based Music",
                      style: TextStyle(color: Colors.tealAccent, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 20),

              // 🔹 AI Suggestion (Glassmorphism)
              if (aiSuggestion.isNotEmpty)
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.07),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.white24),
                  ),
                  padding: EdgeInsets.all(16),
                  child: AISuggestionWidget(aiSuggestion: aiSuggestion),
                ),

              SizedBox(height: 30),

              // 🔹 Mood Trends Header
              Text(
                "Your Mood Trends",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 10),

              // 🔹 Mood Graph (Blurred Background)
              Container(
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.07),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white24),
                ),
                padding: EdgeInsets.all(12),
                child: isLoading
                    ? Center(child: CircularProgressIndicator(color: Colors.white))
                    : MoodGraph(moodHistory: moodHistory),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
