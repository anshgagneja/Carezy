import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart'; // For animations
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
      appBar: AppBar(
        title: Text("Mood Tracking",
            style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        elevation: 5,
        backgroundColor: Colors.deepPurple.shade900,
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.all(20.0),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.deepPurple.shade900, Colors.deepPurple.shade500],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 🔹 Mood Animation
              Center(
                child: Lottie.asset(
                  'assets/animations/mood_animation.json',
                  width: 150,
                  height: 150,
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

              // 🔹 Note Input
              // 🔹 Note Input Field (Fixed)
              Container(
                decoration: BoxDecoration(
                  color: Colors.deepPurple
                      .shade50, // Light purple background for better visibility
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                      color: Colors.deepPurple.shade300), // Adds visibility
                ),
                child: TextField(
                  controller: noteController,
                  style: TextStyle(
                      color:
                          Colors.black), // Ensuring black text for readability
                  decoration: InputDecoration(
                    labelText: "Add a Note (Optional)",
                    labelStyle:
                        TextStyle(color: Colors.deepPurple), // Matches theme
                    border: InputBorder.none,
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                    prefixIcon: Icon(Icons.note, color: Colors.deepPurple),
                  ),
                ),
              ),

              SizedBox(height: 20),

              // 🔹 Action Buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: isLogging ? null : logMood,
                      icon: Icon(Icons.add_circle_outline, size: 20),
                      label: isLogging
                          ? CircularProgressIndicator(color: Colors.white)
                          : Text("Log Mood"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepPurpleAccent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding: EdgeInsets.symmetric(vertical: 15),
                      ),
                    ),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: isFetchingAI ? null : getAISuggestion,
                      icon: Icon(Icons.lightbulb, size: 20),
                      label: isFetchingAI
                          ? CircularProgressIndicator(color: Colors.white)
                          : Text("Get AI Suggestion"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.purpleAccent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding: EdgeInsets.symmetric(vertical: 15),
                      ),
                    ),
                  ),
                ],
              ),

              SizedBox(height: 20),

              // 🔹 Fixed Music Suggestion Button (Removed Extra Icon)
              ElevatedButton(
                onPressed: getMusicSuggestion,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: EdgeInsets.symmetric(vertical: 15),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.music_note,
                        size: 20, color: Colors.white), // Single icon
                    SizedBox(width: 8), // Space between icon and text
                    Text(
                      "Get Mood-Based Music",
                      style: TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 20),

              // 🔹 AI Suggestion
              aiSuggestion.isNotEmpty
                  ? AISuggestionWidget(aiSuggestion: aiSuggestion)
                  : Container(),

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

              // 🔹 Mood Graph
              isLoading
                  ? Center(
                      child: CircularProgressIndicator(color: Colors.white))
                  : MoodGraph(moodHistory: moodHistory),
            ],
          ),
        ),
      ),
    );
  }
}
