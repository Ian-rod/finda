import 'dart:convert';

import 'package:finda/constants/constants.dart';
import 'package:finda/constants/geoconstants.dart';
import 'package:finda/datamodel/safezone.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:geofence_service/geofence_service.dart';

late SharedPreferences prefs;
//fetch data from local storage else create a new
//the map is converted into a json string then stored as a string variable
Future<void> getdata() async {
  var jsonString;
  try {
    prefs = await SharedPreferences.getInstance();
    jsonString = prefs.getString("geofencelist");
    if (jsonString != null) {
      //convert to List<String> then to List<Geofence>
      List<dynamic> templist = List.from(json.decode(jsonString));
      for (var element in templist) {
        // var tempmap = jsonDecode(element);
        // print(element['placeid']);
        var geofenceradius;
        if (element['radius'] == "20.0") {
          geofenceradius = GeofenceRadius(id: 'radius_20m', length: 20);
        } else if (element['radius'] == "50.0") {
          geofenceradius = GeofenceRadius(id: 'radius_50m', length: 50);
        } else if (element['radius'] == "100.0") {
          geofenceradius = GeofenceRadius(id: 'radius_100m', length: 100);
        } else if (element['radius'] == "150.0") {
          geofenceradius = GeofenceRadius(id: 'radius_150m', length: 150);
        } else if (element['radius'] == "200.0") {
          geofenceradius = GeofenceRadius(id: 'radius_200m', length: 200);
        } else if (element['radius'] == "250.0") {
          geofenceradius = GeofenceRadius(id: 'radius_250m', length: 250);
        }
        GeoFenceConstants.geofenceList.add(Geofence(
            id: element['placeid'],
            latitude: double.parse(element['latitude']),
            longitude: double.parse(element['longitude']),
            radius: [geofenceradius]));
      }
    }

    //
  } catch (e) {
    print("RUN INTO EXCEPTION :" + e.toString());
  }
}

Future<String> savedata() async {
  prefs = await SharedPreferences.getInstance();
  String returnmessage = "Geofence changes saved successfully";
  try {
    //convert to list<String> then encode
    List<Map<String, String>> templist = [];
    for (var element in GeoFenceConstants.geofenceList) {
      String placeid = element.id;
      String radius = element.radius[0].length.toString();
      String longitude = element.longitude.toString();
      String latitude = element.latitude.toString();
      Map<String, String> data = {
        'placeid': placeid,
        'radius': radius,
        'longitude': longitude,
        'latitude': latitude
      };
      templist.add(data);
    }
    //save safe area details
    var jsonString = jsonEncode(templist);
    await prefs.setString("geofencelist", jsonString);
  } catch (e) {
    returnmessage = e.toString();
  }
  return returnmessage;
}

Future<String> saveSafezonedata() async {
  prefs = await SharedPreferences.getInstance();
  String returnmessage = "Safezone saved successfully";
  try {
    //convert to list<String> then encode
    Map<String, String> tempdata = {
      "geofenceName": Constants.safezone.geofenceName,
      "longitude": Constants.safezone.longitude.toString(),
      "latitude": Constants.safezone.latitude.toString(),
      "radius": Constants.safezone.radius.toString(),
    };
    //save safe area details
    var jsonString = jsonEncode(tempdata);
    await prefs.setString("safezone", jsonString);
  } catch (e) {
    returnmessage = e.toString();
  }
  return returnmessage;
}

Future<void> getsafezonedata() async {
  var jsonString;
  try {
    prefs = await SharedPreferences.getInstance();
    jsonString = prefs.getString("safezone");
    if (jsonString != null) {
      Map<String, dynamic> tempdata = json.decode(jsonString);
      Constants.safezone = Safezone(
          geofenceName: tempdata["geofenceName"]!,
          longitude: double.parse(tempdata["longitude"]!),
          latitude: double.parse(tempdata["latitude"]!),
          radius: double.parse(tempdata["radius"]!));
    }

    //
  } catch (e) {
    print("RUN INTO EXCEPTION :" + e.toString());
  }
}
