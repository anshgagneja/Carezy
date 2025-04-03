import 'package:flutter/material.dart';
import 'package:carezy/screens/mood_screen.dart';
import 'package:carezy/screens/task_screen.dart';
import 'package:carezy/screens/chat_bot_screen.dart';
import 'package:carezy/screens/profile_screen.dart';
import '../api/profile_api.dart';
import '../api/mood_api.dart';
import 'package:carezy/widgets/mood_graph.dart';
import 'package:carezy/widgets/quick_tasks.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key}); 

  @override
  HomeScreenState createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  
  final List<Widget> _screens = [
    const HomeContent(),
    const MoodScreen(),
    const TaskScreen(),
    ChatBotScreen(),
    const ProfileScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    if (index == 4) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const ProfileScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        backgroundColor: Colors.black,
        selectedItemColor: Colors.deepPurpleAccent,
        unselectedItemColor: Colors.white60,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.emoji_emotions), label: 'Mood'),
          BottomNavigationBarItem(icon: Icon(Icons.task), label: 'Tasks'),
          BottomNavigationBarItem(icon: Icon(Icons.smart_toy), label: 'Carezy Companion'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}

class HomeContent extends StatefulWidget {
  const HomeContent({super.key}); // Added 'key' parameter

   @override
  HomeContentState createState() => HomeContentState();
}

class HomeContentState extends State<HomeContent> {
  List<dynamic> moodHistory = [];
  bool isLoading = false;
  String? profileImageUrl;

  @override
  void initState() {
    super.initState();
    fetchProfileData();
    fetchMoodHistory();
  }

  Future<void> fetchProfileData() async {
    final profileData = await ProfileAPI.fetchProfile();
    if (profileData != null) {
      setState(() {
        profileImageUrl = profileData["profile_image"];
      });
    }
  }

  Future<void> fetchMoodHistory() async {
    setState(() => isLoading = true);
    final moods = await MoodAPI.getMoodHistory();
    setState(() {
      isLoading = false;
      moodHistory = moods ?? [];
    });
  }

  String _getGreetingMessage() {
    final hour = DateTime.now().hour;
    if (hour < 12) return "Good Morning! ☀️";
    if (hour < 17) return "Good Afternoon! 🌤️";
    return "Good Evening! 🌙";
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.black, Colors.black87],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 50),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _getGreetingMessage(),
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const Text(
                        "Stay mindful & track your journey 🌿",
                        style: TextStyle(fontSize: 16, color: Colors.white70),
                      ),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const ProfileScreen()),
                    );
                    fetchProfileData();
                  },
                  child: CircleAvatar(
                    radius: 30,
                    backgroundImage: profileImageUrl != null
                        ? NetworkImage("$profileImageUrl?t=${DateTime.now().millisecondsSinceEpoch}")
                        : const AssetImage("assets/images/profile_placeholder.png") as ImageProvider,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            GestureDetector(
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const MoodScreen())),
              child: _buildFeatureCard(
                icon: Icons.bar_chart_rounded,
                title: "Track Your Mood",
                subtitle: "Log how you feel & monitor trends",
              ),
            ),
            const SizedBox(height: 20),
            GestureDetector(
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => ChatBotScreen())),
              child: _buildFeatureCard(
                icon: Icons.smart_toy,
                title: "Carezy Companion",
                subtitle: "Daily Check-ins & AI chat support",
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              "Your Mood Trends",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            const SizedBox(height: 10),
            isLoading
                ? const Center(child: CircularProgressIndicator(color: Colors.white))
                : MoodGraph(moodHistory: moodHistory),
            const SizedBox(height: 20),
            QuickTasks(),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureCard({required IconData icon, required String title, required String subtitle}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade900,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.deepPurpleAccent, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.deepPurpleAccent.withAlpha(50), // Replaced 'withOpacity'
            blurRadius: 8,
            offset: const Offset(2, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(icon, size: 30, color: Colors.deepPurpleAccent),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                Text(subtitle, style: const TextStyle(color: Colors.white70, fontSize: 14)),
              ],
            ),
          ),
          const Icon(Icons.arrow_forward_ios, size: 18, color: Colors.white70),
        ],
      ),
    );
  }
}
