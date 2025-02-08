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
        title: Text("Task Management"),
        backgroundColor: Colors.teal,
      ),
      body: Stack(
        children: [
          // Gradient Background
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.teal.shade100, Colors.teal.shade50],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                // Add Task Card
                Card(
                  elevation: 10,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  color: Colors.white, // Light background inside the card
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        TextField(
                          controller: titleController,
                          decoration: InputDecoration(
                            labelText: "Task Title",
                            prefixIcon: Icon(Icons.title, color: Colors.teal.shade700),
                            filled: true,
                            fillColor: Colors.teal.shade50,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),
                        SizedBox(height: 10),
                        TextField(
                          controller: descriptionController,
                          decoration: InputDecoration(
                            labelText: "Description",
                            prefixIcon: Icon(Icons.description, color: Colors.teal.shade700),
                            filled: true,
                            fillColor: Colors.teal.shade50,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),
                        SizedBox(height: 10),
                        ElevatedButton(
                          onPressed: addTask,
                          child: Text("Add Task"),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.teal.shade700,
                            foregroundColor: Colors.white,
                            padding: EdgeInsets.symmetric(horizontal: 40, vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 20),

                // Task List
                Expanded(
                  child: isLoading
                      ? Center(child: CircularProgressIndicator())
                      : ListView.builder(
                          itemCount: tasks.length,
                          itemBuilder: (context, index) {
                            final task = tasks[index];
                            return Card(
                              elevation: 4,
                              margin: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                              color: Colors.white, // Light background inside the task card
                              child: ListTile(
                                title: Text(
                                  task['title'],
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                  ),
                                ),
                                subtitle: Text(
                                  task['description'] ?? "No Description",
                                  style: TextStyle(color: Colors.black54),
                                ),
                                trailing: task['status'] == "completed"
                                    ? Icon(Icons.check_circle, color: Colors.green)
                                    : ElevatedButton(
                                        onPressed: () => completeTask(task['task_id']),
                                        child: Text("Complete"),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.teal.shade700,
                                          foregroundColor: Colors.white,
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
