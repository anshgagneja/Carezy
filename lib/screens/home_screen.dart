import 'package:flutter/material.dart';
import 'mood_screen.dart';
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
        title: Text("Home"),
        actions: [
          IconButton(icon: Icon(Icons.logout), onPressed: () => logout(context))
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("Welcome to Carezy!"),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => MoodScreen()));
              },
              child: Text("Track Your Mood"),
            ),
          ],
        ),
      ),
    );
  }
}
