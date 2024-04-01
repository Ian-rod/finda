import 'package:finda/constants/constants.dart';
import 'package:finda/pages/mydrawer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  List<Marker> myMarkers = [];
  Map<String, IconData> activityIconMapper = {
    "still": Icons.attribution,
    "running": Icons.run_circle_outlined,
    "bicycle": Icons.bike_scooter,
    "unknown": Icons.device_unknown,
    "walking": Icons.directions_walk_outlined,
    "in vehicle": Icons.car_repair
  };

  @override
  Widget build(BuildContext context) {
    if (GoRouterState.of(context).pathParameters.isNotEmpty) {
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

      double lat =
          double.parse(GoRouterState.of(context).pathParameters["latitude"]!);
      double long =
          double.parse(GoRouterState.of(context).pathParameters["longitude"]!);
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
      appBar: myappdrawer(context),
      body: FlutterMap(
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
          MarkerLayer(markers: myMarkers)
        ],
      ),
    );
  }
}
