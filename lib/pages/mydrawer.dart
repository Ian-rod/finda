// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:finda/constants/constants.dart';
import 'package:flutter/material.dart';

Widget mydrawer(BuildContext context) {
  return SafeArea(
    child: Drawer(
      backgroundColor: Constants.appcolor,
      child: ListView(
        addRepaintBoundaries: true,
        children: [
          Container(
            margin: EdgeInsets.all(4),
            //TO CHECK LATER DEFINITION
            child: Image.asset(
              "images/gps.jpeg",
              fit: BoxFit.fill,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: ListTile(
              leading: Icon(Icons.location_history, color: Colors.white),
              title: Text(
                "Location history",
                style: TextStyle(color: Colors.white),
              ),
              onTap: () {
                //navigate to location history page
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: ListTile(
              leading: Icon(Icons.fence, color: Colors.white),
              title: Text(
                "Geofencing",
                style: TextStyle(color: Colors.white),
              ),
              onTap: () {
                //navigate to geofence page
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: ListTile(
              leading: Icon(
                Icons.person,
                color: Colors.white,
              ),
              title: Text(
                "Trustee",
                style: TextStyle(color: Colors.white),
              ),
              onTap: () {
                //navigate to trustee page
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: ListTile(
              leading: Icon(Icons.sos, color: Colors.white),
              title: Text(
                "Distress setup",
                style: TextStyle(color: Colors.white),
              ),
              onTap: () {
                //navigate to Distress set up page
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: ListTile(
              leading: Icon(Icons.flag_rounded, color: Colors.white),
              title: Text(
                "Flag suspicious",
                style: TextStyle(color: Colors.white),
              ),
              onTap: () {
                //navigate to Distress set up page
              },
            ),
          )
        ],
      ),
    ),
  );
}

PreferredSizeWidget appbar = AppBar(
  elevation: 10,
  forceMaterialTransparency: true,
  foregroundColor: Constants.appcolor,
  title: Text(Constants.appname),
  centerTitle: true,
  actions: [
    Icon(Icons.person_3_rounded),
    SizedBox(
      width: 20,
    )
  ],
);
