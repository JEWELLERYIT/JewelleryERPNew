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

class StoneOutStandingDetails extends StatefulWidget {
  String keyName = "";

  StoneOutStandingDetails({required this.keyName});

  @override
  _StoneOutStandingDetailsState createState() =>
      _StoneOutStandingDetailsState();
}

class _StoneOutStandingDetailsState extends State<StoneOutStandingDetails> {
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
        await constans.callApi(formData, StaticUrl.erp_clientstoneoutstanding);
    Map<String, dynamic> responseData = json.decode(response);

    print("erp_clientstoneoutstanding --- " + response);

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

  TextStyle headerStyle = const TextStyle(
    color: Colors.white,
    fontWeight: FontWeight.bold,
  );

  TextStyle rowStyle = const TextStyle(
    color: Colors.black,
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: const Color(0xFFF6F6F6),
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60), // Adjust the height if needed
        child: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.of(context).pop(),
          ),
          title: Text(
            widget.keyName,
            style: const TextStyle(
              fontSize: 20,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          centerTitle: true,
          backgroundColor: const Color(0xFF4C5564),
          elevation: 0, // Optional: Removes shadow for a cleaner look
        ),
      ),
      body: loader
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              // ✅ Removed Expanded, using only SingleChildScrollView
              child: Column(
                children: [
                  Container(
                    color: Colors.white,
                    child: const Card(
                      margin: EdgeInsets.all(10),
                      elevation: 2,
                      color: Colors.blue,
                      child: Padding(
                        padding: EdgeInsets.all(20),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    "Stone Packet",
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold),
                                    softWrap: true,
                                  ),
                                  SizedBox(height: 20),
                                  Text(
                                    "Bal. Cts",
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold),
                                    softWrap: true,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  if (data.isNotEmpty)
                    Column(
                      children: data.map((client) {
                        return GestureDetector(
                          onTap: () {
                            // Navigator.push(
                            //   context,
                            //   MaterialPageRoute(
                            //     builder: (context) => MaxWidthContainer(
                            //       child: StoneOutStandingDetails(
                            //         keyName: client['clientname'],
                            //       ),
                            //     ),
                            //   ),
                            // );
                          },
                          child: Container(
                            color: Colors.white,
                            child: Card(
                              margin: const EdgeInsets.all(10),
                              elevation: 2,
                              color: Colors.white,
                              child: Padding(
                                padding: const EdgeInsets.all(20),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            client['ssku'],
                                            style: const TextStyle(
                                                fontWeight: FontWeight.bold),
                                            softWrap: true,
                                          ),
                                          const SizedBox(height: 20),
                                          Text(
                                            client['balwt'],
                                            style: const TextStyle(
                                                color: Color(0x908A8A8A)),
                                            softWrap: true,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    )
                  else
                    const SizedBox(
                      height: 500,
                      child: Center(
                        child: Text(
                          "No Data Found",
                          style: TextStyle(fontWeight: FontWeight.bold),
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
