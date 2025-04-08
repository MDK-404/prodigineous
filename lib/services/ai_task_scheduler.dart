import 'package:cloud_firestore/cloud_firestore.dart';

class AITaskScheduler {
  static List<QueryDocumentSnapshot> scheduleTasks(
      List<QueryDocumentSnapshot> tasks) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day); // Just date part

    List<QueryDocumentSnapshot> high = [];
    List<QueryDocumentSnapshot> medium = [];
    List<QueryDocumentSnapshot> low = [];

    // Optional: For grouping by due date (not required here, but for reference)
    Map<String, List<QueryDocumentSnapshot>> dueDateMap = {};

    for (var task in tasks) {
      var data = task.data() as Map<String, dynamic>;

      // Skip if task is marked as done
      if ((data['status'] ?? '').toString().toLowerCase() == 'done') continue;

      // Skip if dueDate is missing or invalid
      DateTime? dueDate;
      try {
        dueDate = (data['dueDate'] as Timestamp).toDate();
      } catch (_) {
        continue;
      }

      final DateTime cleanDueDate =
          DateTime(dueDate.year, dueDate.month, dueDate.day);
      final int daysUntilDue = cleanDueDate.difference(today).inDays;

      // Skip if due date is already passed
      if (cleanDueDate.isBefore(today)) continue;

      final String priority = (data['priority'] ?? 'medium').toLowerCase();

      // Group tasks by rules
      if (priority == 'high' && daysUntilDue <= 2) {
        high.add(task);
      } else if (priority == 'medium' && daysUntilDue <= 2) {
        medium.add(task);
      } else if (priority == 'low' && daysUntilDue == 0) {
        low.add(task);
      }
    }

    // Sort all by due date ascending
    high.sort((a, b) => _dueDateOf(a).compareTo(_dueDateOf(b)));
    medium.sort((a, b) => _dueDateOf(a).compareTo(_dueDateOf(b)));
    low.sort((a, b) => _dueDateOf(a).compareTo(_dueDateOf(b)));

    return [...high, ...medium, ...low];
  }

  static DateTime _dueDateOf(QueryDocumentSnapshot task) {
    return (task['dueDate'] as Timestamp).toDate();
  }
}
