import 'dart:io';

import 'package:finda/constants/constants.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:open_filex/open_filex.dart';

Future<String> printReport() async {
  //using Constants.mylocationHistory
  //load images
  final f = DateFormat('yyyy-MM-dd hh:mm a');
  final font = await rootBundle.load("assets/open-sans.ttf");
  final gpsImage = pw.MemoryImage(
    (await rootBundle.load('images/gps.png')).buffer.asUint8List(),
  );
  final pdf = pw.Document();
  final headers = ['Longitude', 'Latitude', 'Log Time', 'Address'];
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
      var templist = Constants.mylocationHistory.sublist(startindex, endindex);
      //create table
      final List<List<String>> data = templist.map((location) {
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
