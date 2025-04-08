import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:prodigenious/widgets/color_circle_custom_widget.dart';
import 'package:prodigenious/widgets/custom_appbar.dart';
import 'package:prodigenious/widgets/navigation_bar.dart';
import 'package:prodigenious/widgets/task_dashboard_chart.dart';

class TaskDashboardScreen extends StatefulWidget {
  final String userEmail;

  const TaskDashboardScreen({required this.userEmail});

  @override
  State<TaskDashboardScreen> createState() => _TaskDashboardScreenState();
}

class _TaskDashboardScreenState extends State<TaskDashboardScreen> {
  int done = 0;
  int todo = 0;
  int inProgress = 0;
  int terminated = 0;

  Future<void> fetchData() async {
    final now = DateTime.now();

    final tasks = await FirebaseFirestore.instance
        .collection('tasks')
        .where('email', isEqualTo: widget.userEmail)
        .get();

    int _done = 0, _todo = 0, _inProgress = 0;

    for (var doc in tasks.docs) {
      final data = doc.data();
      final Timestamp due = data['dueDate'];
      final DateTime dueDate = due.toDate();
      final String status = data['status'];

      if (status == 'Done') {
        _done++;
      } else if (dueDate.isAfter(now)) {
        if (status == 'ToDo') {
          _todo++;
        } else if (status == 'InProgress') {
          _inProgress++;
        }
      }
    }

    final history = await FirebaseFirestore.instance
        .collection('history')
        .where('email', isEqualTo: widget.userEmail)
        .get();

    int _terminated = 0;

    for (var doc in history.docs) {
      final data = doc.data();
      final String status = data['status'];
      final Timestamp due = data['dueDate'];
      final DateTime dueDate = due.toDate();

      if (status != 'Done' && dueDate.isBefore(now)) {
        _terminated++;
      } else if (status == 'Done') {
        _done++; // count completed in history too
      }
    }

    setState(() {
      done = _done;
      todo = _todo;
      inProgress = _inProgress;
      terminated = _terminated;
    });
  }

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  void _onHomeTap() {
    Navigator.popAndPushNamed(context, '/home');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(),
      body: Padding(
        padding: const EdgeInsets.all(14.0),
        child: Column(
          children: [
            Row(
              children: [
                Icon(Icons.dashboard, color: Colors.deepPurple),
                SizedBox(width: 8),
                Text(
                  "Task Dashboard",
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            TaskStatusLegend(),
            SizedBox(height: 10),
            Align(
              alignment: Alignment.centerLeft,
              child: ElevatedButton.icon(
                onPressed: fetchData,
                icon: Icon(
                  Icons.refresh,
                  color: Colors.white,
                ),
                label: Text(
                  "Refresh Dashboard",
                  style: GoogleFonts.poppins(fontSize: 16, color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xff945FD4),
                  shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(6), // 🔸 less rounded corners
                  ),
                ),
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                child: TaskDashboardChart(
                  done: done,
                  todo: todo,
                  inProgress: inProgress,
                  terminated: terminated,
                ),
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
            onPressed: () {},
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
        activeScreen: "dashboard",
        onHomeTap: _onHomeTap,
        onScheduledTap: () {
          Navigator.pushNamed(context, '/scheduled_task_screen');
        },
        onNotificationTap: () {
          Navigator.pushNamed(context, '/notifications');
        },
        onHistoryTap: () {
          Navigator.pushNamed(context, '/history');
        },
      ),
    );
  }
}
