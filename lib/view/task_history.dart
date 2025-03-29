import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:prodigenious/widgets/add_task_dialog.dart';
import 'package:prodigenious/widgets/custom_appbar.dart';
import 'package:prodigenious/widgets/navigation_bar.dart';

class HistoryScreen extends StatefulWidget {
  final String userEmail;
  final String username; // ADD THIS

  const HistoryScreen({
    Key? key,
    required this.userEmail,
    required this.username, // ADD THIS
  }) : super(key: key);

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  // void showAddTaskDialog() {}

  void _onHomeTap() {
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(),
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Icon(Icons.history, size: 24, color: Color(0xFF2E3A59)),
                const SizedBox(width: 8),
                Text(
                  "Task History",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2E3A59),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Previous Tasks can be found here",
                style: TextStyle(fontSize: 14, color: Colors.black87),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                _coloredDot(Colors.green),
                SizedBox(width: 4),
                Text("Done Task"),
                SizedBox(width: 20),
                _coloredDot(Colors.red),
                SizedBox(width: 4),
                Text("Overdue Task"),
              ],
            ),
            const SizedBox(height: 10),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('tasks')
                    .where('email', isEqualTo: widget.userEmail)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final now = DateTime.now();
                  final docs = snapshot.data!.docs;

                  final historyTasks = docs.where((doc) {
                    final data = doc.data() as Map<String, dynamic>;

                    DateTime? dueDate;
                    if (data['dueDate'] != null) {
                      try {
                        dueDate = DateTime.parse(data['dueDate']);
                      } catch (_) {}
                    }

                    if (dueDate == null) return false;

                    return dueDate.isBefore(now);
                  }).toList();

                  if (historyTasks.isEmpty) {
                    return const Center(
                      child: Text("No history tasks found."),
                    );
                  }

                  return ListView(
                    children: historyTasks.map((doc) {
                      final data = doc.data() as Map<String, dynamic>;
                      final String taskName = data['task'] ?? 'No Task';
                      final String status = data['status'] ?? 'unknown';
                      final String priority = data['priority'] ?? 'Low';

                      DateTime? assignedDate;
                      if (data['assignedDate'] != null) {
                        try {
                          assignedDate = DateTime.parse(data['assignedDate']);
                        } catch (_) {}
                      }

                      final Color textColor =
                          (status == 'Done') ? Colors.green : Colors.red;

                      IconData priorityIcon;
                      switch (priority.toLowerCase()) {
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

                      final assignedStr = (assignedDate == null)
                          ? 'N/A'
                          : DateFormat('dd/MM/yyyy').format(assignedDate);

                      return Container(
                        margin:
                            EdgeInsets.symmetric(vertical: 5, horizontal: 5),
                        padding: EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border:
                              Border.all(color: Color(0xff3D0087), width: 2),
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: const [
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
                                  child: Text(
                                    taskName,
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: textColor,
                                    ),
                                  ),
                                ),
                                Row(
                                  children: [
                                    Text(
                                      "Priority",
                                      style: TextStyle(
                                        color: Colors.black54,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    SizedBox(width: 4),
                                    Icon(
                                      priorityIcon,
                                      color: (priority.toLowerCase() == 'high')
                                          ? Colors.red
                                          : (priority.toLowerCase() == 'low'
                                              ? Colors.grey
                                              : Colors.orange),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              "Assigned Date : $assignedStr",
                              style: TextStyle(fontSize: 14),
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
              showAddTaskDialog(context, widget.userEmail,
                  widget.username); // Correct way to pass arguments
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
      bottomNavigationBar: BottomNavBar(
        activeScreen: "history",
        onHomeTap: _onHomeTap,
        onRefreshTap: () {},
        onNotificationTap: () {},
        onHistoryTap: () {},
      ),
    );
  }

  Widget _coloredDot(Color color) {
    return Container(
      width: 10,
      height: 10,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }
}
