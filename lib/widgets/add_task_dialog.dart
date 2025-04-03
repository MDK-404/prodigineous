import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:prodigenious/services/firestore_task_services.dart';
import 'package:prodigenious/services/notificaiton_service.dart';

void showAddTaskDialog(
    BuildContext context, String username, String userEmail) {
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
                      Navigator.of(context).pop();
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
                onPressed: () async {
                  if (taskController.text.isEmpty || selectedDueDate == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Please enter all details")),
                    );
                    return;
                  }
                  String taskTitle = taskController.text.trim();

                  addTaskToFirestore(
                    taskController.text.trim(),
                    selectedPriority,
                    selectedDueDate!,
                    username,
                    userEmail,
                  );
                  if (selectedDueDate != null) {
                    DateTime now = DateTime.now();
                    DateTime notificationDate1 = selectedDueDate!
                        .subtract(Duration(days: 2)); // 2 din pehle
                    DateTime notificationDate2 = selectedDueDate!
                        .subtract(Duration(days: 1)); // 1 din pehle

                    if (notificationDate1.isAfter(now)) {
                      if (kDebugMode) {
                        print(
                            "🔔 Scheduling Notification for: $notificationDate1");
                      }
                      await NotificationService.scheduleNotification(
                        id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
                        title: "Task Reminder",
                        body: "Your task '$taskTitle ' is due in 2 days!",
                        scheduledDate: notificationDate1,
                        userEmail: userEmail,
                      );
                    }

                    if (notificationDate2.isAfter(now)) {
                      await NotificationService.scheduleNotification(
                          id: (DateTime.now().millisecondsSinceEpoch ~/ 1000) +
                              1,
                          title: "Task Reminder",
                          body: "Your task '$taskTitle' is due tomorrow!",
                          scheduledDate: notificationDate2,
                          userEmail: userEmail);
                    }
                  }
                  Navigator.of(context).pop();
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
