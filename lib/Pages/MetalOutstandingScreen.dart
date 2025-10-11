// import 'dart:convert';
// import 'dart:math' as math;

// import 'package:flutter/material.dart';
// import 'package:jewelleryerp/Pages/HomeDashBoard.dart';
// import '../Components/SideNavigation.dart';
// import 'package:flutter/services.dart';
// import 'package:shared_preferences/shared_preferences.dart';

// import '../Constants/Functions.dart';
// import '../Constants/StaticConstant.dart';
// import 'MetalOutstandingDetailsScreen.dart';
// import 'MaxWidthContainer.dart';
// import 'package:pie_chart/pie_chart.dart';

// class MetalOutstandingScreen extends StatefulWidget {
//   @override
//   _MetalOutstandingScreenState createState() => _MetalOutstandingScreenState();
// }

// class _MetalOutstandingScreenState extends State<MetalOutstandingScreen> {
//   int selectedSort = 0;
//   int selectedSortType = 0;

//   final TextEditingController _searchController = TextEditingController();

//   bool loader = false;
//   Constans constans = Constans();

//   @override
//   void initState() {
//     super.initState();
//     getUserData();

//     // Add listener to the search controller
//     _searchController.addListener(() {
//       onSubmitSearch(_searchController.text);
//     });
//   }

//   List<Map<String, dynamic>> mainList = [];
//   List<Map<String, dynamic>> data = [];

//   Future<void> getUserData() async {
//     String? userData = await Constans().getData(StaticConstant.userData);

//     fetchLists(jsonDecode(userData!));
//   }

//   Future<void> fetchLists(Map<String, dynamic> userData) async {
//     getMetalList(userData);
//   }

//   Future<void> getMetalList(Map<String, dynamic> userData) async {
//     var formData = {
//       'companyid': userData['companyid'],
//       'group': "1",
//     };

//     print("userData --------- ${userData}");

//     if (userData['isAdmin'] == "0") {
//       // formData[""] = "";
//       formData["clouduserid"] = userData['username'];
//     }

//     String response =
//         await constans.callApi(formData, StaticUrl.erpClientoutstandingUrl);
//     Map<String, dynamic> responseData = json.decode(response);

//     print("Client OutStanding: $formData $response");

//     setState(() {
//       mainList = List<Map<String, dynamic>>.from(responseData['data']);
//       data = List<Map<String, dynamic>>.from(responseData['data']);

//       // data = List.from(mainList)..sort((a, b) => a["clientname"].toLowerCase().compareTo(b["clientname"].toLowerCase()));

//       // data = List.from(data)..sort((a, b) => b["clientname"].toLowerCase().compareTo(a["clientname"].toLowerCase()));
//     });
//     // }
//   }

//   final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

//   void onSubmitSearch(String value) {
//     setState(() {
//       data = mainList.where((client) {
//         // Check if clientname contains the pattern (case-insensitive)
//         return client['clientname']
//             .toString()
//             .toLowerCase()
//             .contains(value.toLowerCase());
//       }).toList();
//     });
//   }

//   void _sortData(int columnIndex) {
//     setState(() {
//       if (selectedSort == columnIndex) {
//         selectedSortType = selectedSortType == 0 ? 1 : 0;
//       } else {
//         selectedSort = columnIndex;
//         selectedSortType = 0;
//       }

