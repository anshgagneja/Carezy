import 'package:flutter/material.dart';
import 'mood_screen.dart';
import 'task_screen.dart';
import '../api/auth_api.dart';

class HomeScreen extends StatelessWidget {
  void logout(BuildContext context) async {
    await AuthAPI.logout();
    Navigator.pushReplacementNamed(context, '/login');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Carezy Home", style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        elevation: 5,
        backgroundColor: Colors.deepPurple,
      ),
      drawer: Drawer(
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
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.deepPurple.shade100, Colors.deepPurple.shade50],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Welcome Header
              Text(
                "Welcome to Carezy!",
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.deepPurple,
                ),
              ),
              SizedBox(height: 10),
              Text(
                "Your mental health and productivity companion.",
                style: TextStyle(fontSize: 18, color: Colors.deepPurple.shade700),
              ),
              SizedBox(height: 20),

              // Features Grid
              GridView.count(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                children: [
                  _buildFeatureCard(
                    context,
                    title: "Mood & Wellness",
                    icon: Icons.self_improvement_rounded,
                    gradientColors: [Colors.purpleAccent, Colors.deepPurple],
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => MoodScreen()),
                    ),
                  ),
                  _buildFeatureCard(
                    context,
                    title: "Task Management",
                    icon: Icons.task_alt_rounded,
                    gradientColors: [Colors.teal, Colors.cyan],
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => TaskScreen()),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Function to build fancy feature cards
  Widget _buildFeatureCard(
    BuildContext context, {
    required String title,
    required IconData icon,
    required List<Color> gradientColors,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: gradientColors.last.withOpacity(0.4),
              blurRadius: 10,
              offset: Offset(0, 6),
            ),
          ],
          gradient: LinearGradient(
            colors: gradientColors,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, size: 40, color: Colors.white),
                SizedBox(height: 10),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
