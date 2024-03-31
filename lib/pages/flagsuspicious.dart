// ignore_for_file: prefer_const_constructors

import 'package:finda/constants/constants.dart';
import 'package:finda/constants/geoconstants.dart';
import 'package:finda/datamodel/safezone.dart';
import 'package:finda/pages/mydrawer.dart';
import 'package:finda/requests/offlinestorage.dart';
import 'package:flutter/material.dart';
import 'package:geofence_service/geofence_service.dart';

class FlagSusupicious extends StatefulWidget {
  const FlagSusupicious({super.key});

  @override
  State<FlagSusupicious> createState() => _FlagSusupiciousState();
}

class _FlagSusupiciousState extends State<FlagSusupicious> {
  Geofence safezone = GeoFenceConstants.geofenceList[0];

  //Add a safe zone dialog
  addSafeZone(BuildContext context) {
    showDialog(
        context: context,
        builder: (context) {
          return StatefulBuilder(
            builder: (context, setState) {
              return AlertDialog(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(20))),
                  contentPadding: EdgeInsets.only(top: 10),
                  title: Text(
                    "Choose a safezone",
                    style: TextStyle(fontSize: 24),
                  ),
                  content: SizedBox(
                      height: 200,
                      width: 300,
                      child: ListView(padding: EdgeInsets.all(10), children: [
                        Column(
                          children: [
                            //event title
                            Padding(
                              padding: const EdgeInsets.all(10.0),
                              child: Text(
                                  "Choose a geofence to set as a safezone"),
                            ),
                            //add select radius option
                            Padding(
                              padding: const EdgeInsets.all(10.0),
                              child: SizedBox(
                                  child: DropdownButton(
                                      value: safezone,
                                      hint: Text(
                                          "Select the radius of the geofence"),
                                      items: GeoFenceConstants.geofenceList
                                          .map((e) {
                                        return DropdownMenuItem(
                                            value: e, child: Text(e.id));
                                      }).toList(),
                                      onChanged: (value) {
                                        setState(() {
                                          safezone = value!;
                                        });
                                      })),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(10.0),
                              child: ElevatedButton(
                                  onPressed: () async {
                                    //create a safezone instance

                                    //save
                                    await saveSafezonedata().then((value) {
                                      Navigator.of(context).pop();
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                              SnackBar(content: Text(value)));
                                    });
                                    super.setState(() {
                                      Constants.safezone = Safezone(
                                          geofenceName: safezone.id,
                                          longitude: safezone.longitude,
                                          latitude: safezone.latitude,
                                          radius: safezone.radius[0].length);
                                    });
                                  },
                                  child: Text("Save safezone")),
                            )
                          ],
                        ),
                      ])));
            },
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: myappdrawer(context),
      drawer: mydrawer(context),
      body: Constants.safezone != null
          ? Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Text(
                    "Current Safezone",
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Constants.appcolor,
                        fontSize: 40),
                  ),
                ),
                Center(
                  child: SizedBox(
                    height: 500,
                    width: 500,
                    child: Center(
                      child: Card(
                        elevation: 10,
                        child: Column(
                          children: [
                            Image.asset("images/safezone.jpeg"),
                            SizedBox(
                              height: 20,
                            ),
                            ListTile(
                              title: Text(
                                  "Geofence Name: ${Constants.safezone.geofenceName}"),
                              subtitle: Text(
                                  "Longitude: ${Constants.safezone.longitude.toString()}\nLatitude: ${Constants.safezone.latitude.toString()}"),
                              trailing: Text(
                                  "Radius: ${Constants.safezone.radius.toString()}m"),
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                Text(
                  "Please note that ALL transactions need to be performed at this location \nany other location will be REJECTED\nsafezone currently limited to one for security concerns",
                  style: TextStyle(
                      fontSize: 20,
                      color: Colors.red[900],
                      fontWeight: FontWeight.bold),
                )
              ],
            )
          : Center(child: Text("Tap + to add a safezone")),
      floatingActionButton: FloatingActionButton(
          child: Icon(Icons.add),
          onPressed: () {
            //add a safezone
            addSafeZone(context);
          }),
    );
  }
}
