// ignore_for_file: prefer_const_constructors

import 'package:finda/constants/constants.dart';
import 'package:finda/pages/flagsuspicious.dart';
import 'package:finda/pages/geofence.dart';
import 'package:finda/pages/home.dart';
import 'package:finda/pages/sospage.dart';
import 'package:finda/pages/sossetup.dart';
import 'package:finda/pages/trustee.dart';
import 'package:finda/requests/locationrequests.dart';
import 'package:finda/requests/notificationrequests.dart';
import 'package:finda/requests/offlinestorage.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

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
  //offliine db calls
  await requestPermission();
  await getdata();
  await getsafezonedata();
  await getTrusteedata();
  await getSOSdata();
  await getSOS();

  //request phone permissions
  await Constants.telephony.requestPhoneAndSmsPermissions;
//turn on/off SOS service
  if (Constants.sosOn) {
    await showSOSNotification("Click to send a distress call");
  }

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

  //to review
  if (Constants.notificationtapped && Constants.sosOn) {
    Constants.appHome = SOSPage();
  } else {
    Constants.appHome = Home();
  }

  MaterialColor colorCustom = MaterialColor(0xFF013220, color);
  runApp(MaterialApp(
    home: Constants.appHome,
    title: "Finda",
    theme: ThemeData(
        elevatedButtonTheme: ElevatedButtonThemeData(
            style: ButtonStyle(
                backgroundColor: MaterialStatePropertyAll(Constants.appcolor),
                foregroundColor: MaterialStatePropertyAll(Colors.white))),
        floatingActionButtonTheme: FloatingActionButtonThemeData(
            foregroundColor: Colors.white, backgroundColor: Constants.appcolor),
        primarySwatch: colorCustom,
        primaryColor: Constants.appcolor),
    routes: {
      "/geofence": (context) => GeoFence(),
      "/safezone": (context) => FlagSusupicious(),
      "/trustee": (context) => TrusteePage(),
      "/sosPage": (context) => SOSPage(),
      "/sosSetup": (context) => SOSsetupPage()
    },
  ));
}
