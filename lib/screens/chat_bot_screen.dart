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
  final List<Map<String, dynamic>> _mcqs = [
    {"question": "How are you feeling today?", "options": ["Happy", "Sad", "Neutral"]},
    {"question": "Have you been stressed lately?", "options": ["Yes", "No"]},
    {"question": "Are you getting enough sleep?", "options": ["Yes", "No"]},
    {"question": "How often do you exercise?", "options": ["Daily", "Sometimes", "Never"]},
    {"question": "Do you feel socially connected?", "options": ["Yes", "No"]},
  ];
  final Map<String, String> _answers = {};

  // Backend URL
  final String _backendUrl = 'http://localhost:5000/chatbot';

  // Secure storage for token retrieval
  final FlutterSecureStorage _storage = FlutterSecureStorage();

  // Fetch token from secure storage
  Future<String?> _getAuthToken() async {
    return await _storage.read(key: 'token');
  }

  // Send user messages to the chatbot backend
  Future<void> sendMessage(String message) async {
    final token = await _getAuthToken();
    if (token == null) {
      setState(() {
        _conversation.add({
          "role": "bot",
          "content": "❌ You are not logged in. Please log in again.",
        });
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

        // Clean up response to avoid duplicate "bot:" prefix
        if (botResponse.startsWith("bot:")) {
          botResponse = botResponse.replaceFirst("bot:", "").trim();
        }

        setState(() {
          _conversation.add({"role": "bot", "content": botResponse});
        });
      } else if (response.statusCode == 401) {
        setState(() {
          _conversation.add({
            "role": "bot",
            "content": "❌ Session expired. Please log in again.",
          });
        });
        Navigator.pushReplacementNamed(context, '/login');
      } else {
        setState(() {
          _conversation.add({
            "role": "bot",
            "content": "❌ Server Error: ${response.statusCode}. Please try again later.",
          });
        });
      }
    } catch (error) {
      setState(() {
        _conversation.add({
          "role": "bot",
          "content": "❌ Failed to connect to the server. Check your internet.",
        });
      });
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // Handle MCQ Answer
  void _handleMCQAnswer(String answer) {
    _answers[_mcqs[_currentMCQIndex]['question']] = answer;
    if (_currentMCQIndex < _mcqs.length - 1) {
      setState(() {
        _currentMCQIndex++;
      });
    } else {
      _provideSuggestion();
    }
  }

  // Provide Suggestion Based on Answers
  void _provideSuggestion() {
  // Analyze user answers and generate a custom suggestion
  String suggestion = "Based on your answers:\n\n";

  if (_answers["How are you feeling today?"] == "Happy") {
    suggestion += "- It's great to see you're happy! Keep spreading positivity. 😊\n";
  } else if (_answers["How are you feeling today?"] == "Sad") {
    suggestion +=
        "- Consider practicing mindfulness or talking to a friend to lift your spirits. 🌟\n";
  } else if (_answers["How are you feeling today?"] == "Neutral") {
    suggestion += "- Maybe try a new hobby or a relaxing activity to brighten your day! 🎨\n";
  }

  if (_answers["Have you been stressed lately?"] == "Yes") {
    suggestion += "- Stress management is important. Try deep breathing or yoga. 🧘‍♀️\n";
  } else if (_answers["Have you been stressed lately?"] == "No") {
    suggestion += "- Fantastic! Keep maintaining a stress-free lifestyle. ✨\n";
  }

  if (_answers["Are you getting enough sleep?"] == "No") {
    suggestion +=
        "- Sleep is crucial for mental health. Aim for 7-8 hours of quality sleep nightly. 🛌\n";
  } else {
    suggestion += "- Good sleep habits are the foundation of well-being. Keep it up! 🌙\n";
  }

  if (_answers["How often do you exercise?"] == "Daily") {
    suggestion += "- Consistent exercise is wonderful for your mind and body. Keep moving! 🏃‍♂️\n";
  } else if (_answers["How often do you exercise?"] == "Sometimes") {
    suggestion += "- Regular exercise can significantly boost your mood. Try making it a habit! 🏋️‍♀️\n";
  } else {
    suggestion += "- Adding some light exercise, like walking, can make a big difference. 🚶‍♂️\n";
  }

  if (_answers["Do you feel socially connected?"] == "No") {
    suggestion +=
        "- Connecting with friends or loved ones can greatly improve your mood. Reach out! 🤝\n";
  } else {
    suggestion += "- Social connections are important. Keep nurturing your relationships. ❤️\n";
  }

  suggestion += "\nDo you want to share anything else or need help with something?";

  setState(() {
    _conversation.add({"role": "bot", "content": suggestion});
    _isAskingMCQs = false;
  });
}


  // Follow-Up MCQ
  void _handleFollowUp(String choice) {
    if (choice == "Yes") {
      setState(() {
        _conversation.add({
          "role": "bot",
          "content": "Great! Feel free to share your thoughts with me.",
        });
      });
    } else {
      setState(() {
        _conversation.add({
          "role": "bot",
          "content": "Thank you for chatting with me! Have a wonderful day! 😊",
        });
      });
    }
  }

  @override
  void initState() {
    super.initState();
    // Add the opening question when the screen is loaded
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        _conversation.add({
          "role": "bot",
          "content": "👋 How are you feeling today?",
        });
      });
    });
  }

  // Build MCQ Card
  Widget _buildMCQCard(Map<String, dynamic> mcq) {
    return Card(
      margin: EdgeInsets.all(16),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      color: Colors.deepPurple.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              mcq['question'],
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.deepPurple.shade900,
              ),
            ),
            SizedBox(height: 12),
            ...mcq['options'].map<Widget>((option) {
              return Container(
                margin: EdgeInsets.symmetric(vertical: 5),
                decoration: BoxDecoration(
                  color: Colors.deepPurple.shade100,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: ListTile(
                  title: Text(
                    option,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.deepPurple.shade900,
                    ),
                  ),
                  onTap: () => _isAskingMCQs
                      ? _handleMCQAnswer(option)
                      : _handleFollowUp(option),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
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
      appBar: AppBar(
        title: Text(
          "Carezy Chatbot",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.deepPurple,
        elevation: 5,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.deepPurple.shade100, Colors.deepPurple.shade50],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
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
                        color: isUser
                            ? Colors.deepPurple.shade200
                            : Colors.deepPurple.shade50,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 4,
                            offset: Offset(2, 2),
                          ),
                        ],
                      ),
                      child: Text(
                        message['content']!,
                        style: TextStyle(
                          color: isUser ? Colors.white : Colors.black87,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            if (_isAskingMCQs)
              _buildMCQCard(_mcqs[_currentMCQIndex])
            else if (_conversation.isNotEmpty &&
                _conversation.last['content']
                    ?.contains("Do you want to share anything else") ==
                    true)
              _buildMCQCard({
                "question": "Do you want to share something else?",
                "options": ["Yes", "No"]
              }),
            if (_isLoading)
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: CircularProgressIndicator(
                  color: Colors.deepPurple,
                ),
              ),
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
                        fillColor: Colors.deepPurple.shade50,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding:
                            EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      ),
                      style: TextStyle(color: Colors.black),
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
                      foregroundColor: Colors.white,
                      padding:
                          EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: Icon(Icons.send),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
