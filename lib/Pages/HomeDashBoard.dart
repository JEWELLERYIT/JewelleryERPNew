import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:responsive_grid_list/responsive_grid_list.dart';
import '../Constants/Functions.dart';
import '../Constants/StaticConstant.dart';
import 'package:widget_zoom/widget_zoom.dart';

class HomeDashBoard extends StatefulWidget {
  String keyName = "";
  String data = "";

  HomeDashBoard({required this.keyName, required this.data});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeDashBoard> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  String imageUrl = "";

  Constans constans = Constans();

  bool loaderStatus = false;
  String isAdmin = "0";
  bool showBox = false;
  List<dynamic> productList = [];

  final List<String> _items = [
    "SKU",
    "OrderDate [A-Z]",
    "OrderDate [Z-A]",
    "Del.Date [A-Z]",
    "Del.Date [Z-A]"
  ];

  @override
  void initState() {
    super.initState();

    homeApi("SKU");
  }

  Future<void> homeApi(String sortby) async {
    String? userData = await Constans().getData(StaticConstant.userData);

    Map<String, dynamic> userDataMap = jsonDecode(userData!);

    isAdmin = userDataMap['isAdmin'];

    imageUrl =
        "https://digicat.in/webroot/uploads/erp/${userDataMap['companyid']}/";
    var formData = {
      'companyid': userDataMap['companyid'],
      'username': userDataMap['username'],
      'sortby': sortby,
      'allstatus': "1",
      'isuser': userDataMap["isAdmin"],
      widget.keyName: widget.data
    };

    String response = await constans.callApi(formData, StaticUrl.loginUrl);
    print("responseData === $formData $response");

    Map<String, dynamic> responseData = json.decode(response);

    setState(() {
      if (widget.data != "" && widget.keyName == "search") {
        setState(() {
          productList = responseData['data'].where((client) {
            final searchText = widget.data.toLowerCase();

            print("searchText $searchText");
            final sku = client['sku']?.toString().toLowerCase() ?? '';
            final jobno = client['jobno']?.toString().toLowerCase() ?? '';

            return sku.contains(searchText) || jobno.contains(searchText);
          }).toList();

          print("productList 1: $productList");
        });
      } else {
        print("productList 2: $productList");

        productList = responseData['data'];
      }

      print("productList  $productList");

      // print("productList - productList ${productList.length}");
    });
  }

