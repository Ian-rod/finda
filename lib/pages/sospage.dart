import 'package:finda/constants/constants.dart';
import 'package:finda/pages/mydrawer.dart';
import 'package:finda/requests/notificationrequests.dart';
import 'package:finda/requests/offlinestorage.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class SOSPage extends StatefulWidget {
  const SOSPage({super.key});

  @override
  State<SOSPage> createState() => _SOSPageState();
}

class _SOSPageState extends State<SOSPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: myappdrawer(context),
      drawer: mydrawer(context),
      body: ListView(
        children: [
          //SOS switch
          Center(
            child: Row(
              children: [
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Switch(
                      value: Constants.sosOn,
                      activeColor: Constants.appcolor,
                      onChanged: (value) async {
                        setState(() {
                          Constants.sosOn = !Constants.sosOn;
                        });
                        if (Constants.sosOn) {
                          await showSOSNotification(
                              "Click to send a distress message");
                        } else {
                          //remove notification
                          await flutterLocalNotificationsPlugin.cancel(1);
                        }
                        await saveSOS().then((value) {
                          ScaffoldMessenger.of(context)
                              .showSnackBar(SnackBar(content: Text(value)));
                        });
                      }),
                ),
                Text(Constants.sosOn
                    ? "SOS service is on"
                    : "SOS service is off"),
              ],
            ),
          ),
          //trustee set up page
          Center(
            child: Padding(
              padding: const EdgeInsets.all(15.0),
              child: TextButton.icon(
                style: ButtonStyle(
                    foregroundColor:
                        const MaterialStatePropertyAll(Colors.white),
                    backgroundColor:
                        MaterialStatePropertyAll(Constants.appcolor)),
                onPressed: () {
                  //navigate to SOS setup page
                  context.go("/sosSetup");
                },
                icon: const Icon(Icons.sos_sharp),
                label: const Text("Set up SOS receivers"),
              ),
            ),
          )
        ],
      ),
    );
  }
}
