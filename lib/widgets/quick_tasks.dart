import 'package:flutter/material.dart';
import '../api/task_api.dart';

class QuickTasks extends StatelessWidget {
  final bool showCompleted;

  QuickTasks({this.showCompleted = true});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<dynamic>>(
      future: TaskAPI.getTasks(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator(color: Colors.white));
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return SizedBox.shrink(); // ✅ Prevents extra empty space
        }

        final tasks = snapshot.data!.where((task) {
          return showCompleted ? true : task['status'] != "completed";
        }).toList();

        if (tasks.isEmpty) return SizedBox.shrink(); // ✅ No pending tasks? Remove widget

        return ListView.builder(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          itemCount: tasks.length,
          itemBuilder: (context, index) {
            final task = tasks[index];
            return Card(
              color: Colors.grey.shade900,
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              child: ListTile(
                title: Text(task['title'], style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                subtitle: Text(task['description'] ?? "No description", style: TextStyle(color: Colors.white70)),
                trailing: Icon(Icons.arrow_forward_ios, color: Colors.white70, size: 18),
              ),
            );
          },
        );
      },
    );
  }
}
