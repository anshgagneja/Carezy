import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'mood_screen.dart';
import 'task_screen.dart';
import 'chat_bot_screen.dart';
import '../api/auth_api.dart';

class HomeScreen extends StatelessWidget {
  void logout(BuildContext context) async {
    await AuthAPI.logout();
    Navigator.pushReplacementNamed(context, '/login');
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
    return Scaffold(
      drawer: _buildDrawer(context),
      body: SafeArea(
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.deepPurple.shade900, Colors.deepPurple.shade500],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: Column(
            children: [
              // ✅ APP BAR (WITH MENU & LOGOUT)
              _buildAppBar(context),
              SizedBox(height: 15),

              // ✅ GREETING & QUOTE SECTION
              _buildGreetingCard(),

              SizedBox(height: 20),

              // ✅ FEATURE CARDS - STACKED VIEW
              Expanded(
                child: ListView(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  children: [
                    _buildFeatureCard(
                      context,
                      title: "Mood & Wellness",
                      icon: Icons.self_improvement_rounded,
                      subtitle: "Track your emotions & improve well-being",
                      image: "assets/images/mood.png",
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => MoodScreen()),
                      ),
                    ),
                    _buildFeatureCard(
                      context,
                      title: "Task Management",
                      icon: Icons.task_alt_rounded,
                      subtitle: "Stay organized with daily tasks",
                      image: "assets/images/tasks.png",
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => TaskScreen()),
                      ),
                    ),
                    _buildFeatureCard(
                      context,
                      title: "Carezy Assistant",
                      icon: Icons.chat_bubble_outline_rounded,
                      subtitle: "Your personal AI chat companion",
                      image: "assets/images/chatbot.png",
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => ChatBotScreen()),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => ChatBotScreen()),
          );
        },
        backgroundColor: Colors.deepPurpleAccent,
        child: Icon(Icons.chat_bubble_outline_rounded, color: Colors.white, size: 30),
        tooltip: "Carezy Assistant",
      ),
    );
  }

  // ✅ APP BAR WITH MENU & LOGOUT
  Widget _buildAppBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Builder(
            builder: (context) => IconButton(
              icon: Icon(Icons.menu, color: Colors.white),
              onPressed: () => Scaffold.of(context).openDrawer(),
            ),
          ),
          IconButton(
            icon: Icon(Icons.logout, color: Colors.white),
            onPressed: () => logout(context),
          ),
        ],
      ),
    );
  }

  // ✅ GREETING CARD (WITH QUOTE)
  Widget _buildGreetingCard() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16),
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.deepPurpleAccent.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white24, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _getGreetingMessage(),
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 8),
          Text(
            "“Your mental well-being is just as important as your physical health.”",
            style: TextStyle(
              fontSize: 14,
              color: Colors.white70,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }

  // ✅ FEATURE CARDS WITH IMAGE & ICON
  Widget _buildFeatureCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required String image,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.only(bottom: 16),
        padding: EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white24, width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 6,
              offset: Offset(2, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(15),
              child: Image.asset(
                image,
                width: 80,
                height: 80,
                fit: BoxFit.cover,
              ),
            ),
            SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 6),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ),
            Icon(icon, size: 28, color: Colors.white70),
          ],
        ),
      ),
    );
  }

  // ✅ DRAWER MENU
  Widget _buildDrawer(BuildContext context) {
    return Drawer(
      child: Container(
        color: Colors.deepPurple,
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.deepPurple, Colors.purpleAccent],
                ),
              ),
              child: Center(
                child: Text(
                  'Carezy Menu',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            ListTile(
              leading: Icon(Icons.home, color: Colors.white),
              title: Text('Home', style: TextStyle(color: Colors.white)),
              onTap: () => Navigator.pushNamed(context, '/home'),
            ),
            ListTile(
              leading: Icon(Icons.task, color: Colors.white),
              title: Text('Tasks', style: TextStyle(color: Colors.white)),
              onTap: () => Navigator.pushNamed(context, '/tasks'),
            ),
            ListTile(
              leading: Icon(Icons.logout, color: Colors.white),
              title: Text('Logout', style: TextStyle(color: Colors.white)),
              onTap: () => logout(context),
            ),
          ],
        ),
      ),
    );
  }
}
