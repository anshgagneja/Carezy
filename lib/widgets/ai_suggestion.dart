import 'package:flutter/material.dart';

class AISuggestionWidget extends StatelessWidget {
  final String aiSuggestion;

  const AISuggestionWidget({super.key, required this.aiSuggestion});

  @override
  Widget build(BuildContext context) {
    if (aiSuggestion.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(top: 20.0),
      child: Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: Colors.blueAccent.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.blueAccent),
        ),
        child: Text(
          "AI Suggestion: $aiSuggestion",
          style: const TextStyle(
            fontSize: 16, 
            fontWeight: FontWeight.bold, 
            color: Colors.blue,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
