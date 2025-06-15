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
import 'OrderScreen.dart';

class Orderhistoryscreen extends StatefulWidget {
  final String clouduserid;

  const Orderhistoryscreen({super.key, required this.clouduserid});

  @override
  _OrderhistoryscreenState createState() => _OrderhistoryscreenState();
}

class _OrderhistoryscreenState extends State<Orderhistoryscreen> {
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
      'select': "1",
      'id': "0",
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
        return client['orderref']
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
              "Order History",
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
                                  print("Click"),
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => MaxWidthContainer(
                                        child: OrderScreen(
                                          data: client,
                                        ),
                                      ),
                                    ),
                                  ).then((_) {
                                    getUserData();
                                  }),
                                },
                                child: Card(
                                  margin: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 8),
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12)),
                                  elevation: 4,
                                  child: Padding(
                                    padding: const EdgeInsets.all(16),
                                    child: Row(
                                      children: [
                                        // IMAGE
                                        Column(
                                          children: [
                                            GestureDetector(
                                              onTap: () {
                                                Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                      builder: (_) => Scaffold(
                                                        appBar: AppBar(),
                                                        body: Center(
                                                          child:
                                                              InteractiveViewer(
                                                            minScale: 1,
                                                            maxScale: 5,
                                                            child:
                                                                Image.network(
                                                              "https://digicat.in/webroot/RiteshApi/${client['image1link']}",
                                                              errorBuilder:
                                                                  (context,
                                                                          error,
                                                                          stackTrace) =>
                                                                      Container(
                                                                color: Colors
                                                                    .grey[300],
                                                                child: const Icon(
                                                                    Icons
                                                                        .image_not_supported,
                                                                    size: 80),
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    ));
                                              },
                                              child: ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                                child: Image.network(
                                                  "https://digicat.in/webroot/RiteshApi/${client['image1link']}",
                                                  height: 80,
                                                  width: 80,
                                                  fit: BoxFit.cover,
                                                  errorBuilder: (context, error,
                                                          stackTrace) =>
                                                      Container(
                                                    color: Colors.grey[300],
                                                    height: 80,
                                                    width: 80,
                                                    child: const Icon(
                                                        Icons
                                                            .image_not_supported,
                                                        size: 40),
                                                  ),
                                                ),
                                              ),
                                            ),
                                            Text(
                                                "${client['clientname'] ?? ''}",
                                                style: const TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.black87)),
                                          ],
                                        ),
                                        const SizedBox(width: 16),
                                        // TEXT INFO
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Text(
                                                    "Date:       ${formatDate(client['thisdate'])}",
                                                    style: const TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: Colors.black87,
                                                    ),
                                                  ),
                                                  IconButton(
                                                    icon: const Icon(
                                                        Icons.delete,
                                                        color: Colors.red),
                                                    onPressed: () {
                                                      showDialog(
                                                        context: context,
                                                        builder: (BuildContext
                                                            context) {
                                                          return AlertDialog(
                                                            title: const Text(
                                                                "Confirm Delete"),
                                                            content: const Text(
                                                                "Are you sure you want to delete this order?"),
                                                            actions: [
                                                              TextButton(
                                                                child: const Text(
                                                                    "Cancel"),
                                                                onPressed: () {
                                                                  Navigator.of(
                                                                          context)
                                                                      .pop(); // Close the dialog
                                                                },
                                                              ),
                                                              TextButton(
                                                                child: const Text(
                                                                    "Delete",
                                                                    style: TextStyle(
                                                                        color: Colors
                                                                            .red)),
                                                                onPressed: () {
                                                                  deleteOrder(
                                                                      client[
                                                                          'id'],
                                                                      client);
                                                                  Navigator.of(
                                                                          context)
                                                                      .pop(); // Close the dialog
                                                                  // ✅ Perform your delete logic here
                                                                },
                                                              ),
                                                            ],
                                                          );
                                                        },
                                                      );
                                                    },
                                                  ),
                                                ],
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                  "Order Ref: ${client['orderref'] ?? ''}",
                                                  style: const TextStyle(
                                                      fontSize: 12)),
                                              Text(
                                                  "Item:         ${client['item'] ?? ''}",
                                                  style: const TextStyle(
                                                      fontSize: 12)),
                                              Text(
                                                  "Ref SKU:   ${client['refsku'] ?? ''}",
                                                  style: const TextStyle(
                                                      fontSize: 12)),
                                              Text(
                                                  "C-Ref:       ${client['cref'] ?? ''}",
                                                  style: const TextStyle(
                                                      fontSize: 12)),
                                              Text(
                                                  "Job no:       ${client['jobno'] ?? ''}",
                                                  style: const TextStyle(
                                                      fontSize: 12)),
                                              Text(
                                                  "Delete Date:       ${client['deldate'] ?? ''}",
                                                  style: const TextStyle(
                                                      fontSize: 12)),
                                              const SizedBox(height: 6),
                                              Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 10,
                                                        vertical: 6),
                                                decoration: BoxDecoration(
                                                  color:
                                                      Colors.deepPurple.shade50,
                                                  borderRadius:
                                                      BorderRadius.circular(20),
                                                ),
                                                child: Text(
                                                  "Metal : ${client['metal'] ?? ''} | Col : ${client['color'] ?? ''}",
                                                  style: const TextStyle(
                                                      fontWeight:
                                                          FontWeight.w500,
                                                      color: Colors.deepPurple),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
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
