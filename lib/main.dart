import 'package:finda/pages/home.dart';
import 'package:finda/requests/locationrequests.dart';
import 'package:flutter/material.dart';

void main() async {
  WidgetsFlutterBinding binding = WidgetsFlutterBinding();
  await requestPermission();
  Map<int, Color> color = {
    50: Color.fromRGBO(136, 14, 79, .1),
    100: Color.fromRGBO(208, 17, 119, 0.2),
    200: Color.fromRGBO(136, 14, 79, .3),
    300: Color.fromRGBO(136, 14, 79, .4),
    400: Color.fromRGBO(136, 14, 79, .5),
    500: Color.fromRGBO(136, 14, 79, .6),
    600: Color.fromRGBO(136, 14, 79, .7),
    700: Color.fromRGBO(136, 14, 79, .8),
    800: Color.fromRGBO(136, 14, 79, .9),
    900: Color.fromRGBO(136, 14, 79, 1),
  };
  MaterialColor colorCustom = MaterialColor(0xFF013220, color);
  runApp(MaterialApp(
    title: "Finda",
    theme: ThemeData(primarySwatch: colorCustom),
    routes: {"/": (context) => Home()},
  ));
}
