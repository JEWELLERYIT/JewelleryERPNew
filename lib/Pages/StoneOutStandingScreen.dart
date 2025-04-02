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

class StoneOutStandingScreen extends StatefulWidget {
  @override
  _StoneOutStandingScreenState createState() => _StoneOutStandingScreenState();
}

class _StoneOutStandingScreenState extends State<StoneOutStandingScreen> {
  int selectedSort = 0;
  int selectedSortType = 0;

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
      'clients': "1",
    };

    String response =
        await constans.callApi(formData, StaticUrl.erp_clientstoneoutstanding);

    Map<String, dynamic> responseData = json.decode(response);

    print("Client OutStanding: $formData $response");

    setState(() {
      mainList = List<Map<String, dynamic>>.from(responseData['data']);
      data = List<Map<String, dynamic>>.from(responseData['data']);
    });
  }

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  void onSubmitSearch(String value) {
    setState(() {
      data = mainList.where((client) {
        // Check if clientname contains the pattern (case-insensitive)
        return client['clientnameaa']
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
              "Stone Outstanding",
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
          : Column(
              children: [
                Card(
                  margin: const EdgeInsets.all(10),
                  elevation: 2,
                  color: Colors.white,
                  // Set your desired background color here
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Row(
                      children: [
                        const Icon(Icons.search, color: Colors.grey),
                        const SizedBox(
                          width: 10,
                        ),
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
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        // Data Rows
                        if (data.isNotEmpty)
                          Column(
                            children: data.map((client) {
                              return GestureDetector(
                                onTap: () {
                                  // print(
                                  //     "client['clientname'] ${client['clientname']}");
                                  //
                                  // // onRowTap(client); // Handle row tap
                                  // Navigator.push(
                                  //   context,
                                  //   MaterialPageRoute(
                                  //     builder: (context) => MaxWidthContainer(
                                  //       child: ClientOutstandingDetailsScreen(
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
                                      // Set your desired background color here
                                      child: Padding(
                                        padding: const EdgeInsets.all(20),
                                        child: Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    client['clientname'],
                                                    style: const TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold),
                                                    softWrap: true,
                                                  ),
                                                  const SizedBox(height: 20),
                                                  Text(
                                                    client['clouduserid'],
                                                    style: const TextStyle(
                                                        color:
                                                            Color(0x908A8A8A)),
                                                    softWrap: true,
                                                  ),
                                                ],
                                              ),
                                            ),
                                            Text(
                                              "Wight\n${double.parse(client['balwt']).toStringAsFixed(3)} Cts",
                                              textAlign: TextAlign.center,
                                              // Center the text inside the widget
                                              style: const TextStyle(
                                                  color: Color(0xFF9E8A58),
                                                  fontWeight: FontWeight.bold),
                                            ),
                                          ],
                                        ),
                                      ),
                                    )),
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
                              ))),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}
