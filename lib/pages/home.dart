// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:finda/constants/constants.dart';
import 'package:finda/pages/mydrawer.dart';
import 'package:finda/requests/basicfunctionalityrequests.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geofence_service/geofence_service.dart';
import 'package:finda/constants/geoconstants.dart';
import 'package:finda/requests/notificationrequests.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  //Geofence request
  // This function is to be called when the geofence status is changed.
  Future<void> _onGeofenceStatusChanged(
      Geofence geofence,
      GeofenceRadius geofenceRadius,
      GeofenceStatus geofenceStatus,
      Location location) async {
    String message = "Entering ${geofence.id} geofence";
    if (geofenceStatus == GeofenceStatus.DWELL) {
      message = "Dwelling within ${geofence.id} geofence";
    } else if (geofenceStatus == GeofenceStatus.EXIT) {
      message = "Exiting ${geofence.id} geofence";
    }
    message =
        "$message remaining distance is ${geofenceRadius.remainingDistance.toString()} radius is ${geofenceRadius.length}";
    await showNotification(message);

    var geofenceStreamController;
    geofenceStreamController.sink.add(geofence);
  }

  var activityIcon;
  String currentActivity = "Loading";
  String previousActivity = "Loading";
  String confidence = "0";
// This function is to be called when the activity has changed.
  void _onActivityChanged(Activity prevActivity, Activity currActivity) async {
    if (currActivity.type == ActivityType.STILL) {
      activityIcon = Icons.attribution;
      currentActivity = "Still";
      previousActivity = prevActivity.type.name;
      confidence = currActivity.confidence.name;
    } else if (currActivity.type == ActivityType.RUNNING) {
      activityIcon = Icons.run_circle_outlined;
      currentActivity = "Running";
      previousActivity = prevActivity.type.name;
      confidence = currActivity.confidence.name;
    } else if (currActivity.type == ActivityType.ON_BICYCLE) {
      activityIcon = Icons.bike_scooter;
      currentActivity = "Bicycle";
      previousActivity = prevActivity.type.name;
      confidence = currActivity.confidence.name;
    } else if (currActivity.type == ActivityType.UNKNOWN) {
      activityIcon = Icons.device_unknown;
      currentActivity = "Unknown";
      previousActivity = prevActivity.type.name;
      confidence = currActivity.confidence.name;
    } else if (currActivity.type == ActivityType.WALKING) {
      activityIcon = Icons.directions_walk_outlined;
      currentActivity = "Walking";
      previousActivity = prevActivity.type.name;
      confidence = currActivity.confidence.name;
    } else {
      activityIcon = Icons.car_repair;
      currentActivity = "In vehicle";
      previousActivity = prevActivity.type.name;
      confidence = currActivity.confidence.name;
    }
    // await showNotification(
    //     "previous Activity: ${prevActivity.toJson()}\n current Activity: ${currActivity.toJson()}");
    var activityStreamController;
    activityStreamController.sink.add(currActivity);
  }

// This function is to be called when the location has changed.
  void _onLocationChanged(Location location) async {
    setState(() {
      Constants.currentlocation = location;
    });
    //  print('location: ${location.toJson()}');
  }

// This function is to be called when a location services status change occurs
// since the service was started.
  void _onLocationServicesStatusChanged(bool status) {
    // print('isLocationServicesEnabled: $status');
  }

// This function is used to handle errors that occur in the service.
  void _onError(error) {
    final errorCode = getErrorCodesFromError(error);
    if (errorCode == null) {
      print('Undefined error: $error');
      return;
    }

    //  print('ErrorCode: $errorCode');
  }

