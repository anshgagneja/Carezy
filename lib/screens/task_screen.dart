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
      appBar: AppBar(title: Text("Task Management")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    TextField(controller: titleController, decoration: InputDecoration(labelText: "Task Title")),
                    TextField(controller: descriptionController, decoration: InputDecoration(labelText: "Description")),
                    SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: addTask,
                      child: Text("Add Task", style: TextStyle(fontSize: 16)),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 20),
            Expanded(
              child: isLoading
                  ? Center(child: CircularProgressIndicator())
                  : ListView.builder(
                      itemCount: tasks.length,
                      itemBuilder: (context, index) {
                        final task = tasks[index];
                        return Card(
                          elevation: 2,
                          margin: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                          child: ListTile(
                            title: Text(task['title'], style: TextStyle(fontWeight: FontWeight.bold)),
                            subtitle: Text(task['description'] ?? "No Description"),
                            trailing: task['status'] == "completed"
                                ? Icon(Icons.check_circle, color: Colors.green)
                                : ElevatedButton(
                                    onPressed: () => completeTask(task['task_id']),
                                    child: Text("Complete"),
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
    );
  }
}
