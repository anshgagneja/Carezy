import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import '../api/auth_api.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});
  @override
  ForgotPasswordScreenState createState() => ForgotPasswordScreenState();
}

class ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController otpController = TextEditingController();
  final TextEditingController newPasswordController = TextEditingController();
  final GlobalKey<ScaffoldMessengerState> scaffoldKey = GlobalKey<ScaffoldMessengerState>();

  bool isLoading = false;
  bool isOTPSent = false;

  // 🔹 Show SnackBar
  void showSnackBar(String message, {bool success = false}) {
    scaffoldKey.currentState?.showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: success ? Colors.green : Colors.red,
      ),
    );
  }

  // 🔹 Send OTP
  Future<void> sendOTP() async {
    final email = emailController.text.trim();

    if (email.isEmpty) {
      showSnackBar("❌ Please enter your email.");
      return;
    }

    if (mounted) setState(() => isLoading = true);

    try {
      final otpSent = await AuthAPI.sendResetOTP(email);
      if (otpSent) {
        if (mounted) setState(() => isOTPSent = true);
        showSnackBar("✅ OTP has been sent to your email.", success: true);
      } else {
        showSnackBar("❌ Failed to send OTP. Try again.");
      }
    } catch (e) {
      showSnackBar("❌ Error: ${e.toString()}");
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  // 🔹 Reset Password
  Future<void> resetPassword() async {
    final otp = otpController.text.trim();
    final newPassword = newPasswordController.text.trim();

    if (otp.isEmpty || newPassword.isEmpty) {
      showSnackBar("❌ Please enter OTP and new password.");
      return;
    }

    if (newPassword.length < 6) {
      showSnackBar("⚠️ Password must be at least 6 characters long.");
      return;
    }

    if (mounted) setState(() => isLoading = true);

    try {
      final resetSuccess =
          await AuthAPI.resetPassword(emailController.text.trim(), otp, newPassword);

      if (resetSuccess) {
        showSnackBar("✅ Password reset successful!", success: true);
        if (mounted) Navigator.pop(context);
      } else {
        showSnackBar("❌ Invalid OTP or password reset failed.");
      }
    } catch (e) {
      showSnackBar("❌ Error: ${e.toString()}");
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ScaffoldMessenger(
      key: scaffoldKey,
      child: Scaffold(
        body: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: Stack(
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
                          color: Colors.white.withAlpha(25),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.white.withAlpha(50)),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.blueAccent.withAlpha(80),
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
                                fillColor: Colors.white.withAlpha(25),
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
                                      fillColor: Colors.white.withAlpha(25),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: BorderSide.none,
                                      ),
                                    ),
                                    obscureText: true,
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
                                      fillColor: Colors.white.withAlpha(25),
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
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.blueAccent,
                                      foregroundColor: Colors.white,
                                      padding: EdgeInsets.symmetric(horizontal: 50, vertical: 14),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(15),
                                      ),
                                    ),
                                    onPressed: isOTPSent ? resetPassword : sendOTP,
                                    child: Text(
                                      isOTPSent ? "Reset Password" : "Send OTP",
                                      style: const TextStyle(
                                          fontSize: 18, fontWeight: FontWeight.bold),
                                    ),
                                  ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
