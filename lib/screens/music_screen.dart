import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../api/mood_api.dart';

class MusicScreen extends StatefulWidget {
  final String mood;
  MusicScreen({required this.mood});

  @override
  _MusicScreenState createState() => _MusicScreenState();
}

class _MusicScreenState extends State<MusicScreen> {
  Map<String, dynamic>? song;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchMusic();
  }

  void fetchMusic() async {
  try {
    final musicData = await MoodAPI.getMusicSuggestion(widget.mood);
    print("Music API Response: $musicData"); // Log API response
    setState(() {
      song = musicData;
      isLoading = false;
    });
  } catch (e) {
    setState(() {
      isLoading = false;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("❌ Error fetching music suggestion.")),
    );
  }
}

  void openYouTube() async {
    if (song != null && song!['videoId'] != null) {
      final Uri url = Uri.parse("https://www.youtube.com/watch?v=${song!['videoId']}");
      if (await canLaunchUrl(url)) {
        await launchUrl(url, mode: LaunchMode.externalApplication);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("❌ Error opening YouTube")),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("❌ No video available to play.")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Music for ${widget.mood} Mood"),
        backgroundColor: Colors.purple,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.purple.shade800, Colors.purple.shade200],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: isLoading
              ? CircularProgressIndicator(color: Colors.white)
              : song == null
                  ? Text(
                      "No music suggestions found.",
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    )
                  : Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (song!['thumbnail'] != null)
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.network(
                              song!['thumbnail'],
                              width: 250,
                              errorBuilder: (context, error, stackTrace) => Icon(
                                Icons.music_note,
                                size: 100,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        SizedBox(height: 20),
                        Text(
                          song!['title'] ?? "No Title Available",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(height: 10),
                        Text(
                          song!['hashtags'] ?? "",
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 14, color: Colors.white70),
                        ),
                        SizedBox(height: 20),
                        ElevatedButton.icon(
                          onPressed: openYouTube,
                          icon: Icon(Icons.play_arrow, color: Colors.white),
                          label: Text("Play on YouTube"),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            padding: EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                          ),
                        ),
                      ],
                    ),
        ),
      ),
    );
  }
}
