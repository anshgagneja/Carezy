import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../api/auth_api.dart';
import '../api/profile_api.dart';
import 'forgot_password_screen.dart';
import 'home_screen.dart'; // ✅ Import HomeScreen

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  File? _profileImage;
  final ImagePicker _picker = ImagePicker();
  String userName = "Loading...";
  String userEmail = "Loading...";
  String? profileImageUrl;
  bool isLoading = true;
  bool isUploading = false;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    final profileData = await ProfileAPI.fetchProfile();
    if (profileData != null) {
      setState(() {
        userName = profileData["name"] ?? "No Name";
        userEmail = profileData["email"] ?? "No Email";
        profileImageUrl = profileData["profile_image"];
        isLoading = false;
      });
    } else {
      setState(() {
        userName = "User not found";
        userEmail = "No Email";
        isLoading = false;
      });
    }
  }

  Future<void> _pickAndUploadImage() async {
    if (isUploading) return;
    isUploading = true;

    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      File imageFile = File(pickedFile.path);
      setState(() {
        _profileImage = imageFile;
      });

      final uploadedImageUrl = await ProfileAPI.uploadProfileImage(imageFile);

      if (uploadedImageUrl != null) {
        setState(() {
          profileImageUrl = uploadedImageUrl;
        });
      }
    }

    isUploading = false;
  }

  void logout(BuildContext context) async {
    await AuthAPI.logout();
    Navigator.pushReplacementNamed(context, '/login');
  }

  void navigateToForgotPassword(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ForgotPasswordScreen()),
    );
  }

  void navigateToHome(BuildContext context) {
    if (Navigator.canPop(context)) {
      Navigator.pop(context); // ✅ Go back if possible (Fixes bottom navbar issue)
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HomeScreen()),
      ); // ✅ Ensure HomeScreen is shown if no back stack exists
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => navigateToHome(context), // ✅ Always navigates to HomeScreen
        ),
        title: Text("Profile", style: TextStyle(color: Colors.white)),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.black, Colors.black87],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(height: 20),
                GestureDetector(
                  onTap: _pickAndUploadImage,
                  child: Stack(
                    alignment: Alignment.bottomRight,
                    children: [
                      CircleAvatar(
                        radius: 60,
                        backgroundColor: Colors.white,
                        backgroundImage: profileImageUrl != null
                            ? NetworkImage(
                                "$profileImageUrl?t=${DateTime.now().millisecondsSinceEpoch}")
                            : AssetImage('assets/images/avatar.png')
                                as ImageProvider,
                      ),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.deepPurpleAccent,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(color: Colors.black26, blurRadius: 3)
                          ],
                        ),
                        padding: EdgeInsets.all(6),
                        child: Icon(Icons.camera_alt,
                            color: Colors.white, size: 22),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 20),
                Card(
                  elevation: 10,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20)),
                  color: Colors.white.withOpacity(0.1),
                  margin: EdgeInsets.symmetric(horizontal: 30),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        isLoading
                            ? CircularProgressIndicator(color: Colors.white)
                            : Column(
                                children: [
                                  Text(userName,
                                      style: TextStyle(
                                          fontSize: 22,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white)),
                                  SizedBox(height: 5),
                                  Text(userEmail,
                                      style: TextStyle(
                                          fontSize: 16, color: Colors.white70)),
                                ],
                              ),
                        SizedBox(height: 15),
                        Divider(color: Colors.white30),
                        _buildProfileOption(
                            Icons.lock, "Change Password", () {
                          navigateToForgotPassword(context);
                        }),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 30),
                ElevatedButton.icon(
                  onPressed: () => logout(context),
                  icon: Icon(Icons.exit_to_app, color: Colors.white),
                  label: Text("Logout",
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.redAccent,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(horizontal: 40, vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileOption(IconData icon, String title, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: Colors.white),
      title: Text(title, style: TextStyle(fontSize: 16, color: Colors.white)),
      trailing: Icon(Icons.arrow_forward_ios, color: Colors.white54, size: 16),
      onTap: onTap,
    );
  }
}
