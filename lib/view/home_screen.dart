import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:prodigenious/view/task_history.dart';
import 'package:prodigenious/widgets/custom_appbar.dart';
import 'package:prodigenious/widgets/navigation_bar.dart';

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
    String selectedPriority = "High";
    DateTime? selectedDueDate;

    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25),
          ),
          backgroundColor: Color(0xFFA558E0),
          child: Container(
            padding: EdgeInsets.all(20),
            width: MediaQuery.of(context).size.width * 0.85,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Title + Close Button Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Add New Task Manually",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        Navigator.of(context).pop(); // Close Dialog
                      },
                      icon: Icon(Icons.close, color: Colors.white),
                    ),
                  ],
                ),
                Divider(color: Colors.white, thickness: 1),
                SizedBox(height: 10),

                // Task Name
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "Enter The Task Name",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
                SizedBox(height: 5),
                TextField(
                  controller: taskController,
                  style: TextStyle(color: Colors.black),
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white,
                    hintText: "e.g., Complete Flutter UI",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                SizedBox(height: 15),

                // Priority & Date Row
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Choose Priority",
                              style: TextStyle(color: Colors.white)),
                          SizedBox(height: 5),
                          DropdownButtonFormField<String>(
                            value: selectedPriority,
                            icon: Icon(Icons.arrow_drop_down),
                            dropdownColor: Colors.white,
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: Colors.white,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            onChanged: (value) {
                              selectedPriority = value!;
                            },
                            items: ["High", "Medium", "Low"]
                                .map((priority) => DropdownMenuItem(
                                      value: priority,
                                      child: Text(priority),
                                    ))
                                .toList(),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Set Due Date",
                              style: TextStyle(color: Colors.white)),
                          SizedBox(height: 5),
                          ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: Colors.black,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            onPressed: () async {
                              DateTime? picked = await showDatePicker(
                                context: context,
                                initialDate: DateTime.now(),
                                firstDate: DateTime(2023),
                                lastDate: DateTime(2100),
                              );
                              if (picked != null) {
                                selectedDueDate = picked;
                              }
                            },
                            icon: Icon(Icons.calendar_today, size: 18),
                            label: Text("Date"),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 20),
                Divider(color: Colors.white, thickness: 1),
                SizedBox(height: 10),

                // Add Task Button
                ElevatedButton(
                  onPressed: () {
                    if (taskController.text.isEmpty ||
                        selectedDueDate == null) {
                      // simple validation
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("Please enter all details")),
                      );
                      return;
                    }

                    addTaskToFirestore(
                      taskController.text.trim(),
                      selectedPriority,
                      selectedDueDate!,
                    );

                    Navigator.of(context).pop(); // Close Dialog
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.purple.shade700,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  child: Text("Add Task"),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ADD TASK TO FIRESTORE

  void addTaskToFirestore(
      String task, String priority, DateTime dueDate) async {
    if (username.isEmpty || userEmail.isEmpty) {
      fetchUserData();
    }
    // Default new tasks to "ToDo"
    await FirebaseFirestore.instance.collection('tasks').add({
      'task': task,
      'priority': priority,
      'dueDate': dueDate.toIso8601String(),
      'assignedDate': DateTime.now().toIso8601String(),
      'username': username,
      'email': userEmail,
      'status': "ToDo",
    });
  }

  // UPDATE TASK STATUS

  void updateTaskStatus(String taskId, String newStatus) async {
    await FirebaseFirestore.instance.collection('tasks').doc(taskId).update({
      'status': newStatus,
    });
    checkForCompletedTasks(); // so the trash icon can appear/disappear
  }

  // ---------------------------------------------------------------------------
  // CHECK & DELETE COMPLETED (RENAMED TO "DONE") TASKS
  // ---------------------------------------------------------------------------
  void checkForCompletedTasks() async {
    // If you want "Done" tasks to show in the trash icon:
    var snapshot = await FirebaseFirestore.instance
        .collection('tasks')
        .where('email', isEqualTo: userEmail)
        .where('status', isEqualTo: "Done")
        .get();

    setState(() {
      hasCompletedTasks = snapshot.docs.isNotEmpty;
    });
  }

  void deleteCompletedTasks() async {
    // This will set tasks with "Done" to "deleted"
    var snapshot = await FirebaseFirestore.instance
        .collection('tasks')
        .where('email', isEqualTo: userEmail)
        .where('status', isEqualTo: "Done")
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

  // ---------------------------------------------------------------------------
  // WIDGET BUILD
  // ---------------------------------------------------------------------------
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
            // Greeting
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

            // Search
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

            // Status Legend
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Row(
                children: [
                  Text("Task Status: - "),
                  Row(
                    children: [
                      CircleAvatar(radius: 5, backgroundColor: Colors.yellow),
                      SizedBox(width: 5),
                      Text("ToDo"),
                    ],
                  ),
                  SizedBox(width: 10),
                  Row(
                    children: [
                      CircleAvatar(radius: 5, backgroundColor: Colors.blue),
                      SizedBox(width: 5),
                      Text("In Progress"),
                    ],
                  ),
                  SizedBox(width: 10),
                  Row(
                    children: [
                      CircleAvatar(radius: 5, backgroundColor: Colors.green),
                      SizedBox(width: 5),
                      Text("Done"),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(height: 10),

            // TASK LIST
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('tasks')
                    .where('email', isEqualTo: userEmail)
                    // Show all three statuses instead of just "pending"
                    .where('status',
                        whereIn: ["ToDo", "InProgress", "Done"]).snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return Center(child: CircularProgressIndicator());
                  }

                  var tasks = snapshot.data!.docs;

                  return ListView(
                    children: tasks.map((task) {
                      var data = task.data() as Map<String, dynamic>;
                      String currentStatus = data['status'] ?? 'ToDo';

                      // Parse assignedDate & dueDate (both stored as ISO strings)
                      DateTime? assignedDt;
                      DateTime? dueDt;
                      try {
                        assignedDt = DateTime.parse(data['assignedDate']);
                      } catch (_) {}
                      try {
                        dueDt = DateTime.parse(data['dueDate']);
                      } catch (_) {}

                      // Format them
                      String assignedDateStr = assignedDt == null
                          ? 'N/A'
                          : DateFormat('dd/MM/yyyy').format(assignedDt);
                      String dueDateStr = dueDt == null
                          ? 'N/A'
                          : DateFormat('dd/MM/yyyy').format(dueDt);

                      // Priority arrow
                      IconData priorityIcon;
                      switch (
                          (data['priority'] ?? '').toString().toLowerCase()) {
                        case 'high':
                          priorityIcon = Icons.arrow_upward;
                          break;
                        case 'low':
                          priorityIcon = Icons.arrow_downward;
                          break;
                        default:
                          // For "Medium" or anything else
                          priorityIcon = Icons.drag_handle;
                          break;
                      }

                      // Status-based text color
                      Color statusColor;
                      switch (data['status']) {
                        case 'InProgress':
                          statusColor = Colors.blue;
                          break;
                        case 'Done':
                          statusColor = Colors.green;
                          break;
                        case 'ToDo':
                        default:
                          statusColor = Colors.yellow;
                      }

                      // Task name
                      final String taskName = data['task'] ?? 'No Task';

                      return Container(
                        margin:
                            EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                        padding: EdgeInsets.all(8),
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
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Top row: Task Name + Priority + 3-dots
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                // Task Name
                                Expanded(
                                  child: Text(
                                    taskName,
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: statusColor,
                                    ),
                                  ),
                                ),
                                // Priority label + arrow
                                Row(
                                  children: [
                                    Text(
                                      "Priority",
                                      style: TextStyle(
                                        color: Colors.purple.shade900,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    SizedBox(width: 5),
                                    Icon(priorityIcon,
                                        color:
                                            priorityIcon == Icons.arrow_upward
                                                ? Colors.red
                                                : (priorityIcon ==
                                                        Icons.arrow_downward
                                                    ? Colors.grey
                                                    : Colors.orange)),
                                  ],
                                ),

                                // 3 dots (popup menu)
                                PopupMenuButton<String>(
                                  onSelected: (value) {
                                    // Update status in Firestore
                                    updateTaskStatus(task.id, value);
                                  },
                                  itemBuilder: (context) => [
                                    // A disabled heading
                                    PopupMenuItem<String>(
                                      enabled: false,
                                      child: Text(
                                        "Set Task Status",
                                        style: TextStyle(
                                            color: Colors.black,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                    // ToDo
                                    PopupMenuItem<String>(
                                      value: 'ToDo',
                                      child: Row(
                                        children: [
                                          Icon(
                                            Icons.radio_button_checked,
                                            color: (currentStatus == 'ToDo')
                                                ? Colors.yellow
                                                : Colors.grey,
                                          ),
                                          SizedBox(width: 8),
                                          Text('To Do'),
                                        ],
                                      ),
                                    ),
                                    // InProgress
                                    PopupMenuItem<String>(
                                      value: 'InProgress',
                                      child: Row(
                                        children: [
                                          Icon(
                                            Icons.radio_button_checked,
                                            color:
                                                (currentStatus == 'InProgress')
                                                    ? Colors.blue
                                                    : Colors.grey,
                                          ),
                                          SizedBox(width: 8),
                                          Text('In Progress'),
                                        ],
                                      ),
                                    ),
                                    // Done
                                    PopupMenuItem<String>(
                                      value: 'Done',
                                      child: Row(
                                        children: [
                                          Icon(
                                            Icons.radio_button_checked,
                                            color: (currentStatus == 'Done')
                                                ? Colors.green
                                                : Colors.grey,
                                          ),
                                          SizedBox(width: 8),
                                          Text('Done'),
                                        ],
                                      ),
                                    ),
                                  ],
                                  icon: Icon(Icons.more_vert),
                                ),
                              ],
                            ),
                            SizedBox(height: 5),
                            // Second row: Assigned Date & Due Date
                            Row(
                              children: [
                                Text(
                                  "Assigned Date: $assignedDateStr",
                                  style: TextStyle(fontSize: 14),
                                ),
                                SizedBox(width: 20),
                                Text(
                                  "Due Date: $dueDateStr",
                                  style: TextStyle(fontSize: 14),
                                ),
                              ],
                            ),
                          ],
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

      // FAB
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

      // Bottom Navigation
      bottomNavigationBar: BottomNavBar(onHistoryTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => HistoryScreen(
                    userEmail: userEmail,
                  )),
        );
      }),
    );
  }
}
