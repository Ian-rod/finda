// ignore_for_file: prefer_const_constructors

import 'package:finda/constants/constants.dart';
import 'package:finda/datamodel/trusteemodel.dart';
import 'package:finda/requests/offlinestorage.dart';
import 'package:flutter/material.dart';

class SOSsetupPage extends StatefulWidget {
  const SOSsetupPage({super.key});

  @override
  State<SOSsetupPage> createState() => _SOSsetupPageState();
}

class _SOSsetupPageState extends State<SOSsetupPage> {
  Trustee selectedTrustee = Constants.trusteeList[0];
  //add an SOS receiver
  addSOSReceiver(BuildContext context) {
    showDialog(
        context: context,
        builder: (context) {
          return StatefulBuilder(builder: (context, setState) {
            return AlertDialog(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(20))),
                contentPadding: EdgeInsets.only(top: 10),
                title: Text(
                  "Add a SOS Receiver",
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
                                "Choose a trustee to set as an SOS Receiver"),
                          ),
                          //add select trustee option
                          Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: SizedBox(
                                child: DropdownButton(
                                    value: selectedTrustee,
                                    hint: Text(
                                        "Select the radius of the geofence"),
                                    items: Constants.trusteeList.map((e) {
                                      return DropdownMenuItem(
                                          value: e, child: Text(e.trusteeName));
                                    }).toList(),
                                    onChanged: (value) {
                                      setState(() {
                                        selectedTrustee = value!;
                                      });
                                    })),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: ElevatedButton(
                                onPressed: () async {
                                  //create a safezone instance
                                  super.setState(() {
                                    Constants.sosReceiver.add(selectedTrustee);
                                  });
                                  //save
                                  await saveSOSReceiverdata().then((value) {
                                    Navigator.of(context).pop();
                                    ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(content: Text(value)));
                                  });
                                },
                                child: Text("Save SOS receiver")),
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
      appBar: AppBar(
        title: Text("Trustee set up page"),
        centerTitle: true,
      ),
      body: Constants.sosReceiver.isNotEmpty
          ? ListView.builder(
              itemCount: Constants.sosReceiver.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Card(
                    elevation: 10,
                    child: ListTile(
                      onLongPress: () {
                        //call confirmation box
                        showDialog(
                            context: context,
                            builder: (context) {
                              return AlertDialog(
                                title: Row(children: const [
                                  Text("Confirm delete"),
                                  SizedBox(
                                    width: 7,
                                  ),
                                  Icon(Icons.delete_forever)
                                ]),
                                content: Text(
                                    "Are you sure you want to delete the selected SOS Receiver?"),
                                actions: [
                                  TextButton(
                                      onPressed: () async {
                                        //perform delete
                                        setState(() {
                                          Constants.sosReceiver.removeAt(index);
                                        });
                                        //save
                                        await saveSOSReceiverdata()
                                            .then((value) {
                                          Navigator.of(context).pop();
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(SnackBar(
                                                  content: Text(value)));
                                        });
                                      },
                                      child: Text("Yes")),
                                  TextButton(
                                      onPressed: () {
                                        //close dialog
                                        Navigator.of(context).pop();
                                      },
                                      child: Text("No"))
                                ],
                              );
                            });
                      },
                      title: Text(Constants.sosReceiver[index].trusteeName),
                      leading: CircleAvatar(
                        foregroundColor: Colors.white,
                        backgroundColor: Constants.appcolor,
                        child: Icon(Icons.person),
                      ),
                    ),
                  ),
                );
              },
            )
          : Center(
              child: Text("No SOS receivers set tap + to add an SOS receiver"),
            ),
      floatingActionButton: FloatingActionButton(
          child: Icon(Icons.add),
          onPressed: () {
            //add an SOS receiver
            addSOSReceiver(context);
          }),
    );
  }
}
