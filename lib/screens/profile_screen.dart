import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../api/auth_api.dart';
import '../api/profile_api.dart';
import 'forgot_password_screen.dart';
import 'home_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key}); // ✅ Use super.key for constructor

  @override
  State<ProfileScreen> createState() => ProfileScreenState(); // ✅ Make it public
}

class ProfileScreenState extends State<ProfileScreen> { // ✅ Made public
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
    final Map<String, dynamic>? profileData = await ProfileAPI.fetchProfile();

    setState(() {
      userName = profileData?["name"] ?? "No Name";
      userEmail = profileData?["email"] ?? "No Email";
      profileImageUrl = profileData?["profile_image"];
      isLoading = false;
    });
  }

  Future<void> _pickAndUploadImage() async {
    if (isUploading) return;
    setState(() => isUploading = true);

    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      final uploadedImageUrl =
          await ProfileAPI.uploadProfileImage(File(pickedFile.path));
      if (uploadedImageUrl != null) {
        setState(() => profileImageUrl = uploadedImageUrl);
      }
    }
    setState(() => isUploading = false);
  }

  void logout() async {
    await AuthAPI.logout();
    if (mounted) {
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  void navigateToForgotPassword() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) =>  ForgotPasswordScreen()), // ✅ Add const
    );
  }

  void navigateToHome() {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const HomeScreen()),
      (route) => false, // Removes all previous routes, ensuring it goes directly to HomeScreen
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: navigateToHome,
        ),
        title: const Text("Profile", style: TextStyle(color: Colors.white)),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
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
                const SizedBox(height: 20),
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
                            : const AssetImage('assets/images/avatar.png')
                                as ImageProvider,
                      ),
                      Container(
                        decoration: const BoxDecoration(
                          color: Colors.deepPurpleAccent,
                          shape: BoxShape.circle,
                          boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 3)],
                        ),
                        padding: const EdgeInsets.all(6),
                        child: const Icon(Icons.camera_alt, color: Colors.white, size: 22),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Card(
                  elevation: 10,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  color: Colors.white.withAlpha(26),
                  margin: const EdgeInsets.symmetric(horizontal: 30),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        isLoading
                            ? const CircularProgressIndicator(color: Colors.white)
                            : Column(
                                children: [
                                  Text(userName,
                                      style: const TextStyle(
                                          fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
                                  const SizedBox(height: 5),
                                  Text(userEmail,
                                      style: const TextStyle(fontSize: 16, color: Colors.white70)),
                                ],
                              ),
                        const SizedBox(height: 15),
                        const Divider(color: Colors.white30),
                        _buildProfileOption(Icons.lock, "Change Password", navigateToForgotPassword),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 30),
                ElevatedButton.icon(
                  onPressed: logout,
                  icon: const Icon(Icons.exit_to_app, color: Colors.white),
                  label: const Text("Logout", style: TextStyle(fontWeight: FontWeight.bold)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.redAccent,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
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
      title: Text(title, style: const TextStyle(fontSize: 16, color: Colors.white)),
      trailing: const Icon(Icons.arrow_forward_ios, color: Colors.white54, size: 16),
      onTap: onTap,
    );
  }
}
