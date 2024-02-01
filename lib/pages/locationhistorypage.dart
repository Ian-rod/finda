// ignore_for_file: prefer_const_constructors

import 'package:finda/constants/constants.dart';
import 'package:finda/pages/mydrawer.dart';
import 'package:flutter/material.dart';

class LocationHistoryPage extends StatefulWidget {
  const LocationHistoryPage({super.key});

  @override
  State<LocationHistoryPage> createState() => _LocationHistoryPageState();
}

class _LocationHistoryPageState extends State<LocationHistoryPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appbar,
      drawer: mydrawer(context),
      body: Column(
        children: [
          Center(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Center(
                    child: Text(
                      "Location history",
                      style: TextStyle(
                          fontSize: 20,
                          color: Constants.appcolor,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(5.0),
                  child: TextButton.icon(
                    style: ButtonStyle(
                        foregroundColor:
                            const MaterialStatePropertyAll(Colors.white),
                        backgroundColor:
                            MaterialStatePropertyAll(Constants.appcolor)),
                    onPressed: () {
                      //navigate to Location history preferences dialog
                      // Navigator.pushNamed(context, "/sosSetup");
                    },
                    icon: const Icon(Icons.settings),
                    label: const Text("Location history preferences"),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(5.0),
                  child: TextButton.icon(
                    style: ButtonStyle(
                        foregroundColor:
                            const MaterialStatePropertyAll(Colors.white),
                        backgroundColor:
                            MaterialStatePropertyAll(Constants.appcolor)),
                    onPressed: () {
                      //clear location history
                    },
                    icon: const Icon(Icons.delete_forever_sharp),
                    label: const Text("Clear location history"),
                  ),
                ),
              ],
            ),
          ),
          Constants.mylocationHistory.isNotEmpty
              ? Expanded(
                  child: ListView.builder(
                    itemBuilder: (context, index) {
                      return ListTile();
                    },
                  ),
                )
              : Center(
                  child: const Text(
                      "No history yet, set your preferences and await logs"),
                )
        ],
      ),
    );
  }
}
