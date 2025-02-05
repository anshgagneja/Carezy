import 'package:flutter/material.dart';

class AISuggestionWidget extends StatelessWidget {
  final String aiSuggestion;

  AISuggestionWidget({required this.aiSuggestion});

  @override
  Widget build(BuildContext context) {
    return aiSuggestion.isNotEmpty
        ? Padding(
            padding: const EdgeInsets.only(top: 20.0),
            child: Container(
              padding: EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: Colors.blueAccent.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.blueAccent),
              ),
              child: Text(
                "AI Suggestion: $aiSuggestion",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.blue),
                textAlign: TextAlign.center,
              ),
            ),
          )
        : Container();
  }
}
