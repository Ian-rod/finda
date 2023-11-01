import 'package:finda/constants/constants.dart';
import 'package:location/location.dart';

//request location permission
Future<void> requestPermission() async {
  bool _serviceEnabled;
  PermissionStatus _permissionGranted;

  _serviceEnabled = await Constants.location.serviceEnabled();
  if (!_serviceEnabled) {
    _serviceEnabled = await Constants.location.requestService();
    if (!_serviceEnabled) {
      return;
    }
  }

  _permissionGranted = await Constants.location.hasPermission();
  if (_permissionGranted == PermissionStatus.denied) {
    _permissionGranted = await Constants.location.requestPermission();
    if (_permissionGranted != PermissionStatus.granted) {
      return;
    }
  }

  Constants.currentlocation = await Constants.location.getLocation();
}
