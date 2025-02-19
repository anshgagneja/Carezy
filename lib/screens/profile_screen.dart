import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../api/auth_api.dart';

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  File? _profileImage;
  final ImagePicker _picker = ImagePicker();
  String userName = "Ansh Gagneja"; // Fetch from backend later
  String userEmail = "ansh@example.com"; // Fetch from backend later

  // 📷 Pick image from gallery
  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _profileImage = File(pickedFile.path);
      });
    }
  }

  // 🔹 Logout Function
  void logout(BuildContext context) async {
    await AuthAPI.logout();
    Navigator.pushReplacementNamed(context, '/login');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, // 🔥 Sleek Dark Mode
      body: Stack(
        children: [
          // 🔹 Gradient Background
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.black, Colors.black87],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),

          // 🔹 Profile Content
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(height: 40),

                // 🔹 Profile Picture
                GestureDetector(
                  onTap: _pickImage,
                  child: Stack(
                    alignment: Alignment.bottomRight,
                    children: [
                      CircleAvatar(
                        radius: 60,
                        backgroundColor: Colors.white,
                        backgroundImage: _profileImage != null
                            ? FileImage(_profileImage!)
                            : AssetImage('assets/images/avatar.png') as ImageProvider,
                      ),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.deepPurpleAccent,
                          shape: BoxShape.circle,
                          boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 3)],
                        ),
                        padding: EdgeInsets.all(6),
                        child: Icon(Icons.camera_alt, color: Colors.white, size: 22),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 20),

                // 🔹 User Info Card
                Card(
                  elevation: 10,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  color: Colors.white.withOpacity(0.1), // Glass effect
                  margin: EdgeInsets.symmetric(horizontal: 30),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        Text(userName,
                            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
                        SizedBox(height: 5),
                        Text(userEmail, style: TextStyle(fontSize: 16, color: Colors.white70)),
                        SizedBox(height: 15),
                        Divider(color: Colors.white30),

                        // 🔹 Profile Actions
                        _buildProfileOption(Icons.person, "Edit Profile"),
                        _buildProfileOption(Icons.lock, "Change Password"),
                        _buildProfileOption(Icons.settings, "Settings"),
                      ],
                    ),
                  ),
                ),

                SizedBox(height: 30),

                // 🔹 Logout Button
                ElevatedButton.icon(
                  onPressed: () => logout(context),
                  icon: Icon(Icons.exit_to_app, color: Colors.white),
                  label: Text("Logout", style: TextStyle(fontWeight: FontWeight.bold)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.redAccent,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(horizontal: 40, vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    shadowColor: Colors.redAccent.withOpacity(0.5),
                    elevation: 8,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 🔹 Profile Option Widget
  Widget _buildProfileOption(IconData icon, String title) {
    return ListTile(
      leading: Icon(icon, color: Colors.white),
      title: Text(title, style: TextStyle(fontSize: 16, color: Colors.white)),
      trailing: Icon(Icons.arrow_forward_ios, color: Colors.white54, size: 16),
      onTap: () {},
    );
  }
}
