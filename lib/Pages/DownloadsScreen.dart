import 'dart:convert';
import 'dart:math' as math;
import 'package:flutter_file_dialog/flutter_file_dialog.dart';
import 'package:http/http.dart' as http;
import 'dart:io';
import 'package:path_provider/path_provider.dart';

import 'package:flutter/material.dart';
import 'package:jewelleryerp/Pages/HomeDashBoard.dart';
import '../Components/SideNavigation.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../Constants/Functions.dart';
import '../Constants/StaticConstant.dart';
import 'MetalOutstandingDetailsScreen.dart';
import 'MaxWidthContainer.dart';
import 'package:pie_chart/pie_chart.dart';

class DownloadsScreen extends StatefulWidget {
  @override
  _DownloadsScreenState createState() => _DownloadsScreenState();
}

class _DownloadsScreenState extends State<DownloadsScreen> {
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

  Future<void> getUserData() async {
    String? userData = await Constans().getData(StaticConstant.userData);

    getMetalList(jsonDecode(userData!));
  }

  Future<void> getMetalList(Map<String, dynamic> userData) async {
    var formData = {
      'username': userData['username'],
      'companyid': userData['companyid'],
      'selectinvoice': "1",
    };

    String response = await constans.callApi(formData, StaticUrl.erpSalesUrl);
    Map<String, dynamic> responseData = json.decode(response);

    print("Client OutStanding: $formData $response");

    setState(() {
      mainList = List<Map<String, dynamic>>.from(responseData['data']);
    });
    // }
  }

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

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
              "Downloads",
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
          : Padding(
            padding: const EdgeInsets.all(8.0),
            child: ListView.builder(
                itemCount: mainList.length,
                itemBuilder: (context, index) {
                  return Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            "Delivery Challan No. ${mainList[index]['vrno']} ${mainList[index]['vrdate']}",
                            style:
                                const TextStyle(color: Colors.blue, fontSize: 12),
                          ),
                          const SizedBox(
                            height: 5,
                          ),
                          Row(
                            children: [
                              Column(
                                children: [
                                  Text(
                                    "Fine WT. ${mainList[index]['finewt']} Gms",
                                    style: const TextStyle(
                                      color: Color(0xFFB47F0F),
                                      fontSize: 12,
                                    ),
                                  ),
                                  Text(
                                    "Amount : ${double.parse(mainList[index]['total']).toStringAsFixed(2)}",
                                    style: const TextStyle(
                                      color: Color(0xFF0F2F0C),
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(
                                width: 50,
                              ),
                              GestureDetector(
                                onTap: () => {
                                  // downloadPdf("https://digicat.in//webroot//uploads//erp//1005//invoice//2471.pdf")
                                  downloadPdf(mainList[index]['doclink'],mainList[index]['vrno'])
                                },
                                child: Image.asset(
                                  'assets/download_pdf.png',
                                  height: 24,
                                  width: 24,
                                ),
                              )
                            ],
                          )
                        ],
                      ),
                    ),
                  );
                },
              ),
          ),
    );
  }


  Future<void> downloadPdf(String url , String vrno) async {
    try {
      // Step 1: Download the file
      var response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final tempDir = await getTemporaryDirectory();
        final tempPath = '${tempDir.path}/${vrno}.pdf';

        // Step 2: Save to temp file
        File tempFile = File(tempPath);
        await tempFile.writeAsBytes(response.bodyBytes);

        // Step 3: Ask the user where to save it
        final savePath = await FlutterFileDialog.saveFile(
          params: SaveFileDialogParams(sourceFilePath: tempPath),
        );

        if (savePath != null) {
          print("✅ File saved successfully at: $savePath");
        } else {
          print("⚠️ User canceled file save.");
        }
      } else {
        print("❌ Failed to download file.");
      }
    } catch (e) {
      print("⚠️ Error downloading PDF: $e");
    }
  }
}
