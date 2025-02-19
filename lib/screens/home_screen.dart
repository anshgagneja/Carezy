import 'package:flutter/material.dart';
import 'package:carezy/screens/mood_screen.dart';
import 'package:carezy/screens/task_screen.dart';
import 'package:carezy/screens/chat_bot_screen.dart';
import 'package:carezy/screens/profile_screen.dart';
import '../api/mood_api.dart';
import 'package:carezy/widgets/mood_graph.dart';
import 'package:carezy/widgets/quick_tasks.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    HomeContent(),
    MoodScreen(),
    TaskScreen(),
    ChatBotScreen(), // Carezy Companion
    ProfileScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black, // 🔹 Ensures full black background
      child: Scaffold(
        backgroundColor: Colors.black, // 🔹 Matches background with navbar
        body: _screens[_selectedIndex],
        bottomNavigationBar: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            color: Colors.black, // 🔹 Matches screen background
          ),
          clipBehavior: Clip.hardEdge, // 🔹 Prevents white leaks at rounded corners
          child: BottomNavigationBar(
            currentIndex: _selectedIndex,
            onTap: _onItemTapped,
            backgroundColor: Colors.black, // 🔹 Matches background
            selectedItemColor: Colors.deepPurpleAccent,
            unselectedItemColor: Colors.white60,
            elevation: 0, // 🔹 No extra shadows
            showUnselectedLabels: true,
            type: BottomNavigationBarType.fixed,
            items: const [
              BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
              BottomNavigationBarItem(icon: Icon(Icons.emoji_emotions), label: 'Mood'),
              BottomNavigationBarItem(icon: Icon(Icons.task), label: 'Tasks'),
              BottomNavigationBarItem(icon: Icon(Icons.smart_toy), label: 'Carezy Companion'),
              BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
            ],
          ),
        ),
      ),
    );
  }
}

// 🔹 Main Home Content
class HomeContent extends StatefulWidget {
  @override
  _HomeContentState createState() => _HomeContentState();
}

class _HomeContentState extends State<HomeContent> {
  List<dynamic> moodHistory = [];
  bool isLoading = false;

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
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.black, Colors.black87],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 50),

            // 🔹 Greeting Section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _getGreetingMessage(),
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                    Text(
                      "Stay mindful & track your journey 🌿",
                      style: TextStyle(fontSize: 16, color: Colors.white70),
                    ),
                  ],
                ),
                CircleAvatar(
                  radius: 30,
                  backgroundImage: AssetImage("assets/images/profile_placeholder.png"),
                ),
              ],
            ),

            SizedBox(height: 20),

            // 🔥 Track Your Mood
            GestureDetector(
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => MoodScreen()));
              },
              child: Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade900,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.deepPurpleAccent, width: 1),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.deepPurpleAccent.withOpacity(0.2),
                      blurRadius: 8,
                      offset: Offset(2, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Icon(Icons.bar_chart_rounded, size: 30, color: Colors.deepPurpleAccent),
                    SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Track Your Mood",
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                          ),
                          Text(
                            "Log how you feel & monitor trends",
                            style: TextStyle(color: Colors.white70, fontSize: 14),
                          ),
                        ],
                      ),
                    ),
                    Icon(Icons.arrow_forward_ios, size: 18, color: Colors.white70),
                  ],
                ),
              ),
            ),

            SizedBox(height: 20),

            // 🔥 Carezy Companion
            GestureDetector(
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => ChatBotScreen()));
              },
              child: Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.deepPurple.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    Icon(Icons.smart_toy, size: 40, color: Colors.white),
                    SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Carezy Companion",
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                          ),
                          Text(
                            "Daily Check-ins & AI chat support",
                            style: TextStyle(color: Colors.white70, fontSize: 14),
                          ),
                        ],
                      ),
                    ),
                    Icon(Icons.arrow_forward_ios, size: 18, color: Colors.white70),
                  ],
                ),
              ),
            ),

            SizedBox(height: 20),

            // 🔹 Mood Graph
            Text("Your Mood Trends", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
            SizedBox(height: 10),
            isLoading ? Center(child: CircularProgressIndicator(color: Colors.white)) : MoodGraph(moodHistory: moodHistory),

            SizedBox(height: 20),

            // 🔹 Quick Tasks (Only Pending Tasks)
            Text("Upcoming Tasks", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
            SizedBox(height: 10),
            QuickTasks(showCompleted: false), // ✅ Only Pending Tasks

            SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}