//       data = List.from(data)
//         ..sort((a, b) {
//           var valueA, valueB;
//           if (columnIndex == 0) {
//             valueA = a["clientname"].toLowerCase();
//             valueB = b["clientname"].toLowerCase();
//           } else {
//             valueA = double.parse(a[columnIndex == 1 ? "balwt" : "balamt"]);
//             valueB = double.parse(b[columnIndex == 1 ? "balwt" : "balamt"]);
//           }
//           return selectedSortType == 0
//               ? valueA.compareTo(valueB)
//               : valueB.compareTo(valueA);
//         });
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       key: _scaffoldKey,
//       drawer: Drawer(
//         child: SideNavigation(
//           type: 0,
//           setState: () {},
//         ),
//       ),
//       backgroundColor: const Color(0xFFF6F6F6),
//       appBar: AppBar(
//         // backgroundColor: Colors.white,
//         // Replace with your color
//         leading: IconButton(
//           icon: Image.asset(
//             color: Colors.white,
//             'assets/menu.png', // Replace with your image path
//             height: 20, // Adjust the height as needed
//           ),
//           onPressed: () => _scaffoldKey.currentState?.openDrawer(),
//         ),
//         title: null,
//         // Set to null to center the image
//         backgroundColor: const Color(0xFF4C5564),
//         flexibleSpace: Container(
//           margin: const EdgeInsets.only(top: 35),
//           child: const Center(
//             child: Text(
//               "Metal Outstanding",
//               style: TextStyle(
//                   fontSize: 20,
//                   color: Colors.white,
//                   fontWeight: FontWeight.bold),
//             ),
//           ),
//         ),
//       ),
//       body: loader
//           ? const Center(child: CircularProgressIndicator())
//           : Column(
//               children: [
//                 Card(
//                   margin: const EdgeInsets.all(10),
//                   elevation: 2,
//                   color: Colors.white,
//                   // Set your desired background color here
//                   child: Padding(
//                     padding: const EdgeInsets.symmetric(horizontal: 10),
//                     child: Row(
//                       children: [
//                         const Icon(Icons.search, color: Colors.grey),
//                         const SizedBox(
//                           width: 10,
//                         ),
//                         Expanded(
//                           child: TextField(
//                             controller: _searchController,
//                             decoration: const InputDecoration(
//                               hintText: "Search",
//                               border: InputBorder.none,
//                             ),
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//                 Container(
//                   color: Colors.blueAccent,
//                   padding:
//                       const EdgeInsets.symmetric(horizontal: 2.0, vertical: 10),
//                   // Added padding
//                   child: Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                     children: [
//                       Expanded(
//                         flex: 1,
//                         child: Row(
//                           children: [
//                             const Text(
//                               'Client Name',
//                               style: TextStyle(
//                                   color: Colors.white,
//                                   fontWeight: FontWeight.bold),
//                             ),
//                             const SizedBox(width: 2),
//                             GestureDetector(
//                               onTap: () => _sortData(0),
//                               child: Image.asset(
//                                 selectedSort == 0
//                                     ? selectedSortType == 0
//                                         ? 'assets/ic_up.png'
//                                         : 'assets/ic_down.png'
//                                     : 'assets/ic_up_down.png',
//                                 height: 12,
//                                 width: 12,
//                                 color: Colors.white,
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                       Expanded(
//                         flex: 1,
//                         child: Row(
//                           mainAxisAlignment: MainAxisAlignment.end,
//                           children: [
//                             const Text(
//                               'Fine Balance',
//                               style: TextStyle(
//                                   color: Colors.white,
//                                   fontWeight: FontWeight.bold),
//                             ),
//                             const SizedBox(width: 2),
//                             GestureDetector(
//                               onTap: () => _sortData(1),
//                               child: Image.asset(
//                                 selectedSort == 1
//                                     ? selectedSortType == 0
//                                         ? 'assets/ic_up.png'
//                                         : 'assets/ic_down.png'
//                                     : 'assets/ic_up_down.png',
//                                 height: 12,
//                                 width: 12,
//                                 color: Colors.white,
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                       Expanded(
//                         flex: 1,
//                         child: Row(
//                           mainAxisAlignment: MainAxisAlignment.end,
//                           children: [
//                             const Text(
//                               'Amt Balance',
//                               style: TextStyle(
//                                   color: Colors.white,
//                                   fontWeight: FontWeight.bold),
//                             ),
//                             const SizedBox(width: 2),
//                             GestureDetector(
//                               onTap: () => _sortData(2),
//                               child: Image.asset(
//                                 selectedSort == 2
//                                     ? selectedSortType == 0
//                                         ? 'assets/ic_up.png'
//                                         : 'assets/ic_down.png'
//                                     : 'assets/ic_up_down.png',
//                                 height: 12,
//                                 width: 12,
//                                 color: Colors.white,
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                     ],
//                   ),
//                   // child: Row(
//                   //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   //   children: [
//                   //     Expanded(
//                   //       flex: 1,
//                   //       child: Row(
//                   //         children: [
//                   //           const Text(
//                   //             'Client Name',
//                   //             style: TextStyle(
//                   //               color: Colors.white,
//                   //               fontWeight: FontWeight.bold,
//                   //             ),
//                   //           ),
//                   //       GestureDetector(
//                   //         onTap: () => _sortData(0), // For Client Name
//                   //         child: Image.asset(
//                   //           selectedSort == 0
//                   //               ? selectedSortType == 0 ? 'assets/ic_up.png' : 'assets/ic_down.png'
//                   //               : 'assets/ic_up_down.png',
//                   //           height: 12,
//                   //           width: 12,
//                   //           color: Colors.white,
//                   //         ),
//                   //       ),
//                   //
//                   //       // GestureDetector(
//                   //           //   onTap: () {
//                   //           //     if (selectedSort == 0) {
//                   //           //       setState(() {
//                   //           //         selectedSortType =
//                   //           //         selectedSortType == 0 ? 1 : 0;
//                   //           //       });
//                   //           //     } else {
//                   //           //       setState(() {
//                   //           //         selectedSort = 0;
//                   //           //         selectedSortType = 0;
//                   //           //       });
//                   //           //     }
//                   //           //
//                   //           //     setState(() {
//                   //           //       if (selectedSortType == 0) {
//                   //           //         data = List.from(mainList)
//                   //           //           ..sort((a, b) => a["clientname"]
//                   //           //               .toLowerCase()
//                   //           //               .compareTo(b["clientname"]
//                   //           //               .toLowerCase()));
//                   //           //       } else {
//                   //           //         data = List.from(data)
//                   //           //           ..sort((a, b) => b["clientname"]
//                   //           //               .toLowerCase()
//                   //           //               .compareTo(a["clientname"]
//                   //           //               .toLowerCase()));
//                   //           //       }
//                   //           //     });
//                   //           //   },
//                   //           //   child: Padding(
//                   //           //     padding: const EdgeInsets.all(2.0),
//                   //           //     child: Image.asset(
//                   //           //       selectedSort == 0
//                   //           //           ? selectedSortType == 0
//                   //           //           ? 'assets/ic_up.png'
//                   //           //           : 'assets/ic_down.png'
//                   //           //           : 'assets/ic_up_down.png',
//                   //           //       height: 12,
//                   //           //       width: 12,
//                   //           //       color: Colors.white,
//                   //           //       colorBlendMode: BlendMode.srcIn,
//                   //           //     ),
//                   //           //   ),
//                   //           // ),
//                   //         ],
//                   //       ),
//                   //     ),
//                   //     Container(
//                   //       color: Colors.blueAccent,
//                   //       child: Expanded(
//                   //         flex: 1,
//                   //         child: Row(
//                   //           mainAxisAlignment: MainAxisAlignment.end,
//                   //           children: [
//                   //             const Text(
//                   //               'Fine Balance',
//                   //               style: TextStyle(
//                   //                 color: Colors.white,
//                   //                 fontWeight: FontWeight.bold,
//                   //               ),
//                   //             ),
//                   //             GestureDetector(
//                   //               onTap: () => _sortData(1), // 1 for Fine Balance
//                   //               child: Padding(
//                   //                 padding: const EdgeInsets.all(2.0),
//                   //                 child: Image.asset(
//                   //                   selectedSort == 1
//                   //                       ? selectedSortType == 0 ? 'assets/ic_up.png' : 'assets/ic_down.png'
//                   //                       : 'assets/ic_up_down.png',
//                   //                   height: 12,
//                   //                   width: 12,
//                   //                   color: Colors.white,
//                   //                 ),
//                   //               ),
//                   //             ),
//                   //
//                   //             // GestureDetector(
//                   //             //   onTap: () {
//                   //             //     if (selectedSort == 1) {
//                   //             //       setState(() {
//                   //             //         selectedSortType =
//                   //             //         selectedSortType == 0 ? 1 : 0;
//                   //             //       });
//                   //             //     } else {
//                   //             //       setState(() {
//                   //             //         selectedSort = 1;
//                   //             //         selectedSortType = 0;
//                   //             //       });
//                   //             //     }
//                   //             //
//                   //             //     setState(() {
//                   //             //       if (selectedSortType == 0) {
//                   //             //         data = List.from(data)
//                   //             //           ..sort((a, b) =>
//                   //             //               double.parse(a["balwt"])
//                   //             //                   .compareTo(double.parse(
//                   //             //                   b["balwt"])));
//                   //             //       } else {
//                   //             //         data = List.from(data)
//                   //             //           ..sort((a, b) =>
//                   //             //               double.parse(b["balwt"])
//                   //             //                   .compareTo(double.parse(
//                   //             //                   a["balwt"])));
//                   //             //       }
//                   //             //     });
//                   //             //   },
//                   //             //   child: Padding(
//                   //             //     padding: const EdgeInsets.all(2.0),
//                   //             //     child: Image.asset(
//                   //             //       selectedSort == 1
//                   //             //           ? selectedSortType == 0
//                   //             //           ? 'assets/ic_up.png'
//                   //             //           : 'assets/ic_down.png'
//                   //             //           : 'assets/ic_up_down.png',
//                   //             //       height: 12,
//                   //             //       width: 12,
//                   //             //       color: Colors.white,
//                   //             //       colorBlendMode: BlendMode.srcIn,
//                   //             //     ),
//                   //             //   ),
//                   //             // )
//                   //           ],
//                   //         ),
//                   //       ),
//                   //     ),
//                   //     Expanded(
//                   //       flex: 1,
//                   //       child: Row(
//                   //         mainAxisAlignment: MainAxisAlignment.end,
//                   //         children: [
//                   //           const Text(
//                   //             'Amt Balance',
//                   //             style: TextStyle(
//                   //               color: Colors.white,
//                   //               fontWeight: FontWeight.bold,
//                   //             ),
//                   //           ),
//                   //           GestureDetector(
//                   //             onTap: () {
//                   //               if (selectedSort == 2) {
//                   //                 setState(() {
//                   //                   selectedSortType =
//                   //                   selectedSortType == 0 ? 1 : 0;
//                   //                 });
//                   //               } else {
//                   //                 setState(() {
//                   //                   selectedSort = 2;
//                   //                   selectedSortType = 0;
//                   //                 });
//                   //               }
//                   //
//                   //               setState(() {
//                   //                 if (selectedSortType == 0) {
//                   //                   data = List.from(data)
//                   //                     ..sort((a, b) =>
//                   //                         double.parse(a["balamt"])
//                   //                             .compareTo(double.parse(
//                   //                             b["balamt"])));
//                   //                 } else {
//                   //                   data = List.from(data)
//                   //                     ..sort((a, b) =>
//                   //                         double.parse(b["balamt"])
//                   //                             .compareTo(double.parse(
//                   //                             a["balamt"])));
//                   //                 }
//                   //               });
//                   //             },
//                   //             child: Padding(
//                   //               padding: const EdgeInsets.symmetric(horizontal: 2,vertical: 10),
//                   //               child: Image.asset(
//                   //                 selectedSort == 2
//                   //                     ? selectedSortType == 0
//                   //                     ? 'assets/ic_up.png'
//                   //                     : 'assets/ic_down.png'
//                   //                     : 'assets/ic_up_down.png',
//                   //                 height: 12,
//                   //                 width: 12,
//                   //                 color: Colors.white,
//                   //                 colorBlendMode: BlendMode.srcIn,
//                   //               ),
//                   //             ),
//                   //           )
//                   //         ],
//                   //       ),
//                   //     ),
//                   //   ],
//                   // ),
//                 ),
//                 Expanded(
//                   child: SingleChildScrollView(
//                     child: Column(
//                       children: [
//                         // Data Rows
//                         if (data.isNotEmpty)
//                           Column(
//                             children: data.map((client) {
//                               return GestureDetector(
//                                 onTap: () {
//                                   print(
//                                       "client['clientname'] ${client['clientname']}");

//                                   // onRowTap(client); // Handle row tap
//                                   Navigator.push(
//                                     context,
//                                     MaterialPageRoute(
//                                       builder: (context) => MaxWidthContainer(
//                                         child: MetalOutstandingDetailsScreen(
//                                           keyName: client['clientname'],
//                                         ),
//                                       ),
//                                     ),
//                                   );
//                                 },
//                                 child: Container(
//                                   color: Colors.white,
//                                   child: Column(
//                                     children: [
//                                       Row(
//                                         children: [
//                                           Expanded(
//                                             child: Padding(
//                                               padding:
//                                                   const EdgeInsets.all(8.0),
//                                               child: Text(
//                                                 client['clientname'],
//                                                 maxLines: 3,
//                                                 overflow: TextOverflow.ellipsis,
//                                               ),
//                                             ),
//                                           ),
//                                           Expanded(
//                                             child: Padding(
//                                               padding:
//                                                   const EdgeInsets.all(8.0),
//                                               child: Text(
//                                                 client['balwt'],
//                                                 textAlign: TextAlign.right,
//                                                 style: TextStyle(
//                                                   //  fontWeight: FontWeight.bold,
//                                                   color: double.parse(
//                                                               client['balwt']) >
//                                                           0
//                                                       ? Colors.green
//                                                       : Colors.red,
//                                                 ),
//                                               ),
//                                             ),
//                                           ),
//                                           Expanded(
//                                             child: Padding(
//                                               padding:
//                                                   const EdgeInsets.all(8.0),
//                                               child: Text(
//                                                 client['balamt'],
//                                                 textAlign: TextAlign.right,
//                                                 style: TextStyle(
//                                                   //  fontWeight: FontWeight.bold,
//                                                   color: double.parse(client[
//                                                               'balamt']) >
//                                                           0
//                                                       ? Colors.green
//                                                       : Colors.red,
//                                                 ),
//                                               ),
//                                             ),
//                                           ),
//                                         ],
//                                       ),
//                                       const Divider(
//                                         height: 1, // Space around the divider
//                                         thickness: 1, // Thickness of the line
//                                         color:
//                                             Colors.grey, // Color of the divider
//                                       )
//                                     ],
//                                   ),
//                                 ),
//                               );
//                             }).toList(),
//                           )
//                         else
//                           const SizedBox(
//                               height: 500,
//                               child: Center(
//                                   child: Text(
//                                 "No Data Found",
//                                 style: TextStyle(fontWeight: FontWeight.bold),
//                               ))),
//                       ],
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//     );
//   }
// }
import 'dart:convert';
import 'package:flutter/material.dart';
import '../Components/SideNavigation.dart';
import '../Constants/Functions.dart';
import '../Constants/StaticConstant.dart';
import 'MetalOutstandingDetailsScreen.dart';
import 'MaxWidthContainer.dart';

class MetalOutstandingScreen extends StatefulWidget {
  @override
  _MetalOutstandingScreenState createState() => _MetalOutstandingScreenState();
}

class _MetalOutstandingScreenState extends State<MetalOutstandingScreen> {
  int selectedSort = 0;
  int selectedSortType = 0;

  final TextEditingController _searchController = TextEditingController();

  bool loader = false;
  Constans constans = Constans();

  List<Map<String, dynamic>> mainList = [];
  List<Map<String, dynamic>> data = [];

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    getUserData();

    _searchController.addListener(() {
      onSubmitSearch(_searchController.text);
    });
  }

  Future<void> getUserData() async {
    String? userData = await Constans().getData(StaticConstant.userData);
    if (userData != null) fetchLists(jsonDecode(userData));
  }

  Future<void> fetchLists(Map<String, dynamic> userData) async {
    getMetalList(userData);
  }

  Future<void> getMetalList(Map<String, dynamic> userData) async {
    setState(() {
      loader = true;
    });

    var formData = {
      'companyid': userData['companyid'],
      'group': "1",
    };

    if (userData['isAdmin'] == "0") {
      formData["clouduserid"] = userData['username'];
    }

    String response =
        await constans.callApi(formData, StaticUrl.erpClientoutstandingUrl);
    Map<String, dynamic> responseData = json.decode(response);

    setState(() {
      mainList = List<Map<String, dynamic>>.from(responseData['data']);
      data = List<Map<String, dynamic>>.from(responseData['data']);
      loader = false;
    });
  }

  void onSubmitSearch(String value) {
    setState(() {
      data = mainList.where((client) {
        return client['clientname']
            .toString()
            .toLowerCase()
            .contains(value.toLowerCase());
      }).toList();
    });
  }

  void _sortData(int columnIndex) {
    setState(() {
      if (selectedSort == columnIndex) {
        selectedSortType = selectedSortType == 0 ? 1 : 0;
      } else {
        selectedSort = columnIndex;
        selectedSortType = 0;
      }

      data = List.from(data)
        ..sort((a, b) {
          dynamic valueA, valueB;
          if (columnIndex == 0) {
            valueA = a["clientname"].toLowerCase();
            valueB = b["clientname"].toLowerCase();
          } else {
            valueA = double.parse(a[columnIndex == 1 ? "balwt" : "balamt"]);
            valueB = double.parse(b[columnIndex == 1 ? "balwt" : "balamt"]);
          }
          return selectedSortType == 0
              ? valueA.compareTo(valueB)
              : valueB.compareTo(valueA);
        });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      drawer: Drawer(
        child: SideNavigation(type: 0, setState: () {}),
      ),
      backgroundColor: const Color(0xFFF6F6F6),
      appBar: AppBar(
        leading: IconButton(
          icon: Image.asset(
            'assets/menu.png',
            height: 20,
            color: Colors.white,
          ),
          onPressed: () => _scaffoldKey.currentState?.openDrawer(),
        ),
        backgroundColor: const Color(0xFF4C5564),
        flexibleSpace: Container(
          margin: const EdgeInsets.only(top: 35),
          child: const Center(
            child: Text(
              "Metal Outstanding",
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
                // Search Box
                Card(
                  margin: const EdgeInsets.all(10),
                  elevation: 2,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Row(
                      children: [
                        const Icon(Icons.search, color: Colors.grey),
                        const SizedBox(width: 10),
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

                // Table Header
                Container(
                  color: Colors.blueAccent,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 2.0, vertical: 10),
                  child: Row(
                    children: [
                      _buildHeaderCell("Client Name", 0, flex: 3),
                      _buildHeaderCell("Fine Balance", 1,
                          flex: 2, alignRight: true),
                      _buildHeaderCell("Amt Balance", 2,
                          flex: 2, alignRight: true),
                    ],
                  ),
                ),

                // Table Rows
                Expanded(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: SizedBox(
                      width: MediaQuery.of(context).size.width,
                      child: SingleChildScrollView(
                        child: Table(
                          border: TableBorder.all(color: Colors.grey.shade300),
                          columnWidths: const {
                            0: FlexColumnWidth(3),
                            1: FlexColumnWidth(2),
                            2: FlexColumnWidth(2),
                          },
                          children: data.isNotEmpty
                              ? data.map((client) {
                                  return TableRow(
                                    decoration: const BoxDecoration(
                                      color: Colors.white,
                                    ),
                                    children: [
                                      _buildDataCell(client['clientname'], 0,
                                          onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                MaxWidthContainer(
                                              child:
                                                  MetalOutstandingDetailsScreen(
                                                      keyName:
                                                          client['clientname']),
                                            ),
                                          ),
                                        );
                                      }),
                                      _buildDataCell(client['balwt'], 1,
                                          color:
                                              double.parse(client['balwt']) > 0
                                                  ? Colors.green
                                                  : Colors.red),
                                      _buildDataCell(client['balamt'], 2,
                                          color:
                                              double.parse(client['balamt']) > 0
                                                  ? Colors.green
                                                  : Colors.red),
                                    ],
                                  );
                                }).toList()
                              : [
                                  TableRow(children: [
                                    TableCell(
                                      child: Container(
                                        height: 200,
                                        alignment: Alignment.center,
                                        child: const Text(
                                          "No Data Found",
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                      // columnSpan: 3,
                                    ),
                                  ]),
                                ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  // Header Cell Widget
  Widget _buildHeaderCell(String title, int columnIndex,
      {int flex = 1, bool alignRight = false}) {
    return Expanded(
      flex: flex,
      child: Row(
        mainAxisAlignment:
            alignRight ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
                color: Colors.white, fontWeight: FontWeight.bold),
          ),
          const SizedBox(width: 4),
          GestureDetector(
            onTap: () => _sortData(columnIndex),
            child: Image.asset(
              selectedSort == columnIndex
                  ? selectedSortType == 0
                      ? 'assets/ic_up.png'
                      : 'assets/ic_down.png'
                  : 'assets/ic_up_down.png',
              height: 12,
              width: 12,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  // Data Cell Widget
  TableCell _buildDataCell(String value, int columnIndex,
      {Color? color, VoidCallback? onTap}) {
    return TableCell(
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            value,
            textAlign: columnIndex == 0 ? TextAlign.left : TextAlign.right,
            style: TextStyle(color: color ?? Colors.black),
          ),
        ),
      ),
    );
  }
}
