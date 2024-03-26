import 'dart:io';

import 'package:finda/constants/constants.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/widgets.dart';

Future<String> printReport() async {
  //using Constants.mylocationHistory
  //load images
  final f = DateFormat('yyyy-MM-dd hh:mm');
  final font = await rootBundle.load("assets/open-sans.ttf");
  final gpsImage = pw.MemoryImage(
    (await rootBundle.load('images/gps.png')).buffer.asUint8List(),
  );
  final pdf = pw.Document();
  final headers = ['Longitude', 'Latitude', 'Log Time', 'Address'];
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

//save to file
  try {
    final file = File("/storage/emulated/0/Download/locationlog.pdf");
    await file.writeAsBytes(await pdf.save());

    return "Reports created successfully and can be found at Downloads/locationlog.pdf";
  } catch (e) {
    debugPrint(e.toString());
    return "error generating reports : ${e.toString()}";
  }
}
