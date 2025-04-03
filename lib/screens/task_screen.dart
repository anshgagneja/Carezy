import 'package:flutter/material.dart';
import '../api/task_api.dart';

class TaskScreen extends StatefulWidget {
  const TaskScreen({super.key}); // ✅ Added named 'key' parameter

  @override
  TaskScreenState createState() => TaskScreenState(); // ✅ Changed _TaskScreenState to public
}

class TaskScreenState extends State<TaskScreen> {
  TextEditingController titleController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();

  Future<List<dynamic>> fetchTasks() async {
    return await TaskAPI.getTasks();
  }

  void addTask() async {
    String title = titleController.text.trim();
    String description = descriptionController.text.trim();

    if (title.isEmpty || description.isEmpty) {
      _showSnackBar("❌ Task title and description cannot be empty!");
      return;
    }

    await TaskAPI.addTask(title, description);
    titleController.clear();
    descriptionController.clear();
    setState(() {}); // Refresh UI
  }

  void completeTask(int taskId) async {
    await TaskAPI.updateTaskStatus(taskId, "completed");
    setState(() {}); // Refresh UI
  }

  void deleteTask(int taskId) async {
    await TaskAPI.deleteTask(taskId);
    setState(() {}); // Refresh UI
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(message, style: const TextStyle(color: Colors.white)),
      backgroundColor: Colors.black87,
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, // Dark Theme
      appBar: AppBar(
        title: const Text(
          "Task Manager",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: Colors.black.withAlpha((0.9 * 255).toInt()), // ✅ Fixed opacity issue
        centerTitle: true,
        elevation: 5,
      ),
      body: Stack(
        children: [
          // 🔹 Background Gradient
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.black87, Colors.black],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 🔹 Header
                const Text(
                  "Your Tasks 📋",
                  style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                ),
                const SizedBox(height: 10),

                // 🔹 Glassmorphic Add Task Card
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withAlpha((0.07 * 255).toInt()), // ✅ Fixed opacity
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(color: Colors.white.withAlpha((0.2 * 255).toInt())),
                  ),
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      _buildTextField(
                          titleController, "Task Title", Icons.title),
                      const SizedBox(height: 10),
                      _buildTextField(descriptionController, "Task Description",
                          Icons.description),
                      const SizedBox(height: 15),

                      // Add Task Button
                      ElevatedButton.icon(
                        style: _buttonStyle(),
                        onPressed: addTask,
                        icon: const Icon(Icons.add, color: Colors.white),
                        label: const Text(
                          "Add Task",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // 🔹 Task List Section
                Expanded(
                  child: FutureBuilder<List<dynamic>>(
                    future: fetchTasks(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(
                            child:
                                CircularProgressIndicator(color: Colors.white));
                      }

                      final tasks = snapshot.data ?? [];
                      if (tasks.isEmpty) {
                        return _buildEmptyState();
                      }

                      return ListView.builder(
                        itemCount: tasks.length,
                        itemBuilder: (context, index) {
                          final task = tasks[index];
                          return _buildTaskCard(task);
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 🔹 Task Input Field Builder
  Widget _buildTextField(
      TextEditingController controller, String label, IconData icon) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Colors.white70),
        filled: true,
        fillColor: Colors.white.withAlpha((0.07 * 255).toInt()), // ✅ Fixed opacity
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        labelStyle: const TextStyle(color: Colors.white),
      ),
      style: const TextStyle(color: Colors.white),
    );
  }

  // 🔹 Task Card Builder
  Widget _buildTaskCard(Map<String, dynamic> task) {
    return Card(
      elevation: 5,
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      color: Colors.white.withAlpha((0.07 * 255).toInt()), // ✅ Fixed opacity
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
        leading: CircleAvatar(
          backgroundColor: Colors.deepPurple.shade100,
          child: Icon(Icons.task_alt, color: Colors.deepPurple.shade700),
        ),
        title: Text(
          task['title'],
          style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        subtitle: Text(
          task['description'] ?? "No Description",
          style: const TextStyle(color: Colors.white70),
        ),
        trailing: task['status'] == "completed"
            ? const Icon(Icons.check_circle, color: Colors.green, size: 28)
            : ElevatedButton(
                style: _buttonStyle(),
                onPressed: () => completeTask(task['task_id']),
                child: const Text("Complete"),
              ),
        onLongPress: () => deleteTask(task['task_id']),
      ),
    );
  }

  // 🔹 Empty State UI
  Widget _buildEmptyState() {
  return SingleChildScrollView(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Empty Box Illustration
        Icon(
          Icons.inbox,
          size: 100,
          color: Colors.white24,
        ),
        const SizedBox(height: 10),

        // "No Tasks Yet" Message
        const Text(
          "No tasks yet!",
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 5),

        // "Add a New Task" Subtitle
        const Text(
          "Add a new task to get started.",
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Colors.white70,
          ),
          textAlign: TextAlign.center,
        ),

        const SizedBox(height: 20),

        // "Add Task" Button
        ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.purpleAccent,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text("Tap on 'Add Task' to create a new task!"),
                backgroundColor: Colors.black87,
              ),
            );
          },
          icon: const Icon(Icons.add_task),
          label: const Text("Add Task"),
        ),
      ],
    ),
  );
}

  // 🔹 Button Style
  ButtonStyle _buttonStyle() {
    return ElevatedButton.styleFrom(
      backgroundColor: Colors.purpleAccent,
      foregroundColor: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 14),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    );
  }
}
