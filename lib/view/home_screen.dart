import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:prodigenius/widgets/custom_appbar.dart';
import 'package:prodigenius/widgets/navigation_bar.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String username = "";
  String userEmail = "";
  bool hasCompletedTasks = false; // Track completed tasks

  @override
  void initState() {
    super.initState();
    fetchUserData();
  }

  void fetchUserData() async {
    String uid = FirebaseAuth.instance.currentUser!.uid;
    var userDoc =
        await FirebaseFirestore.instance.collection('users').doc(uid).get();
    if (userDoc.exists) {
      setState(() {
        username = userDoc.data()?['username'] ?? "User";
        userEmail = userDoc.data()?['email'] ?? "user@example.com";
      });
    }
  }

  void showAddTaskDialog() {
    TextEditingController taskController = TextEditingController();
    String selectedPriority = "Medium";
    DateTime selectedDate = DateTime.now();

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text("Enter Task Manually"),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: taskController,
                    decoration: InputDecoration(labelText: "Task Title"),
                  ),
                  SizedBox(height: 10),
                  Align(
                      alignment: Alignment.centerLeft, child: Text("Priority")),
                  DropdownButtonFormField<String>(
                    value: selectedPriority,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12)),
                      contentPadding: EdgeInsets.symmetric(horizontal: 10),
                    ),
                    onChanged: (String? newValue) {
                      setState(() {
                        selectedPriority = newValue!;
                      });
                    },
                    items: ["High", "Medium", "Low"]
                        .map((priority) => DropdownMenuItem(
                              value: priority,
                              child: Row(
                                children: [
                                  Icon(
                                    priority == "High"
                                        ? Icons.priority_high
                                        : priority == "Medium"
                                            ? Icons.swap_horiz
                                            : Icons.low_priority,
                                    color: priority == "High"
                                        ? Colors.red
                                        : priority == "Medium"
                                            ? Colors.orange
                                            : Colors.green,
                                  ),
                                  SizedBox(width: 8),
                                  Text(priority),
                                ],
                              ),
                            ))
                        .toList(),
                  ),
                  SizedBox(height: 10),
                  ListTile(
                    title: Text("Select Date & Time"),
                    subtitle: Text(
                      DateFormat('yyyy-MM-dd HH:mm').format(selectedDate),
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    onTap: () async {
                      DateTime? pickedDate = await showDatePicker(
                        context: context,
                        initialDate: selectedDate,
                        firstDate: DateTime.now(),
                        lastDate: DateTime(2100),
                      );
                      if (pickedDate != null) {
                        TimeOfDay? pickedTime = await showTimePicker(
                          context: context,
                          initialTime: TimeOfDay.fromDateTime(selectedDate),
                        );
                        if (pickedTime != null) {
                          setState(() {
                            selectedDate = DateTime(
                              pickedDate.year,
                              pickedDate.month,
                              pickedDate.day,
                              pickedTime.hour,
                              pickedTime.minute,
                            );
                          });
                        }
                      }
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text("Cancel"),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (taskController.text.isNotEmpty) {
                      addTaskToFirestore(
                          taskController.text, selectedPriority, selectedDate);
                      Navigator.pop(context);
                    }
                  },
                  child: Text("Add Task"),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void toggleTaskStatus(String taskId, bool isChecked) async {
    String newStatus = isChecked ? "complete" : "pending";

    await FirebaseFirestore.instance.collection('tasks').doc(taskId).update({
      'status': newStatus,
    });

    checkForCompletedTasks();
  }

  void checkForCompletedTasks() async {
    var snapshot = await FirebaseFirestore.instance
        .collection('tasks')
        .where('email', isEqualTo: userEmail)
        .where('status', isEqualTo: "complete")
        .get();

    setState(() {
      hasCompletedTasks = snapshot.docs.isNotEmpty;
    });
  }

  void deleteCompletedTasks() async {
    var snapshot = await FirebaseFirestore.instance
        .collection('tasks')
        .where('email', isEqualTo: userEmail)
        .where('status', isEqualTo: "complete")
        .get();

    for (var doc in snapshot.docs) {
      await doc.reference.update({'status': 'deleted'});
    }

    checkForCompletedTasks(); // Refresh UI
  }

  void showDeleteConfirmationDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Delete Task"),
        content: Text("Are you sure you want to delete this task?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () {
              deleteCompletedTasks();
              Navigator.pop(context);
            },
            child: Text("Yes"),
          ),
        ],
      ),
    );
  }

  void addTaskToFirestore(
      String task, String priority, DateTime dateTime) async {
    if (username.isEmpty || userEmail.isEmpty) {
      fetchUserData(); // Fetch user data again
    }
    await FirebaseFirestore.instance.collection('tasks').add({
      'task': task,
      'priority': priority,
      'dateTime': dateTime.toIso8601String(),
      'username': username,
      'email': userEmail,
      'status': "pending", // Default status
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: CustomAppBar(),
      body: Padding(
        padding: EdgeInsets.all(5),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              margin: EdgeInsets.symmetric(horizontal: 10),
              child: Text(
                "Hello $username!",
                style: GoogleFonts.poppins(
                  fontSize: 24,
                  color: Color(0xFF2E3A59),
                ),
              ),
            ),
            SizedBox(height: 5),
            Container(
              margin: EdgeInsets.symmetric(horizontal: 10),
              child: Text("Have a nice day.",
                  style: TextStyle(fontSize: 16, color: Colors.grey)),
            ),
            SizedBox(height: 10),
            Container(
              margin: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
              child: TextField(
                decoration: InputDecoration(
                  labelText: "Search Tasks",
                  prefixIcon: Icon(Icons.search),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
            SizedBox(height: 10),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('tasks')
                    .where('email', isEqualTo: userEmail)
                    .where('status', whereIn: [
                  "pending",
                ]).snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData)
                    return Center(child: CircularProgressIndicator());

                  var tasks = snapshot.data!.docs;

                  return ListView(
                    children: tasks.map((task) {
                      var data = task.data() as Map<String, dynamic>;
                      bool isCompleted = data['status'] == "complete";

                      return Container(
                        margin:
                            EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                        padding: EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border:
                              Border.all(color: Color(0xff3D0087), width: 2),
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black12,
                              blurRadius: 4,
                              offset: Offset(2, 2),
                            ),
                          ],
                        ),
                        child: ListTile(
                          title: Text(
                            data['task'] ?? 'No Task',
                            style: TextStyle(
                              decoration: isCompleted
                                  ? TextDecoration.lineThrough
                                  : TextDecoration.none,
                            ),
                          ),
                          subtitle: Text(
                              "Priority: ${data['priority']} | ${DateFormat('yyyy-MM-dd HH:mm').format(DateTime.parse(data['dateTime']))}"),
                          trailing: Checkbox(
                            value: isCompleted,
                            onChanged: (bool? newValue) {
                              if (newValue != null) {
                                toggleTaskStatus(task.id, newValue);
                              }
                            },
                          ),
                        ),
                      );
                    }).toList(),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: Transform.translate(
        offset: Offset(0, 35),
        child: Container(
          height: 70,
          width: 70,
          child: FloatingActionButton(
            onPressed: showAddTaskDialog,
            backgroundColor: Colors.purple,
            shape: CircleBorder(
              side: BorderSide(color: Colors.white, width: 5),
            ),
            child: Icon(Icons.add, size: 35, color: Colors.white),
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomNavBar(
        hasCompletedTasks: hasCompletedTasks,
        onTrashClick: showDeleteConfirmationDialog,
      ),
    );
  }
}
