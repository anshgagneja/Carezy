import 'package:flutter/material.dart';

class MoodSlider extends StatelessWidget {
  final double value;
  final Function(double) onChanged;

  MoodSlider({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text("Mood Score: ${value.toInt()}",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        Slider(
          value: value,
          min: 1,
          max: 10,
          divisions: 9,
          label: value.toInt().toString(),
          onChanged: onChanged,
        ),
      ],
    );
  }
}
