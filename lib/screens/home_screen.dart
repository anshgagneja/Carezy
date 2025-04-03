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
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const HomeContent(),
    const MoodScreen(),
    const TaskScreen(),
    const ChatBotScreen(),
    const ProfileScreen(),
  ];

  void _onItemTapped(int index) async {
    setState(() {
      _selectedIndex = index;
    });

    // ✅ Refresh profile image when switching back to Home or Profile
    if (index == 0 || index == 4) {
      _screens[0] = const HomeContent();
      _screens[4] = const ProfileScreen();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black,
      child: Scaffold(
        backgroundColor: Colors.black,
        body: _screens[_selectedIndex],
        bottomNavigationBar: Container(
          decoration: const BoxDecoration(
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            color: Colors.black,
          ),
          clipBehavior: Clip.hardEdge,
          child: BottomNavigationBar(
            currentIndex: _selectedIndex,
            onTap: _onItemTapped,
            backgroundColor: Colors.black,
            selectedItemColor: Colors.deepPurpleAccent,
            unselectedItemColor: Colors.white60,
            elevation: 0,
            showUnselectedLabels: true,
            type: BottomNavigationBarType.fixed,
            items: const [
              BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
              BottomNavigationBarItem(
                  icon: Icon(Icons.emoji_emotions), label: 'Mood'),
              BottomNavigationBarItem(icon: Icon(Icons.task), label: 'Tasks'),
              BottomNavigationBarItem(
                  icon: Icon(Icons.smart_toy), label: 'Carezy Companion'),
              BottomNavigationBarItem(
                  icon: Icon(Icons.person), label: 'Profile'),
            ],
          ),
        ),
      ),
    );
  }
}

// 🔹 Main Home Content
class HomeContent extends StatefulWidget {
  const HomeContent({super.key});

  @override
  State<HomeContent> createState() => _HomeContentState();
}

class _HomeContentState extends State<HomeContent> {
  List<dynamic> _moodHistory = [];
  bool _isLoading = false;
  String? _profileImageUrl;

  @override
  void initState() {
    super.initState();
    _fetchProfileData();
    _fetchMoodHistory();
  }

  Future<void> _fetchProfileData() async {
    final profileData = await ProfileAPI.fetchProfile();
    if (profileData != null) {
      setState(() {
        _profileImageUrl = profileData["profile_image"];
      });
    }
  }

  void _fetchMoodHistory() async {
    setState(() => _isLoading = true);
    final moods = await MoodAPI.getMoodHistory();
    setState(() {
      _isLoading = false;
      _moodHistory = moods ?? [];
    });
  }

  String _getGreetingMessage() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return "Good Morning! ☀️";
    } else if (hour < 17) {
      return "Good Afternoon! 🌤️";
    } else {
      return "Good Evening! 🌙";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.black, Colors.black87],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 50),

            // 🔹 Greeting Section
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
                            color: Colors.white),
                      ),
                      const Text(
                        "Stay mindful & track your journey 🌿",
                        style: TextStyle(fontSize: 16, color: Colors.white70),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                GestureDetector(
                  onTap: () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const ProfileScreen()),
                    );
                    _fetchProfileData();
                  },
                  child: CircleAvatar(
                    radius: 30,
                    backgroundImage: _profileImageUrl != null
                        ? NetworkImage(
                            "$_profileImageUrl?t=${DateTime.now().millisecondsSinceEpoch}") // 🔥 Force Refresh
                        : const AssetImage("assets/images/profile_placeholder.png")
                            as ImageProvider,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // 🔥 Track Your Mood
            _buildFeatureTile(
              context,
              icon: Icons.bar_chart_rounded,
              title: "Track Your Mood",
              subtitle: "Log how you feel & monitor trends",
              onTap: () {
                Navigator.push(
                    context, MaterialPageRoute(builder: (context) => const MoodScreen()));
              },
              backgroundColor: Colors.grey.shade900,  // ✅ Darker background for contrast
               borderColor: Colors.deepPurpleAccent,  // ✅ Vibrant border
  shadowColor: Colors.deepPurpleAccent.withAlpha(80),
            ),

            const SizedBox(height: 20),

            // 🔥 Carezy Companion
            _buildFeatureTile(
              context,
              icon: Icons.smart_toy,
              title: "Carezy Companion",
              subtitle: "Daily Check-ins & AI chat support",
              onTap: () {
                Navigator.push(
                    context, MaterialPageRoute(builder: (context) => const ChatBotScreen()));
              },
              backgroundColor: Colors.deepPurple.withAlpha(50), // ✅ Replaced withAlpha()
            ),

            const SizedBox(height: 20),

            // 🔹 Mood Graph
            const Text("Your Mood Trends",
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white)),
            const SizedBox(height: 10),
            _isLoading
                ? const Center(child: CircularProgressIndicator(color: Colors.white))
                : MoodGraph(moodHistory: _moodHistory),

            const SizedBox(height: 20),

            // 🔹 Quick Tasks (Only Pending Tasks)
            const Text("Upcoming Tasks",
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white)),
            const SizedBox(height: 10),
            const QuickTasks(showCompleted: false),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureTile(BuildContext context,
      {required IconData icon,
      required String title,
      required String subtitle,
      required VoidCallback onTap,
      Color borderColor = Colors.transparent, // ✅ New Parameter
      Color shadowColor = Colors.transparent, // ✅ New Parameter
      Color backgroundColor = Colors.black}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            Icon(icon, size: 40, color: Colors.white),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white)),
                  Text(subtitle,
                      style: const TextStyle(color: Colors.white70, fontSize: 14)),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, size: 18, color: Colors.white70),
          ],
        ),
      ),
    );
  }
}
