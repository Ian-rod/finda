// ignore_for_file: prefer_const_constructors

import 'dart:io';
import 'package:firebase_core/firebase_core.dart';

import 'firebase_options.dart';

import 'package:finda/constants/constants.dart';
import 'package:finda/datamodel/locationhistory.dart';
import 'package:finda/pages/flagsuspicious.dart';
import 'package:finda/pages/geofence.dart';
import 'package:finda/pages/home.dart';
import 'package:finda/pages/locationhistorypage.dart';
import 'package:finda/pages/map.dart';
import 'package:finda/pages/sospage.dart';
import 'package:finda/pages/sossetup.dart';
import 'package:finda/pages/trustee.dart';
import 'package:finda/requests/backgroundservices.dart';
import 'package:finda/requests/locationrequests.dart';
import 'package:finda/requests/notificationrequests.dart';
import 'package:finda/requests/offlinestorage.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:background_fetch/background_fetch.dart';
import 'package:go_router/go_router.dart';

@pragma('vm:entry-point')
void backgroundFetchHeadlessTask(HeadlessTask task) async {
  //get existing history
  await getLocationHistoryandStatus();
  String taskId = task.taskId;
  bool isTimeout = task.timeout;
  if (isTimeout) {
    // This task has exceeded its allowed running-time.
    // You must stop what you're doing and immediately .finish(taskId)
    BackgroundFetch.finish(taskId);
    return;
  }
  try {
    final result = await InternetAddress.lookup('example.com');
    Constants.currentlocation = await Constants.location.getLocation();
    if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
      //internet available
      //store current location in location list
      Constants.mylocationHistory.add(LocationHistory(
          longitude: Constants.currentlocation.longitude,
          latitude: Constants.currentlocation.latitude,
          logTime: DateTime.now(),
          address: await obtainAddress()));
    }
  } on SocketException catch (_) {
    //internet unavailable
    Constants.mylocationHistory.add(LocationHistory(
        longitude: Constants.currentlocation.longitude,
        latitude: Constants.currentlocation.latitude,
        logTime: DateTime.now(),
        address: "Address unavailable"));
  }
  await showLocationUpdateNotification("Current location logged");
  //save to local storage
  await saveLocationHistoryAndStatus();
  BackgroundFetch.finish(taskId);
}

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
  await getLocationHistoryandStatus();
  await getUsername();
  //request phone permissions
  await Constants.telephony.requestPhoneAndSmsPermissions;

//turn on/off SOS service
  if (Constants.sosOn) {
    await showSOSNotification("Click to send a distress message");
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
  //a reminder
  locationHistorypdater();
  //initialize firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  //go router config
  final GoRouter router = GoRouter(
    routes: <RouteBase>[
      GoRoute(
        path: '/',
        builder: (BuildContext context, GoRouterState state) {
          return Constants.appHome;
        },
        routes: <RouteBase>[
          GoRoute(
            path: 'geofence',
            builder: (BuildContext context, GoRouterState state) {
              return const GeoFence();
            },
          ),
          GoRoute(
            path: 'safezone',
            builder: (BuildContext context, GoRouterState state) {
              return const FlagSusupicious();
            },
          ),
          GoRoute(
            path: 'trustee',
            builder: (BuildContext context, GoRouterState state) {
              return const TrusteePage();
            },
          ),
          GoRoute(
            path: 'sosPage',
            builder: (BuildContext context, GoRouterState state) {
              return const SOSPage();
            },
          ),
          GoRoute(
            path: 'sosSetup',
            builder: (BuildContext context, GoRouterState state) {
              return const SOSsetupPage();
            },
          ),
          GoRoute(
            path: 'locationhistory',
            builder: (BuildContext context, GoRouterState state) {
              return const LocationHistoryPage();
            },
          ),
          GoRoute(
            path: 'mapPage',
            builder: (BuildContext context, GoRouterState state) {
              return const MapPage();
            },
          ),
        ],
      ),
    ],
  );
  runApp(MaterialApp.router(
    routerConfig: router,
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
  ));
  //register headless when app is terminated
  BackgroundFetch.registerHeadlessTask(backgroundFetchHeadlessTask);
}
