import 'dart:collection';
import 'dart:io';

import 'package:finda/constants/constants.dart';
import 'package:finda/requests/backgroundservices.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:geocoding/geocoding.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:open_filex/open_filex.dart';

//most visited places
Map<String, int> mostvisited = {};
List<pw.Widget> mostvisitedOutput = [];
Future<String> printReport() async {
  //using Constants.mylocationHistory
  //load images
  final f = DateFormat('yyyy-MM-dd hh:mm a');
  final gpsImage = pw.MemoryImage(
    (await rootBundle.load('images/gps.png')).buffer.asUint8List(),
  );
  final pdf = pw.Document();
  final headers = ['Longitude', 'Latitude', 'Log Time', 'Address'];
  await getfrequentLocation();
//compulsory page for details
  pdf.addPage(
    pw.Page(
      build: (pw.Context context) {
        return pw.Center(
          child: pw.Padding(
            padding: const pw.EdgeInsets.all(10),
            child: pw.ListView(children: [
              pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.center,
                  crossAxisAlignment: pw.CrossAxisAlignment.center,
                  children: [
                    pw.Text(Constants.appname,
                        style: pw.TextStyle(
                            fontSize: 30, fontWeight: pw.FontWeight.bold)),
                    pw.SizedBox(
                        child: pw.Image(gpsImage), height: 70, width: 70)
                  ]),
              pw.RichText(
                  text: pw.TextSpan(
                      style: const pw.TextStyle(
                        fontSize: 16.0,
                      ),
                      children: [
                    pw.TextSpan(
                        text: "Current safezone:",
                        style: pw.TextStyle(
                            fontSize: 20, fontWeight: pw.FontWeight.bold)),
                    pw.TextSpan(
                        text:
                            "\n\t\t\t\t\t\t\t\t${Constants.safezone.geofenceName}")
                  ])),
              //most frequent location
              pw.Column(children: mostvisitedOutput)
            ]),
          ),
        );
      },
    ),
  );

  //divide data into (13) for multiple pages
  if (Constants.mylocationHistory.length <= 13) {
    final List<List<String>> data = Constants.mylocationHistory.map((location) {
      return [
        location.longitude.toString(),
        location.latitude.toString(),
        f.format(location.logTime),
        location.address,
      ];
    }).toList();

    // Add headers and data to the table
    final table = pw.TableHelper.fromTextArray(
      headers: headers,
      data: data,
      border: pw.TableBorder.all(),
      headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
      cellAlignments: {
        0: pw.Alignment.center,
        1: pw.Alignment.center,
        2: pw.Alignment.center,
        3: pw.Alignment.centerLeft,
      },
    );

    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Center(
            child: pw.Padding(
              padding: const pw.EdgeInsets.all(10),
              child: table,
            ),
          );
        },
      ),
    );
  } else {
    //multiple pages need to be created
    int listsize = Constants.mylocationHistory.length;
    debugPrint(listsize.toString());
    int looptimes = (listsize / 13).ceil();
    int startindex = 0;
    int endindex = 12;
    for (int i = 0; i < looptimes; i++) {
      var mostvisitedlist =
          Constants.mylocationHistory.sublist(startindex, endindex);
      //create table
      final List<List<String>> data = mostvisitedlist.map((location) {
        return [
          location.longitude.toString(),
          location.latitude.toString(),
          f.format(location.logTime),
          location.address,
        ];
      }).toList();

      // Add headers and data to the table
      final table = pw.TableHelper.fromTextArray(
        headers: headers,
        data: data,
        border: pw.TableBorder.all(),
        headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
        cellAlignments: {
          0: pw.Alignment.center,
          1: pw.Alignment.center,
          2: pw.Alignment.center,
          3: pw.Alignment.centerLeft,
        },
      );

      pdf.addPage(
        pw.Page(
          build: (pw.Context context) {
            return pw.Center(
              child: pw.Padding(
                padding: const pw.EdgeInsets.all(10),
                child: pw.ListView(children: [
                  pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.end,
                      crossAxisAlignment: pw.CrossAxisAlignment.end,
                      children: [
                        pw.Text(Constants.appname,
                            style: pw.TextStyle(
                                fontSize: 30, fontWeight: pw.FontWeight.bold)),
                        pw.SizedBox(
                            child: pw.Image(gpsImage), height: 70, width: 70)
                      ]),
                  table
                ]),
              ),
            );
          },
        ),
      );
      startindex = endindex;
      //end index
      if (listsize - (endindex + 1) > 13) {
        endindex += 13;
      } else {
        endindex = listsize;
      }
    }
  }

//save to file
  try {
    final file = File("/storage/emulated/0/Download/locationlog.pdf");
    await file.writeAsBytes(await pdf.save());
    //open the pdf
    OpenFilex.open("/storage/emulated/0/Download/locationlog.pdf");
    return "Reports created successfully";
  } catch (e) {
    debugPrint(e.toString());
    return "error generating reports : ${e.toString()}";
  }
}

