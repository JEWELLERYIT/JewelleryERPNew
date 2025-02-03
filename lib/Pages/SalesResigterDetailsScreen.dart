import 'dart:convert';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:jewelleryerp/Pages/HomeDashBoard.dart';
import '../Components/SideNavigation.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../Constants/Functions.dart';
import '../Constants/StaticConstant.dart';
import 'ClientOutstandingDetailsScreen.dart';
import 'MaxWidthContainer.dart';
import 'package:pie_chart/pie_chart.dart';

class SalesResigterDetailsScreen extends StatefulWidget {
  final List<Map<String, dynamic>> mainList;

  SalesResigterDetailsScreen({required this.mainList});

  @override
  _SalesResigterDetailsScreenState createState() =>
      _SalesResigterDetailsScreenState();
}

class _SalesResigterDetailsScreenState
    extends State<SalesResigterDetailsScreen> {
  int selectedSort = 0;
  int selectedSortType = 0;

  bool loader = false;
  Constans constans = Constans();

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      drawer: Drawer(
        child: SideNavigation(
          type: 0,
          setState: () {},
        ),
      ),
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
          child: const Center(
            child: Text(
              "Sales Analysis Details",
              style: TextStyle(
                  fontSize: 20,
                  color: Colors.white,
                  fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ),
      body: loader
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      color: Colors.blueAccent,
                      child: Row(
                        children: [
                          SizedBox(width: 200, child: headerText("Client Name",leftAlign: 1)),
                          SizedBox(width: 120, child: headerText("Vr Date",leftAlign: 1)),
                          SizedBox(width: 120, child: headerText("Item Name", leftAlign: 1)),
                          SizedBox(width: 120, child: headerText("Sub Item", leftAlign: 1)),
                          SizedBox(width: 120, child: headerText("PCS")),
                          SizedBox(width: 120, child: headerText("Vr no")),
                          SizedBox(width: 120, child: headerText("Metal")),
                          SizedBox(width: 150, child: headerText("Sku")),
                          SizedBox(width: 120, child: headerText("Family")),
                          SizedBox(width: 120, child: headerText("Category")),
                          SizedBox(width: 120, child: headerText("Sale Price")),
                          SizedBox(width: 120, child: headerText("Cost Price")),
                          SizedBox(width: 120, child: headerText("Gross Wt")),
                          SizedBox(width: 120, child: headerText("Net Wt")),
                          SizedBox(width: 120, child: headerText("Diam Wt")),
                          SizedBox(width: 120, child: headerText("Cswt")),
                        ],
                      ),
                    ),
                    SingleChildScrollView(
                      scrollDirection: Axis.vertical,
                      child: Column(
                        children: widget.mainList.map((client) {
                          return Container(
                            decoration: BoxDecoration(
                              border: Border(
                                bottom: BorderSide(color: Colors.grey.shade300),
                              ),
                            ),
                            child: Row(
                              children: [
                                SizedBox(width: 200, child: dataText(client['clientname'],leftAlign: 1)),
                                SizedBox(width: 120, child: dataText(client['vrdate'],leftAlign: 1)),
                                SizedBox(width: 120, child: dataText(client['item'].toString(),leftAlign: 1)),
                                SizedBox(width: 120, child: dataText(client['subitem'], leftAlign: 1)),
                                SizedBox(width: 120, child: dataText(client['pcs'])),
                                SizedBox(width: 120, child: dataText(client['vrno'])),
                                SizedBox(width: 120, child: dataText(client['metal'])),
                                SizedBox(width: 150, child: dataText(client['sku'])),
                                SizedBox(width: 120, child: dataText(client['family'])),
                                SizedBox(width: 120, child: dataText(client['category'])),
                                SizedBox(width: 120, child: dataText(client['grosswt'])),
                                SizedBox(width: 120, child: dataText(client['netwt'])),
                                SizedBox(width: 120, child: dataText(client['saleprice'])),
                                SizedBox(width: 120, child: dataText(client['costprice'])),
                                SizedBox(width: 120, child: dataText(client['diamwt'])),
                                SizedBox(width: 120, child: dataText(client['cswt'])),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

// Common Text Styles
  TextStyle headerStyle = const TextStyle(
    color: Colors.white,
    fontWeight: FontWeight.bold,
  );

  TextStyle rowStyle = const TextStyle(
    color: Colors.black,
  );

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
