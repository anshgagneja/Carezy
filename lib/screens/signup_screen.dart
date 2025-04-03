import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import '../api/auth_api.dart';
import 'login_screen.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key}); // ✅ Used super.key

  @override
  SignupScreenState createState() => SignupScreenState(); // ✅ Public class
}

class SignupScreenState extends State<SignupScreen> { // ✅ Made public
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();
  bool isLoading = false;

  // 🛑 Email Validation Function
  bool isValidEmail(String email) {
    return RegExp(r"^[^@]+@[^@]+\.[^@]+").hasMatch(email);
  }

  // 🔒 Password Validation Function
  bool isValidPassword(String password) {
    return password.length >= 6 &&
        RegExp(r'[0-9]').hasMatch(password) && // At least 1 number
        RegExp(r'[A-Za-z]').hasMatch(password) && // At least 1 letter
        RegExp(r'[!@#\$%^&*(),.?":{}|<>]').hasMatch(password); // At least 1 special character
  }

  // 🚀 Signup Function
  void signup() async {
    String name = nameController.text.trim();
    String email = emailController.text.trim();
    String password = passwordController.text.trim();
    String confirmPassword = confirmPasswordController.text.trim();

    if (name.isEmpty || email.isEmpty || password.isEmpty || confirmPassword.isEmpty) {
      showSnackBar("❌ All fields are required!");
      return;
    }

    if (!isValidEmail(email)) {
      showSnackBar("❌ Please enter a valid email address!");
      return;
    }

    if (!isValidPassword(password)) {
      showSnackBar("❌ Password must be at least 6 characters long and contain at least 1 letter, 1 number, and 1 special character!");
      return;
    }

    if (password != confirmPassword) {
      showSnackBar("❌ Passwords do not match!");
      return;
    }

    setState(() => isLoading = true);

    try {
      final success = await AuthAPI.signup(name, email, password);
      
      if (!mounted) return;
      setState(() => isLoading = false);

      if (success?['token'] != null) {
        showSnackBar("✅ Account created successfully! Please login.");
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => LoginScreen()),
        );
      } else {
        String errorMessage = success?['message'] ?? "Signup failed. Please try again.";
        showSnackBar("❌ $errorMessage");
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => isLoading = false);
      showSnackBar("❌ An error occurred: $e");
    }
  }

  // 🍔 Snackbar Function
  void showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), duration: const Duration(seconds: 3)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // 🎨 Gradient Background
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF1A1A2E), Color(0xFF16213E)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),

          // 🎬 Neon Glow Animation
          Positioned(
            top: -50,
            left: -50,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.blueAccent.withAlpha(77), // ✅ Replaced withAlpha()
                    blurRadius: 150,
                    spreadRadius: 50,
                  ),
                ],
              ),
            ),
          ),

          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 25),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // 🔹 Lottie Animation
                  Lottie.asset(
                    'assets/animations/signup.json',
                    width: 180,
                    height: 180,
                  ),
                  const SizedBox(height: 20),

                  // 🏆 Signup Form Card
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white.withAlpha(25), // ✅ Replaced withAlpha()
                      borderRadius: BorderRadius.circular(25),
                      border: Border.all(color: Colors.white.withAlpha(77)), // ✅ Fixed transparency
                      boxShadow: [
                        BoxShadow(
                          color: Colors.blueAccent.withAlpha(51), // ✅ Fixed transparency
                          blurRadius: 20,
                          spreadRadius: 3,
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          "Create Account",
                          style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            letterSpacing: 1.2,
                          ),
                        ),
                        const SizedBox(height: 20),

                        // 📝 Name Field
                        _buildTextField(nameController, "Name", Icons.person),
                        const SizedBox(height: 12),

                        // 📧 Email Field
                        _buildTextField(emailController, "Email", Icons.email),
                        const SizedBox(height: 12),

                        // 🔒 Password Field
                        _buildTextField(passwordController, "Password", Icons.lock, isPassword: true),
                        const SizedBox(height: 12),

                        // 🔄 Confirm Password Field
                        _buildTextField(confirmPasswordController, "Confirm Password", Icons.lock_outline, isPassword: true),
                        const SizedBox(height: 20),

                        // 🚀 Signup Button
                        isLoading
                            ? const CircularProgressIndicator(color: Colors.white)
                            : ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.blueAccent,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 14),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(25),
                                  ),
                                  elevation: 8,
                                  shadowColor: Colors.blueAccent.withAlpha(127), // ✅ Fixed transparency
                                ),
                                onPressed: signup,
                                child: const Text(
                                  "Sign Up",
                                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                ),
                              ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 12),

                  // 🔄 Navigate to Login
                  GestureDetector(
                    onTap: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => LoginScreen()),
                      );
                    },
                    child: const Text(
                      "Already have an account? Login",
                      style: TextStyle(
                        color: Colors.blueAccent,
                        fontSize: 16,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 🔹 Custom TextField Widget
  Widget _buildTextField(TextEditingController controller, String hint, IconData icon, {bool isPassword = false}) {
    return TextField(
      controller: controller,
      obscureText: isPassword,
      style: const TextStyle(color: Colors.white, fontSize: 16),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.white70),
        filled: true,
        fillColor: Colors.white.withAlpha(25), // ✅ Fixed transparency
        prefixIcon: Icon(icon, color: Colors.blueAccent),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
        contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
      ),
    );
  }
}