//get most frequent location...perform reverse geocoding
getfrequentLocation() async {
  mostvisited.clear();
  mostvisitedOutput.clear();
  for (var location in Constants.mylocationHistory) {
    String latitude = location.latitude.toString();
    String longitude = location.longitude.toString();
    //filter to 5 digits
    latitude = latitude.substring(0, 6); //for the -
    longitude = longitude.substring(0, 6);
    String key = "$latitude,$longitude";
    if (mostvisited.containsKey(key)) {
      mostvisited.update(key, (value) => ++value);
    } else {
      mostvisited[key] = 1;
    }
  }
  //address look up for the most visited
  //sort based on most visited

  var sortedKeys = mostvisited.keys.toList(growable: false)
    ..sort((k1, k2) => mostvisited[k1]!.compareTo(mostvisited[k2]!));
  LinkedHashMap<String, int> sortedMap =
      LinkedHashMap<String, int>.fromIterable(sortedKeys,
          key: (k) => k, value: (k) => mostvisited[k]!);
  try {
    final result = await InternetAddress.lookup('example.com');
    if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
      //internet available
      for (int i = 0; i < sortedMap.length; i++) {
        MapEntry<String, int> entry = sortedMap.entries.elementAt(i);
        int commaindex = entry.key.indexOf(",");
        double latitude = double.parse(entry.key.substring(0, commaindex));
        double longitude =
            double.parse(entry.key.substring(commaindex + 1, entry.key.length));
        List<Placemark> placemarks =
            await placemarkFromCoordinates(latitude, longitude);
        String address =
            "\t\t\t\t\t\tCountry: ${placemarks[0].country}\n\t\t\t\t\t\tLocality: ${placemarks[0].locality}\n\t\t\t\t\t\tStreet: ${placemarks[0].street}";

        //build output widget
        mostvisitedOutput.add(
          pw.RichText(
              text: pw.TextSpan(
                  style: const pw.TextStyle(
                    fontSize: 16.0,
                  ),
                  children: [
                pw.TextSpan(
                    text: "\nMost visited places:",
                    style: pw.TextStyle(
                        fontSize: 20, fontWeight: pw.FontWeight.bold)),
                pw.TextSpan(text: "\n$address"),
              ])),
        );
        mostvisitedOutput.add(
          pw.RichText(
              text: pw.TextSpan(
                  style: const pw.TextStyle(
                    fontSize: 16.0,
                  ),
                  children: [
                pw.TextSpan(
                    text: "\nLatitude,Longitude:",
                    style: pw.TextStyle(
                        fontSize: 20, fontWeight: pw.FontWeight.bold)),
                pw.TextSpan(text: "\n\t\t\t\t\t\t${entry.key}"),
              ])),
        );
        mostvisitedOutput.add(
          pw.RichText(
              text: pw.TextSpan(
                  style: const pw.TextStyle(
                    fontSize: 16.0,
                  ),
                  children: [
                pw.TextSpan(
                    text: "\nFrequency:",
                    style: pw.TextStyle(
                        fontSize: 20, fontWeight: pw.FontWeight.bold)),
                pw.TextSpan(text: "\n\t\t\t\t\t\t${entry.value.toString()}")
              ])),
        );
      }
    }
  } on SocketException catch (_) {
    //internet unavailable
    for (int i = 0; i < sortedMap.length; i++) {
      MapEntry<String, int> entry = sortedMap.entries.elementAt(i);
      String address = "address unavailable due to lack of internet";

      //build output widget
      mostvisitedOutput.add(
        pw.RichText(
            text: pw.TextSpan(
                style: const pw.TextStyle(
                  fontSize: 16.0,
                ),
                children: [
              pw.TextSpan(
                  text: "\nMost visited places:",
                  style: pw.TextStyle(
                      fontSize: 20, fontWeight: pw.FontWeight.bold)),
              pw.TextSpan(text: "\n$address"),
            ])),
      );
      mostvisitedOutput.add(
        pw.RichText(
            text: pw.TextSpan(
                style: const pw.TextStyle(
                  fontSize: 16.0,
                ),
                children: [
              pw.TextSpan(
                  text: "\nLatitude,Longitude:",
                  style: pw.TextStyle(
                      fontSize: 20, fontWeight: pw.FontWeight.bold)),
              pw.TextSpan(text: "\n\t\t\t\t\t\t${entry.key}"),
            ])),
      );
      mostvisitedOutput.add(
        pw.RichText(
            text: pw.TextSpan(
                style: const pw.TextStyle(
                  fontSize: 16.0,
                ),
                children: [
              pw.TextSpan(
                  text: "\nFrequency:",
                  style: pw.TextStyle(
                      fontSize: 20, fontWeight: pw.FontWeight.bold)),
              pw.TextSpan(text: "\n\t\t\t\t\t\t${entry.value.toString()}")
            ])),
      );
    }
  }
}
