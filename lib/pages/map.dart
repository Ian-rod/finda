import 'dart:convert';

import 'package:finda/constants/constants.dart';
import 'package:finda/pages/mydrawer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';
import 'package:http/http.dart' as http;

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  List<Marker> myMarkers = [];
  bool createdWaypoints = false;
  Map<String, IconData> activityIconMapper = {
    "still": Icons.attribution,
    "running": Icons.run_circle_outlined,
    "bicycle": Icons.bike_scooter,
    "unknown": Icons.device_unknown,
    "walking": Icons.directions_walk_outlined,
    "in vehicle": Icons.car_repair
  };
  List<LatLng> polylinePoints = [];
//get route between the two points
  getroute(String destLat, String destlong) async {
    polylinePoints.clear();
    try {
      var uri = Uri.parse(
          "http://router.project-osrm.org/route/v1/driving/${Constants.currentlocation.longitude},${Constants.currentlocation.latitude};$destlong,$destLat?steps=true&annotations=true&geometries=geojson&overview=full");
      var response = await http.get(uri);
      setState(() {
        var routepoints =
            jsonDecode(response.body)['routes'][0]['geometry']['coordinates'];
        for (int i = 0; i < routepoints.length; i++) {
          var coordinates = routepoints[i];
          var long = coordinates[0];
          var lat = coordinates[1];

          polylinePoints.add(LatLng(lat, long));
        }
      });
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  double long = 0;
  double lat = 0;
  @override
  Widget build(BuildContext context) {
    if (GoRouterState.of(context).pathParameters.isNotEmpty) {
      lat = double.parse(GoRouterState.of(context).pathParameters["latitude"]!);
      long =
          double.parse(GoRouterState.of(context).pathParameters["longitude"]!);
      //capture passed params
      String username = GoRouterState.of(context).pathParameters["username"]!;
      String currActivity = GoRouterState.of(context)
          .pathParameters["currActivity"]!
          .toLowerCase();
      String prevActivity = GoRouterState.of(context)
          .pathParameters["prevActivity"]!
          .toLowerCase();
      String speed = GoRouterState.of(context).pathParameters["speed"]!;
      String altitude = GoRouterState.of(context).pathParameters["altitude"]!;
      String confidence =
          GoRouterState.of(context).pathParameters["confidence"]!;
      //mapping Icons

      //create a marker
      myMarkers = [
        //me
        Marker(
            height: 35,
            width: 100,
            point: LatLng(
              Constants.currentlocation.latitude,
              Constants.currentlocation.longitude,
            ),
            child: TextButton.icon(
              style: const ButtonStyle(
                  foregroundColor: MaterialStatePropertyAll(Colors.white),
                  backgroundColor: MaterialStatePropertyAll(Colors.black)),
              onPressed: () {
                //open info pop up
                showModalBottomSheet(
                    context: context,
                    builder: (context) {
                      return Column(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(15.0),
                            child: Center(
                              child: Text(
                                "${Constants.username} details",
                                style: TextStyle(
                                    fontSize: 20,
                                    color: Constants.appcolor,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                          Expanded(
                              child: ListView(children: [
                            ListTile(
                              leading: Icon(activityIconMapper[
                                  Constants.currentActivity.toLowerCase()]),
                              title: const Text("Current activity"),
                              trailing: Text(Constants.currentActivity),
                            ),
                            ListTile(
                              leading: Icon(activityIconMapper[
                                  Constants.previousActivity.toLowerCase()]),
                              title: const Text("Previous activity"),
                              trailing: Text(Constants.previousActivity),
                            ),
                            ListTile(
                              leading: const Icon(Icons.speed),
                              title: const Text("speed"),
                              trailing: Text(
                                  "${Constants.currentlocation.speed.toInt().toString()} m/s"),
                            ),
                            ListTile(
                              leading: const Icon(Icons.arrow_upward),
                              title: const Text("altitude"),
                              trailing: Text(
                                  "${Constants.currentlocation.altitude.toInt().toString()} m"),
                            ),
                            ListTile(
                              leading: const Icon(Icons.check_circle),
                              title: const Text("Confidence"),
                              trailing: Text(Constants.confidence),
                            )
                          ]))
                        ],
                      );
                    });
              },
              icon: const Icon(Icons.location_history),
              label: Text("${Constants.username} (You)"),
            )),
        //extra marker
        Marker(
            height: 35,
            width: 100,
            point: LatLng(
              lat,
              long,
            ),
            child: TextButton.icon(
              style: ButtonStyle(
                  foregroundColor: const MaterialStatePropertyAll(Colors.white),
                  backgroundColor:
                      MaterialStatePropertyAll(Constants.appcolor)),
              onPressed: () {
                //open info pop up
                showModalBottomSheet(
                    context: context,
                    builder: (context) {
                      return Column(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(15.0),
                            child: Center(
                              child: Text(
                                "$username details",
                                style: TextStyle(
                                    fontSize: 20,
                                    color: Constants.appcolor,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                          Expanded(
                              child: ListView(children: [
                            ListTile(
                              leading: Icon(activityIconMapper[
                                  currActivity.toLowerCase()]),
                              title: const Text("Current activity"),
                              trailing: Text(currActivity),
                            ),
                            ListTile(
                              leading: Icon(activityIconMapper[
                                  prevActivity.toLowerCase()]),
                              title: const Text("Previous activity"),
                              trailing: Text(prevActivity),
                            ),
                            ListTile(
                              leading: const Icon(Icons.speed),
                              title: const Text("speed"),
                              trailing: Text("$speed m/s"),
                            ),
                            ListTile(
                              leading: const Icon(Icons.arrow_upward),
                              title: const Text("altitude"),
                              trailing: Text("$altitude m"),
                            ),
                            ListTile(
                              leading: const Icon(Icons.check_circle),
                              title: const Text("Confidence"),
                              trailing: Text(confidence),
                            )
                          ]))
                        ],
                      );
                    });
              },
              icon: const Icon(Icons.location_history),
              label: Text(username),
            ))
      ];
    } else {
      myMarkers = [
        //me
        Marker(
            height: 35,
            width: 80,
            point: LatLng(
              Constants.currentlocation.latitude,
              Constants.currentlocation.longitude,
            ),
            child: TextButton.icon(
              style: ButtonStyle(
                  foregroundColor: const MaterialStatePropertyAll(Colors.white),
                  backgroundColor:
                      MaterialStatePropertyAll(Constants.appcolor)),
              onPressed: () {
                //open info pop up
                showModalBottomSheet(
                    context: context,
                    builder: (context) {
                      return Column(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(15.0),
                            child: Center(
                              child: Text(
                                "${Constants.username} details",
                                style: TextStyle(
                                    fontSize: 20,
                                    color: Constants.appcolor,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                          Expanded(
                              child: ListView(children: [
                            ListTile(
                              leading: Icon(activityIconMapper[
                                  Constants.currentActivity.toLowerCase()]),
                              title: const Text("Current activity"),
                              trailing: Text(Constants.currentActivity),
                            ),
                            ListTile(
                              leading: Icon(activityIconMapper[
                                  Constants.previousActivity.toLowerCase()]),
                              title: const Text("Previous activity"),
                              trailing: Text(Constants.previousActivity),
                            ),
                            ListTile(
                              leading: const Icon(Icons.speed),
                              title: const Text("speed"),
                              trailing: Text(
                                  "${Constants.currentlocation.speed.toInt().toString()} m/s"),
                            ),
                            ListTile(
                              leading: const Icon(Icons.arrow_upward),
                              title: const Text("altitude"),
                              trailing: Text(
                                  "${Constants.currentlocation.altitude.toInt().toString()} m"),
                            ),
                            ListTile(
                              leading: const Icon(Icons.check_circle),
                              title: const Text("Confidence"),
                              trailing: Text(Constants.confidence),
                            )
                          ]))
                        ],
                      );
                    });
              },
              icon: const Icon(Icons.location_history),
              label: Text(Constants.username),
            )),
      ];
    }
    return Scaffold(
      appBar: myappbar(context),
      body: createdWaypoints
          ? FlutterMap(
              options: MapOptions(
                initialCenter: LatLng(
                  Constants.currentlocation.latitude,
                  Constants.currentlocation.longitude,
                ),
                initialZoom: 9.2,
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.example.app',
                ),
                PolylineLayer(polylines: [
                  Polyline(
                      borderStrokeWidth: 20,
                      points: polylinePoints,
                      borderColor: Constants.appcolor)
                ]),
                MarkerLayer(markers: myMarkers),
              ],
            )
          : FlutterMap(
              options: MapOptions(
                initialCenter: LatLng(
                  Constants.currentlocation.latitude,
                  Constants.currentlocation.longitude,
                ),
                initialZoom: 9.2,
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.example.app',
                ),
                MarkerLayer(markers: myMarkers),
              ],
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          late BuildContext dialogcontext;
          showDialog(
              context: context,
              builder: (context) {
                dialogcontext = context;
                return AlertDialog(
                  title: const Row(children: [
                    Text("Creating waypoints"),
                    SizedBox(
                      width: 7,
                    ),
                    Icon(Icons.route)
                  ]),
                  content: SizedBox(
                    height: 200,
                    width: 200,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        SizedBox(
                            height: 70,
                            width: 70,
                            child: CircularProgressIndicator(
                              color: Constants.appcolor,
                            )),
                        const Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text("Creating route to target"),
                        )
                      ],
                    ),
                  ),
                );
              });
          await getroute(lat.toString(), long.toString()).then((value) {
            debugPrint(
                "Plotting points for $lat,$long to ${Constants.currentlocation.latitude}.${Constants.currentlocation.longitude}");
            dialogcontext.pop();
            setState(() {
              createdWaypoints = true;
            });
            debugPrint("Done plotting waypoints ${polylinePoints.length}");
          });
        },
        child: const Icon(
          Icons.route,
          color: Colors.white,
        ),
      ),
    );
  }
}
