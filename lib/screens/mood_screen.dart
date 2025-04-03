import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import '../api/mood_api.dart';
import '../widgets/mood_slider.dart';
import '../widgets/mood_graph.dart';
import '../widgets/ai_suggestion.dart';
import 'music_screen.dart';

class MoodScreen extends StatefulWidget {
  const MoodScreen({super.key});
  @override
  State<MoodScreen> createState() => _MoodScreenState();
}


class _MoodScreenState extends State<MoodScreen> {
  int selectedMood = 5;
  final TextEditingController noteController = TextEditingController();
  List<dynamic> moodHistory = [];
  String aiSuggestion = "";
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    fetchMoodHistory();
  }

  Future<void> fetchMoodHistory() async {
    setState(() => isLoading = true);
    final history = await MoodAPI.getMoodHistory();
    setState(() {
      moodHistory = history ?? [];
      isLoading = false;
    });
  }

  Future<void> logMood() async {
    final success = await MoodAPI.logMood(selectedMood, noteController.text);
    if (mounted) {
      _showSnackbar(success ? "✅ Mood logged successfully" : "❌ Failed to log mood");
      if (success) fetchMoodHistory();
    }
  }

  Future<void> getAISuggestion() async {
    final suggestion = await MoodAPI.analyzeMood(selectedMood, noteController.text);
    if (mounted) {
      setState(() => aiSuggestion = suggestion ?? "❌ Failed to get AI suggestion.");
    }
  }

  void getMusicSuggestion() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => MusicScreen(mood: selectedMood.toString())),
    );
  }

  void _showSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  void dispose() {
    noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 0, 0, 0),
      appBar: AppBar(
        title: const Text("Mood Tracking", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        centerTitle: true,
        elevation: 5,
        backgroundColor: const Color.fromARGB(230, 0, 0, 0),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildLottieAnimation(),
            const SizedBox(height: 20),
            _buildMoodTitle(),
            const SizedBox(height: 10),
            MoodSlider(
              value: selectedMood.toDouble(),
              onChanged: (value) => setState(() => selectedMood = value.toInt()),
            ),
            const SizedBox(height: 20),
            _buildNoteInput(),
            const SizedBox(height: 20),
            _buildActionButtons(),
            const SizedBox(height: 20),
            _buildMusicButton(),
            const SizedBox(height: 20),
            if (aiSuggestion.isNotEmpty) _buildAISuggestion(),
            const SizedBox(height: 30),
            _buildMoodGraph(),
          ],
        ),
      ),
    );
  }

  Widget _buildLottieAnimation() {
    return Center(
      child: Lottie.asset('assets/animations/mood_animation.json', width: 120, height: 120),
    );
  }

  Widget _buildMoodTitle() {
    return const Text(
      "How are you feeling today?",
      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
    );
  }

  Widget _buildNoteInput() {
    return Container(
      decoration: BoxDecoration(
        color: const Color.fromARGB(150, 88, 88, 88),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white24),
      ),
      child: TextField(
        controller: noteController,
        style: const TextStyle(color: Colors.white),
        decoration: const InputDecoration(
          labelText: "Add a Note",
          labelStyle: TextStyle(color: Colors.deepPurpleAccent),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
          prefixIcon: Icon(Icons.edit, color: Color.fromARGB(179, 121, 152, 255)),
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton(
            onPressed: logMood,
            style: _buttonStyle(const Color.fromARGB(255, 103, 58, 183)),
            child: const Text("Log Mood", style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: ElevatedButton(
            onPressed: getAISuggestion,
            style: _buttonStyle(const Color.fromARGB(255, 156, 39, 176)),
            child: const Text("Get AI Suggestion", style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ),
      ],
    );
  }

  Widget _buildMusicButton() {
    return ElevatedButton(
      onPressed: getMusicSuggestion,
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color.fromARGB(150, 255, 255, 255),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        padding: const EdgeInsets.symmetric(vertical: 15),
      ),
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.music_note, size: 20, color: Colors.tealAccent),
          SizedBox(width: 8),
          Text("Get Mood-Based Music", style: TextStyle(color: Colors.tealAccent, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildAISuggestion() {
    return Container(
      margin: const EdgeInsets.only(top: 20),
      decoration: BoxDecoration(
        color: const Color.fromARGB(150, 255, 255, 255),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white24),
      ),
      padding: const EdgeInsets.all(16),
      child: AISuggestionWidget(aiSuggestion: aiSuggestion),
    );
  }

  Widget _buildMoodGraph() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Your Mood Trends", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
        const SizedBox(height: 10),
        Container(
          decoration: BoxDecoration(
            color: const Color.fromARGB(150, 255, 255, 255),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white24),
          ),
          padding: const EdgeInsets.all(12),
          child: isLoading
              ? const Center(child: CircularProgressIndicator(color: Colors.white))
              : MoodGraph(moodHistory: moodHistory),
        ),
      ],
    );
  }

  ButtonStyle _buttonStyle(Color color) {
    return ElevatedButton.styleFrom(
      backgroundColor: color,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      padding: const EdgeInsets.symmetric(vertical: 15),
    );
  }
}
