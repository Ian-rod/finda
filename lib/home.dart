import 'package:finda/constants/constants.dart';
import 'package:flutter/material.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  //update the current location
  @override
  Widget build(BuildContext context) {
    Constants.location.onLocationChanged.listen((currentLocation) {
      print("Location changed");
      setState(() {
        Constants.currentlocation = currentLocation;
      });
    });
    return Scaffold(
      body: Center(
          child: Text("Your location is : " +
              Constants.currentlocation.toString() +
              "\n\n" +
              "Latitude is : " +
              Constants.currentlocation.latitude.toString() +
              "\n" +
              "Longitude is : " +
              Constants.currentlocation.longitude.toString() +
              "\n" +
              "time is : " +
              Constants.currentlocation.time.toString() +
              "\n" +
              "The speed is : " +
              Constants.currentlocation.speed.toString() +
              "\n" +
              "The satellite number is " +
              Constants.currentlocation.satelliteNumber.toString() +
              "\n" +
              "Altitude is : " +
              Constants.currentlocation.altitude.toString())),
    );
  }
}
