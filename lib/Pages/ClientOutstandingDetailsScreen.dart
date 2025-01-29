import 'dart:convert';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:jewelleryerp/Pages/HomeDashBoard.dart';
import '../Components/SideNavigation.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../Constants/Functions.dart';
import '../Constants/StaticConstant.dart';
import 'MaxWidthContainer.dart';
import 'package:pie_chart/pie_chart.dart';

class ClientOutstandingDetailsScreen extends StatefulWidget {
  String keyName = "";

  ClientOutstandingDetailsScreen({required this.keyName});

  @override
  _ClientOutstandingDetailsScreenState createState() =>
      _ClientOutstandingDetailsScreenState();
}

class _ClientOutstandingDetailsScreenState
    extends State<ClientOutstandingDetailsScreen> {
  bool _isSearchVisible = false;
  final TextEditingController _searchController = TextEditingController();

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
          )),
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
                        SizedBox(width: 120, child: headerText("Date")),
                        SizedBox(width: 80, child: headerText("Vrno")),
                        SizedBox(width: 80, child: headerText("Type")), // Divider added here
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
                                    child: dataText(constans
                                        .getDate(client['vrdate'])
                                        .toString())),
                                SizedBox(
                                    width: 80,
                                    child: dataText(client['vrno'])),
                                SizedBox(
                                    width: 80, child: dataText(client['fot'])),
                                Container(width: 1, height: 60,color:Colors.grey.shade300),
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
                                Container(width: 1, height: 60,color:Colors.grey.shade300),
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
  Widget headerText(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Text(text, style: headerStyle,textAlign: TextAlign.right),
    );
  }

  Widget dataText(String text, {Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12,vertical: 15),
      child: Text(text, style: rowStyle.copyWith(color: color ?? Colors.black),textAlign: TextAlign.right,),
    );
  }
}
