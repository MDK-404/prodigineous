// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// // import your custom app bar

// // import other packages as needed (e.g., firebase_auth if you need current user)
// import 'package:intl/intl.dart';
// import 'package:prodigenious/widgets/custom_appbar.dart';

// class HistoryScreen extends StatefulWidget {
//   final String userEmail; // pass in the user's email

//   const HistoryScreen({Key? key, required this.userEmail}) : super(key: key);

//   @override
//   State<HistoryScreen> createState() => _HistoryScreenState();
// }

// class _HistoryScreenState extends State<HistoryScreen> {
//   /// Clears all tasks from history by setting status to 'deleted'.
//   /// We define "history" tasks as either:
//   ///  - status == 'Done'
//   ///  - dueDate < now AND status != 'deleted'
//   Future<void> _clearHistory() async {
//     final now = DateTime.now();

//     // Fetch all tasks for this user
//     final query = await FirebaseFirestore.instance
//         .collection('tasks')
//         .where('email', isEqualTo: widget.userEmail)
//         .get();

//     for (var doc in query.docs) {
//       final data = doc.data();
//       final status = data['status'] ?? '';

//       // Convert dueDate if it's stored as a String
//       DateTime? dueDate;
//       if (data['dueDate'] != null) {
//         try {
//           dueDate = DateTime.parse(data['dueDate']);
//         } catch (_) {
//           // handle parse error if needed
//         }
//       }

//       // If the task is done OR overdue (and not already deleted), set to 'deleted'
//       if (status == 'Done' ||
//           (dueDate != null && dueDate.isBefore(now) && status != 'deleted')) {
//         await doc.reference.update({'status': 'deleted'});
//       }
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       // Use your custom app bar here
//       appBar:
//           CustomAppBar(), // If your custom app bar has a logo/hamburger, it will appear

//       body: Padding(
//         padding: const EdgeInsets.all(10.0),
//         child: Column(
//           children: [
//             /// -------------------- TOP ROW: Title & Clear Button --------------------
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 // "Task History" + icon
//                 Row(
//                   children: [
//                     // The icon sized to match text
//                     Icon(
//                       Icons.history,
//                       size: 24,
//                       color: Color(0xFF2E3A59),
//                     ),
//                     const SizedBox(width: 8),
//                     Text(
//                       "Task History",
//                       style: TextStyle(
//                         fontSize: 24,
//                         fontWeight: FontWeight.bold,
//                         color: Color(0xFF2E3A59),
//                       ),
//                     ),
//                   ],
//                 ),

//                 // Clear History button
//                 ElevatedButton.icon(
//                   onPressed: () async {
//                     await _clearHistory();
//                   },
//                   icon: const Icon(Icons.delete, color: Colors.white),
//                   label: const Text("Clear History"),
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: Color(0xFFA558E0),
//                     foregroundColor: Colors.white,
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(8),
//                     ),
//                   ),
//                 ),
//               ],
//             ),

//             const SizedBox(height: 8),

//             /// -------------------- LEGEND TEXT --------------------
//             Align(
//               alignment: Alignment.centerLeft,
//               child: Text(
//                 "Previous Task Can be found here",
//                 style: TextStyle(
//                   fontSize: 14,
//                   color: Colors.black87,
//                 ),
//               ),
//             ),
//             const SizedBox(height: 8),

//             // Legend: Complete task (green), Terminated task (red)
//             Row(
//               children: [
//                 // Complete
//                 _buildColoredDot(Colors.green),
//                 const SizedBox(width: 4),
//                 const Text("Complete Task"),

//                 const SizedBox(width: 16),

//                 // Terminated
//                 _buildColoredDot(Colors.red),
//                 const SizedBox(width: 4),
//                 const Text("Terminated Task"),
//               ],
//             ),

//             const SizedBox(height: 10),

