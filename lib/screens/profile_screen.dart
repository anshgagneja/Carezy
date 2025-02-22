import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../api/auth_api.dart';
import '../api/profile_api.dart';

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
  bool isLoading = true; // ✅ Added loading state

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  // 🔹 Fetch Profile Data
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

  // 📷 Pick and Upload Image
  bool isUploading = false; // ✅ Prevent multiple uploads

  Future<void> _pickAndUploadImage() async {
    if (isUploading) return; // ✅ Prevent multiple taps
    isUploading = true;

    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      File imageFile = File(pickedFile.path);
      setState(() {
        _profileImage = imageFile;
      });

      print("📤 Uploading Image...");

      // Upload image to backend
      final uploadedImageUrl = await ProfileAPI.uploadProfileImage(imageFile);

      if (uploadedImageUrl != null) {
        setState(() {
          profileImageUrl = uploadedImageUrl;
        });
        print("✅ Image Uploaded: $uploadedImageUrl");
      } else {
        print("❌ Image Upload Failed");
      }
    }

    isUploading = false; // ✅ Reset flag after upload
  }

  // 🔹 Logout Function
  void logout(BuildContext context) async {
    await AuthAPI.logout();
    Navigator.pushReplacementNamed(context, '/login');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
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
                SizedBox(height: 40),
                // 🔹 Profile Picture with Proper Error Handling
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
                                "$profileImageUrl?t=${DateTime.now().millisecondsSinceEpoch}") // 🔥 Force Refresh
                            : AssetImage('assets/images/avatar.png')
                                as ImageProvider,
                        onBackgroundImageError: (_, __) {
                          print("❌ Image Load Error - Using default avatar");
                          setState(() {
                            profileImageUrl = null; // Reset to default avatar
                          });
                        },
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
                        _buildProfileOption(Icons.person, "Edit Profile"),
                        _buildProfileOption(Icons.lock, "Change Password"),
                        _buildProfileOption(Icons.settings, "Settings"),
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

  Widget _buildProfileOption(IconData icon, String title) {
    return ListTile(
      leading: Icon(icon, color: Colors.white),
      title: Text(title, style: TextStyle(fontSize: 16, color: Colors.white)),
      trailing: Icon(Icons.arrow_forward_ios, color: Colors.white54, size: 16),
    );
  }
}
