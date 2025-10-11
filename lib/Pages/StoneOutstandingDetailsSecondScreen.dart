import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/services.dart';
import '../Constants/Functions.dart';
import '../Constants/StaticConstant.dart';
import 'MaxWidthContainer.dart';
import 'package:flutter_native_html_to_pdf/flutter_native_html_to_pdf.dart';
import 'PDFScreen.dart';

class StoneOutstandingDetailsSecondScreen extends StatefulWidget {
  String keyName = "";
  String ssku = "";

  StoneOutstandingDetailsSecondScreen(
      {required this.keyName, required this.ssku});

  @override
  _StoneOutstandingDetailsSecondScreenState createState() =>
      _StoneOutstandingDetailsSecondScreenState();
}

class _StoneOutstandingDetailsSecondScreenState
    extends State<StoneOutstandingDetailsSecondScreen> {
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
      'detail': "1",
      'clientname': widget.keyName,
      'ssku': widget.ssku,
    };

    String response =
        await constans.callApi(formData, StaticUrl.erp_clientstoneoutstanding);
    Map<String, dynamic> responseData = json.decode(response);

    print("responseData['data'] --: $formData $response");

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

  Future<void> createCatalogHTML(
      BuildContext context, String clientName) async {
    balWt = 0;
    balAmt = 0;
    String currentDate = DateFormat('dd-MM-yyyy').format(DateTime.now());

    String list = "";
    for (var item in data) {
      final inwt = double.tryParse(item['inwt'].toString()) ?? 0;
      final outwt = double.tryParse(item['outwt'].toString()) ?? 0;
      final inamt = double.tryParse(item['inamt'].toString()) ?? 0;
      final outamt = double.tryParse(item['outamt'].toString()) ?? 0;

      list += """<tr>
          <td>${constans.getDate(item['date'])}</td>
          <td>${item['vrno']}</td>
          <td>${item['vrtype']}</td>
          <td>${inwt.toStringAsFixed(3)}</td>
          <td>${outwt.toStringAsFixed(3)}</td>
          <td>${getBalWt(inwt - outwt)}</td>
          <td>${inamt.toStringAsFixed(2)}</td>
          <td>${outamt.toStringAsFixed(2)}</td>
          <td>${getBalAmt(inamt - outamt)}</td>
      </tr>""";
    }

    String finalHTML = """
<!DOCTYPE html>
<html>
<head>
  <meta charset="UTF-8">
  <style>
    body { font-family: Arial, sans-serif; }
    .header { display: flex; justify-content: space-between; margin-bottom: 10px; }
    table { width: 100%; border-collapse: collapse; }
    th, td { border: 1px solid #444; padding: 6px; font-size: 12px; text-align: center; }
    th { background: #f0f0f0; }
  </style>
</head>
<body>
  <div class="header">
    <h3>$clientName</h3>
    <h3>Date: $currentDate</h3>
  </div>
  <table>
    <thead>
      <tr>
        <th>Date</th>
        <th>VR No</th>
        <th>Type</th>
        <th>In-Fine</th>
        <th>Out-Fine</th>
        <th>Bal-Fine</th>
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

    final generatedPdfFilePath = generatedPdfFile?.path;

    if (generatedPdfFilePath != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => MaxWidthContainer(
            child: PdfViewScreen(pathStr: generatedPdfFilePath),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: const Color(0xFFF6F6F6),
      // appBar: AppBar(
      //     ,
      //     actions: [
      //       IconButton(
      //         icon: const Icon(Icons.picture_as_pdf, color: Colors.white),
      //         onPressed: () => {
      //
      //         createCatalogHTML(context, widget.keyName)
      //         },
      //       )
      //     ]),
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60), // Adjust the height if needed
        child: AppBar(
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.of(context).pop(),
            ),
            title: Text(
              widget.ssku,
              style: const TextStyle(
                fontSize: 20,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            centerTitle: true,
            backgroundColor: const Color(0xFF4C5564),
            elevation: 0,
            // Optional: Removes shadow for a cleaner look

            actions: [
              IconButton(
                icon: const Icon(Icons.picture_as_pdf, color: Colors.white),
                onPressed: () => {createCatalogHTML(context, widget.keyName)},
              )
            ]),
      ),
      body: loader
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade400),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header Row
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      color: Colors.blueAccent,
                      child: Row(
                        children: [
                          _buildHeaderCell("Date", 120),
                          _buildHeaderCell("Vrno", 80),
                          _buildHeaderCell("Type", 80),
                          _buildHeaderCell("In-Fine", 100),
                          _buildHeaderCell("Out-Fine", 100),
                          _buildHeaderCell("Bal-Fine", 100),
                        ],
                      ),
                    ),

                    // Data Rows with vertical scrolling
                    SizedBox(
                      height: MediaQuery.of(context).size.height -
                          150, // adjust based on AppBar and header
                      child: SingleChildScrollView(
                        child: Column(
                          children: data.map((client) {
                            return Container(
                              decoration: BoxDecoration(
                                border: Border(
                                  bottom:
                                      BorderSide(color: Colors.grey.shade300),
                                ),
                              ),
                              child: Row(
                                children: [
                                  _buildDataCell(
                                      constans
                                          .getDate(client['date'])
                                          .toString(),
                                      120),
                                  _buildDataCell(client['vrno'], 80),
                                  _buildDataCell(client['vrtype'], 80),
                                  _buildDataCell(client['inwt'], 100,
                                      color: Colors.orange),
                                  _buildDataCell(client['outwt'], 100,
                                      color: Colors.orange),
                                  _buildDataCell(
                                      getBalWt(double.parse(client['inwt']) -
                                              double.parse(client['outwt']))
                                          .toString(),
                                      100,
                                      color: Colors.orange),
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
            ),
    );
  }

  Widget _buildHeaderCell(String text, double width) {
    return Container(
      width: width,
      decoration: BoxDecoration(
        border: Border(
          right: BorderSide(color: Colors.grey.shade400),
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Text(
        text,
        style: headerStyle,
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildDataCell(String text, double width, {Color? color}) {
    return Container(
      width: width,
      decoration: BoxDecoration(
        border: Border(
          right: BorderSide(color: Colors.grey.shade300),
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 15),
      child: Text(
        text,
        style: rowStyle.copyWith(color: color ?? Colors.black),
        textAlign: TextAlign.center,
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
