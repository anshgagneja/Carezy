import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../api/mood_api.dart';

class MusicScreen extends StatefulWidget {
  final String mood;
  const MusicScreen({super.key, required this.mood}); // ✅ Use super.key

  @override
  State<MusicScreen> createState() => _MusicScreenState();
}

class _MusicScreenState extends State<MusicScreen> {
  Map<String, dynamic>? song;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchMusic();
  }

  Future<void> fetchMusic() async {
    try {
      final musicData = await MoodAPI.getMusicSuggestion(widget.mood);
      if (!mounted) return; // ✅ Prevent setState() if widget is disposed
      setState(() {
        song = musicData;
        isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("❌ Error fetching music suggestion.")),
      );
    }
  }

  Future<void> openYouTube() async {
    if (song == null || song!['videoId'] == null) {
      _showSnackBar("❌ No video available to play.");
      return;
    }
    final Uri url = Uri.parse("https://www.youtube.com/watch?v=${song!['videoId']}");

    try {
      if (await canLaunchUrl(url)) {
        await launchUrl(url, mode: LaunchMode.externalApplication);
      } else {
        throw "Cannot launch URL";
      }
    } catch (e) {
      _showSnackBar("❌ Error opening YouTube: $e");
    }
  }

  void _showSnackBar(String message) {
    if (!mounted) return; // ✅ Prevent using BuildContext across async gaps
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text("🎵 Music for ${widget.mood} Mood"),
        backgroundColor: Colors.black,
        elevation: 0,
        centerTitle: true,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.black, Colors.black87],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: isLoading
              ? _buildLoadingPlaceholder()
              : song == null
                  ? _buildErrorMessage()
                  : _buildMusicCard(),
        ),
      ),
    );
  }

  Widget _buildLoadingPlaceholder() {
    return Container(
      width: 250,
      height: 250,
      decoration: BoxDecoration(
        color: Colors.grey[800],
        borderRadius: BorderRadius.circular(15),
      ),
      child: const Center(child: CircularProgressIndicator(color: Colors.white)),
    );
  }

  Widget _buildErrorMessage() {
    return const Text(
      "No music suggestions found.",
      style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
    );
  }

  Widget _buildMusicCard() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(15),
            child: Image.network(
              song!['thumbnail'] ?? "https://via.placeholder.com/250",
              width: 250,
              errorBuilder: (context, error, stackTrace) => const Icon(
                Icons.music_note,
                size: 100,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(height: 20),
          Card(
            elevation: 10,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            color: Colors.white.withAlpha(38), // ✅ Replaced .withOpacity(0.15)
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Text(
                    song!['title'] ?? "No Title Available",
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    song!['hashtags'] ?? "",
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 16, color: Colors.white70),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: openYouTube,
            icon: const Icon(Icons.play_arrow, color: Colors.white),
            label: const Text("Play on YouTube"),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
              textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}
