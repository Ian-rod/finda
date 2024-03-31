import 'package:finda/constants/constants.dart';
import 'package:finda/pages/mydrawer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  @override
  Widget build(BuildContext context) {
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
          MarkerLayer(markers: [
            Marker(
                height: 35,
                width: 80,
                point: LatLng(
                  Constants.currentlocation.latitude,
                  Constants.currentlocation.longitude,
                ),
                child: TextButton.icon(
                  style: ButtonStyle(
                      foregroundColor:
                          const MaterialStatePropertyAll(Colors.white),
                      backgroundColor:
                          MaterialStatePropertyAll(Constants.appcolor)),
                  onPressed: () {
                    //open info pop up
                  },
                  icon: const Icon(Icons.location_history),
                  label: Text(Constants.username),
                ))
          ])
        ],
      ),
    );
  }
}
