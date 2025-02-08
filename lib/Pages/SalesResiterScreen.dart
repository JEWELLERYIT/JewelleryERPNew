import 'dart:convert';
import 'dart:ffi';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import '../Components/SideNavigation.dart';

import '../Constants/Functions.dart';
import '../Constants/StaticConstant.dart';
import 'MaxWidthContainer.dart';
import 'SalesResigterDetailsScreen.dart';

class SalesResiterScreen extends StatefulWidget {
  @override
  _SalesResiterScreenState createState() => _SalesResiterScreenState();
}

class _SalesResiterScreenState extends State<SalesResiterScreen> {
  int selectedSort = 0;
  int selectedSortType = 0;

  final TextEditingController _searchController = TextEditingController();

  bool loader = false;
  Constans constans = Constans();

  @override
  void initState() {
    super.initState();
    getUserData();
  }

  List<Map<String, dynamic>> mainList = [];
  List<Map<String, dynamic>> data = [];
  List<_ChartData> chartData = [];

  double graphWidth = 0.0;

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
    };

    String response = await constans.callApi(formData, StaticUrl.erpSalesUrl);
    Map<String, dynamic> responseData = json.decode(response);

    setState(() {
      mainList = List<Map<String, dynamic>>.from(responseData['data']);
      // data = List<Map<String, dynamic>>.from(responseData['data']);
      data = aggregateData(
          List<Map<String, dynamic>>.from(responseData['data']), "item");
    });

    // // }
  }

  List<Map<String, dynamic>> aggregateData(
      List<Map<String, dynamic>> data, String keyName,
      [bool isPcs = true]) {
    Map<String, Map<String, dynamic>> result = {};
    Map<String, double> itemCounts = {};
    data = List.from(data)
      ..sort((a, b) =>
          a[keyName].toLowerCase().compareTo(b[keyName].toLowerCase()));

    for (var item in data) {
      String itemType = item[keyName];
      int pcs = int.parse(item["pcs"]);
      double grosswt = double.parse(item["grosswt"]);
      double netwt = double.parse(item["netwt"]);
      double saleprice = double.parse(item["saleprice"]);
      double costprice = double.parse(item["costprice"]);
      double diamwt = double.parse(item["diamwt"]);
      double cswt = double.parse(item["cswt"]);

      if (!result.containsKey(itemType)) {
        result[itemType] = {
          "item": itemType,
          "pcs": 0,
          "grosswt": 0.0,
          "netwt": 0.0,
          "saleprice": 0.0,
          "costprice": 0.0,
          "diamwt": 0.0,
          "cswt": 0.0
        };
      }

      result[itemType]!["pcs"] += pcs;
      result[itemType]!["grosswt"] += grosswt;
      result[itemType]!["netwt"] += netwt;
      result[itemType]!["saleprice"] += saleprice;
      result[itemType]!["costprice"] += costprice;
      result[itemType]!["diamwt"] += diamwt;
      result[itemType]!["cswt"] += cswt;

      double pcsint = (itemCounts[itemType] ?? 0.0); // Ensure default value is double
      if (isPcs) {
        itemCounts[itemType] = pcsint + pcs.toDouble(); // Convert pcs to double
      } else {
        itemCounts[itemType] = pcsint + grosswt; // Already a double
      }

    }

    setState(() {
      if (itemCounts.length < 5) {
        graphWidth = 300;
      } else {
        graphWidth = itemCounts.length * 50;
      }

      chartData = itemCounts.entries
          .map((e) => _ChartData(e.key, e.value.toInt())) // Convert double to int if needed
          .toList();
    });

    return result.values.toList();
  }

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  void onSubmitSearch(String value) {
    setState(() {
      data = mainList.where((client) {
        // Check if clientname contains the pattern (case-insensitive)
        return client['clientname']
            .toString()
            .toLowerCase()
            .contains(value.toLowerCase());
      }).toList();
    });
  }

  String selectedItem = "item";
  String selectedValue = "PCS"; // Default selected value

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
          icon: Image.asset(
            color: Colors.white,
            'assets/menu.png', // Replace with your image path
            height: 20, // Adjust the height as needed
          ),
          onPressed: () => _scaffoldKey.currentState?.openDrawer(),
        ),
        title: null,
        // Set to null to center the image
        backgroundColor: const Color(0xFF4C5564),
        flexibleSpace: Container(
          margin: const EdgeInsets.only(top: 35),
          child: const Center(
            child: Text(
              "Sales Analysis",
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
              scrollDirection: Axis.vertical, // Enable vertical scrolling
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SingleChildScrollView(
                    scrollDirection:
                        Axis.horizontal, // Enable horizontal scrolling
                    child: Padding(
                      padding: const EdgeInsets.only(left: 10, right: 10),
                      child: Row(children: [
                        ElevatedButton(
                          onPressed: () {
                            setState(() {
                              selectedItem = "item";
                              data = aggregateData(mainList, "item");
                            });
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: selectedItem == "item"
                                ? Colors.blueAccent
                                : Colors.grey, // Button background color
                          ),
                          child: const Text(
                            "Item Wise",
                            style: TextStyle(
                              fontWeight: FontWeight.bold, // Bold font
                              color: Colors.white, // Text color
                            ),
                          ),
                        ),
                        const SizedBox(
                          width: 20,
                        ),
                        ElevatedButton(
                          onPressed: () {
                            setState(() {
                              selectedItem = "family";
                              data = aggregateData(mainList, "family");
                            });
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: selectedItem == "family"
                                ? Colors.blueAccent
                                : Colors.grey, // Button background color
                            // Button background color
                          ),
                          child: const Text(
                            "Family Wise",
                            style: TextStyle(
                              fontWeight: FontWeight.bold, // Bold font
                              color: Colors.white, // Text color
                            ),
                          ),
                        ),
                        const SizedBox(
                          width: 20,
                        ),
                        ElevatedButton(
                          onPressed: () {
                            setState(() {
                              selectedItem = "category";
                              data = aggregateData(mainList, "category");
                            });
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: selectedItem == "category"
                                ? Colors.blueAccent
                                : Colors.grey, // Button background color
                            // Button background color
                          ),
                          child: const Text(
                            "Category Wise",
                            style: TextStyle(
                              fontWeight: FontWeight.bold, // Bold font
                              color: Colors.white, // Text color
                            ),
                          ),
                        ),
                        const SizedBox(
                          width: 20,
                        ),
                        ElevatedButton(
                          onPressed: () {
                            setState(() {
                              selectedItem = "metal";
                              data = aggregateData(mainList, "metal");
                            });
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: selectedItem == "metal"
                                ? Colors.blueAccent
                                : Colors.grey, // Button background color
                            // Button background color
                          ),
                          child: const Text(
                            "Metal Wise",
                            style: TextStyle(
                              fontWeight: FontWeight.bold, // Bold font
                              color: Colors.white, // Text color
                            ),
                          ),
                        ),
                        const SizedBox(
                          width: 20,
                        ),
                        ElevatedButton(
                          onPressed: () {
                            setState(() {
                              selectedItem = "clientname";
                              data = aggregateData(mainList, "clientname");
                            });
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: selectedItem == "clientname"
                                ? Colors.blueAccent
                                : Colors.grey, // Button background color
                            // Button background color
                          ),
                          child: const Text(
                            "Client Wise",
                            style: TextStyle(
                              fontWeight: FontWeight.bold, // Bold font
                              color: Colors.white, // Text color
                            ),
                          ),
                        )
                      ]),
                    ),
                  ),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: SizedBox(
                      width: graphWidth,
                      height: 300,
                      child: SfCartesianChart(
                        legend: const Legend(isVisible: false),
                        primaryYAxis: const NumericAxis(
                          interval: 50,
                          edgeLabelPlacement: EdgeLabelPlacement.shift,
                          labelIntersectAction:
                              AxisLabelIntersectAction.rotate45,
                          labelStyle: TextStyle(fontSize: 12),
                          minimum: 0,
                          axisLine: AxisLine(width: 0),
                          majorTickLines: MajorTickLines(size: 0),
                          minorTickLines: MinorTickLines(size: 0),
                        ),
                        primaryXAxis: CategoryAxis(
                          labelRotation: 90,
                          majorGridLines: const MajorGridLines(width: 0),
                          edgeLabelPlacement: EdgeLabelPlacement.shift,
                          labelStyle: const TextStyle(
                            fontSize: 12,
                          ),
                          arrangeByIndex: true,
                          interval: 1,
                          axisLabelFormatter: (AxisLabelRenderDetails details) {
                            String truncatedText = details.text.length > 10
                                ? '${details.text.substring(0, 10)}...'
                                : details.text;
                            return ChartAxisLabel(
                                truncatedText, details.textStyle);
                          },
                        ),
                        series: <CartesianSeries<_ChartData, String>>[
                          ColumnSeries<_ChartData, String>(
                            dataSource: chartData,
                            xValueMapper: (_ChartData data, _) => data.item,
                            yValueMapper: (_ChartData data, _) => data.pcs,
                            width: 0.2,
                            dataLabelSettings: const DataLabelSettings(
                              isVisible: true,
                              labelAlignment: ChartDataLabelAlignment.outer,
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Radio(
                        value: "PCS",
                        groupValue: selectedValue,
                        onChanged: (value) {
                          setState(() {
                            selectedValue = value.toString();
                            data = aggregateData(mainList, selectedItem, true);
                          });
                        },
                      ),
                      const Text("PCS"),
                      const SizedBox(width: 20), // Spacing
                      Radio(
                        value: "GrossWt",
                        groupValue: selectedValue,
                        onChanged: (value) {
                          setState(() {
                            selectedValue = value.toString();
                            data = aggregateData(mainList, selectedItem, false);
                          });
                        },
                      ),
                      const Text("GrossWt"),
                    ],
                  ),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          color: Colors.blueAccent,
                          child: Row(
                            children: [
                              SizedBox(
                                  width: 100,
                                  child: headerText("Item Name", leftAlign: 1)),
                              SizedBox(width: 120, child: headerText("PCS")),
                              SizedBox(
                                  width: 120, child: headerText("Gross WT")),
                              SizedBox(width: 120, child: headerText("Net WT")),
                              SizedBox(
                                  width: 120, child: headerText("Sale Price")),
                              SizedBox(
                                  width: 120, child: headerText("Cost Price")),
                              SizedBox(width: 120, child: headerText("Diamwt")),
                              SizedBox(width: 120, child: headerText("Cswt"))
                            ],
                          ),
                        ),
                        SingleChildScrollView(
                          child: Column(
                            children: data.map((client) {
                              return GestureDetector(
                                onTap: () {
                                  List<Map<String, dynamic>> filteredList =
                                      mainList
                                          .where((element) =>
                                              element[selectedItem]
                                                  .toString()
                                                  .contains(client['item']
                                                      .toString()))
                                          .toList();

                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => MaxWidthContainer(
                                        child: SalesResigterDetailsScreen(
                                            mainList: filteredList),
                                      ),
                                    ),
                                  );
                                },
                                child: Container(
                                  decoration: BoxDecoration(
                                    border: Border(
                                      bottom: BorderSide(
                                          color: Colors.grey.shade300),
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      SizedBox(
                                        width: 100,
                                        child: dataText(
                                            client['item'].toString(),
                                            leftAlign: 1),
                                      ),
                                      SizedBox(
                                        width: 120,
                                        child:
                                            dataText(client['pcs'].toString()),
                                      ),
                                      SizedBox(
                                        width: 120,
                                        child: dataText(client['grosswt']
                                            .toStringAsFixed(3)),
                                      ),
                                      SizedBox(
                                        width: 120,
                                        child: dataText(
                                            client['netwt'].toStringAsFixed(3)),
                                      ),
                                      SizedBox(
                                        width: 120,
                                        child: dataText(client['saleprice']
                                            .toStringAsFixed(2)),
                                      ),
                                      SizedBox(
                                        width: 120,
                                        child: dataText(client['costprice']
                                            .toStringAsFixed(2)),
                                      ),
                                      SizedBox(
                                        width: 120,
                                        child: dataText(client['diamwt']
                                            .toStringAsFixed(2)),
                                      ),
                                      SizedBox(
                                        width: 120,
                                        child: dataText(
                                            client['cswt'].toStringAsFixed(2)),
                                      )
                                    ],
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        )
                      ],
                    ),
                  ),
                ],
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

class _ChartData {
  final String item;
  final int pcs;

  _ChartData(this.item, this.pcs);
}
