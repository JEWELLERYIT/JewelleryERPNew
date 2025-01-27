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

class ClientOutstandingScreen extends StatefulWidget {
  @override
  _ClientOutstandingScreenState createState() =>
      _ClientOutstandingScreenState();
}

class _ClientOutstandingScreenState extends State<ClientOutstandingScreen> {
  final TextEditingController _searchController = TextEditingController();

  bool loader = false;
  Constans constans = Constans();

  @override
  void initState() {
    super.initState();
    getUserData();

    // Add listener to the search controller
    _searchController.addListener(() {
      onSubmitSearch(_searchController.text);
    });
  }

  List<Map<String, dynamic>> mainList = [];
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
      'group': "1",
    };

    String response =
        await constans.callApi(formData, StaticUrl.erpClientoutstandingUrl);
    Map<String, dynamic> responseData = json.decode(response);

    print("Client OutStanding: $formData $response");

    setState(() {
      data = List<Map<String, dynamic>>.from(responseData['data']);
      mainList = List<Map<String, dynamic>>.from(responseData['data']);
    });
    // }
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
          ),

      ),
      body: loader
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                children: [
                  Visibility(
                    visible: true,
                    child: Card(
                      margin: const EdgeInsets.all(10),
                      elevation: 2,
                      color: Colors.white,
                      // Set your desired background color here
                      child: Padding(
                        padding: const EdgeInsets.all(0),
                        child: Row(
                          children: [
                            Icon(Icons.search, color: Colors.white),
                            Expanded(
                              child: TextField(
                                controller: _searchController,
                                decoration: const InputDecoration(
                                  hintText: "Search",
                                  border: InputBorder.none,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Container(
                    color: Colors.white, // Set the color of the line
                    height: 1.0, // Set the height (thickness) of the line
                    width: double
                        .infinity, // Make the line span the full width of its container
                  ),
                  Container(
                    color: Colors.blueAccent,
                    child: const Row(
                      children: [
                        Expanded(
                          child: Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Text(
                              'Client Name',
                              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                        Expanded(
                          child: Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Text(
                              'Fine Balance',
                              textAlign: TextAlign.right,
                              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                        Expanded(
                          child: Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Text(
                              'Amt Balance',
                              textAlign: TextAlign.right,
                              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Data Rows
                  Column(
                    children: data.map((client) {
                      return GestureDetector(
                        onTap: () {

                          print("client['clientname'] ${client['clientname']}");

                          // onRowTap(client); // Handle row tap
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => MaxWidthContainer(
                                child: ClientOutstandingDetailsScreen(keyName: client['clientname'],),
                              ),
                            ),
                          );
                        },
                        child: Container(
                          color: Colors.white,
                          child: Column(
                            children: [
                              Row(

                                children: [
                                  Expanded(
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Text(
                                        client['clientname'],
                                        maxLines: 3,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Text(client['balwt'],textAlign: TextAlign.right,
                                        style: TextStyle(
                                          //  fontWeight: FontWeight.bold,
                                          color: double.parse(client['balwt']) > 0 ? Colors.green : Colors.red,

                                        ),
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Text(client['balamt'],textAlign: TextAlign.right,
                                        style: TextStyle(
                                      //  fontWeight: FontWeight.bold,
                                          color: double.parse(client['balamt']) > 0 ? Colors.green : Colors.red,

                                        ),

                                        ),

                                    ),
                                  ),
                                ],
                              ),
                              const Divider(
                                height: 1, // Space around the divider
                                thickness: 1, // Thickness of the line
                                color: Colors.grey, // Color of the divider
                              )
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
    );
  }
}
