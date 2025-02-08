import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import '../api/auth_api.dart';
import 'login_screen.dart';

class SignupScreen extends StatefulWidget {
  @override
  _SignupScreenState createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();
  bool isLoading = false;

  void signup() async {
    if (passwordController.text != confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("❌ Passwords do not match!")),
      );
      return;
    }

    setState(() => isLoading = true);

    final success = await AuthAPI.signup(
      nameController.text,
      emailController.text,
      passwordController.text,
    );

    setState(() => isLoading = false);

    if (success != null && success['token'] != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("✅ Account created successfully! Please login.")),
      );
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LoginScreen()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("❌ Signup failed. Please try again.")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Gradient Background
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.teal.shade100, Colors.teal.shade50],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),

          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Lottie Animation
                  Lottie.asset(
                    'assets/animations/signup.json',
                    width: 150,
                    height: 150,
                  ),
                  SizedBox(height: 20),

                  // Signup Form Card
                  Card(
                    elevation: 10,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    color: Colors.white, // Light background inside the card
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            "Create Account",
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.teal.shade900,
                            ),
                          ),
                          SizedBox(height: 20),

                          // Name Field
                          TextField(
                            controller: nameController,
                            decoration: InputDecoration(
                              labelText: "Name",
                              prefixIcon: Icon(Icons.person, color: Colors.teal.shade700),
                              filled: true,
                              fillColor: Colors.teal.shade50,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide.none,
                              ),
                            ),
                          ),
                          SizedBox(height: 10),

                          // Email Field
                          TextField(
                            controller: emailController,
                            decoration: InputDecoration(
                              labelText: "Email",
                              prefixIcon: Icon(Icons.email, color: Colors.teal.shade700),
                              filled: true,
                              fillColor: Colors.teal.shade50,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide.none,
                              ),
                            ),
                          ),
                          SizedBox(height: 10),

                          // Password Field
                          TextField(
                            controller: passwordController,
                            decoration: InputDecoration(
                              labelText: "Password",
                              prefixIcon: Icon(Icons.lock, color: Colors.teal.shade700),
                              filled: true,
                              fillColor: Colors.teal.shade50,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide.none,
                              ),
                            ),
                            obscureText: true,
                          ),
                          SizedBox(height: 10),

                          // Confirm Password Field
                          TextField(
                            controller: confirmPasswordController,
                            decoration: InputDecoration(
                              labelText: "Confirm Password",
                              prefixIcon: Icon(Icons.lock_outline, color: Colors.teal.shade700),
                              filled: true,
                              fillColor: Colors.teal.shade50,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide.none,
                              ),
                            ),
                            obscureText: true,
                          ),
                          SizedBox(height: 20),

                          // Signup Button
                          isLoading
                              ? CircularProgressIndicator()
                              : ElevatedButton(
                                  onPressed: signup,
                                  child: Text("Sign Up"),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.teal.shade700,
                                    foregroundColor: Colors.white,
                                    padding: EdgeInsets.symmetric(horizontal: 40, vertical: 12),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                  ),
                                ),
                        ],
                      ),
                    ),
                  ),

                  SizedBox(height: 10),

                  // Navigate to Login
                  GestureDetector(
                    onTap: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => LoginScreen()),
                      );
                    },
                    child: Text(
                      "Already have an account? Login",
                      style: TextStyle(
                        color: Colors.teal.shade800,
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
}
