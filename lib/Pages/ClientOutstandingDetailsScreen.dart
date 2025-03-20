import 'dart:convert';
import 'dart:io';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:jewelleryerp/Pages/HomeDashBoard.dart';
import 'package:path_provider/path_provider.dart';
import '../Components/SideNavigation.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../Constants/Functions.dart';
import '../Constants/StaticConstant.dart';
import 'MaxWidthContainer.dart';
import 'package:pie_chart/pie_chart.dart';
import 'package:flutter_native_html_to_pdf/flutter_native_html_to_pdf.dart';

import 'PDFScreen.dart';

class ClientOutstandingDetailsScreen extends StatefulWidget {
  String keyName = "";

  ClientOutstandingDetailsScreen({required this.keyName});

  @override
  _ClientOutstandingDetailsScreenState createState() =>
      _ClientOutstandingDetailsScreenState();
}

class _ClientOutstandingDetailsScreenState
    extends State<ClientOutstandingDetailsScreen> {
  final _flutterNativeHtmlToPdfPlugin = FlutterNativeHtmlToPdf();

  bool loader = true;
  Constans constans = Constans();

  @override
  void initState() {
    super.initState();
    getUserData();
  }

  List<Map<String, dynamic>> data = [];

  Future<void> getUserData() async {
    String? userData = await Constans().getData(StaticConstant.userData);

    fetchLists(jsonDecode(userData!));
  }

  Future<void> fetchLists(Map<String, dynamic> userData) async {
    getMetalList(userData);
  }

  Future<void> getMetalList(Map<String, dynamic> userData) async {
    var formData = {
      'companyid': userData['companyid'],
      'select': "1",
      'clientname': widget.keyName,
    };

    String response =
        await constans.callApi(formData, StaticUrl.erpClientoutstandingUrl);
    Map<String, dynamic> responseData = json.decode(response);

    print(responseData['data']);

    setState(() {
      loader = false;
      data = List<Map<String, dynamic>>.from(responseData['data']);
    });
    // }
  }

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  double balWt = 0;
  double balAmt = 0;

  String getBalWt(double differet) {
    balWt = balWt + differet;
    return balWt.toStringAsFixed(3);
  }

  String getBalAmt(double differet) {
    balAmt = balAmt + differet;

    return balAmt.toStringAsFixed(2);
  }

// Common Text Styles
  TextStyle headerStyle = const TextStyle(
    color: Colors.white,
    fontWeight: FontWeight.bold,
  );

  TextStyle rowStyle = const TextStyle(
    color: Colors.black,
  );

  Future<int> createCatalogHTML(BuildContext context, String clientName) async {

    balWt = 0;
    balAmt = 0;
    String? generatedPdfFilePath;
    String currentDate = DateFormat('dd-MM-yyyy').format(DateTime.now());

    String list = "";


    // <th>Date</th>
    // <th>VR No</th>
    // <th>Type</th>
    // <th>In-Fine</th>
    // <th>Out-Fine</th>
    // <th>Bal Fine</th>
    // <th>In-Amt</th>
    // <th>Out-Amt</th>
    // <th>Bal-Amt</th>
    for (var item in data) {
      list += """<tr>
                <td>${constans.getDate(item['vrdate'])}</td>
                <td>${item['vrno']}</td>
                <td>${item['fot']}</td>
                <td>${item['inwt']}</td>
                <td>${item['outwt']}</td>
                <td>${getBalWt((double.parse(item['inwt']) -double.parse(item['outwt'])))}</td>
                <td>${item['inamt']}</td>
                <td>${item['outamt']}</td>
                <td>${getBalAmt((double.parse(item['inamt']) -double.parse(item['outamt']))).toString()}</td>
            </tr>""";
    }

    String finalHTML = """<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <style>
        @page {
            size: A4;
            margin: 50px 20px; /* Add space for header */
        }
        body {
            font-family: Arial, sans-serif;
            margin: 0;
            padding: 0;
        }
.header {
            display: flex;
            justify-content: space-between;
            align-items: center;
        }
        .table {
            width: 100%;
            border-collapse: collapse;
            margin-top: 10px;
        }

        .table th, .table td {
            border: 1px solid rgba(0, 0, 0, 0.25);
            text-align: center;
            font-size: 12px;
            padding: 5px;
        }

        thead {
            display: table-header-group; /* Ensures the header is repeated on each page */
        }

        .page-break {
            page-break-before: always; /* Forces a new page */
        }
    </style>
</head>
<body>

    <div class="header">
        <h2>${clientName}</h2>
        <h2>Date: $currentDate</h2>
    </div>

    <table class="table">
        <thead>
            <tr>
                <th>Date</th>
                <th>VR No</th>
                <th>Type</th>
                <th>In-Fine</th>
                <th>Out-Fine</th>
                <th>Bal Fine</th>
                <th>In-Amt</th>
                <th>Out-Amt</th>
                <th>Bal-Amt</th>
            </tr>
        </thead>
        <tbody>
            $list
        </tbody>
    </table>

</body>
</html>
""";

    Directory appDocDir = await getApplicationDocumentsDirectory();
    final targetPath = appDocDir.path;
    final generatedPdfFile =
        await _flutterNativeHtmlToPdfPlugin.convertHtmlToPdf(
      html: finalHTML,
      targetDirectory: targetPath,
      targetName: clientName,
    );

    generatedPdfFilePath = generatedPdfFile?.path;

    print("generatedPdfFilePath $generatedPdfFilePath");

    await Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => MaxWidthContainer(
                child: PdfViewScreen(
                  pathStr: generatedPdfFilePath!,
                ),
              )), // Implement HomeScreen
    );

    return 1;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: const Color(0xFFF6F6F6),
      appBar: AppBar(
          // backgroundColor: Colors.white,
          // Replace with your color
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.of(context).pop(),
          ),
          title: null,
          // Set to null to center the image
          backgroundColor: const Color(0xFF4C5564),
          flexibleSpace: Container(
            margin: const EdgeInsets.only(top: 35),
            child: Center(
              child: Text(
                widget.keyName,
                style: const TextStyle(
                    fontSize: 20,
                    color: Colors.white,
                    fontWeight: FontWeight.bold),
              ),
            ),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.picture_as_pdf, color: Colors.white),
              onPressed: () => {

              createCatalogHTML(context, widget.keyName)
              },
            )
          ]),
      body: loader
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header Row
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    color: Colors.blueAccent,
                    child: Row(
                      children: [
                        SizedBox(
                            width: 120,
                            child: headerText("Date", leftAlign: 1)),
                        SizedBox(
                            width: 80, child: headerText("Vrno", leftAlign: 1)),
                        SizedBox(
                            width: 80, child: headerText("Type", leftAlign: 1)),
                        // Divider added here
                        SizedBox(width: 100, child: headerText("In-Fine")),
                        SizedBox(width: 100, child: headerText("Out-Fine")),
                        SizedBox(width: 100, child: headerText("Bal-Fine")),
                        SizedBox(width: 100, child: headerText("In-Amt")),
                        SizedBox(width: 100, child: headerText("Out-Amt")),
                        SizedBox(width: 100, child: headerText("Bal-Amt")),
                      ],
                    ),
                  ),

                  // Data Rows with Vertical Scrolling
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        children: data.map((client) {
                          return Container(
                            decoration: BoxDecoration(
                              border: Border(
                                  bottom:
                                      BorderSide(color: Colors.grey.shade300)),
                            ),
                            child: Row(
                              children: [
                                SizedBox(
                                    width: 120,
                                    child: dataText(
                                        constans
                                            .getDate(client['vrdate'])
                                            .toString(),
                                        leftAlign: 1)),
                                SizedBox(
                                    width: 80,
                                    child:
                                        dataText(client['vrno'], leftAlign: 1)),
                                SizedBox(
                                    width: 80,
                                    child:
                                        dataText(client['fot'], leftAlign: 1)),
                                Container(
                                    width: 1,
                                    height: 60,
                                    color: Colors.grey.shade300),
                                SizedBox(
                                    width: 100,
                                    child: dataText(client['inwt'],
                                        color: Colors.orange)),
                                SizedBox(
                                    width: 100,
                                    child: dataText(client['outwt'],
                                        color: Colors.orange)),
                                SizedBox(
                                    width: 100,
                                    child: dataText(
                                      getBalWt((double.parse(client['inwt']) -
                                              double.parse(client['outwt'])))
                                          .toString(),
                                      color: Colors.orange,
                                    )),
                                Container(
                                    width: 1,
                                    height: 60,
                                    color: Colors.grey.shade300),
                                SizedBox(
                                    width: 100,
                                    child: dataText(client['inamt'],
                                        color: Colors.indigo)),
                                SizedBox(
                                    width: 100,
                                    child: dataText(client['outamt'],
                                        color: Colors.indigo)),
                                SizedBox(
                                    width: 100,
                                    child: dataText(
                                      getBalAmt((double.parse(client['inamt']) -
                                              double.parse(client['outamt'])))
                                          .toString(),
                                      color: Colors.indigo,
                                    )),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

// Helper functions for text widgets
  Widget headerText(String text, {int leftAlign = 2}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Text(text,
          style: headerStyle,
          textAlign: leftAlign == 1 ? TextAlign.left : TextAlign.right),
    );
  }

  Widget dataText(String text, {Color? color, int leftAlign = 2}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 15),
      child: Text(text,
          style: rowStyle.copyWith(color: color ?? Colors.black),
          textAlign: leftAlign == 1 ? TextAlign.left : TextAlign.right),
    );
  }
}
