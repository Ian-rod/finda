import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

// Create an instance of the notification plugin
FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

// Initialize the plugin
const AndroidInitializationSettings initializationSettingsAndroid =
    AndroidInitializationSettings('@mipmap/ic_launcher');
final InitializationSettings initializationSettings =
    InitializationSettings(android: initializationSettingsAndroid);
Future<void> showNotification(String message) async {
  await flutterLocalNotificationsPlugin.initialize(
    initializationSettings,
  );
  const AndroidNotificationDetails androidPlatformChannelSpecifics =
      AndroidNotificationDetails(
    'geofence_service_notification_channel', // Replace with your own channel ID
    'geolocation changed', // Replace with your own channel name
    importance: Importance.high,
    priority: Priority.high,
  );
  const NotificationDetails platformChannelSpecifics =
      NotificationDetails(android: androidPlatformChannelSpecifics);

  await flutterLocalNotificationsPlugin.show(
    0, // Notification ID
    'Location Update',
    message,
    platformChannelSpecifics,
  );
}

//SOS
Future<void> showSOSNotification(String message) async {
  // Create an instance of the notification plugin

  await flutterLocalNotificationsPlugin.initialize(
    initializationSettings,
    onDidReceiveNotificationResponse: (details) {
      print("Sending to trustee...");
    },
  );
  const AndroidNotificationDetails androidPlatformChannelSpecifics =
      AndroidNotificationDetails(
          'SOSAlert', // Replace with your own channel ID
          'SOS channel', // Replace with your own channel name
          importance: Importance.high,
          priority: Priority.high,
          ongoing: true);
  const NotificationDetails platformChannelSpecifics =
      NotificationDetails(android: androidPlatformChannelSpecifics);

  await flutterLocalNotificationsPlugin.show(
    1, // Notification ID
    'SOS',
    message,
    platformChannelSpecifics,
  );
}
