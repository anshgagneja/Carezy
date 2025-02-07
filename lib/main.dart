import 'package:carezy/screens/signup_screen.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart'; // Import dotenv package
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';
import 'screens/task_screen.dart'; // ✅ Added Task Screen
import 'utils/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load .env from assets (for Flutter Web compatibility)
  await dotenv.load(fileName: "assets/.env");

  try {
    if (kIsWeb) {
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
      await Firebase.initializeApp();
    }
  } catch (e) {
    runApp(ErrorApp(message: "Failed to initialize Firebase"));
    return;
  }

  final storage = FlutterSecureStorage();
  String? token;

  try {
    token = await storage.read(key: "token");
  } catch (e) {
    token = null;
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
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      initialRoute: token != null ? '/home' : '/login',
      routes: {
        '/login': (context) => LoginScreen(),
        '/signup': (context) => SignupScreen(), // Added signup route
        '/home': (context) => HomeScreen(),
        '/tasks': (context) => TaskScreen(), // ✅ Added route for tasks
      },
    );
  }
}

// 🔹 Show an error message if Firebase fails to initialize
class ErrorApp extends StatelessWidget {
  final String message;
  ErrorApp({required this.message});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Center(child: Text(message, style: TextStyle(fontSize: 18, color: Colors.red))),
      ),
    );
  }
}
