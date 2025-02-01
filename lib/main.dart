import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Ensure Flutter is ready

  try {
    if (kIsWeb) {
      await Firebase.initializeApp(
        options: const FirebaseOptions(
          apiKey: "AIzaSyC9eJHMOqUY6XwnNVANzJLMOahEHjdA1jE",
          authDomain: "carezy-3c815.firebaseapp.com",
          projectId: "carezy-3c815",
          storageBucket: "carezy-3c815.appspot.com",  // Fixed incorrect URL
          messagingSenderId: "738760302648",
          appId: "1:738760302648:web:a46b1acef48d09fd81c6cd",
          measurementId: "G-6SJCHPZE6R",
        ),
      );
    } else {
      await Firebase.initializeApp();
    }
    print("✅ Firebase Initialized Successfully");
  } catch (e) {
    print("❌ Firebase Initialization Error: $e");
  }

  final storage = FlutterSecureStorage();

  // Retrieve token after Firebase is initialized
  String? token;
  try {
    token = await storage.read(key: "token");
    print("🔍 Retrieved Token on App Start: $token");
  } catch (e) {
    print("❌ Error retrieving token: $e");
  }

  runApp(CarezyApp(token: token));
}

class CarezyApp extends StatelessWidget {
  final String? token;
  CarezyApp({this.token});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: token != null ? '/home' : '/login',
      routes: {
        '/login': (context) => LoginScreen(),
        '/home': (context) => HomeScreen(),
      },
    );
  }
}
