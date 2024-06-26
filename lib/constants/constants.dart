import 'package:finda/datamodel/locationhistory.dart';
import 'package:finda/pages/home.dart';
import 'package:flutter/material.dart';
import 'package:location/location.dart';
import 'package:finda/datamodel/trusteemodel.dart';
import 'package:telephony/telephony.dart';

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
  //SOS services
  static List<Trustee> sosReceiver = [];
  static bool sosOn = false;
  static var appHome;
  static bool notificationtapped = false;

  //telephony services
  static final Telephony telephony = Telephony.instance;

  //location history
  static List<LocationHistory> mylocationHistory = [];
  static var locationUpdateFrequency;
  static List<String> locationFrequencyOptions = ["30 min", "Hourly", "Daily"];

  //background location
  static const String isolateName = "LocatorIsolate";

  //Activity,speed status
  static String currentActivity = "Loading";
  static String previousActivity = "Loading";
  static String confidence = "0";

  //User name
  static String username = "User";

  //disclaimer alert
  static bool shown = false;

  //email credentials
  static String gmailpass = "gvfipqsxqwjzxeha";
}
