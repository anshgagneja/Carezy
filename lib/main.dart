import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'screens/login_screen.dart';
import 'screens/signup_screen.dart';
import 'screens/home_screen.dart';
import 'screens/task_screen.dart';
import 'screens/chat_bot_screen.dart';
import 'utils/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load .env file for environment variables
  await dotenv.load(fileName: "assets/.env");

  try {
    if (kIsWeb) {
      // Firebase initialization for web
      await Firebase.initializeApp(
        options: FirebaseOptions(
          apiKey: dotenv.env['FIREBASE_API_KEY']!,
          authDomain: dotenv.env['FIREBASE_AUTH_DOMAIN']!,
          projectId: dotenv.env['FIREBASE_PROJECT_ID']!,
          storageBucket: dotenv.env['FIREBASE_STORAGE_BUCKET']!,
          messagingSenderId: dotenv.env['FIREBASE_MESSAGING_SENDER_ID']!,
          appId: dotenv.env['FIREBASE_APP_ID']!,
          measurementId: dotenv.env['FIREBASE_MEASUREMENT_ID']!,
        ),
      );
    } else {
      // Firebase initialization for non-web platforms
      await Firebase.initializeApp();
    }
  } catch (e) {
    runApp(ErrorApp(message: "Failed to initialize Firebase: $e"));
    return;
  }

  // Retrieve token and user ID from secure storage
  final storage = FlutterSecureStorage();
  String? token;
  String? userId;

  try {
    token = await storage.read(key: "token");
    userId = await storage.read(key: "userId");
  } catch (e) {
    print("❌ Error retrieving token or userId: $e");
    token = null;
    userId = null;
  }

  print("🔹 Stored Token: $token");
  print("🔹 Stored User ID: $userId");

  runApp(CarezyApp(token: token, userId: userId));
}

class CarezyApp extends StatelessWidget {
  final String? token;
  final String? userId;

  CarezyApp({this.token, this.userId});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      initialRoute: (token != null && userId != null) ? '/home' : '/login', // ✅ Ensure user is authenticated
      routes: {
        '/login': (context) => LoginScreen(),
        '/signup': (context) => SignupScreen(),
        '/home': (context) => HomeScreen(),
        '/tasks': (context) => TaskScreen(),
        '/chatbot': (context) => ChatBotScreen(),
      },
    );
  }
}

// 🔹 Fallback error screen when Firebase initialization fails
class ErrorApp extends StatelessWidget {
  final String message;
  ErrorApp({required this.message});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: Text(
            message,
            style: TextStyle(fontSize: 18, color: Colors.red),
          ),
        ),
      ),
    );
  }
}
