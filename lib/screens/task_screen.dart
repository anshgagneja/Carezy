import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart'; // For animations
import '../api/task_api.dart';

class TaskScreen extends StatefulWidget {
  const TaskScreen({super.key}); // ✅ Added key

  @override
  State<TaskScreen> createState() => TaskScreenState(); // ✅ Made public
}

class TaskScreenState extends State<TaskScreen> {
  List<dynamic> tasks = []; // ✅ Removed null-aware operator
  bool isLoading = false;
  final TextEditingController titleController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchTasks();
  }

  Future<void> fetchTasks() async {
    setState(() => isLoading = true);
    final fetchedTasks = await TaskAPI.getTasks();
    setState(() {
      isLoading = false;
      tasks = fetchedTasks;
    });
  }

  Future<void> addTask() async {
    if (titleController.text.trim().isEmpty) return; // ✅ Prevent empty tasks
    await TaskAPI.addTask(titleController.text, descriptionController.text);
    titleController.clear();
    descriptionController.clear();
    fetchTasks();
  }

  Future<void> completeTask(int taskId) async {
    await TaskAPI.updateTaskStatus(taskId, "completed");
    fetchTasks();
  }

  Future<void> deleteTask(int taskId) async {
    await TaskAPI.deleteTask(taskId);
    fetchTasks();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text(
          "Task Manager",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: Colors.black.withAlpha(230), // ✅ Replaced withAlpha()
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
                const Text(
                  "Your Tasks 📋",
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                const SizedBox(height: 10),

                // 🔹 Glassmorphic Add Task Card
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withAlpha(18), // ✅ Used withAlpha()
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(color: Colors.white.withAlpha(51)), // ✅ Used withAlpha()
                  ),
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      // Task Title Input
                      TextField(
                        controller: titleController,
                        decoration: InputDecoration(
                          labelText: "Task Title",
                          prefixIcon: const Icon(Icons.title, color: Colors.white70),
                          filled: true,
                          fillColor: Colors.white.withAlpha(18), // ✅ Used withAlpha()
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          labelStyle: const TextStyle(color: Colors.white),
                        ),
                        style: const TextStyle(color: Colors.white),
                      ),
                      const SizedBox(height: 10),

                      // Task Description Input
                      TextField(
                        controller: descriptionController,
                        decoration: InputDecoration(
                          labelText: "Task Description",
                          prefixIcon: const Icon(Icons.description, color: Colors.white70),
                          filled: true,
                          fillColor: Colors.white.withAlpha(18), // ✅ Used withAlpha()
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          labelStyle: const TextStyle(color: Colors.white),
                        ),
                        style: const TextStyle(color: Colors.white),
                      ),
                      const SizedBox(height: 15),

                      // Add Task Button (Gradient)
                      ElevatedButton.icon(
                        onPressed: addTask,
                        icon: const Icon(Icons.add, color: Colors.white),
                        label: const Text("Add Task", style: TextStyle(fontWeight: FontWeight.bold)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.purpleAccent,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // 🔹 Task List Section
                Expanded(
                  child: isLoading
                      ? const Center(child: CircularProgressIndicator(color: Colors.white))
                      : tasks.isEmpty
                          ? Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                //Lottie.asset('assets/animations/empty_tasks.json', width: 200),
                                const SizedBox(height: 10),
                                const Text(
                                  "No tasks yet! Add a new task to get started.",
                                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white70),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            )
                          : ListView.builder(
                              itemCount: tasks.length,
                              itemBuilder: (context, index) {
                                final task = tasks[index];
                                return Card(
                                  elevation: 5,
                                  margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                  color: Colors.white.withAlpha(18), // ✅ Used withAlpha()
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
                                            onPressed: () => completeTask(task['task_id']),
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: Colors.purpleAccent,
                                              foregroundColor: Colors.white,
                                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                              shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(8),
                                              ),
                                            ),
                                            child: const Text("Complete"),
                                          ),
                                    onLongPress: () => deleteTask(task['task_id']),
                                  ),
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
}
