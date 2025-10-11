import 'dart:convert';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:jewelleryerp/Pages/HomeDashBoard.dart';
import '../Components/SideNavigation.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../Constants/Functions.dart';
import '../Constants/StaticConstant.dart';
import 'MaxWidthContainer.dart';
import 'package:pie_chart/pie_chart.dart';

class FilterScreen extends StatefulWidget {
  @override
  _FilterScreenState createState() => _FilterScreenState();
}

class _FilterScreenState extends State<FilterScreen> {
  bool _isSearchVisible = false;
  final TextEditingController _searchController = TextEditingController();

  bool loader = false;
  String companyId = "";
  List<dynamic> itemList = [];
  List<dynamic> metalList = [];
  List<dynamic> processList = [];
  List<dynamic> clientList = [];
  bool modalVisible = false;
  Constans constans = Constans();

  @override
  void initState() {
    super.initState();
    getUserData();
  }

  Future<void> getUserData() async {
    String? userData = await Constans().getData(StaticConstant.userData);

    fetchLists(jsonDecode(userData!));
  }

  Future<void> fetchLists(Map<String, dynamic> userData) async {
    getMetalList(userData);

    // await Future.wait([
    //   getItemList(userData),
    //   getProcessList(userData),
    // ]);
  }

  Future<void> getMetalList(Map<String, dynamic> userData) async {
    var formData = {
      'username': userData['username'],
      'companyid': userData['companyid'],
      'all_summ': "1",
      'isuser': userData["isAdmin"],
    };

    String response = await constans.callApi(formData, StaticUrl.loginUrl);
    Map<String, dynamic> responseData = json.decode(response);

    print("Home API: $response");

    setState(() {
      itemList = responseData['item']!;
      metalList = responseData['metal']!;
      processList = responseData['process']!;
      if (responseData.containsKey('client')) {
        clientList = responseData['client'];
      }
    });
    // }
  }

  void showLogoutModal() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Jewellery ERP"),
          content: const Text("Are you sure you want to logout?"),
          actions: [
            TextButton(
              onPressed: () {
                SharedPreferences.getInstance().then((prefs) {
                  prefs.clear();
                  Navigator.of(context).pushReplacementNamed('/LoginScreen');
                });
              },
              child: const Text("OK"),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text("Cancel"),
            ),
          ],
        );
      },
    );
  }

  final dataMap = <String, double>{
    "Flutter": 5,
    "React": 3,
    "Xamarin": 2,
    "Ionic": 2,
  };

  final colorList = [
    const Color(0xfffdcb6e),
    const Color(0xff0984e3),
    const Color(0xfffd79a8),
    const Color(0xffe17055),
  ];

  ChartType chartType = ChartType.disc;
  bool showCenterText = true;
  bool showLegends = true;
  bool showChartValues = true;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  void onSubmitSearch(String value) {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => MaxWidthContainer(
                  child: HomeDashBoard(keyName: "search", data: value),
                )));
    // _hasMore = true;
    // _productList.clear();
    // page = 1;
    // callApi(page!);
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
            child: Center(
              child: Image.asset(
                'assets/login_logo.jpeg', // Replace with your image path
                height: 30, // Adjust the height as needed
              ),
            ),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.search, color: Colors.white),
              onPressed: () => {
                setState(() {
                  _isSearchVisible = true;
                })
              },
            )
          ]),
      body: loader
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                children: [
                  Visibility(
                    visible: _isSearchVisible,
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
                                onSubmitted: onSubmitSearch,
                                decoration: const InputDecoration(
                                  hintText: "Search",
                                  border: InputBorder.none,
                                ),
                              ),
                            ),
                            IconButton(
                              icon: Image.asset('assets/cross.png',
                                  // Replace with your image path
                                  height: 30, // Adjust the height as needed
                                  width: 30),
                              onPressed: () {
                                setState(() {
                                  _isSearchVisible = false;
                                  _searchController.text = "";
                                  // page = 1;
                                  // _productList.clear();
                                  // callApi(1);
                                });
                              },
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
                  SizedBox(
                    height: 20,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Work In Progress",
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.black),
                      ),
                    ],
                  ),
                  Card(
                    margin: const EdgeInsets.all(10),
                    child: ListTile(
                      title: const Text(
                        "All Products ",
                        style: TextStyle(
                            fontSize: 18,
                            color: Colors.deepOrange,
                            fontWeight: FontWeight.bold),
                      ),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => MaxWidthContainer(
                                      child:
                                          HomeDashBoard(keyName: "", data: ""),
                                    )));
                      },
                    ),
                  ),
                  if (itemList.isNotEmpty)
                    buildCategoryList("Items", itemList, "item"),
                  if (metalList.isNotEmpty)
                    buildCategoryList("Metals", metalList, "metal"),
                  if (processList.isNotEmpty)
                    buildCategoryList("Process", processList, "process"),
                  if (clientList.isNotEmpty)
                    buildCategoryList("Clients", clientList, "username"),
                ],
              ),
            ),
    );
  }

  Widget buildCategoryList(String title, List<dynamic> list, String key) {
    // Creating a data map for the PieChart
    // final Map<String, double> dataMap = {
    //   for (var item in list)
    //     item[key] as String: (item['nos'] is String
    //         ? double.tryParse(item['nos']) ?? 0.0
    //         : item['nos'] as double),
    // };

    return Card(
      margin: const EdgeInsets.all(10),
      color: Colors.white54,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(10),
            child: Text(
              title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          const Divider(),
          ListView.builder(
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            itemCount: list.length,
            itemBuilder: (context, index) {
              final item = list[index];
              return Column(
                children: [
                  ListTile(
                    title: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "${item[key]} (${item['nos']})",
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.black54,
                            //color: Colors.grey,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          "Wt : ${double.parse(item['weight']).toStringAsFixed(3)} GRM ",
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.black87,
                            //color: Colors.grey,
                            fontWeight: FontWeight.normal,
                          ),
                        )
                      ],
                    ),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () {
                      // print("ListTile onTap triggered");

                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => MaxWidthContainer(
                            child: HomeDashBoard(
                                keyName: key != "username" ? key : "client",
                                data: item[key]),
                          ),
                        ),
                      );
                      // Your logic here if needed
                    },
                  ),
                  if (index != list.length - 1) const Divider(),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}
