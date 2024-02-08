import 'package:finda/constants/constants.dart';
import 'package:finda/datamodel/trusteemodel.dart';
import 'package:finda/pages/sospage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:telephony/telephony.dart';

// Create an instance of the notification plugin
FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

// Initialize the plugin
const AndroidInitializationSettings initializationSettingsAndroid =
    AndroidInitializationSettings('@mipmap/ic_launcher');
const InitializationSettings initializationSettings =
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
      Constants.notificationtapped = true;
      Constants.appHome = const SOSPage();
      //send message to sos list
      for (Trustee t in Constants.sosReceiver) {
        //send message to each SOS receiver
        Constants.telephony.sendSms(
            to: t.trusteePhone,
            message:
                "You received an SOS alert from Ian\nCurrent location is\n https://maps.google.com/?q=${Constants.currentlocation.latitude},${Constants.currentlocation.longitude}");
      }
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

//set up for location history updated notification
Future<void> showLocationUpdateNotification(String message) async {
  // Create an instance of the notification plugin

  await flutterLocalNotificationsPlugin.initialize(
    initializationSettings,
    onDidReceiveNotificationResponse: (details) {},
  );
  const AndroidNotificationDetails androidPlatformChannelSpecifics =
      AndroidNotificationDetails(
          'LocationUpdateChannel', // Replace with your own channel ID
          'LOcation Update channel', // Replace with your own channel name
          importance: Importance.high,
          priority: Priority.high,
          ongoing: false);
  const NotificationDetails platformChannelSpecifics =
      NotificationDetails(android: androidPlatformChannelSpecifics);

  await flutterLocalNotificationsPlugin.show(
    1, // Notification ID
    'Location History Update',
    message,
    platformChannelSpecifics,
  );
}
