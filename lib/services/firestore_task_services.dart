import 'package:cloud_firestore/cloud_firestore.dart';

Future<void> addTaskToFirestore(String task, String priority, DateTime dueDate,
    String username, String userEmail) async {
  await FirebaseFirestore.instance.collection('tasks').add({
    'task': task,
    'priority': priority,
    'dueDate': Timestamp.fromDate(dueDate),
    'assignedDate': DateTime.now(),
    'username': username,
    'email': userEmail,
    'status': "ToDo",
  });
}

Future<void> checkAndMoveTasksToHistory() async {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final DateTime now = DateTime.now();

  final QuerySnapshot tasksSnapshot = await firestore.collection('tasks').get();

  for (final DocumentSnapshot doc in tasksSnapshot.docs) {
    final data = doc.data() as Map<String, dynamic>;
    final Timestamp? dueDateTimestamp = data['dueDate'];

    if (dueDateTimestamp != null) {
      final DateTime dueDate = dueDateTimestamp.toDate();

      print("Checking task ${doc.id} with due date: $dueDate, now: $now");

      if (dueDate.isBefore(now)) {
        // Add a flag to prevent duplicate history entries
        final historyDoc =
            await firestore.collection('history').doc(doc.id).get();
        if (!historyDoc.exists) {
          await firestore.collection('history').doc(doc.id).set({
            ...data,
            'movedToHistoryAt': FieldValue.serverTimestamp(),
          });
          print("Copied task ${doc.id} to history");
        }
      }
    }
  }
}

Future<void> markNotificationAsDelivered(String notificationId) async {
  await FirebaseFirestore.instance
      .collection('notifications')
      .doc(notificationId)
      .update({'isDelivered': true});
}
