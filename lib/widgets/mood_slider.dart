import 'package:flutter/material.dart';

class MoodSlider extends StatelessWidget {
  final double value;
  final ValueChanged<double> onChanged; // ✅ Better function type

  const MoodSlider({super.key, required this.value, required this.onChanged}); // ✅ Used super.key

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          "Mood Score: ${value.toInt()}",
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold), // ✅ Used const
        ),
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