//start geofence service
  startGeofence() {
    Constants.binding.addPostFrameCallback((_) {
      GeoFenceConstants.geofenceService
          .addGeofenceStatusChangeListener(_onGeofenceStatusChanged);
      GeoFenceConstants.geofenceService
          .addLocationChangeListener(_onLocationChanged);
      GeoFenceConstants.geofenceService.addLocationServicesStatusChangeListener(
          _onLocationServicesStatusChanged);
      GeoFenceConstants.geofenceService
          .addActivityChangeListener(_onActivityChanged);
      GeoFenceConstants.geofenceService.addStreamErrorListener(_onError);
      GeoFenceConstants.geofenceService
          .start(GeoFenceConstants.geofenceList)
          .catchError(_onError);
    });
  }

  //geofence switch trigger
  bool geofenceOff = true;
  geofenceSwitchController() {
    if (geofenceOff) {
      startGeofence();
    } else {
      //stop geofence
      GeofenceService.instance.stop();
      GeoFenceConstants.geofenceService
          .removeGeofenceStatusChangeListener(_onGeofenceStatusChanged);
      GeoFenceConstants.geofenceService
          .removeLocationChangeListener(_onLocationChanged);
      GeoFenceConstants.geofenceService
          .removeLocationServicesStatusChangeListener(
              _onLocationServicesStatusChanged);
      GeoFenceConstants.geofenceService
          .removeActivityChangeListener(_onActivityChanged);
      GeoFenceConstants.geofenceService.removeStreamErrorListener(_onError);
      GeoFenceConstants.geofenceService.clearAllListeners();
      GeoFenceConstants.geofenceService.stop();
    }
  }

  //SOS trigger
  bool suspiciousFlagOff = true;
  var methodchannel = MethodChannel("STKchannel");

  //control the suspicous flag
  suspicousFlagController() {
    if (geofenceOff && suspiciousFlagOff) {
      //turn on the Suspicious Flag, prevent the stk
      //pass location details to the method.....pass the entire georadius or just the centre and the radius length and do math
      if (Constants.safezone != null) {
        List<double> limitlist = getBoundingBox(Constants.safezone.latitude,
            Constants.safezone.longitude, Constants.safezone.radius);
        methodchannel.invokeMethod("setSafeZone", {
          "maxLong": limitlist[3],
          "minLong": limitlist[2],
          "maxLat": limitlist[1],
          "minLat": limitlist[0]
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(
                "Please set a safezone to flag activities outside your safezone")));
      }
    } else {
      //switch off Suspicious flag
      methodchannel.invokeMethod("disableSuspiciousFlag");
    }
  }

  @override
  void initState() {
    super.initState();

    //geofence trigger
    Constants.location.onLocationChanged.listen((currentLocation) {
      //send location to location checker
      methodchannel.invokeMethod("checkIfinRange", {
        "Latitude": currentLocation.latitude,
        "Longitude": currentLocation.longitude
      });
      setState(() {
        Constants.currentlocation = currentLocation;
      });
    });
    suspicousFlagController();
  }

  @override
  Widget build(BuildContext context) {
    return WillStartForegroundTask(
      onWillStart: () async {
        // You can add a foreground task start condition.

        return GeoFenceConstants.geofenceService.isRunningService;
      },
      androidNotificationOptions: AndroidNotificationOptions(
        channelId: 'geofence_service_notification_channel',
        channelName: 'Geofence Service Notification',
        channelDescription:
            'This notification appears when the geofence service is running in the background.',
        channelImportance: NotificationChannelImportance.LOW,
        priority: NotificationPriority.LOW,
        isSticky: false,
      ),
      iosNotificationOptions: const IOSNotificationOptions(),
      foregroundTaskOptions: const ForegroundTaskOptions(),
      notificationTitle: "Geofence Service is running",
      notificationText: 'Tap to return to the app',
      child: Scaffold(
        drawer: mydrawer(context),
        appBar: appbar,
        body: ListView(
          shrinkWrap: true,
          children: [
            SizedBox(
              height: 150,
              width: 250,
              child: GridView.count(
                physics: NeverScrollableScrollPhysics(),
                childAspectRatio: 16 / 9,
                crossAxisCount: 2,
                crossAxisSpacing: 6,
                mainAxisSpacing: 7,
                padding: EdgeInsets.all(10),
                children: [
                  Card(
                    elevation: 10,
                    child: Stack(
                      children: [
                        Image.asset(
                          "images/speed.png",
                          fit: BoxFit.fitWidth,
                        ),
                        Positioned(
                            top: 80,
                            left: 70,
                            child: Text(
                                "speed : ${Constants.currentlocation.speed.toInt().toString()} m/s"))
                      ],
                    ),
                  ),
                  Card(
                    elevation: 10,
                    child: Stack(
                      children: [
                        Image.asset(
                          "images/location.png",
                          fit: BoxFit.fitWidth,
                        ),
                        Positioned(
                            bottom: 0,
                            left: 40,
                            child: Text(
                                "${Constants.currentlocation.latitude} , ${Constants.currentlocation.longitude}"))
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Stack(children: [
                Card(elevation: 10, child: Image.asset("images/mountain.png")),
                Positioned(
                    top: 20,
                    left: 20,
                    child: Text(
                        "Your altitude is ${Constants.currentlocation.altitude.toInt().toString()} m"))
              ]),
            ),
            //geofence switch
            Center(
              child: Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Switch(
                        value: geofenceOff,
                        activeColor: Constants.appcolor,
                        onChanged: (value) {
                          setState(() {
                            geofenceOff = !geofenceOff;
                          });
                          geofenceSwitchController();
                        }),
                  ),
                  Text(geofenceOff
                      ? "Geofence service is on"
                      : "Geofence service is off"),
                ],
              ),
            ),
            //Flag suspicuous switch
            Center(
              child: Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Switch(
                        value: geofenceOff && suspiciousFlagOff,
                        activeColor: Constants.appcolor,
                        onChanged: (value) {
                          setState(() {
                            suspiciousFlagOff = !suspiciousFlagOff;
                          });
                          suspicousFlagController();
                        }),
                  ),
                  Text(geofenceOff && suspiciousFlagOff
                      ? "Flag suspicious service is on"
                      : "Flag suspicious service is off"),
                ],
              ),
            ),
            //add activity type
            Center(
              child: Card(
                elevation: 10,
                child: Column(children: [
                  Padding(
                    padding: const EdgeInsets.all(15.0),
                    child: Icon(
                      activityIcon ?? Icons.question_mark,
                      size: 50,
                      color: Constants.appcolor,
                    ),
                  ),
                  ListTile(
                    title: Text("Current activity: $currentActivity"),
                    subtitle: Text("Previous activity: $previousActivity"),
                    trailing: Text("Confidence level: $confidence"),
                  )
                ]),
              ),
            ),
            //visibility status
            Center(
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: Text("The above information is currently visible to"),
              ),
            ),
            SizedBox(
              height: 150,
              width: MediaQuery.of(context).size.width,
              child: Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(15.0),
                    child: Card(
                      elevation: 10,
                      child: SizedBox(
                        height: 150,
                        width: MediaQuery.of(context).size.width / 2,
                        child: Center(
                          child: ListTile(
                            onTap: () {
                              //open trustee view details page
                            },
                            leading: CircleAvatar(
                              foregroundColor: Colors.white,
                              backgroundColor: Constants.appcolor,
                              child: Icon(Icons.person_2_rounded),
                            ),
                            title: Text("Bruce Lyken"),
                            subtitle: Text("Primary"),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
