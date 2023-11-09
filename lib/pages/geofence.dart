// ignore_for_file: prefer_const_constructors

import 'package:finda/constants/constants.dart';
import 'package:finda/constants/geoconstants.dart';
import 'package:finda/pages/mydrawer.dart';
import 'package:finda/requests/notificationrequests.dart';
import 'package:finda/requests/offlinestorage.dart';
import 'package:flutter/material.dart';
import 'package:geofence_service/geofence_service.dart';

class GeoFence extends StatefulWidget {
  const GeoFence({super.key});

  @override
  State<GeoFence> createState() => _GeoFenceState();
}

class _GeoFenceState extends State<GeoFence> {
  var geofenceradius;

  String textRadius = "20m";
  var itemindex;
  //Geofence request
  // This function is to be called when the geofence status is changed.
  Future<void> _onGeofenceStatusChanged(
      Geofence geofence,
      GeofenceRadius geofenceRadius,
      GeofenceStatus geofenceStatus,
      Location location) async {
    String message = "Entering geofence";
    if (geofenceStatus == GeofenceStatus.DWELL) {
      message = "Dwelling within geofence";
    } else if (geofenceStatus == GeofenceStatus.EXIT) {
      message = "Exiting geofence";
    }
    await showNotification(message);
    var _geofenceStreamController;
    _geofenceStreamController.sink.add(geofence);
  }

// This function is to be called when the activity has changed.
  void _onActivityChanged(Activity prevActivity, Activity currActivity) async {
    await showNotification(
        "previous Activity: ${prevActivity.toJson()}\n current Activity: ${currActivity.toJson()}");
    var _activityStreamController;
    _activityStreamController.sink.add(currActivity);
  }

// This function is to be called when the location has changed.
  void _onLocationChanged(Location location) async {
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

  @override
  void initState() {
    super.initState();

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

  var formKey = GlobalKey<FormState>();
  var placeId = TextEditingController();
  //add geofence
  addgeofence(BuildContext context) {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(20))),
              contentPadding: EdgeInsets.only(top: 10),
              title: Text(
                "Add a Geofence",
                style: TextStyle(fontSize: 24),
              ),
              content: SizedBox(
                  height: 300,
                  width: 300,
                  child: ListView(padding: EdgeInsets.all(10), children: [
                    Form(
                      key: formKey,
                      child: Column(
                        children: [
                          //event title
                          Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: TextFormField(
                              controller: placeId,
                              validator: (value) {
                                if (value == null || value.toString().isEmpty) {
                                  return "Please enter a unique name for the geofence";
                                }
                                return null;
                              },
                              decoration: InputDecoration(
                                  border: OutlineInputBorder(),
                                  hintText: "Enter the geofence name",
                                  labelText: "Geofence name"),
                            ),
                          ),
                          //add select radius option
                          Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: SizedBox(
                                child: DropdownButton(
                                    value: textRadius,
                                    hint: Text(
                                        "Select the radius of the geofence"),
                                    items: [
                                      DropdownMenuItem(
                                          child: Text("20m"), value: "20m"),
                                      DropdownMenuItem(
                                          child: Text("50m"), value: "50m"),
                                      DropdownMenuItem(
                                        child: Text("100m"),
                                        value: "100m",
                                      ),
                                      DropdownMenuItem(
                                        child: Text("150m"),
                                        value: "150m",
                                      ),
                                      DropdownMenuItem(
                                          child: Text("200m"), value: "200m"),
                                      DropdownMenuItem(
                                        child: Text("250m"),
                                        value: "250m",
                                      ),
                                    ],
                                    onChanged: (value) {
                                      setState(() {
                                        textRadius = value!;
                                        Navigator.of(context).pop();
                                        addgeofence(context);
                                      });
                                      print(textRadius);
                                    })),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: ElevatedButton(
                                onPressed: () async {
                                  //Save details
                                  if (formKey.currentState!.validate()) {
                                    //save geofence
                                    //convert string to actual geofence radius
                                    if (textRadius == "20m") {
                                      geofenceradius = GeofenceRadius(
                                          id: 'radius_20m', length: 20);
                                    } else if (textRadius == "50m") {
                                      geofenceradius = GeofenceRadius(
                                          id: 'radius_50m', length: 50);
                                    } else if (textRadius == "100m") {
                                      geofenceradius = GeofenceRadius(
                                          id: 'radius_100m', length: 100);
                                    } else if (textRadius == "150m") {
                                      geofenceradius = GeofenceRadius(
                                          id: 'radius_150m', length: 150);
                                    } else if (textRadius == "200m") {
                                      geofenceradius = GeofenceRadius(
                                          id: 'radius_200m', length: 200);
                                    } else {
                                      geofenceradius = GeofenceRadius(
                                          id: 'radius_250m', length: 250);
                                    }
                                    setState(() {
                                      GeoFenceConstants.geofenceList
                                          .add(Geofence(
                                        id: placeId.text,
                                        latitude:
                                            Constants.currentlocation.latitude,
                                        longitude:
                                            Constants.currentlocation.longitude,
                                        radius: [
                                          geofenceradius,
                                        ],
                                      ));
                                    });
                                    Navigator.of(context).pop();
                                    placeId.clear();
                                    //save records
                                    //save data to local storage and show sucess message
                                    await savedata().then((value) {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                              SnackBar(content: Text(value)));
                                    });
                                  }
                                },
                                child: Text("Save geofence")),
                          )
                        ],
                      ),
                    ),
                  ])));
        });
  }

