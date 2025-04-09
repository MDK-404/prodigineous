import 'package:flutter/material.dart';
import 'package:prodigenious/services/firestore_task_services.dart';
import 'package:prodigenious/services/notificaiton_service.dart';

void showAddTaskDialog(
    BuildContext context, String username, String userEmail) {
  TextEditingController taskController = TextEditingController();
  String selectedPriority = "High";
  DateTime? selectedDueDate;
  TimeOfDay? selectedTime;

  showDialog(
    context: context,
    builder: (context) {
      return Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(25),
        ),
        backgroundColor: Color(0xFFA558E0),
        child: SingleChildScrollView(
          child: Container(
            padding: EdgeInsets.all(20),
            width: MediaQuery.of(context).size.width * 0.85,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
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
                              DateTime? pickedDate = await showDatePicker(
                                context: context,
                                initialDate: DateTime.now(),
                                firstDate: DateTime(2023),
                                lastDate: DateTime(2100),
                              );
                              if (pickedDate != null) {
                                selectedDueDate = pickedDate;
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
                SizedBox(height: 10),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "Select Time",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
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
                    TimeOfDay? pickedTime = await showTimePicker(
                      context: context,
                      initialTime: TimeOfDay.now(),
                    );
                    if (pickedTime != null) {
                      selectedTime = pickedTime;
                    }
                  },
                  icon: Icon(Icons.access_time, size: 18),
                  label: Text("Select Time"),
                ),
                SizedBox(height: 20),
                Divider(color: Colors.white, thickness: 1),
                SizedBox(height: 10),
                ElevatedButton(
                  onPressed: () async {
                    if (taskController.text.isEmpty ||
                        selectedDueDate == null ||
                        selectedTime == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("Please enter all details")),
                      );
                      return;
                    }

                    String taskTitle = taskController.text.trim();

                    DateTime dueDateTime = DateTime(
                      selectedDueDate!.year,
                      selectedDueDate!.month,
                      selectedDueDate!.day,
                      selectedTime!.hour,
                      selectedTime!.minute,
                      0,
                    );

                    await addTaskToFirestore(
                      taskTitle,
                      selectedPriority,
                      dueDateTime,
                      username,
                      userEmail,
                    );

                    DateTime now = DateTime.now();
                    DateTime notificationDate1 =
                        dueDateTime.subtract(Duration(days: 2));
                    DateTime notificationDate2 =
                        dueDateTime.subtract(Duration(days: 1));

                    notificationDate1 = DateTime(
                      notificationDate1.year,
                      notificationDate1.month,
                      notificationDate1.day,
                      selectedTime!.hour,
                      selectedTime!.minute,
                      0,
                    );
                    notificationDate2 = DateTime(
                      notificationDate2.year,
                      notificationDate2.month,
                      notificationDate2.day,
                      selectedTime!.hour,
                      selectedTime!.minute,
                      0,
                    );
                    DateTime oneDayBefore =
                        dueDateTime.subtract(Duration(days: 1));

                    if (oneDayBefore.isAfter(now.add(Duration(minutes: 1)))) {
                      await NotificationService.scheduleNotification(
                        id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
                        title: "Task Reminder",
                        body: "Your task '$taskTitle' is due tomorrow!",
                        scheduledDateTime: oneDayBefore,
                        userEmail: userEmail,
                      );
                      print("✅ Notification scheduled for: $oneDayBefore");
                    } else {
                      print(
                          "❌ Notification not scheduled: time has already passed or too close.");
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
        ),
      );
    },
  );
}
