import 'package:finda/constants/constants.dart';
import 'package:finda/constants/geoconstants.dart';
import 'package:location/location.dart' as locationPackage;
import 'package:geofence_service/geofence_service.dart';

//request location permission
Future<void> requestPermission() async {
  bool _serviceEnabled;
  locationPackage.PermissionStatus _permissionGranted;

  _serviceEnabled = await Constants.location.serviceEnabled();
  if (!_serviceEnabled) {
    _serviceEnabled = await Constants.location.requestService();
    if (!_serviceEnabled) {
      return;
    }
  }

  _permissionGranted = await Constants.location.hasPermission();
  if (_permissionGranted == locationPackage.PermissionStatus.denied) {
    _permissionGranted = await Constants.location.requestPermission();
    if (_permissionGranted != locationPackage.PermissionStatus.granted) {
      return;
    }
  }

  Constants.currentlocation = await Constants.location.getLocation();
}
