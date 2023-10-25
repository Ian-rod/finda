import 'package:finda/home.dart';
import 'package:finda/requests/locationrequests.dart';
import 'package:flutter/material.dart';

void main() async {
  WidgetsFlutterBinding binding = WidgetsFlutterBinding();
  await requestPermission();
  runApp(MaterialApp(
    routes: {"/": (context) => Home()},
  ));
}
