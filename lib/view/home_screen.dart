import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:prodigenious/services/ai_task_prioritizer.dart';
import 'package:prodigenious/services/notificaiton_service.dart';
import 'package:prodigenious/view/task_history.dart';
import 'package:prodigenious/widgets/add_task_dialog.dart';
import 'package:prodigenious/widgets/custom_appbar.dart';
import 'package:prodigenious/widgets/navigation_bar.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String username = "";
  String userEmail = "";

  bool hasCompletedTasks = false;

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      NotificationService.markDeliveredNotificationsIfTimePassed();
    });
    fetchUserData();
    final userEmail = FirebaseAuth.instance.currentUser?.email;
    if (userEmail != null) {
      NotificationService.markAllAsTapped(userEmail);
    }
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

  void updateTaskStatus(String taskId, String newStatus) async {
    final taskRef = FirebaseFirestore.instance.collection('tasks').doc(taskId);

    final Map<String, dynamic> updateData = {
      'status': newStatus,
    };

    if (newStatus == 'Done') {
      updateData['completedDate'] = FieldValue.serverTimestamp();
    }

    await taskRef.update(updateData);
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
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Row(
                children: [
                  Text("Task Status: - "),
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 5,
                        backgroundColor: Color(0xffFFCF0F),
                      ),
                      SizedBox(width: 5),
                      Text("ToDo"),
                    ],
                  ),
                  SizedBox(width: 10),
                  Row(
                    children: [
                      CircleAvatar(
                          radius: 5, backgroundColor: Color(0xff0B7CFE)),
                      SizedBox(width: 5),
                      Text("In Progress"),
                    ],
                  ),
                  SizedBox(width: 10),
                  Row(
                    children: [
                      CircleAvatar(
                          radius: 5, backgroundColor: Color(0xff0CC302)),
                      SizedBox(width: 5),
                      Text("Done"),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(height: 10),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('tasks')
                    .where('email', isEqualTo: userEmail)
                    .where('status',
                        whereIn: ["ToDo", "InProgress", "Done"]).snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return Center(child: CircularProgressIndicator());
                  }

                  var rawTasks = snapshot.data!.docs;
                  var tasks = AITaskPrioritizer.prioritizeTasks(rawTasks);

                  return ListView(
                    children: tasks.map((task) {
                      var data = task.data() as Map<String, dynamic>;
                      String currentStatus = data['status'] ?? 'ToDo';
                      bool isAiPrioritized =
                          AITaskPrioritizer.isTaskAIPrioritized(task);
                      DateTime? assignedDt;
                      DateTime? dueDt;
                      try {
                        assignedDt =
                            (data['assignedDate'] as Timestamp).toDate();
                      } catch (_) {}
                      try {
                        dueDt = (data['dueDate'] as Timestamp).toDate();
                      } catch (_) {}
                      String assignedDateStr = assignedDt == null
                          ? 'N/A'
                          : DateFormat('dd/MM/yyyy').format(assignedDt);
                      String dueDateStr = dueDt == null
                          ? 'N/A'
                          : DateFormat('dd/MM/yyyy').format(dueDt);

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
                          priorityIcon = Icons.drag_handle;
                          break;
                      }

                      Color statusColor;
                      switch (data['status']) {
                        case 'InProgress':
                          statusColor = Color(0xff0B7CFE);
                          break;
                        case 'Done':
                          statusColor = Color(0xff0CC302);
                          break;
                        case 'ToDo':
                        default:
                          statusColor = Color(0xffFFCF0F);
                      }

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
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Row(
                                    children: [
                                      if (isAiPrioritized)
                                        Icon(Icons.smart_toy_rounded,
                                            color: Colors.deepPurple, size: 20),
                                      if (isAiPrioritized) SizedBox(width: 4),
                                      Flexible(
                                        child: Text(
                                          taskName,
                                          style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                            color: statusColor,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
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
                                PopupMenuButton<String>(
                                  onSelected: (value) {
                                    updateTaskStatus(task.id, value);
                                  },
                                  itemBuilder: (context) => [
                                    PopupMenuItem<String>(
                                      enabled: false,
                                      child: Text(
                                        "Set Task Status",
                                        style: TextStyle(
                                            color: Colors.black,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                    PopupMenuItem<String>(
                                      value: 'ToDo',
                                      child: Row(
                                        children: [
                                          Icon(
                                            Icons.radio_button_checked,
                                            color: (currentStatus == 'ToDo')
                                                ? Color(0xffFFCF0F)
                                                : Colors.grey,
                                          ),
                                          SizedBox(width: 8),
                                          Text('To Do'),
                                        ],
                                      ),
                                    ),
                                    PopupMenuItem<String>(
                                      value: 'InProgress',
                                      child: Row(
                                        children: [
                                          Icon(
                                            Icons.radio_button_checked,
                                            color:
                                                (currentStatus == 'InProgress')
                                                    ? Color(0xff0B7CFE)
                                                    : Colors.grey,
                                          ),
                                          SizedBox(width: 8),
                                          Text('In Progress'),
                                        ],
                                      ),
                                    ),
                                    PopupMenuItem<String>(
                                      value: 'Done',
                                      child: Row(
                                        children: [
                                          Icon(
                                            Icons.radio_button_checked,
                                            color: (currentStatus == 'Done')
                                                ? Color(0xff0CC302)
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
      floatingActionButton: Transform.translate(
        offset: Offset(0, 35),
        child: Container(
          height: 70,
          width: 70,
          child: FloatingActionButton(
            onPressed: () {
              showAddTaskDialog(context, username, userEmail);
            },
            backgroundColor: Colors.purple,
            shape: CircleBorder(
              side: BorderSide(color: Colors.white, width: 5),
            ),
            child: Icon(Icons.add, size: 35, color: Colors.white),
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: StreamBuilder<int>(
        stream: NotificationService.getUnreadNotificationCount(userEmail),
        builder: (context, snapshot) {
          final unreadCount = snapshot.data ?? 0;

          return BottomNavBar(
            activeScreen: 'home',
            unreadNotificationCount: unreadCount,
            onScheduledTap: () {
              Navigator.pushNamed(context, '/scheduled_task_screen');
            },
            onHistoryTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => HistoryScreen(
                    userEmail: userEmail,
                    username: username,
                  ),
                ),
              );
            },
            onNotificationTap: () {
              Navigator.pushReplacementNamed(context, '/notifications');
            },
          );
        },
      ),
    );
  }
}
