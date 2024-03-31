// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:finda/constants/constants.dart';
import 'package:finda/requests/notificationrequests.dart';
import 'package:finda/requests/offlinestorage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

Widget mydrawer(BuildContext context) {
  var methodchannel = MethodChannel("STKchannel");
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
              "images/gps.png",
              fit: BoxFit.fill,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: ListTile(
              leading: Icon(Icons.home, color: Colors.white),
              title: Text(
                "Home",
                style: TextStyle(color: Colors.white),
              ),
              onTap: () {
                //navigate to homepage
                Navigator.pushReplacementNamed(context, "/");
              },
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
                Navigator.pushReplacementNamed(context, "/locationhistory");
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
                Navigator.pushReplacementNamed(context, "/geofence");
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
                Navigator.pushReplacementNamed(context, "/trustee");
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

                Navigator.pushReplacementNamed(context, "/sosPage");
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: ListTile(
              leading: Icon(Icons.flag_rounded, color: Colors.white),
              title: Text(
                "Flag suspicious settings",
                style: TextStyle(color: Colors.white),
              ),
              onTap: () {
                //navigate to flag susupicious set up page
                Navigator.pushReplacementNamed(context, "/safezone");
              },
            ),
          )
        ],
      ),
    ),
  );
}

PreferredSizeWidget myappdrawer(BuildContext context) {
  return AppBar(
    elevation: 10,
    forceMaterialTransparency: true,
    foregroundColor: Constants.appcolor,
    title: Text(Constants.appname),
    centerTitle: true,
    actions: [
      InkWell(
          onTap: () {
            //set up user name or display name
            Constants.username == "User"
                ? createUserNameDialog(context)
                : displayUserNameDialog(context);
          },
          child: Icon(Icons.person_3_rounded)),
      SizedBox(
        width: 20,
      )
    ],
  );
}

TextEditingController userName = TextEditingController();
var formKey = GlobalKey<FormState>();
createUserNameDialog(BuildContext context) {
  showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(builder: (context, setState) {
          return AlertDialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(20))),
              contentPadding: EdgeInsets.only(top: 10),
              title: Text(
                "Create a username",
                style: TextStyle(fontSize: 24),
              ),
              content: SizedBox(
                  height: 200,
                  width: 300,
                  child: ListView(padding: EdgeInsets.all(10), children: [
                    Form(
                      key: formKey,
                      child: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(15.0),
                            child: TextFormField(
                              controller: userName,
                              inputFormatters: [
                                // Prevent spaces in the username field
                                FilteringTextInputFormatter.deny(RegExp(r'\s')),
                              ],
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return "Please enter your Username";
                                }
                                return null;
                              },
                              decoration: const InputDecoration(
                                  suffixIcon: Icon(Icons.person_3_rounded),
                                  border: OutlineInputBorder(),
                                  hintText: "Enter your Username",
                                  labelText: "Username"),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: ElevatedButton(
                                onPressed: () async {
                                  //save
                                  if (formKey.currentState!.validate()) {
                                    Constants.username = userName.text;
                                    await saveUsername().then((value) {
                                      Navigator.of(context).pop();
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                              SnackBar(content: Text(value)));
                                    });
                                  }
                                },
                                child: Text("Save username")),
                          )
                        ],
                      ),
                    ),
                  ])));
        });
      });
}

displayUserNameDialog(BuildContext context) {
  showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(builder: (context, setState) {
          return AlertDialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(20))),
              contentPadding: EdgeInsets.only(top: 10),
              title: Text(
                "Current username",
                style: TextStyle(fontSize: 24),
              ),
              content: SizedBox(
                  height: 200,
                  width: 300,
                  child: ListView(padding: EdgeInsets.all(10), children: [
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        CircleAvatar(
                          radius: 80,
                          child: Icon(
                            Icons.person,
                            size: 50,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: Text(Constants.username),
                        )
                      ],
                    ),
                  ])));
        });
      });
}
