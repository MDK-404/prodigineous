import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:prodigenious/widgets/custom_appbar.dart';
import 'package:prodigenious/widgets/task_productivity_chart.dart';

class ProductivityScreen extends StatefulWidget {
  const ProductivityScreen({super.key});

  @override
  State<ProductivityScreen> createState() => _ProductivityScreenState();
}

class _ProductivityScreenState extends State<ProductivityScreen> {
  int monthlyAssigned = 0;
  int monthlyDone = 0;
  int monthlyFailed = 0;

  int weeklyAssigned = 0;
  int weeklyDone = 0;
  int weeklyFailed = 0;

  double monthlyProgress = 0.0;

  @override
  void initState() {
    super.initState();
    fetchTaskStats();
  }

  Future<void> fetchTaskStats() async {
    final now = DateTime.now();
    final firstDayOfMonth = DateTime(now.year, now.month, 1);
    final firstDayOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final today = DateTime(now.year, now.month, now.day);

    final tasksSnapshot =
        await FirebaseFirestore.instance.collection('tasks').get();

    int mAssigned = 0, mDone = 0, mFailed = 0;
    int wAssigned = 0, wDone = 0, wFailed = 0;

    for (var doc in tasksSnapshot.docs) {
      final data = doc.data();
      final status = data['status'] ?? '';
      final dueDate = (data['dueDate'] as Timestamp).toDate();

      if (dueDate.isAfter(firstDayOfMonth)) {
        mAssigned++;
        if (status == 'Done') {
          mDone++;
        } else if (dueDate.isBefore(today)) {
          mFailed++;
        }
      }

      if (dueDate.isAfter(firstDayOfWeek)) {
        wAssigned++;
        if (status == 'Done') {
          wDone++;
        } else if (dueDate.isBefore(today)) {
          wFailed++;
        }
      }
    }

    setState(() {
      monthlyAssigned = mAssigned;
      monthlyDone = mDone;
      monthlyFailed = mFailed;

      weeklyAssigned = wAssigned;
      weeklyDone = wDone;
      weeklyFailed = wFailed;

      monthlyProgress = mAssigned > 0 ? (mDone / mAssigned) : 0.0;
    });
  }

  // Widget section(String title, int assigned, int done, int failed) {
  //   return Column(
  //     crossAxisAlignment: CrossAxisAlignment.start,
  //     children: [
  //       const SizedBox(height: 25),
  //       Text(
  //         title,
  //         style: GoogleFonts.poppins(
  //           fontSize: 20,
  //           fontWeight: FontWeight.w600,
  //         ),
  //       ),
  //       const SizedBox(height: 10),
  //       Row(
  //         crossAxisAlignment: CrossAxisAlignment.center,
  //         children: [
  //           Expanded(
  //             flex: 2,
  //             child: SizedBox(
  //               height: 120,
  //               child: Container(
  //                 padding: const EdgeInsets.all(16),
  //                 decoration: BoxDecoration(
  //                   color: const Color(0xFFB388FF),
  //                   borderRadius: BorderRadius.circular(16),
  //                 ),
  //                 child: Center(
  //                   child: Text(
  //                     "Assigned Tasks\n$assigned",
  //                     style: const TextStyle(
  //                       color: Colors.white,
  //                       fontWeight: FontWeight.bold,
  //                       fontSize: 16,
  //                     ),
  //                     textAlign: TextAlign.center,
  //                   ),
  //                 ),
  //               ),
  //             ),
  //           ),
  //           const SizedBox(width: 8),
  //           Expanded(
  //             flex: 2,
  //             child: SizedBox(
  //               height: 120,
  //               child: TaskProductivityChart(
  //                 done: done,
  //                 todo: assigned - (done + failed),
  //                 inProgress: 0,
  //                 terminated: failed,
  //               ),
  //             ),
  //           ),
  //         ],
  //       ),
  //     ],
  //   );
  // }

  Widget section(String title, int assigned, int done, int failed) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 25),
        Text(
          title,
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 10),

        // Assigned Task & Pie Chart in a Row
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              flex: 2,
              child: SizedBox(
                height: 120,
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFB388FF),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Center(
                    child: Text(
                      "Assigned Tasks\n$assigned",
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              flex: 2,
              child: SizedBox(
                height: 180,
                child: TaskProductivityChart(
                    done: done,
                    todo: assigned - (done + failed),
                    inProgress: 0,
                    terminated: failed,
                    showLegend: false),
              ),
            ),
          ],
        ),

        const SizedBox(height: 12),

        // Row for Done & Failed stats
        Row(
          children: [
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.green, width: 1.5),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    const Text(
                      "Tasks Done",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      "$done",
                      style: const TextStyle(
                        color: Colors.green,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.red, width: 1.5),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    const Text(
                      "Tasks Failure",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      "$failed",
                      style: const TextStyle(
                        color: Colors.red,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        )
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Heading
              Row(
                children: [
                  const Icon(Icons.insights, color: Color(0xFF2E3A59)),
                  const SizedBox(width: 8),
                  Text(
                    "My Insights",
                    style: GoogleFonts.poppins(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF2E3A59),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Monthly Progress
              Row(
                children: const [
                  Text("Congrats! 🎉",
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                ],
              ),
              const SizedBox(height: 8),
              const Text(
                "Overall Monthly Progress",
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 6),
              LinearProgressIndicator(
                value: monthlyProgress,
                color: Colors.green,
                backgroundColor: Colors.grey[300],
              ),
              const SizedBox(height: 6),
              Text("${(monthlyProgress * 100).toInt()}%",
                  style: const TextStyle(fontWeight: FontWeight.w500)),

              const Divider(height: 32, thickness: 1),

              // Monthly Report
              section("Monthly Report", monthlyAssigned, monthlyDone,
                  monthlyFailed),

              const SizedBox(height: 32),

              // Weekly Report
              section(
                  "Weekly Report", weeklyAssigned, weeklyDone, weeklyFailed),
            ],
          ),
        ),
      ),
    );
  }
}