//             /// -------------------- TASK LIST (EXPANDED) --------------------
//             Expanded(
//               child: StreamBuilder<QuerySnapshot>(
//                 stream: FirebaseFirestore.instance
//                     .collection('tasks')
//                     .where('email', isEqualTo: widget.userEmail)
//                     .snapshots(),
//                 builder: (context, snapshot) {
//                   if (!snapshot.hasData) {
//                     return const Center(child: CircularProgressIndicator());
//                   }

//                   final now = DateTime.now();

//                   // Filter tasks to show only "Done" or "overdue (past dueDate) but not 'deleted'"
//                   final historyDocs = snapshot.data!.docs.where((doc) {
//                     final data = doc.data() as Map<String, dynamic>;
//                     final status = data['status'] ?? '';

//                     // parse the dueDate
//                     DateTime? dueDate;
//                     if (data['dueDate'] != null) {
//                       try {
//                         dueDate = DateTime.parse(data['dueDate']);
//                       } catch (_) {}
//                     }

//                     // Condition:
//                     // 1) If status == 'Done' -> show
//                     // 2) If dueDate < now AND status != 'deleted' -> show
//                     // (You could also skip tasks if status == 'deleted')
//                     if (status == 'Done') {
//                       return true;
//                     } else if (dueDate != null &&
//                         dueDate.isBefore(now) &&
//                         status != 'deleted') {
//                       return true;
//                     }
//                     return false;
//                   }).toList();

//                   if (historyDocs.isEmpty) {
//                     return const Center(
//                       child: Text("No history tasks found."),
//                     );
//                   }

//                   return ListView(
//                     children: historyDocs.map((doc) {
//                       final data = doc.data() as Map<String, dynamic>;

//                       // Determine if it's "Done" or "Terminated"
//                       final status = data['status'] ?? '';
//                       final isDone = (status == 'Done');

//                       // Decide text color
//                       final textColor = isDone ? Colors.green : Colors.red;

//                       // Task name
//                       final String taskName = data['task'] ?? 'No Task';

//                       // Priority
//                       final priority = data['priority'] ?? 'Low';
//                       IconData priorityIcon;
//                       switch (priority.toLowerCase()) {
//                         case 'high':
//                           priorityIcon = Icons.arrow_upward;
//                           break;
//                         case 'low':
//                           priorityIcon = Icons.arrow_downward;
//                           break;
//                         default:
//                           // "medium" or something else
//                           priorityIcon = Icons.drag_handle;
//                       }

//                       // Assigned date
//                       DateTime? assignedDate;
//                       if (data['assignedDate'] != null) {
//                         try {
//                           assignedDate = DateTime.parse(data['assignedDate']);
//                         } catch (_) {}
//                       }
//                       final assignedDateStr = (assignedDate == null)
//                           ? 'N/A'
//                           : DateFormat('d/M/yyyy').format(assignedDate);

//                       return Container(
//                         margin: const EdgeInsets.symmetric(
//                             vertical: 5, horizontal: 5),
//                         padding: const EdgeInsets.all(8),
//                         decoration: BoxDecoration(
//                           color: Colors.white,
//                           border: Border.all(
//                             color: const Color(0xff3D0087),
//                             width: 2,
//                           ),
//                           borderRadius: BorderRadius.circular(10),
//                           boxShadow: const [
//                             BoxShadow(
//                               color: Colors.black12,
//                               blurRadius: 4,
//                               offset: Offset(2, 2),
//                             ),
//                           ],
//                         ),
//                         child: Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             // Row with Task Name & Priority
//                             Row(
//                               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                               children: [
//                                 Expanded(
//                                   child: Text(
//                                     taskName,
//                                     style: TextStyle(
//                                       fontSize: 18,
//                                       fontWeight: FontWeight.bold,
//                                       color: textColor, // green or red
//                                     ),
//                                   ),
//                                 ),
//                                 Row(
//                                   children: [
//                                     const Text(
//                                       "Priority",
//                                       style: TextStyle(
//                                         color: Colors.black54,
//                                         fontWeight: FontWeight.bold,
//                                       ),
//                                     ),
//                                     const SizedBox(width: 4),
//                                     Icon(
//                                       priorityIcon,
//                                       color: (priority.toLowerCase() == 'high')
//                                           ? Colors.red
//                                           : (priority.toLowerCase() == 'low'
//                                               ? Colors.grey
//                                               : Colors.orange),
//                                     ),
//                                   ],
//                                 ),
//                               ],
//                             ),
//                             const SizedBox(height: 8),

