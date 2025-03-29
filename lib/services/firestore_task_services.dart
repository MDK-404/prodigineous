import 'package:cloud_firestore/cloud_firestore.dart';

Future<void> addTaskToFirestore(String task, String priority, DateTime dueDate,
    String username, String userEmail) async {
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
