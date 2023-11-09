import 'package:finda/constants/constants.dart';
import 'package:finda/pages/geofence.dart';
import 'package:finda/pages/home.dart';
import 'package:finda/requests/locationrequests.dart';
import 'package:finda/requests/offlinestorage.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

void main() async {
  Constants.binding = WidgetsFlutterBinding();
  // Request activity recognition permission
  PermissionStatus status = await Permission.activityRecognition.request();
  if (status.isDenied) {
    // Permission is denied, but not permanently
    // You can request it again if needed.
  } else if (status.isPermanentlyDenied) {
    // Permission is permanently denied
    // You need to guide the user to manually allow the permission.
    openAppSettings(); // Open app settings for the user to change the permission manually.
  }
  await requestPermission();
  await getdata();

  Map<int, Color> color = {
    50: Color.fromRGBO(136, 14, 79, .1),
    100: Color.fromRGBO(208, 17, 119, 0.2),
    200: Color.fromRGBO(136, 14, 79, .3),
    300: Color.fromRGBO(136, 14, 79, .4),
    400: Color.fromRGBO(136, 14, 79, .5),
    500: Color.fromRGBO(136, 14, 79, .6),
    600: Color.fromRGBO(136, 14, 79, .7),
    700: Color.fromRGBO(136, 14, 79, .8),
    800: Color.fromRGBO(136, 14, 79, .9),
    900: Color.fromRGBO(136, 14, 79, 1),
  };
  MaterialColor colorCustom = MaterialColor(0xFF013220, color);
  runApp(MaterialApp(
    title: "Finda",
    theme:
        ThemeData(primarySwatch: colorCustom, primaryColor: Constants.appcolor),
    routes: {"/": (context) => Home(), "/geofence": (context) => GeoFence()},
  ));
}
