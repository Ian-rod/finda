import 'package:finda/constants/constants.dart';
import 'package:finda/constants/geoconstants.dart';
import 'package:location/location.dart' as locationpackage;
import 'package:geofence_service/geofence_service.dart';

//request location permission
Future<void> requestPermission() async {
  bool _serviceEnabled;
  locationpackage.PermissionStatus _permissionGranted;

  _serviceEnabled = await Constants.location.serviceEnabled();
  if (!_serviceEnabled) {
    _serviceEnabled = await Constants.location.requestService();
    if (!_serviceEnabled) {
      return;
    }
  }

  _permissionGranted = await Constants.location.hasPermission();
  if (_permissionGranted == locationpackage.PermissionStatus.denied) {
    _permissionGranted = await Constants.location.requestPermission();
    if (_permissionGranted != locationpackage.PermissionStatus.granted) {
      return;
    }
  }

  Constants.currentlocation = await Constants.location.getLocation();
}

//start geofence service