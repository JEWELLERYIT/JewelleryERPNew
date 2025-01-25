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

  bool loader = false;
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

    print("Details Res---- $responseData ");

    setState(() {
      data = List<Map<String, dynamic>>.from(responseData['data']);
    });
    // }
  }

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  double balWt = 0;
  double balAmt = 0;

  double getBalWt(double differet) {
    balWt = balWt + differet;
    return double.parse(NumberFormat('0.000').format(balWt));
  }

  double getBalAmt(double differet) {
    balAmt = balAmt + differet;

    return double.parse(NumberFormat('0.000').format(balAmt));
  }

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
                "Client Metal Outstanding",
                style: TextStyle(
                    fontSize: 20,
                    color: Colors.white,
                    fontWeight: FontWeight.bold),
              ),
            ),
          )),
      body: loader
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                children: [
                  Container(
                    color: Colors.white, // Set the color of the line
                    height: 1.0, // Set the height (thickness) of the line
                    width: double
                        .infinity, // Make the line span the full width of its container
                  ),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: DataTable(
                      columns: const [
                        DataColumn(label: Text('Date')),
                        DataColumn(label: Text("Vrno")),
                        DataColumn(label: Text('Type')),
                        DataColumn(label: Text('inwt')),
                        DataColumn(label: Text('outwt')),
                        DataColumn(label: Text('Bal wt')),
                        DataColumn(label: Text('In Amt')),
                        DataColumn(label: Text('Out Amt')),
                        DataColumn(label: Text('Bal Amt')),
                      ],
                      rows: data.map((client) {
                        return DataRow(cells: [
                          DataCell(Text(client['vrdate'])),
                          DataCell(Text(client['vrno'])),
                          DataCell(Text(client['fot'])),
                          DataCell(Text(client['inwt'])),
                          DataCell(Text(client['outwt'])),
                          DataCell(Text(getBalWt((double.parse(client['inwt']) -
                                  double.parse(client['outwt'])))
                              .toString())),
                          // DataCell(Text(
                          //     getBalWt(())
                          //         .toString())),
                          DataCell(Text(client['inamt'])),
                          DataCell(Text(client['outamt'])),
                          DataCell(Text(getBalAmt(
                                  (double.parse(client['inamt']) -
                                      double.parse(client['outamt'])))
                              .toString())),
                        ]);
                      }).toList(),
                    ),
                  )
                ],
              ),
            ),
    );
  }
}
