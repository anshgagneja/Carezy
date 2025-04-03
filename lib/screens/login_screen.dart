import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import '../api/auth_api.dart';
import 'signup_screen.dart';
import 'home_screen.dart';
import 'forgot_password_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key}); // ✅ Correct usage of super.key

  @override
  LoginScreenState createState() => LoginScreenState(); // ✅ Made state class public
}

class LoginScreenState extends State<LoginScreen>{
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool isLoading = false;
  bool isPasswordVisible = false; // 👁 Password visibility toggle

  void login() async {
  final email = emailController.text.trim();
  final password = passwordController.text.trim();

  if (email.isEmpty || password.isEmpty) {
    if (!mounted) return; // ✅ Check before using 'context'
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("❌ Please enter both email and password.")),
    );
    return;
  }

  setState(() => isLoading = true);
  final success = await AuthAPI.login(email, password);
  
  if (!mounted) return; // ✅ Check again after async call

  setState(() => isLoading = false);

  if (success) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => HomeScreen()),
    );
  } else {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("❌ Invalid email or password. Please try again.")),
    );
  }
}

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(), // 🔹 Dismiss keyboard on tap
      child: Scaffold(
        body: Stack(
          children: [
            // 🔹 Background Gradient
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF000000), Color(0xFF121212)],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),

            // 🔹 Glowing Light Effect
            Positioned(
              top: -100,
              left: -50,
              child: Container(
                width: 300,
                height: 300,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      const Color.fromARGB(51, 0, 128, 255), // ✅ Replaced with ARGB
                      Colors.transparent
                    ],
                  ),
                ),
              ),
            ),

            Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // 🔹 Lottie Animation with Error Handling
                    Lottie.asset(
                      'assets/animations/login.json',
                      width: 170,
                      height: 170,
                      errorBuilder: (context, error, stackTrace) {
                        return const Icon(Icons.error, size: 100, color: Colors.red);
                      },
                    ),
                    const SizedBox(height: 10),

                    // 🔹 Glassmorphic Login Card
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: const Color.fromARGB(25, 255, 255, 255), // ✅ Replaced with ARGB
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: const Color.fromARGB(51, 255, 255, 255)),
                        boxShadow: [
                          BoxShadow(
                            color: const Color.fromARGB(77, 0, 128, 255), // ✅ Replaced with ARGB
                            blurRadius: 15,
                            spreadRadius: 5,
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          const Text(
                            "Welcome Back",
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              letterSpacing: 1.5,
                            ),
                          ),
                          const SizedBox(height: 10),
                          const Text(
                            "Log in to continue your journey",
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.white70,
                            ),
                          ),
                          const SizedBox(height: 20),

                          // 🔹 Email Input Field
                          TextField(
                            controller: emailController,
                            style: const TextStyle(color: Colors.white),
                            keyboardType: TextInputType.emailAddress,
                            decoration: InputDecoration(
                              labelText: "Email",
                              labelStyle: const TextStyle(color: Colors.white70),
                              prefixIcon: const Icon(Icons.email, color: Colors.blueAccent),
                              filled: true,
                              fillColor: const Color.fromARGB(25, 255, 255, 255), // ✅ ARGB
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none,
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),

                          // 🔹 Password Input Field with Visibility Toggle
                          TextField(
                            controller: passwordController,
                            style: const TextStyle(color: Colors.white),
                            obscureText: !isPasswordVisible,
                            decoration: InputDecoration(
                              labelText: "Password",
                              labelStyle: const TextStyle(color: Colors.white70),
                              prefixIcon: const Icon(Icons.lock, color: Colors.blueAccent),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                                  color: Colors.blueAccent,
                                ),
                                onPressed: () {
                                  setState(() {
                                    isPasswordVisible = !isPasswordVisible;
                                  });
                                },
                              ),
                              filled: true,
                              fillColor: const Color.fromARGB(25, 255, 255, 255),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none,
                              ),
                            ),
                          ),

                          // 🔹 Forgot Password Option
                          Align(
                            alignment: Alignment.centerRight,
                            child: Padding(
                              padding: const EdgeInsets.only(top: 5, bottom: 15),
                              child: GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (context) => ForgotPasswordScreen()),
                                  );
                                },
                                child: const Text(
                                  "Forgot Password?",
                                  style: TextStyle(
                                    color: Colors.blueAccent,
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    decoration: TextDecoration.underline,
                                  ),
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 10),

                          // 🔹 Login Button
                          isLoading
                              ? const CircularProgressIndicator(color: Colors.blueAccent)
                              : ElevatedButton(
                                  onPressed: isLoading ? null : login,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.blueAccent,
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 14),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(15),
                                    ),
                                    elevation: 5,
                                    shadowColor: const Color.fromARGB(102, 51, 153, 255), // ✅ ARGB
                                  ),
                                  child: const Text(
                                    "Login",
                                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                  ),
                                ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 15),

                    // 🔹 Signup Redirection
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const SignupScreen()),
                        );
                      },
                      child: const Text(
                        "Don't have an account? Sign up",
                        style: TextStyle(
                          color: Colors.blueAccent,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
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
      ),
    );
  }
}
