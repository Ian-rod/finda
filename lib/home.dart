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
      setState(() {
        print("Location changed");
        Constants.currentlocation = currentLocation;
      });
    });
    return Scaffold(
      body: Center(
          child: Text(
              "Your location is : " + Constants.currentlocation.toString())),
    );
  }
}
