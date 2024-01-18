import 'dart:math';

List<double> getBoundingBox(
    double centerLat, double centerLon, double distance) {
  // Radius of the Earth in meters
  const double earthRadius =
      6378100; // approximate value, can be adjusted for more precision

  // Convert distance from meters to radians
  double distanceRad = distance / earthRadius;

  // Convert latitude and longitude from degrees to radians
  double centerLatRad = radians(centerLat);
  double centerLonRad = radians(centerLon);

  // Calculate latitude range
  double minLat = centerLatRad - distanceRad;
  double maxLat = centerLatRad + distanceRad;

  // Calculate longitude range
  double deltaLon = asin(sin(distanceRad) / cos(centerLatRad));
  double minLon = centerLonRad - deltaLon;
  double maxLon = centerLonRad + deltaLon;

  // Convert back to degrees
  minLat = degrees(minLat);
  maxLat = degrees(maxLat);
  minLon = degrees(minLon);
  maxLon = degrees(maxLon);

  return [minLat, maxLat, minLon, maxLon];
}

double radians(double degrees) {
  return degrees * (pi / 180.0);
}

double degrees(double radians) {
  return radians * (180.0 / pi);
}
