import 'package:finda/constants/constants.dart';
import 'package:finda/pages/mydrawer.dart';
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
      print("speed is : " + currentLocation.speed.toString());
      setState(() {
        Constants.currentlocation = currentLocation;
      });
    });
    return Scaffold(
      drawer: mydrawer(context),
      appBar: appbar,
      body: ListView(
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
        ],
      ),
    );
  }
}
