import 'package:geofence_service/geofence_service.dart';

class GeoFenceConstants {
  //geofence
  // Create a [GeofenceService] instance and set options.
  static final geofenceService = GeofenceService.instance.setup(
      interval: 5000,
      accuracy: 100,
      loiteringDelayMs: 60000,
      statusChangeDelayMs: 10000,
      useActivityRecognition: true,
      allowMockLocations: false,
      printDevLog: false,
      geofenceRadiusSortType: GeofenceRadiusSortType.DESC);
  static List<Geofence> geofenceList = [];
}
