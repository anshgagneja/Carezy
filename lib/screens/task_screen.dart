import 'package:flutter/material.dart';
import '../api/task_api.dart';

class TaskScreen extends StatefulWidget {
  @override
  _TaskScreenState createState() => _TaskScreenState();
}

class _TaskScreenState extends State<TaskScreen> {
  List<dynamic> tasks = [];
  bool isLoading = false;
  TextEditingController titleController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchTasks();
  }

  void fetchTasks() async {
    setState(() => isLoading = true);
    final fetchedTasks = await TaskAPI.getTasks();
    setState(() {
      isLoading = false;
      tasks = fetchedTasks ?? [];
    });
  }

  void addTask() async {
    await TaskAPI.addTask(titleController.text, descriptionController.text);
    titleController.clear();
    descriptionController.clear();
    fetchTasks();
  }

  void completeTask(int taskId) async {
    await TaskAPI.updateTaskStatus(taskId, "completed");
    fetchTasks();
  }

  void deleteTask(int taskId) async {
    await TaskAPI.deleteTask(taskId);
    fetchTasks();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Task Manager", style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.deepPurple,
        centerTitle: true,
        elevation: 5,
      ),
      body: Stack(
        children: [
          // 🔹 Gradient Background
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.deepPurple.shade300, Colors.deepPurple.shade100],
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
                Text(
                  "Your Tasks 📋",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 10),

                // 🔹 Glassmorphic Add Task Card
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(color: Colors.white.withOpacity(0.3)),
                  ),
                  padding: EdgeInsets.all(16),
                  child: Column(
                    children: [
                      // Task Title Input
                      TextField(
                        controller: titleController,
                        decoration: InputDecoration(
                          labelText: "Task Title",
                          prefixIcon: Icon(Icons.title, color: Colors.white),
                          filled: true,
                          fillColor: Colors.white.withOpacity(0.2),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          labelStyle: TextStyle(color: Colors.white),
                        ),
                        style: TextStyle(color: Colors.white),
                      ),
                      SizedBox(height: 10),

                      // Task Description Input
                      TextField(
                        controller: descriptionController,
                        decoration: InputDecoration(
                          labelText: "Task Description",
                          prefixIcon: Icon(Icons.description, color: Colors.white),
                          filled: true,
                          fillColor: Colors.white.withOpacity(0.2),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          labelStyle: TextStyle(color: Colors.white),
                        ),
                        style: TextStyle(color: Colors.white),
                      ),
                      SizedBox(height: 15),

                      // Add Task Button
                      ElevatedButton.icon(
                        onPressed: addTask,
                        icon: Icon(Icons.add, color: Colors.white),
                        label: Text("Add Task"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.purpleAccent,
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(horizontal: 40, vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 20),

                // 🔹 Task List Section
                Expanded(
                  child: isLoading
                      ? Center(child: CircularProgressIndicator())
                      : tasks.isEmpty
                          ? Center(
                              child: Text(
                                "No tasks yet! Add a new task to get started.",
                                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                                textAlign: TextAlign.center,
                              ),
                            )
                          : ListView.builder(
                              itemCount: tasks.length,
                              itemBuilder: (context, index) {
                                final task = tasks[index];
                                return Card(
                                  elevation: 5,
                                  margin: EdgeInsets.symmetric(vertical: 8, horizontal: 10),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                  color: Colors.white.withOpacity(0.2), // Glassmorphic card
                                  child: ListTile(
                                    contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                                    leading: CircleAvatar(
                                      backgroundColor: Colors.deepPurple.shade100,
                                      child: Icon(Icons.task_alt, color: Colors.deepPurple.shade700),
                                    ),
                                    title: Text(
                                      task['title'],
                                      style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                                    ),
                                    subtitle: Text(
                                      task['description'] ?? "No Description",
                                      style: TextStyle(color: Colors.white70),
                                    ),
                                    trailing: task['status'] == "completed"
                                        ? Icon(Icons.check_circle, color: Colors.green, size: 28)
                                        : ElevatedButton(
                                            onPressed: () => completeTask(task['task_id']),
                                            child: Text("Complete"),
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: Colors.purpleAccent,
                                              foregroundColor: Colors.white,
                                              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                              shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(8),
                                              ),
                                            ),
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
