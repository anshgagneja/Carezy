import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class MoodGraph extends StatelessWidget {
  final List<dynamic> moodHistory;

  const MoodGraph({super.key, required this.moodHistory}); // ✅ Used super.key

  @override
  Widget build(BuildContext context) {
    return moodHistory.isEmpty
        ? const Text("No mood data available.") // ✅ Use const for static widgets
        : SizedBox(
            height: 300,
            child: LineChart(
              LineChartData(
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: true),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: true),
                  ),
                ),
                gridData: FlGridData(show: false),
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  LineChartBarData(
                    spots: moodHistory.asMap().entries.map((entry) {
                      int index = entry.key;
                      double moodScore = entry.value['mood_score'].toDouble();
                      return FlSpot(index.toDouble(), moodScore);
                    }).toList(),
                    isCurved: true,
                    color: Colors.blue,
                    barWidth: 3,
                    belowBarData: BarAreaData(
                      show: true,
                      color: Colors.blue.withAlpha(77), // ✅ Replaced .withOpacity(0.3)
                    ),
                  ),
                ],
              ),
            ),
          );
  }
}