  int calculateDaysDifference(String deliveryDateStr) {
    // Parse the delivery date string into a DateTime object
    final DateTime deliveryDate = DateTime.parse(deliveryDateStr);

    // Get the current date
    final DateTime currentDate = DateTime.now();

    // Calculate the difference in days
    return deliveryDate.difference(currentDate).inDays;
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      key: _scaffoldKey,
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
          child: Center(
            child: Image.asset(
              'assets/login_logo.jpeg', // Replace with your image path
              height: 30, // Adjust the height as needed
            ),
          ),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
            margin: const EdgeInsets.only(bottom: 15, top: 1),
            color: const Color(0xFF4C5564), // Replace with your color
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // DropdownButton with reduced width
                SizedBox(
                  width: 130,
                  child: Container(
                    decoration: BoxDecoration(
                      color: StaticColor.lightGrey,
                      borderRadius:
                          BorderRadius.circular(20.0), // Rounded corners
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10.0),
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            icon: const SizedBox.shrink(),
                            hint: Row(
                              children: [
                                Image.asset(
                                  'assets/sort.png',
                                  height: 24,
                                  width: 24,
                                  color: StaticColor.themeColor,
                                ),
                                const SizedBox(width: 18),
                                const Text(
                                  "Sort By",
                                  style: TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.w400,
                                    color: StaticColor.themeColor,
                                  ),
                                ),
                                const SizedBox(width: 18),
                                Image.asset(
                                  'assets/down_1.png',
                                  height: 15,
                                  width: 15,
                                  color: StaticColor.themeColor,
                                ),
                              ],
                            ),
                            items: _items.map((String item) {
                              return DropdownMenuItem<String>(
                                value: item,
                                child: Text(
                                  item,
                                  style: const TextStyle(
                                    color: Colors.black,
                                    fontFamily: 'Arial',
                                    fontWeight: FontWeight.normal,
                                  ),
                                ),
                              );
                            }).toList(),
                            onChanged: (String? newValue) {
                              setState(() {
                                print("newValues --   $newValue");

                                switch (newValue) {
                                  case "SKU":
                                    homeApi("sku");
                                  case "OrderDate [A-Z]":
                                    homeApi("orderDate");
                                  case "OrderDate [Z-A]":
                                    homeApi("OrderDate desc");
                                  case "Del.Date [A-Z]":
                                    homeApi("deldate");
                                  case "Del.Date [Z-A]":
                                    homeApi("deldate desc");
                                }

                                // Handle dropdown value change here
                              });
                            },
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ResponsiveGridList(
              horizontalGridMargin: 10,
              verticalGridMargin: 10,
              minItemWidth: screenWidth / 3,
              children: List.generate(
                productList.length,
                (index) => Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 5),
                        child: Text(
                          productList[index]['sku'],
                          style: const TextStyle(
                            //
                            color: Colors.deepOrange,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            fontFamily: 'PoppinsMedium',
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: GestureDetector(
                          onTap: () => () {},
                          child: WidgetZoom(
                            heroAnimationTag: 'zoomHero',
                            zoomWidget: Image.network(
                              height: 150,
                              '$imageUrl${productList[index]['imagename']}',
                              fit: BoxFit.fitHeight,
                              errorBuilder: (context, error, stackTrace) {
                                return Image.asset(
                                  'assets/placeholder.png',
                                  fit: BoxFit.fitHeight,
                                );
                              },
                            ),
                          ),
                        ),
                      ),
                      Container(
                        width: double.infinity,
                        height: 1,
                        color: const Color(0xFF4C5564),
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              'Order Date:\n${constans.getDate(productList[index]['orderdate'])}',
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: Color(0xFF4C5564),
                                fontSize: 10,
                                fontFamily: 'PoppinsMedium',
                              ),
                            ),
                          ),
                          Container(
                            width: 1,
                            height: 35,
                            color: const Color(0xFF4C5564),
                          ),
                          Expanded(
                            child: Text(
                              'Delivery Date:\n${constans.getDate(productList[index]['deldate'])}',
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: Color(0xFF4C5564),
                                fontSize: 10,
                                fontFamily: 'PoppinsMedium',
                              ),
                            ),
                          ),
                        ],
                      ),
                      Container(
                        width: double.infinity,
                        height: 1,
                        color: const Color(0xFF4C5564),
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              productList[index]['process'],
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: Color(0xFF4C5564),
                                fontSize: 10,
                                fontFamily: 'PoppinsMedium',
                              ),
                            ),
                          ),
                          Container(
                            width: 1,
                            height: 25,
                            color: const Color(0xFF4C5564),
                          ),
                          Expanded(
                            child: Center(
                              child: Text(
                                style: const TextStyle(
                                  color: Colors.red,
                                  fontSize: 12,
                                ),
                                "${calculateDaysDifference(productList[index]['deldate'])} Days",
                              ),
                            ),
                          ),
                        ],
                      ),
                      Container(
                        width: double.infinity,
                        height: 1,
                        color: const Color(0xFF4C5564),
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              productList[index]['item'] ?? '',
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: Color(0xFF4C5564),
                                fontSize: 10,
                                fontFamily: 'PoppinsMedium',
                              ),
                            ),
                          ),
                          Container(
                            width: 1,
                            height: 35,
                            color: const Color(0xFF4C5564),
                          ),
                          Expanded(
                            child: Text(
                              productList[index]['metal'],
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: Color(0xFF4C5564),
                                fontSize: 10,
                                fontFamily: 'PoppinsMedium',
                              ),
                            ),
                          ),
                        ],
                      ),
                      if (isAdmin == "1")
                        Container(
                          width: double.infinity,
                          height: 1,
                          color: const Color(0xFF4C5564),
                        ),
                      if (isAdmin == "1")
                        Row(
                          children: [
                            const Expanded(
                              child: Text(
                                "Client",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Color(0xFF4C5564),
                                  fontSize: 10,
                                  fontFamily: 'PoppinsMedium',
                                ),
                              ),
                            ),
                            Container(
                              width: 1,
                              height: 35,
                              color: const Color(0xFF4C5564),
                            ),
                            Expanded(
                              child: Text(
                                //isAdmin
                                productList[index]['username'],
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  color: Color(0xFF4C5564),
                                  fontSize: 10,
                                  fontFamily: 'PoppinsMedium',
                                ),
                              ),
                            ),
                          ],
                        ),
                      Container(
                        width: double.infinity,
                        height: 1,
                        color: const Color(0xFF4C5564),
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              "Job No.\n${productList[index]['jobno']}",
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: Color(0xFF4C5564),
                                fontSize: 10,
                                fontFamily: 'PoppinsMedium',
                              ),
                            ),
                          ),
                          Container(
                            width: 1,
                            height: 35,
                            color: const Color(0xFF4C5564),
                          ),
                          Expanded(
                            child: Text(
                              //isAdmin
                              "Gross WT\n${productList[index]['grosswt']} G",
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: Color(0xFF4C5564),
                                fontSize: 10,
                                fontFamily: 'PoppinsMedium',
                              ),
                            ),
                          ),
                        ],
                      )
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
}

class Data {
  String productId;
  String itemData;

  Data({required this.productId, required this.itemData});

  factory Data.fromJson(Map<String, dynamic> json) {
    return Data(
      productId: json['product_id'],
      itemData: json['item_data'],
    );
  }
}