//                             // Assigned Date
//                             Text(
//                               "Assigned Date : $assignedDateStr",
//                               style: const TextStyle(fontSize: 14),
//                             ),
//                           ],
//                         ),
//                       );
//                     }).toList(),
//                   );
//                 },
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   // A helper widget to draw a small colored dot
//   Widget _buildColoredDot(Color color) {
//     return Container(
//       width: 10,
//       height: 10,
//       decoration: BoxDecoration(color: color, shape: BoxShape.circle),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:prodigenious/widgets/custom_appbar.dart';
import 'package:prodigenious/widgets/navigation_bar.dart';

// Import your custom app bar

// If you need userEmail from outside, pass it in or fetch from FirebaseAuth

class HistoryScreen extends StatefulWidget {
  final String userEmail;
  const HistoryScreen({Key? key, required this.userEmail}) : super(key: key);

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  // If you need to show an "Add Task" dialog or something, you can reuse your existing method:
  void showAddTaskDialog() {
    // Your code for adding tasks
    // But typically you might not add tasks from the History page
  }

  // Optionally, a function to navigate back to home or something else
  void _onHomeTap() {
    Navigator.pop(context); // or push to HomeScreen if you want
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // 1) Custom App Bar at top
      appBar: CustomAppBar(),

      // 2) Body with heading + tasks
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          children: [
            /// -------------------- Title Row: "Task History" + Icon + Explanation --------------------
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

            // Additional text
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Previous Tasks can be found here",
                style: TextStyle(fontSize: 14, color: Colors.black87),
              ),
            ),
            const SizedBox(height: 8),

            // Could add a small legend if you want:
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

            /// -------------------- TASK LIST (Expanded) --------------------
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

                  // Filter tasks: show only tasks whose dueDate < now
                  // i.e. "due date has passed"
                  final historyTasks = docs.where((doc) {
                    final data = doc.data() as Map<String, dynamic>;
                    // parse dueDate
                    DateTime? dueDate;
                    if (data['dueDate'] != null) {
                      try {
                        dueDate = DateTime.parse(data['dueDate']);
                      } catch (_) {}
                    }

                    // If no valid dueDate, skip
                    if (dueDate == null) return false;

                    // Show only if dueDate is before now
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

                      // parse assignedDate if you want to display it
                      DateTime? assignedDate;
                      if (data['assignedDate'] != null) {
                        try {
                          assignedDate = DateTime.parse(data['assignedDate']);
                        } catch (_) {}
                      }

                      // decide text color
                      // if status == 'Done' => green
                      // else => red
                      final Color textColor =
                          (status == 'Done') ? Colors.green : Colors.red;

                      // decide priority icon
                      IconData priorityIcon;
                      switch (priority.toLowerCase()) {
                        case 'high':
                          priorityIcon = Icons.arrow_upward;
                          break;
                        case 'low':
                          priorityIcon = Icons.arrow_downward;
                          break;
                        default:
                          priorityIcon = Icons.drag_handle; // for "medium" etc.
                          break;
                      }

                      // format assignedDate
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
                            // Row: TaskName + Priority
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    taskName,
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: textColor, // green or red
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

      // 3) Floating Action Button (same style as Home)
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

      // 4) BottomNavBar with "history" active
      bottomNavigationBar: BottomNavBar(
        activeScreen: "history",
        onHomeTap: _onHomeTap,
        // If you want the other icons to do something, define them
        onRefreshTap: () {},
        onNotificationTap: () {},
        onHistoryTap: () {
          // Already on history, so maybe do nothing or show a toast
        },
      ),
    );
  }

  // A small widget for your green/red legend dots
  Widget _coloredDot(Color color) {
    return Container(
      width: 10,
      height: 10,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }
}
