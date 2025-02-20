import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ChatBotScreen extends StatefulWidget {
  @override
  _ChatBotScreenState createState() => _ChatBotScreenState();
}

class _ChatBotScreenState extends State<ChatBotScreen> {
  final TextEditingController _inputController = TextEditingController();
  final List<Map<String, String>> _conversation = [];
  bool _isLoading = false;
  bool _isAskingMCQs = true;
  int _currentMCQIndex = 0;

  // ✅ MCQ Questions
  final List<Map<String, dynamic>> _mcqs = [
    {"question": "How are you feeling today?", "options": ["Happy", "Sad", "Neutral"]},
    {"question": "Have you been stressed lately?", "options": ["Yes", "No"]},
    {"question": "Are you getting enough sleep?", "options": ["Yes", "No"]},
    {"question": "How often do you exercise?", "options": ["Daily", "Sometimes", "Never"]},
    {"question": "Do you feel socially connected?", "options": ["Yes", "No"]},
  ];
  final Map<String, String> _answers = {};

  // ✅ Backend URL
  final String _backendUrl = 'http://10.50.3.152:5000/chatbot';

  // ✅ Secure storage for token retrieval
  final FlutterSecureStorage _storage = FlutterSecureStorage();

  Future<String?> _getAuthToken() async {
    return await _storage.read(key: 'token');
  }

  Future<void> sendMessage(String message) async {
    final token = await _getAuthToken();
    if (token == null) {
      setState(() {
        _conversation.add({"role": "bot", "content": "❌ You are not logged in. Please log in again."});
      });
      return;
    }

    setState(() {
      _conversation.add({"role": "user", "content": message});
      _isLoading = true;
    });

    try {
      final response = await http.post(
        Uri.parse(_backendUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({'query': message}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        String botResponse = data['response'] ?? "No response from the server.";
        setState(() => _conversation.add({"role": "bot", "content": botResponse}));
      } else {
        setState(() => _conversation.add({"role": "bot", "content": "❌ Server Error. Please try again."}));
      }
    } catch (error) {
      setState(() => _conversation.add({"role": "bot", "content": "❌ Failed to connect to the server."}));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _handleMCQAnswer(String answer) {
    _answers[_mcqs[_currentMCQIndex]['question']] = answer;
    if (_currentMCQIndex < _mcqs.length - 1) {
      setState(() => _currentMCQIndex++);
    } else {
      _provideSuggestion();
    }
  }

  void _provideSuggestion() {
    String suggestion = "Based on your answers:\n\n";

    if (_answers["How are you feeling today?"] == "Happy") {
      suggestion += "- Great! Keep spreading positivity. 😊\n";
    } else if (_answers["How are you feeling today?"] == "Sad") {
      suggestion += "- Try mindfulness or talking to a friend. 🌟\n";
    } else {
      suggestion += "- Maybe a new hobby can brighten your day! 🎨\n";
    }

    setState(() {
      _conversation.add({"role": "bot", "content": suggestion});
      _isAskingMCQs = false;
    });
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        _conversation.add({"role": "bot", "content": "👋 How are you feeling today?"});
      });
    });
  }

  // ✅ Modern MCQ UI
  Widget _buildMCQCard(Map<String, dynamic> mcq) {
    return Card(
      margin: EdgeInsets.all(16),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      color: Colors.black.withOpacity(0.8), // Dark Glassmorphic Look
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(mcq['question'], style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
            SizedBox(height: 12),
            ...mcq['options'].map<Widget>((option) {
              return Container(
                margin: EdgeInsets.symmetric(vertical: 5),
                decoration: BoxDecoration(
                  color: Colors.grey.shade900,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: ListTile(
                  title: Text(option, style: TextStyle(fontSize: 16, color: Colors.white)),
                  onTap: () => _handleMCQAnswer(option),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, // 🔥 Sleek Dark Mode
      appBar: AppBar(
        title: Text("Carezy Companion", style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.black.withOpacity(0.9),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: _conversation.length,
              itemBuilder: (context, index) {
                final message = _conversation[index];
                final isUser = message['role'] == 'user';

                return Align(
                  alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: isUser ? Colors.deepPurple.shade800 : Colors.grey.shade900,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      message['content']!,
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  ),
                );
              },
            ),
          ),
          if (_isAskingMCQs) _buildMCQCard(_mcqs[_currentMCQIndex]),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _inputController,
                    decoration: InputDecoration(
                      hintText: "Type your message...",
                      filled: true,
                      fillColor: Colors.black.withOpacity(0.8),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: BorderSide.none),
                      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    ),
                    style: TextStyle(color: Colors.white),
                  ),
                ),
                SizedBox(width: 10),
                ElevatedButton(
                  onPressed: () {
                    final message = _inputController.text.trim();
                    if (message.isNotEmpty) {
                      sendMessage(message);
                      _inputController.clear();
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple,
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  ),
                  child: Icon(Icons.send, color: Colors.white),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