//edit geofence
  editgeofence(BuildContext context) {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(20))),
              contentPadding: EdgeInsets.only(top: 10),
              title: Text(
                "Edit Geofence",
                style: TextStyle(fontSize: 24),
              ),
              content: SizedBox(
                  height: 300,
                  width: 300,
                  child: ListView(padding: EdgeInsets.all(10), children: [
                    Form(
                      key: formKey,
                      child: Column(
                        children: [
                          //event title
                          Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: TextFormField(
                              controller: placeId,
                              validator: (value) {
                                if (value == null || value.toString().isEmpty) {
                                  return "Please enter a unique name for the geofence";
                                }
                                return null;
                              },
                              decoration: InputDecoration(
                                  border: OutlineInputBorder(),
                                  hintText: "Enter the geofence name",
                                  labelText: "Geofence name"),
                            ),
                          ),
                          //add select radius option
                          Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: SizedBox(
                                child: DropdownButton(
                                    value: textRadius,
                                    hint: Text(
                                        "Select the radius of the geofence"),
                                    items: [
                                      DropdownMenuItem(
                                          child: Text("20m"), value: "20m"),
                                      DropdownMenuItem(
                                          child: Text("50m"), value: "50m"),
                                      DropdownMenuItem(
                                        child: Text("100m"),
                                        value: "100m",
                                      ),
                                      DropdownMenuItem(
                                        child: Text("150m"),
                                        value: "150m",
                                      ),
                                      DropdownMenuItem(
                                          child: Text("200m"), value: "200m"),
                                      DropdownMenuItem(
                                        child: Text("250m"),
                                        value: "250m",
                                      ),
                                    ],
                                    onChanged: (value) {
                                      setState(() {
                                        textRadius = value!;
                                        Navigator.of(context).pop();
                                        addgeofence(context);
                                      });
                                      print(textRadius);
                                    })),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: ElevatedButton(
                                onPressed: () async {
                                  GeoFenceConstants.geofenceList
                                      .removeAt(itemindex);
                                  //Save details
                                  if (formKey.currentState!.validate()) {
                                    //save geofence
                                    //convert string to actual geofence radius
                                    if (textRadius == "20m") {
                                      geofenceradius = GeofenceRadius(
                                          id: 'radius_20m', length: 20);
                                    } else if (textRadius == "50m") {
                                      geofenceradius = GeofenceRadius(
                                          id: 'radius_50m', length: 50);
                                    } else if (textRadius == "100m") {
                                      geofenceradius = GeofenceRadius(
                                          id: 'radius_100m', length: 100);
                                    } else if (textRadius == "150m") {
                                      geofenceradius = GeofenceRadius(
                                          id: 'radius_150m', length: 150);
                                    } else if (textRadius == "200m") {
                                      geofenceradius = GeofenceRadius(
                                          id: 'radius_200m', length: 200);
                                    } else {
                                      geofenceradius = GeofenceRadius(
                                          id: 'radius_250m', length: 250);
                                    }
                                    setState(() {
                                      GeoFenceConstants.geofenceList
                                          .add(Geofence(
                                        id: placeId.text,
                                        latitude:
                                            Constants.currentlocation.latitude,
                                        longitude:
                                            Constants.currentlocation.longitude,
                                        radius: [
                                          geofenceradius,
                                        ],
                                      ));
                                    });

                                    Navigator.of(context).pop();
                                    placeId.clear();
                                    //save records
                                    //save data to local storage and show sucess message
                                    await savedata().then((value) {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                              SnackBar(content: Text(value)));
                                    });
                                  }
                                },
                                child: Text("Save geofence")),
                          )
                        ],
                      ),
                    ),
                  ])));
        });
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
        appBar: appbar,
        drawer: mydrawer(context),
        body: GeoFenceConstants.geofenceList.isEmpty
            ? Center(child: Text("No geofences set press + to add a geofence"))
            : Center(
                child: ListView.builder(
                  itemCount: GeoFenceConstants.geofenceList.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: InkWell(
                        onTap: () {
                          //edit geofence
                          itemindex = index;
                          placeId.text =
                              GeoFenceConstants.geofenceList[index].id;
                          editgeofence(context);
                        },
                        onLongPress: () {
                          //delete geofence
                          itemindex = index;
                          //delete event
                          //call confirmation box
                          showDialog(
                              context: context,
                              builder: (context) {
                                return AlertDialog(
                                  title: Row(children: [
                                    Text("Confirm delete"),
                                    SizedBox(
                                      width: 7,
                                    ),
                                    Icon(Icons.delete_forever)
                                  ]),
                                  content: Text(
                                      "Are you sure you want to delete the selected Geofence?"),
                                  actions: [
                                    TextButton(
                                        onPressed: () async {
                                          //perform delete
                                          setState(() {
                                            GeoFenceConstants.geofenceList
                                                .removeAt(index);
                                          });
                                          Navigator.of(context).pop();
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(SnackBar(
                                                  backgroundColor:
                                                      Constants.appcolor,
                                                  content: Row(
                                                    children: [
                                                      Text("Geofence deleted"),
                                                      SizedBox(
                                                        width: 5,
                                                      ),
                                                      Icon(
                                                        Icons.delete_forever,
                                                        color: Colors.white,
                                                      )
                                                    ],
                                                  )));
                                        },
                                        child: Text("Yes")),
                                    TextButton(
                                        onPressed: () {
                                          //close dialog
                                          Navigator.of(context).pop();
                                        },
                                        child: Text("No"))
                                  ],
                                );
                              });
                          //confirm delete
                          //delete then save
                        },
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: Constants.appcolor,
                            child: Icon(
                              Icons.location_on_outlined,
                              color: Colors.white,
                            ),
                          ),
                          title: Text(GeoFenceConstants.geofenceList[index].id),
                        ),
                      ),
                    );
                  },
                ),
              ),
        floatingActionButton: FloatingActionButton(
            backgroundColor: Constants.appcolor,
            child: Icon(Icons.add),
            onPressed: () {
              //trigger add geofence
              addgeofence(context);
            }),
      ),
    );
  }
}
