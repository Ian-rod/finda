import 'package:background_fetch/background_fetch.dart';
import 'package:finda/constants/constants.dart';
import 'package:finda/datamodel/locationhistory.dart';
import 'package:finda/requests/offlinestorage.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';

locationHistorypdater() async {
  await BackgroundFetch.configure(
      BackgroundFetchConfig(
        minimumFetchInterval: Constants.locationUpdateFrequency,
        requiredNetworkType: NetworkType.NONE,
        stopOnTerminate: false,
        enableHeadless: true,
        requiresBatteryNotLow: false,
        requiresCharging: false,
        requiresStorageNotLow: false,
        requiresDeviceIdle: false,
      ), (String taskid) async {
    //update location history records
    //store current location in location list
    Constants.mylocationHistory.add(LocationHistory(
        longitude: Constants.currentlocation.longitude,
        latitude: Constants.currentlocation.latitude,
        logTime: DateTime.now(),
        address: await obtainAddress()));
    //save to local storage
    await saveLocationHistoryAndStatus();
    //close function call
    BackgroundFetch.finish(taskid);
  });
}

//try to obtain longitude and latitude address
//maybe add a location checker
Future<String> obtainAddress() async {
  String address = "Address unavailable";
  try {
    List<Placemark> placemarks = await placemarkFromCoordinates(
        Constants.currentlocation.latitude,
        Constants.currentlocation.longitude);
    address =
        "Country: ${placemarks[0].country}\nLocality: ${placemarks[0].locality}\nStreet: ${placemarks[0].street}";
  } catch (e) {
    debugPrint(e.toString());
  }
  return address;
}
