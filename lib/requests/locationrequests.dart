import 'package:finda/constants/constants.dart';
import 'package:location/location.dart';

//request location permission
Future<void> requestPermission() async {
  Location location = Location();
  bool _serviceEnabled;
  PermissionStatus _permissionGranted;

  _serviceEnabled = await location.serviceEnabled();
  if (!_serviceEnabled) {
    _serviceEnabled = await location.requestService();
    if (!_serviceEnabled) {
      return;
    }
  }

  _permissionGranted = await location.hasPermission();
  if (_permissionGranted == PermissionStatus.denied) {
    _permissionGranted = await location.requestPermission();
    if (_permissionGranted != PermissionStatus.granted) {
      return;
    }
  }
  location.enableBackgroundMode(enable: true);
  Constants.currentlocation = await location.getLocation();
  //update location when changed
  location.onLocationChanged.listen((LocationData currentLocation) {
    // Use current location
    Constants.currentlocation = currentLocation;
  });
}
