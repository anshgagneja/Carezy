import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ChatBotScreen extends StatefulWidget {
  const ChatBotScreen({super.key}); // ✅ Using super parameter for `key`

  @override
  ChatBotScreenState createState() => ChatBotScreenState();
}

class ChatBotScreenState extends State<ChatBotScreen> {
  final TextEditingController _inputController = TextEditingController();
  final List<Map<String, String>> _conversation = [];
  bool _isLoading = false;

  // ✅ Backend URL
  final String _backendUrl = 'http://192.168.1.7:5000/chatbot';

  // ✅ Secure storage instance (final for efficiency)
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  @override
  void initState() {
    super.initState();
    _addBotMessage("👋 Hey there! This is Carezy Assistant. How can I assist you?");
  }

  Future<String?> _getAuthToken() async => await _storage.read(key: 'token');

  void _addBotMessage(String message) {
    setState(() => _conversation.add({"role": "bot", "content": message}));
  }

  void _addUserMessage(String message) {
    setState(() => _conversation.add({"role": "user", "content": message}));
  }

  Future<void> sendMessage(String message) async {
    final token = await _getAuthToken();
    if (token == null) {
      _addBotMessage("❌ You are not logged in. Please log in again.");
      return;
    }

    _addUserMessage(message);
    setState(() => _isLoading = true);

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
        _addBotMessage(data['response'] ?? "🤖 No response from the server.");
      } else {
        _addBotMessage("❌ Server Error. Please try again.");
      }
    } catch (error) {
      _addBotMessage("❌ Failed to connect to the server.");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text("Carezy Companion", style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.black.withAlpha((0.9 * 255).round()), // ✅ Fixed `withOpacity()`
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
                  child: ChatBubble(
                    content: message['content']!,
                    isUser: isUser,
                  ),
                );
              },
            ),
          ),
          _buildInputField(),
        ],
      ),
    );
  }

  Widget _buildInputField() {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _inputController,
              decoration: InputDecoration(
                hintText: "Type your message...",
                filled: true,
                fillColor: Colors.black.withAlpha((0.8 * 255).round()), // ✅ Fixed `withOpacity()`
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              ),
              style: const TextStyle(color: Colors.white),
            ),
          ),
          const SizedBox(width: 10),
          ElevatedButton(
            onPressed: _isLoading ? null : _handleSendMessage,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.deepPurple,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            ),
            child: const Icon(Icons.send, color: Colors.white),
          ),
        ],
      ),
    );
  }

  void _handleSendMessage() {
    final message = _inputController.text.trim();
    if (message.isNotEmpty) {
      sendMessage(message);
      _inputController.clear();
    }
  }
}

class ChatBubble extends StatelessWidget {
  final String content;
  final bool isUser;

  const ChatBubble({required this.content, required this.isUser, super.key}); // ✅ Super parameter

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isUser ? Colors.deepPurple.shade800 : Colors.grey.shade900,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(content, style: const TextStyle(color: Colors.white, fontSize: 16)),
    );
  }
}
