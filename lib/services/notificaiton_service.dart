import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:prodigenious/services/firestore_task_services.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tz;

Future<void> requestExactAlarmPermission() async {
  if (Platform.isAndroid) {
    final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
        FlutterLocalNotificationsPlugin();

    final androidImplementation =
        flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();

    if (androidImplementation != null) {
      bool? isExactAlarmPermissionGranted =
          await androidImplementation.areNotificationsEnabled();

      if (isExactAlarmPermissionGranted == false) {
        await androidImplementation.requestExactAlarmsPermission();
        print("⏰ Exact Alarm Permission Requested");
      }
    }
  }
}

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static Future<void> initNotification() async {
    tz.initializeTimeZones();

    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings iosSettings =
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const InitializationSettings settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notificationsPlugin.initialize(
      settings,
      onDidReceiveNotificationResponse: (NotificationResponse response) async {
        if (response.payload != null) {
          var docRef = FirebaseFirestore.instance
              .collection('notifications')
              .doc(response.payload);

          await docRef.update({'isDelivered': true});
        }
      },
    );
  }

  static Future<void> requestNotificationPermission() async {
    if (Platform.isIOS) {
      await _notificationsPlugin
          .resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(
            alert: true,
            badge: true,
            sound: true,
          );
    } else if (Platform.isAndroid) {
      if (await Permission.notification.isDenied) {
        await Permission.notification.request();
      }
    }
  }

  static Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required String userEmail,
    required DateTime scheduledDateTime,
  }) async {
    // Store notification details in Firestore
    var notificationDoc =
        await FirebaseFirestore.instance.collection('notifications').add({
      'title': title,
      'body': body,
      'scheduledDate': scheduledDateTime,
      'email': userEmail,
      'timestamp': FieldValue.serverTimestamp(),
      'isDelivered': false, // Initially false
    });
    String docId = notificationDoc.id;

    // Schedule the notification
    await _notificationsPlugin.zonedSchedule(
      id,
      title,
      body,
      tz.TZDateTime.from(scheduledDateTime, tz.local),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'main_channel_id',
          'Main Channel',
          channelDescription: 'Your app notification channel',
          importance: Importance.max,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
      payload: docId, // Optional
    );
  }

  static Future<void> markDeliveredNotificationsIfTimePassed() async {
    final now = DateTime.now();

    final snapshot = await FirebaseFirestore.instance
        .collection('notifications')
        .where('isDelivered', isEqualTo: false)
        .get();

    for (var doc in snapshot.docs) {
      final scheduledDate = (doc['scheduledDate'] as Timestamp).toDate();

      if (scheduledDate.isBefore(now)) {
        await doc.reference.update({'isDelivered': true});
      }
    }
  }
}
