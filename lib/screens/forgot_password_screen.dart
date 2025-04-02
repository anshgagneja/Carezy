import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import '../api/auth_api.dart';

class ForgotPasswordScreen extends StatefulWidget {
  @override
  _ForgotPasswordScreenState createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController otpController = TextEditingController();
  final TextEditingController newPasswordController = TextEditingController();
  bool isLoading = false;
  bool isOTPSent = false;

  // 🔹 Send OTP
  void sendOTP() async {
    final email = emailController.text.trim();

    if (email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("❌ Please enter your email.")),
      );
      return;
    }

    setState(() => isLoading = true);
    final otpSent = await AuthAPI.sendResetOTP(email); // API Call
    setState(() => isLoading = false);

    if (otpSent) {
      setState(() {
        isOTPSent = true;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("✅ OTP has been sent to your email.")),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("❌ Failed to send OTP. Try again.")),
      );
    }
  }

  // 🔹 Reset Password
  void resetPassword() async {
    final otp = otpController.text.trim();
    final newPassword = newPasswordController.text.trim();

    if (otp.isEmpty || newPassword.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("❌ Please enter OTP and new password.")),
      );
      return;
    }

    setState(() => isLoading = true);
    final resetSuccess =
        await AuthAPI.resetPassword(emailController.text.trim(), otp, newPassword);
    setState(() => isLoading = false);

    if (resetSuccess) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("✅ Password reset successful!")),
      );
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("❌ Invalid OTP or password reset failed.")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // 🔹 Background Gradient
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF000000), Color(0xFF121212)],
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
                  // 🔹 Lottie Animation
                  Lottie.asset(
                    'assets/animations/forgot_password.json',
                    width: 170,
                    height: 170,
                  ),
                  SizedBox(height: 10),

                  // 🔹 Futuristic Card
                  Container(
                    padding: EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.white.withOpacity(0.2)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.blueAccent.withOpacity(0.3),
                          blurRadius: 15,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Text(
                          "Reset Password",
                          style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            letterSpacing: 1.5,
                          ),
                        ),
                        SizedBox(height: 10),
                        Text(
                          isOTPSent
                              ? "Enter OTP and set a new password"
                              : "Enter your email to receive OTP",
                          style: TextStyle(fontSize: 16, color: Colors.white70),
                        ),
                        SizedBox(height: 20),

                        // 🔹 Email Input Field
                        TextField(
                          controller: emailController,
                          enabled: !isOTPSent,
                          style: TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                            labelText: "Email",
                            labelStyle: TextStyle(color: Colors.white70),
                            prefixIcon: Icon(Icons.email, color: Colors.blueAccent),
                            filled: true,
                            fillColor: Colors.white.withOpacity(0.1),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),
                        SizedBox(height: 10),

                        // 🔹 OTP Input & New Password (Shown After OTP Sent)
                        if (isOTPSent)
                          Column(
                            children: [
                              TextField(
                                controller: otpController,
                                style: TextStyle(color: Colors.white),
                                decoration: InputDecoration(
                                  labelText: "OTP",
                                  labelStyle: TextStyle(color: Colors.white70),
                                  prefixIcon: Icon(Icons.lock_clock, color: Colors.blueAccent),
                                  filled: true,
                                  fillColor: Colors.white.withOpacity(0.1),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide.none,
                                  ),
                                ),
                              ),
                              SizedBox(height: 10),

                              // 🔹 New Password Field
                              TextField(
                                controller: newPasswordController,
                                style: TextStyle(color: Colors.white),
                                decoration: InputDecoration(
                                  labelText: "New Password",
                                  labelStyle: TextStyle(color: Colors.white70),
                                  prefixIcon: Icon(Icons.lock, color: Colors.blueAccent),
                                  filled: true,
                                  fillColor: Colors.white.withOpacity(0.1),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide.none,
                                  ),
                                ),
                                obscureText: true,
                              ),
                              SizedBox(height: 20),
                            ],
                          ),

                        // 🔹 Button (Send OTP or Reset Password)
                        isLoading
                            ? CircularProgressIndicator(color: Colors.blueAccent)
                            : ElevatedButton(
                                onPressed: isOTPSent ? resetPassword : sendOTP,
                                child: Text(
                                  isOTPSent ? "Reset Password" : "Send OTP",
                                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.blueAccent,
                                  foregroundColor: Colors.white,
                                  padding: EdgeInsets.symmetric(horizontal: 50, vertical: 14),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                  elevation: 5,
                                  shadowColor: Colors.blueAccent.withOpacity(0.4),
                                ),
                              ),
                      ],
                    ),
                  ),

                  SizedBox(height: 15),

                  // 🔹 Back to Login
                  GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: Text(
                      "Back",
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
    );
  }
}
