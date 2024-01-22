import 'package:flutter/material.dart';
import 'package:location/location.dart';
import 'package:finda/datamodel/trusteemodel.dart';

class Constants {
  static var appname = "Finda";
  static var appcolor = Colors.green[900];
  static var currentlocation;
  //the global location store
  static Location location = Location();
  static late WidgetsFlutterBinding binding;

  //
  static var safezone;

  //List of trustees
  static List<Trustee> trusteeList = [];
  static List<String> frequencyoptions = [
    "Daily",
    "Weekly",
    "Monthly",
    "Yearly"
  ];
}
