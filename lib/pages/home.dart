// ignore_for_file: prefer_const_constructors

import 'package:finda/constants/constants.dart';
import 'package:finda/pages/mydrawer.dart';
import 'package:flutter/material.dart';
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

    var _geofenceStreamController;
    _geofenceStreamController.sink.add(geofence);
  }

// This function is to be called when the activity has changed.
  void _onActivityChanged(Activity prevActivity, Activity currActivity) async {
    // await showNotification(
    //     "previous Activity: ${prevActivity.toJson()}\n current Activity: ${currActivity.toJson()}");
    var _activityStreamController;
    _activityStreamController.sink.add(currActivity);
  }

// This function is to be called when the location has changed.
  void _onLocationChanged(Location location) async {
    setState(() {
      Constants.currentlocation = location;
    });
    print('location: ${location.toJson()}');
  }

// This function is to be called when a location services status change occurs
// since the service was started.
  void _onLocationServicesStatusChanged(bool status) {
    print('isLocationServicesEnabled: $status');
  }

// This function is used to handle errors that occur in the service.
  void _onError(error) {
    final errorCode = getErrorCodesFromError(error);
    if (errorCode == null) {
      print('Undefined error: $error');
      return;
    }

    print('ErrorCode: $errorCode');
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
  bool geofenceOn = true;

  //update the current location
  @override
  Widget build(BuildContext context) {
    //geofence trigger
    if (geofenceOn) {
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
    Constants.location.onLocationChanged.listen((currentLocation) {
      print("speed is : " + currentLocation.speed.toString());
      setState(() {
        Constants.currentlocation = currentLocation;
      });
    });
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
                            child: Text("speed : " +
                                Constants.currentlocation.speed
                                    .toInt()
                                    .toString() +
                                " m/s"))
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
                            child: Text(Constants.currentlocation.latitude
                                    .toString() +
                                " , " +
                                Constants.currentlocation.longitude.toString()))
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
                    child: Text("Your altitude is " +
                        Constants.currentlocation.altitude.toInt().toString() +
                        " m"))
              ]),
            ),
            //geofence switch
            Center(
              child: Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Switch(
                        value: geofenceOn,
                        activeColor: Constants.appcolor,
                        activeTrackColor: Constants.appcolor,
                        onChanged: (value) {
                          setState(() {
                            geofenceOn = !geofenceOn;
                          });
                        }),
                  ),
                  Text(geofenceOn
                      ? "Geofence service is on"
                      : "Geofence service is off")
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
