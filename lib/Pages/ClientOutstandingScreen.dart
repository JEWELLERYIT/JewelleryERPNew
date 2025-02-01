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
      'group': "1",
    };

    String response =
        await constans.callApi(formData, StaticUrl.erpClientoutstandingUrl);
    Map<String, dynamic> responseData = json.decode(response);

    print("Client OutStanding: $formData $response");

    setState(() {
      mainList = List<Map<String, dynamic>>.from(responseData['data']);
      data = List<Map<String, dynamic>>.from(responseData['data']);

      // data = List.from(mainList)..sort((a, b) => a["clientname"].toLowerCase().compareTo(b["clientname"].toLowerCase()));

      // data = List.from(data)..sort((a, b) => b["clientname"].toLowerCase().compareTo(a["clientname"].toLowerCase()));
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
                Container(
                  color: Colors.blueAccent,
                  padding: const EdgeInsets.symmetric(horizontal: 2.0),
                  // Added padding
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        flex: 1,
                        child: Row(
                          children: [
                            const Text(
                              'Client Name',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            GestureDetector(
                              onTap: () {
                                if (selectedSort == 0) {
                                  setState(() {
                                    selectedSortType =
                                    selectedSortType == 0 ? 1 : 0;
                                  });
                                } else {
                                  setState(() {
                                    selectedSort = 0;
                                    selectedSortType = 0;
                                  });
                                }

                                setState(() {
                                  if (selectedSortType == 0) {
                                    data = List.from(mainList)
                                      ..sort((a, b) => a["clientname"]
                                          .toLowerCase()
                                          .compareTo(b["clientname"]
                                          .toLowerCase()));
                                  } else {
                                    data = List.from(data)
                                      ..sort((a, b) => b["clientname"]
                                          .toLowerCase()
                                          .compareTo(a["clientname"]
                                          .toLowerCase()));
                                  }
                                });
                              },
                              child: Padding(
                                padding: const EdgeInsets.all(2.0),
                                child: Image.asset(
                                  selectedSort == 0
                                      ? selectedSortType == 0
                                      ? 'assets/ic_up.png'
                                      : 'assets/ic_down.png'
                                      : 'assets/ic_up_down.png',
                                  height: 12,
                                  width: 12,
                                  color: Colors.white,
                                  colorBlendMode: BlendMode.srcIn,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        color: Colors.blueAccent,
                        child: Expanded(
                          flex: 1,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              const Text(
                                'Fine Balance',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              GestureDetector(
                                onTap: () {
                                  if (selectedSort == 1) {
                                    setState(() {
                                      selectedSortType =
                                      selectedSortType == 0 ? 1 : 0;
                                    });
                                  } else {
                                    setState(() {
                                      selectedSort = 1;
                                      selectedSortType = 0;
                                    });
                                  }

                                  setState(() {
                                    if (selectedSortType == 0) {
                                      data = List.from(data)
                                        ..sort((a, b) =>
                                            double.parse(a["balwt"])
                                                .compareTo(double.parse(
                                                b["balwt"])));
                                    } else {
                                      data = List.from(data)
                                        ..sort((a, b) =>
                                            double.parse(b["balwt"])
                                                .compareTo(double.parse(
                                                a["balwt"])));
                                    }
                                  });
                                },
                                child: Padding(
                                  padding: const EdgeInsets.all(2.0),
                                  child: Image.asset(
                                    selectedSort == 1
                                        ? selectedSortType == 0
                                        ? 'assets/ic_up.png'
                                        : 'assets/ic_down.png'
                                        : 'assets/ic_up_down.png',
                                    height: 12,
                                    width: 12,
                                    color: Colors.white,
                                    colorBlendMode: BlendMode.srcIn,
                                  ),
                                ),
                              )
                            ],
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 1,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            const Text(
                              'Amt Balance',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            GestureDetector(
                              onTap: () {
                                if (selectedSort == 2) {
                                  setState(() {
                                    selectedSortType =
                                    selectedSortType == 0 ? 1 : 0;
                                  });
                                } else {
                                  setState(() {
                                    selectedSort = 2;
                                    selectedSortType = 0;
                                  });
                                }

                                setState(() {
                                  if (selectedSortType == 0) {
                                    data = List.from(data)
                                      ..sort((a, b) =>
                                          double.parse(a["balamt"])
                                              .compareTo(double.parse(
                                              b["balamt"])));
                                  } else {
                                    data = List.from(data)
                                      ..sort((a, b) =>
                                          double.parse(b["balamt"])
                                              .compareTo(double.parse(
                                              a["balamt"])));
                                  }
                                });
                              },
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 2,vertical: 10),
                                child: Image.asset(
                                  selectedSort == 2
                                      ? selectedSortType == 0
                                      ? 'assets/ic_up.png'
                                      : 'assets/ic_down.png'
                                      : 'assets/ic_up_down.png',
                                  height: 12,
                                  width: 12,
                                  color: Colors.white,
                                  colorBlendMode: BlendMode.srcIn,
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                    ],
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
                                  print(
                                      "client['clientname'] ${client['clientname']}");

                                  // onRowTap(client); // Handle row tap
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => MaxWidthContainer(
                                        child: ClientOutstandingDetailsScreen(
                                          keyName: client['clientname'],
                                        ),
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
                                              padding:
                                                  const EdgeInsets.all(8.0),
                                              child: Text(
                                                client['clientname'],
                                                maxLines: 3,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                          ),
                                          Expanded(
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.all(8.0),
                                              child: Text(
                                                client['balwt'],
                                                textAlign: TextAlign.right,
                                                style: TextStyle(
                                                  //  fontWeight: FontWeight.bold,
                                                  color: double.parse(
                                                              client['balwt']) >
                                                          0
                                                      ? Colors.green
                                                      : Colors.red,
                                                ),
                                              ),
                                            ),
                                          ),
                                          Expanded(
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.all(8.0),
                                              child: Text(
                                                client['balamt'],
                                                textAlign: TextAlign.right,
                                                style: TextStyle(
                                                  //  fontWeight: FontWeight.bold,
                                                  color: double.parse(client[
                                                              'balamt']) >
                                                          0
                                                      ? Colors.green
                                                      : Colors.red,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const Divider(
                                        height: 1, // Space around the divider
                                        thickness: 1, // Thickness of the line
                                        color:
                                            Colors.grey, // Color of the divider
                                      )
                                    ],
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
