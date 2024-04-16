// ignore_for_file: prefer_const_constructors

import 'package:finda/constants/constants.dart';
import 'package:finda/pages/mydrawer.dart';
import 'package:finda/requests/offlinestorage.dart';
import 'package:finda/requests/printreports.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../requests/backgroundservices.dart';

class LocationHistoryPage extends StatefulWidget {
  const LocationHistoryPage({super.key});

  @override
  State<LocationHistoryPage> createState() => _LocationHistoryPageState();
}

class _LocationHistoryPageState extends State<LocationHistoryPage> {
  String updateFrequency = "Daily";
  @override
  void initState() {
    super.initState();
    //check current frequency status
    if (Constants.locationUpdateFrequency == 30) {
      updateFrequency = "30 min";
    } else if (Constants.locationUpdateFrequency == 60) {
      updateFrequency = "Hourly";
    }
  }

  //select update frequency
  updateLocationFrequency(BuildContext context) {
    showDialog(
        context: context,
        builder: (context) {
          return StatefulBuilder(builder: (context, setState) {
            return AlertDialog(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(20))),
                contentPadding: EdgeInsets.only(top: 10),
                title: Text(
                  "Select a frequency interval",
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
                            child: Text("Choose a frequency"),
                          ),
                          //add select trustee option
                          Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: SizedBox(
                                child: DropdownButton(
                                    value: updateFrequency,
                                    hint: Text("Select an update frequency"),
                                    items: Constants.locationFrequencyOptions
                                        .map((e) {
                                      return DropdownMenuItem(
                                          value: e, child: Text(e));
                                    }).toList(),
                                    onChanged: (value) {
                                      setState(() {
                                        updateFrequency = value!;
                                      });
                                    })),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: ElevatedButton(
                                onPressed: () async {
                                  int updateFrequencyValue = 1440;
                                  if (updateFrequency == "30 min") {
                                    updateFrequencyValue = 30;
                                  } else if (updateFrequency == "Hourly") {
                                    updateFrequencyValue = 60;
                                  } else {
                                    updateFrequencyValue = 1440;
                                  }
                                  super.setState(() {
                                    Constants.locationUpdateFrequency =
                                        updateFrequencyValue;
                                  });
                                  //update history log frequency
                                  locationHistorypdater();
                                  //save
                                  await saveLocationHistoryAndStatus()
                                      .then((value) {
                                    Navigator.of(context).pop();
                                    ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(content: Text(value)));
                                  });
                                },
                                child: Text("update location log frequency")),
                          )
                        ],
                      ),
                    ])));
          });
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: myappbar(context),
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
                  padding: const EdgeInsets.all(20.0),
                  child: Center(
                    child: Text(
                      "Current location frequency is: $updateFrequency",
                      style: TextStyle(
                        fontSize: 20,
                        color: Constants.appcolor,
                      ),
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
                      updateLocationFrequency(context);
                    },
                    icon: const Icon(Icons.settings),
                    label: const Text("Location history preferences"),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(5.0),
                      child: TextButton.icon(
                        style: ButtonStyle(
                            foregroundColor:
                                const MaterialStatePropertyAll(Colors.white),
                            backgroundColor:
                                MaterialStatePropertyAll(Constants.appcolor)),
                        onPressed: () async {
                          //clear location history
                          // Constants.mylocationHistory.clear();
                          // await saveLocationHistoryAndStatus();
                          // setState(() {
                          //   Constants.mylocationHistory = [];
                          // });
                        },
                        icon: const Icon(Icons.delete_forever_sharp),
                        label: const Text("Clear location history"),
                      ),
                    ),
                    //print reports
                    Padding(
                      padding: const EdgeInsets.all(5.0),
                      child: TextButton.icon(
                        style: ButtonStyle(
                            foregroundColor:
                                const MaterialStatePropertyAll(Colors.white),
                            backgroundColor:
                                MaterialStatePropertyAll(Constants.appcolor)),
                        onPressed: () async {
                          await printReport().then((value) {
                            ScaffoldMessenger.of(context)
                                .showSnackBar(SnackBar(content: Text(value)));
                          });
                        },
                        icon: const Icon(Icons.print),
                        label: const Text("Print location report"),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Constants.mylocationHistory.isNotEmpty
              ? Expanded(
                  child: ListView.builder(
                    itemCount: Constants.mylocationHistory.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Constants.appcolor,
                          child: Icon(
                            Icons.location_on_outlined,
                            color: Colors.white,
                          ),
                        ),
                        title: Text(
                            "Longitude: ${Constants.mylocationHistory[index].longitude.toString()} Latitude: ${Constants.mylocationHistory[index].latitude.toString()}"),
                        subtitle:
                            Text(Constants.mylocationHistory[index].address),
                        trailing: Text(
                            "${DateFormat.yMMMEd().format(Constants.mylocationHistory[index].logTime)} ${DateFormat.j().format(Constants.mylocationHistory[index].logTime)}"),
                      );
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
