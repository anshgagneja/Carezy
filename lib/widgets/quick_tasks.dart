import 'package:flutter/material.dart';
import '../api/task_api.dart';

class QuickTasks extends StatelessWidget {
  final bool showCompleted;

  const QuickTasks({super.key, this.showCompleted = true}); // ✅ Used super.key & const constructor

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<dynamic>>(
      future: TaskAPI.getTasks(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator(color: Colors.white)); // ✅ Used const
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const SizedBox.shrink(); // ✅ Prevents unnecessary empty space
        }

        final tasks = snapshot.data!.where((task) {
          return showCompleted ? true : task['status'] != "completed";
        }).toList();

        if (tasks.isEmpty) return const SizedBox.shrink(); // ✅ Hide if no pending tasks

        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: tasks.length,
          itemBuilder: (context, index) {
            final task = tasks[index];
            return Card(
              color: Colors.grey.shade900,
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              child: ListTile(
                title: Text(
                  task['title'],
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold), // ✅ Used const
                ),
                subtitle: Text(
                  task['description'] ?? "No description",
                  style: const TextStyle(color: Colors.white70),
                ),
                trailing: const Icon(Icons.arrow_forward_ios, color: Colors.white70, size: 18),
              ),
            );
          },
        );
      },
    );
  }
}
