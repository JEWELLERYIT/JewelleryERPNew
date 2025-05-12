import 'package:flutter/cupertino.dart';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:jewelleryerp/Pages/StoneOutStandingDetails.dart';
import '../Components/SideNavigation.dart';
import 'package:flutter/services.dart';
import '../Constants/Functions.dart';
import '../Constants/StaticConstant.dart';
import 'MaxWidthContainer.dart';
import 'OrderHistoryScreen.dart';
import 'OrderScreen.dart';

class OrderUserListScreen extends StatefulWidget {
  const OrderUserListScreen({super.key});

  @override
  _OrderUserListScreenState createState() => _OrderUserListScreenState();
}

class _OrderUserListScreenState extends State<OrderUserListScreen> {
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
    // companyid:1001
    // select:1
    // id:1
    // clouduserid:1001
    var formData = {
      'companyid': userData['companyid'],
      'group': "1",
      'clouduserid': userData['username'],
    };

    String response = await constans.callApi(
        formData, "https://www.digicat.in/webroot/RiteshApi/erp_order.php");

    Map<String, dynamic> responseData = json.decode(response);

    print("Client OutStanding: $formData $responseData");

    setState(() {
      mainList = List<Map<String, dynamic>>.from(responseData['data']);
      data = List<Map<String, dynamic>>.from(responseData['data']);
    });
  }

  Future<void> deleteOrder(String id, Map<String, dynamic> client) async {
    var formData = {
      'id': id,
      'delete': "1",
    };
    print("Client Delete: REquest  $formData");

    String response = await constans.callApi(
        formData, "https://www.digicat.in/webroot/RiteshApi/erp_order.php");

    // Map<String, dynamic> responseData = json.decode(response);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Order Form Delete Successfully")),
    );
    //
    setState(() {
      mainList.removeWhere((element) => element['id'] == id);
      data.removeWhere((element) => element['id'] == id);
    });
  }

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  void onSubmitSearch(String value) {
    setState(() {
      data = mainList.where((client) {
        // Check if clientname contains the pattern (case-insensitive)
        return client['clouduserid']
            .toString()
            .toLowerCase()
            .contains(value.toLowerCase());
      }).toList();
    });
  }

  String formatDate(String? rawDate) {
    if (rawDate == null || rawDate.isEmpty) return '';
    try {
      final parsedDate = DateTime.parse(rawDate);
      return DateFormat('dd MMM yyyy').format(parsedDate);
    } catch (e) {
      return '';
    }
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
              "Orders",
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
                                onTap: () => {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          MaxWidthContainer(
                                        child: Orderhistoryscreen(clouduserid :client['clouduserid'],),
                                      ),
                                    ),
                                  ).then((_) {
                                    getUserData();
                                  }),
                                },
                                child: Card(
                                  margin: const EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 8),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  elevation: 4,
                                  child: Padding(
                                    padding: const EdgeInsets.all(16),
                                    child: Row(
                                      children: [
                                        const Icon(Icons.person,
                                            size: 48, color: Colors.deepPurple),
                                        const SizedBox(width: 16),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                "User ID: ${client['clouduserid']}",
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 16,
                                                  color: Colors.black87,
                                                ),
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                "Total Orders: ${client['counts']}",
                                                style: const TextStyle(
                                                    fontSize: 14,
                                                    color: Colors.black54),
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                "Last Order: ${client['lastorderdate']}",
                                                style: const TextStyle(
                                                    fontSize: 14,
                                                    color: Colors.black54),
                                              ),
                                            ],
                                          ),
                                        ),
                                        const Icon(
                                            Icons.arrow_forward_ios,
                                            size: 20),
                                      ],
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
