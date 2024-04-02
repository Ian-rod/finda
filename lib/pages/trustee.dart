// ignore_for_file: prefer_const_constructors

import 'package:finda/constants/constants.dart';
import 'package:finda/datamodel/trusteemodel.dart';
import 'package:finda/pages/mydrawer.dart';
import 'package:finda/requests/offlinestorage.dart';
import 'package:flutter/material.dart';

class TrusteePage extends StatefulWidget {
  const TrusteePage({super.key});

  @override
  State<TrusteePage> createState() => _TrusteePageState();
}

class _TrusteePageState extends State<TrusteePage> {
  var formKey = GlobalKey<FormState>();
  var trusteeNameController = TextEditingController();
  var trusteePhoneController = TextEditingController();
  var trusteeEmailController = TextEditingController();
  String frequencyoption = "Daily";
  //add trustee page
  addTrustee(BuildContext context) {
    showDialog(
        context: context,
        builder: (context) {
          return StatefulBuilder(builder: (context, setState) {
            return AlertDialog(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(20))),
                contentPadding: EdgeInsets.only(top: 10),
                title: Text(
                  "Add a trustee",
                  style: TextStyle(fontSize: 24),
                ),
                content: SizedBox(
                    height: 300,
                    width: 300,
                    child: ListView(padding: EdgeInsets.all(10), children: [
                      Form(
                        key: formKey,
                        child: Column(
                          children: [
                            //trustee name
                            Padding(
                              padding: const EdgeInsets.all(10.0),
                              child: TextFormField(
                                controller: trusteeNameController,
                                validator: (value) {
                                  if (value == null ||
                                      value.toString().isEmpty) {
                                    return "Please enter the trustee name";
                                  }
                                },
                                decoration: InputDecoration(
                                    border: OutlineInputBorder(),
                                    hintText: "Enter the trustee name",
                                    labelText: "Trustee name"),
                              ),
                            ),
                            //phone number
                            //trustee phone number
                            Padding(
                              padding: const EdgeInsets.all(10.0),
                              child: TextFormField(
                                controller: trusteePhoneController,
                                keyboardType: TextInputType.phone,
                                validator: (value) {
                                  if (value == null ||
                                      value.toString().isEmpty) {
                                    return "Please enter the trustee phone number";
                                  }
                                  if (value.length != 10) {
                                    return "invalid phone number length";
                                  }
                                  return null;
                                },
                                decoration: InputDecoration(
                                    border: OutlineInputBorder(),
                                    hintText: "Enter the trustee phone number",
                                    labelText: "Trustee phone number"),
                              ),
                            ),
                            //email
                            //trustee name
                            Padding(
                              padding: const EdgeInsets.all(10.0),
                              child: TextFormField(
                                controller: trusteeEmailController,
                                keyboardType: TextInputType.emailAddress,
                                validator: (value) {
                                  if (value == null ||
                                      value.toString().isEmpty) {
                                    return "Please enter the trustee email";
                                  }
                                  if (!RegExp(
                                          r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
                                      .hasMatch(value)) {
                                    return "Please use a valid email address";
                                  }
                                  return null;
                                },
                                decoration: InputDecoration(
                                    border: OutlineInputBorder(),
                                    hintText: "Enter the trustee email",
                                    labelText: "Trustee email"),
                              ),
                            ),
                            //add select radius option
                            Padding(
                              padding: const EdgeInsets.all(10.0),
                              child: SizedBox(
                                  child: DropdownButton(
                                      value: frequencyoption,
                                      hint: Text(
                                          "Select the frequency of the updates"),
                                      items:
                                          Constants.frequencyoptions.map((e) {
                                        return DropdownMenuItem(
                                            value: e, child: Text(e));
                                      }).toList(),
                                      onChanged: (value) {
                                        setState(() {
                                          frequencyoption = value!;
                                        });
                                      })),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(10.0),
                              child: ElevatedButton(
                                  onPressed: () async {
                                    //Save details
                                    if (formKey.currentState!.validate()) {
                                      //save records
                                      //save data to local storage and show sucess message
                                      super.setState(() {
                                        Constants.trusteeList.add(Trustee(
                                            trusteeName:
                                                trusteeNameController.text,
                                            trusteePhone:
                                                trusteePhoneController.text,
                                            trusteeEmail:
                                                trusteeEmailController.text,
                                            frequency: frequencyoption));
                                      });
                                      await saveTrusteedata().then((value) {
                                        //save trustee
                                        Navigator.of(context).pop();
                                        trusteeEmailController.clear();
                                        trusteeNameController.clear();
                                        trusteePhoneController.clear();
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                                SnackBar(content: Text(value)));
                                      });
                                    }
                                  },
                                  child: Text("Save new Trustee")),
                            )
                          ],
                        ),
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
      body: Constants.trusteeList.isNotEmpty
          ? Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Center(
                    child: Text(
                      "Trustees",
                      style: TextStyle(
                          fontSize: 20,
                          color: Constants.appcolor,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: Constants.trusteeList.length,
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
                                          "Are you sure you want to delete the selected Trustee?"),
                                      actions: [
                                        TextButton(
                                            onPressed: () async {
                                              //perform delete
                                              setState(() {
                                                Constants.trusteeList
                                                    .removeAt(index);
                                              });
                                              //save
                                              await saveTrusteedata()
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
                            title:
                                Text(Constants.trusteeList[index].trusteeName),
                            leading: CircleAvatar(
                              foregroundColor: Colors.white,
                              backgroundColor: Constants.appcolor,
                              child: Icon(Icons.person),
                            ),
                            subtitle: Text(
                                "Phone Number: ${Constants.trusteeList[index].trusteePhone}\nEmail: ${Constants.trusteeList[index].trusteeEmail}"),
                            trailing:
                                Text(Constants.trusteeList[index].frequency),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            )
          : Center(child: Text("Tap + to add a trustee")),
      floatingActionButton: FloatingActionButton(
          child: Icon(Icons.add),
          onPressed: () {
            //open trustee add page
            addTrustee(context);
          }),
    );
  }
}
