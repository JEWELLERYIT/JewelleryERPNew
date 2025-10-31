import 'package:flutter/cupertino.dart';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_native_html_to_pdf/flutter_native_html_to_pdf.dart';
import '../Components/SideNavigation.dart';
import '../Constants/Functions.dart';
import '../Constants/StaticConstant.dart';
import 'MaxWidthContainer.dart';
import 'OrderScreen.dart';
import 'PDFScreen.dart';

class Orderhistoryscreen extends StatefulWidget {
  const Orderhistoryscreen({super.key});

  @override
  _OrderhistoryscreenState createState() => _OrderhistoryscreenState();
}

class _OrderhistoryscreenState extends State<Orderhistoryscreen> {
  final TextEditingController _searchController = TextEditingController();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  Constans constans = Constans();

  bool loader = false;
  List<Map<String, dynamic>> mainList = [];
  List<Map<String, dynamic>> data = [];
  Map<String, dynamic> userData = {};
  @override
  void initState() {
    super.initState();
    getUserData();

    _searchController.addListener(() {
      onSubmitSearch(_searchController.text);
    });
    getUserDataInIt();
  }

  void getUserDataInIt() async {
    String? detailsStr = await constans.getData(StaticConstant.userDetails);

    print("Company Logo  -- $detailsStr");

    userData = jsonDecode(detailsStr!);
  }
  // Future<void> getUserData() async {
  //   setState(() => loader = true);

  //   String? userDataStr = await Constans().getData(StaticConstant.userData);

  //   if (userDataStr == null || userDataStr.isEmpty) {
  //     print("No user data found");
  //     setState(() => loader = false);
  //     return;
  //   }

  //   dynamic decodedData;
  //   try {
  //     decodedData = jsonDecode(userDataStr);
  //   } catch (e) {
  //     print("Failed to decode user data: $e");
  //     setState(() => loader = false);
  //     return;
  //   }

  //   Map<String, dynamic> userMap;

  //   if (decodedData is int) {
  //     userMap = {'userid': decodedData};
  //   } else if (decodedData is Map<String, dynamic>) {
  //     userMap = decodedData;
  //   } else {
  //     print("Unexpected user data type: ${decodedData.runtimeType}");
  //     setState(() => loader = false);
  //     return;
  //   }

  //   await fetchLists(userMap);
  //   setState(() => loader = false);
  // }

  Future<void> generateAndOpenPdf(
      BuildContext context, Map<String, dynamic> order) async {
    try {
      String baseUrl =
          "https://digicat.in/webroot/uploads/products/${StaticData.unique_id}/order/";

      String image1 = order['image1link'] != null && order['image1link'] != ""
          ? "$baseUrl${order['image1link']}"
          : "";
      String image2 = order['image2link'] != null && order['image2link'] != ""
          ? "$baseUrl${order['image2link']}"
          : "";
      String audio = order['vnotelink'] != null && order['vnotelink'] != ""
          ? "$baseUrl${order['vnotelink']}"
          : "";

      String formatDate(String? rawDate) {
        if (rawDate == null || rawDate.isEmpty) return '';
        try {
          return DateFormat('dd MMM yyyy').format(DateTime.parse(rawDate));
        } catch (e) {
          return '';
        }
      }

      final htmlContent = """
    <!DOCTYPE html>
    <html>
      <head>
        <meta charset="utf-8">
        <style>
          body { font-family: Arial; margin: 20px; font-size: 12px; color: #222; }
          h1 { text-align: center; color: #4a148c; }
          table { width: 100%; border-collapse: collapse; margin-top: 15px; }
          th, td { border: 1px solid #ccc; padding: 8px; text-align: left; vertical-align: top; }
          th { background-color: #f2f2f2; width: 30%; }
          .image { height: 150px; border: 1px solid #ccc; border-radius: 6px; margin: 8px; }
          a { color: #1e88e5; text-decoration: none; }
          .footer { margin-top: 20px; font-size: 10px; text-align: right; color: #555; }
        </style>
      </head>
      <body>
        <h1>Order Details</h1>
        <table>
          <tr><th>Order ID</th><td>${order['id'] ?? ''}</td></tr>
          <tr><th>Order Date</th><td>${formatDate(order['thisdate'])}</td></tr>
          <tr><th>Client</th><td>${order['clientname'] ?? ''}</td></tr>
          <tr><th>Order Ref</th><td>${order['orderref'] ?? ''}</td></tr>
          <tr><th>Item</th><td>${order['item'] ?? ''}</td></tr>
          <tr><th>Metal</th><td>${order['metal'] ?? ''}</td></tr>
          <tr><th>Color</th><td>${order['color'] ?? ''}</td></tr>
          <tr><th>Size</th><td>${order['size'] ?? ''}</td></tr>
          <tr><th>Ref SKU</th><td>${order['refsku'] ?? ''}</td></tr>
          <tr><th>Pcs</th><td>${order['pcs'] ?? ''}</td></tr>
          <tr><th>Gross Wt</th><td>${order['grosswt'] ?? ''}</td></tr>
          <tr><th>Approx Value</th><td>${order['aprox_value'] ?? ''}</td></tr>
          <tr><th>Advance</th><td>${order['adv_rcvd'] ?? ''}</td></tr>
          <tr><th>Stone Desc</th><td>${order['stonedesc'] ?? ''}</td></tr>
          <tr><th>Item Desc</th><td>${order['itemdesc'] ?? ''}</td></tr>
          <tr><th>Delivery</th><td>${order['deldate'] ?? ''}</td></tr>
          <tr><th>Stamp</th><td>${order['stamp'] ?? ''}</td></tr>
          <tr><th>HUID</th><td>${order['huid'] ?? ''}</td></tr>
        </table>

        <h3>Images</h3>
        <div style="display:flex;flex-wrap:wrap;">
          ${image1.isNotEmpty ? '<img src="$image1" class="image"/>' : ''}
          ${image2.isNotEmpty ? '<img src="$image2" class="image"/>' : ''}
        </div>

        ${audio.isNotEmpty ? '<p><a href="$audio">🎧 Voice Note</a></p>' : ''}

        <div class="footer">
          Generated on: ${DateTime.now().toString().split('.').first}
        </div>
      </body>
    </html>
    """;

      final dir = await getApplicationDocumentsDirectory();
      final converter = FlutterNativeHtmlToPdf();
      final pdfFile = await converter.convertHtmlToPdf(
        html: htmlContent,
        targetDirectory: dir.path,
        targetName:
            "order_${order['id'] ?? DateTime.now().millisecondsSinceEpoch}",
      );

      if (!context.mounted) return;

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => PdfViewScreen(pathStr: pdfFile!.path),
        ),
      );
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error generating PDF: $e")),
      );
    }
  }

  Future<void> generateAndOpenPdfadv(
    BuildContext context,
    Map<String, dynamic> order,
  ) async {
    try {
      String baseUrl =
          "https://digicat.in/webroot/uploads/products/${StaticData.unique_id}/order/";

      String image1 = order['image1link'] != null && order['image1link'] != ""
          ? "$baseUrl${order['image1link']}"
          : "";
      String image2 = order['image2link'] != null && order['image2link'] != ""
          ? "$baseUrl${order['image2link']}"
          : "";
      String audio = order['vnotelink'] != null && order['vnotelink'] != ""
          ? "$baseUrl${order['vnotelink']}"
          : "";

      String formatDateTime(String? rawDate) {
        if (rawDate == null || rawDate.isEmpty) return '';
        try {
          final dt = DateTime.parse(rawDate);
          return DateFormat('dd-MM-yyyy hh:mm a').format(dt);
        } catch (e) {
          return '';
        }
      }

      String formatDate(String? rawDate) {
        if (rawDate == null || rawDate.isEmpty) return '';
        try {
          return DateFormat('dd-MM-yyyy').format(DateTime.parse(rawDate));
        } catch (e) {
          return '';
        }
      }

      String companyLogo = constans.getCompanyImageUrl(userData['image']);
      String companyName = userData['company_name'] ?? '';
      String address = userData['address'] ?? '';
      String phoneNo = userData['phoneNo'] ?? '';

      final htmlContent = """
<!DOCTYPE html>
<html>
<head>
<meta charset="utf-8">
<style>
  body {
    background-color: #F4FFF4;
    font-family: Arial, sans-serif;
    margin: 0;
    padding: 0;
  }
  .content { padding: 10px; font-size: 12px; }
  .header { display: flex; justify-content: space-between; align-items: flex-start; }
  .header img { height: 50px; }
  .header .company-details { text-align: right; font-size: 12px; }
  .title {
    text-align: center;
    color: #1B5E20;
    font-size: 16px;
    font-weight: bold;
    text-decoration: underline;
    margin: 8px 0;
  }
  table {
    width: 100%;
    border-collapse: collapse;
    background: #fff;
  }
  th, td {
    border: 1px solid rgba(0,0,0,0.3);
    padding: 6px;
    text-align: center;
    vertical-align: middle;
  }
  th { background-color: #f9f9f9; }
  .desc-cell {
    text-align: center;
    font-size: 11px;
  }
  .desc-cell .img-row {
    display: flex;
    justify-content: center;
    gap: 12px;
    margin-bottom: 6px;
  }
  .desc-cell img {
    width: 200px;
    height: 200px;
    object-fit: contain;
    border: 1px solid #ccc;
    border-radius: 10px;
  }
  .remarks-box {
    margin-top: 15px;
    border: 1px solid #1B5E20;
    background: #E9FBE9;
    border-radius: 6px;
    padding: 6px;
  }
  .remarks-title {
    color: #1B5E20;
    font-weight: bold;
    font-size: 13px;
    margin-bottom: 5px;
  }
  .remarks-content { font-size: 12px; }
  .footer-details {
    margin-top: 25px;
    background: #fff;
    border: 1px solid #1B5E20;
    border-radius: 6px;
    padding: 8px;
    page-break-inside: avoid;
  }
  .footer-details h3 {
    margin: 0 0 6px 0;
    color: #1B5E20;
    font-size: 13px;
    font-weight: bold;
    text-decoration: underline;
  }
  .details-grid {
    display: grid;
    grid-template-columns: repeat(2, 1fr);
    gap: 6px 10px;
    font-size: 12px;
  }
  .label { font-weight: bold; color: #333; }
  .value { color: #444; }
</style>
</head>
<body>
  <div class="content">

    <!-- Header -->
    <div class="header">
      <img src="$companyLogo" alt="Logo">
      <div class="company-details">
        <div style="font-weight:bold;">$companyName</div>
        <div>$address</div>
        <div>$phoneNo</div>
      </div>
    </div>

    <div class="title">Order Form / Advance Receipt</div>

    <div style="display:flex; justify-content:space-between; font-size:12px;">
      <div>Date: ${formatDate(order['thisdate'])}</div>
      <div>Name: ${order['clientname'] ?? ''}</div>
    </div>

    <div style="margin-top:4px; font-size:12px;">
      <b>Created On:</b> ${(order['created_at'] != null && order['created_at'].toString().isNotEmpty) ? formatDateTime(order['created_at']) : DateFormat('dd-MM-yyyy hh:mm a').format(DateTime.now())}
    </div>

    <br>

    <!-- Product Table -->
    <table>
      <tr>
        <th>S.No.</th>
        <th>Description</th>
        <th>Pcs</th>
        <th>Gross Wt<br>/Gms</th>
        <th>Amt<br>/Rs</th>
      </tr>

      <tr>
        <td>1</td>
        <td class="desc-cell">
          <div class="img-row">
            ${image1.isNotEmpty ? '<img src="$image1" alt="Image1">' : ''}
            ${image2.isNotEmpty ? '<img src="$image2" alt="Image2">' : ''}
          </div>
          ${order['item'] ?? ''} ${order['refsku'] ?? ''}
        </td>
        <td>${order['pcs'] ?? '1'}</td>
        <td>${order['grosswt'] ?? '0.000'}</td>
        <td><b>${order['aprox_value'] ?? '0'}</b></td>
      </tr>

      <tr>
        <td colspan="2" style="text-align:right; font-weight:bold;">Total</td>
        <td>${order['pcs_total'] ?? order['pcs'] ?? '1'}</td>
        <td>${order['grosswt_total'] ?? order['grosswt'] ?? '0.000'}</td>
        <td><b>${order['total'] ?? order['aprox_value'] ?? '0'}</b></td>
      </tr>
    </table>

    <!-- Remarks -->
    <div class="remarks-box">
      <div class="remarks-title">Remarks</div>
      <div class="remarks-content">${order['remark'] ?? 'No remarks'}</div>
    </div>

    <!-- Voice Note -->
    ${audio.isNotEmpty ? """
    <div style="margin-top:10px;">
      <a href="$audio" style="color:#1B5E20; text-decoration:none;">🎧 Voice Note</a>
    </div>
    """ : ''}

    <!-- Footer Details -->
    <div class="footer-details">
      <h3>Order Details</h3>
      <div class="details-grid">
        <div><span class="label">Order ID:</span> <span class="value">${order['id'] ?? ''}</span></div>
        <div><span class="label">Order Date:</span> <span class="value">${formatDate(order['thisdate'])}</span></div>
        <div><span class="label">Client:</span> <span class="value">${order['clientname'] ?? ''}</span></div>
        <div><span class="label">Order Ref:</span> <span class="value">${order['orderref'] ?? ''}</span></div>
        <div><span class="label">Item:</span> <span class="value">${order['item'] ?? ''}</span></div>
        <div><span class="label">Metal:</span> <span class="value">${order['metal'] ?? ''}</span></div>
        <div><span class="label">Color:</span> <span class="value">${order['color'] ?? ''}</span></div>
        <div><span class="label">Size:</span> <span class="value">${order['size'] ?? ''}</span></div>
        <div><span class="label">Ref SKU:</span> <span class="value">${order['refsku'] ?? ''}</span></div>
        <div><span class="label">Pcs:</span> <span class="value">${order['pcs'] ?? ''}</span></div>
        <div><span class="label">Gross Wt:</span> <span class="value">${order['grosswt'] ?? ''}</span></div>
        <div><span class="label">Approx Value:</span> <span class="value">${order['aprox_value'] ?? ''}</span></div>
        <div><span class="label">Advance:</span> <span class="value">${order['adv_rcvd'] ?? ''}</span></div>
        <div><span class="label">Stone Desc:</span> <span class="value">${order['stonedesc'] ?? ''}</span></div>
        <div style="grid-column: span 2;">
          <span class="label">Item Desc:</span>
          <span class="value">${order['itemdesc'] ?? ''}</span>
        </div>
        <div><span class="label">Delivery:</span> <span class="value">${formatDate(order['deldate'])}</span></div>
        <div><span class="label">Stamp:</span> <span class="value">${order['stamp'] ?? ''}</span></div>
        <div><span class="label">HUID:</span> <span class="value">${order['huid'] ?? ''}</span></div>
      </div>
    </div>

  </div>
</body>
</html>
""";

      final dir = await getApplicationDocumentsDirectory();
      final converter = FlutterNativeHtmlToPdf();
      final pdfFile = await converter.convertHtmlToPdf(
        html: htmlContent,
        targetDirectory: dir.path,
        targetName:
            "order_${order['id'] ?? DateTime.now().millisecondsSinceEpoch}",
      );

      if (!context.mounted) return;
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => PdfViewScreen(pathStr: pdfFile!.path),
        ),
      );
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error generating PDF: $e")),
      );
    }
  }

  Future<void> getUserData() async {
    String? userDataStr = await Constans().getData(StaticConstant.userDetails);

    Map<String, dynamic> userData;

    try {
      var parsed = jsonDecode(userDataStr!);

      if (parsed is int) {
        // Sometimes storage returns just an int
        userData = {'userid': parsed.toString()};
      } else if (parsed is Map<String, dynamic>) {
        userData = parsed;
      } else {
        // fallback
        userData = {'userid': parsed.toString()};
      }
    } catch (e) {
      // fallback in case of invalid JSON
      userData = {'userid': userDataStr ?? '0'};
    }

    print("Parsed User Data: $userData");

    fetchLists(userData);
  }

  Future<void> fetchLists(Map<String, dynamic> userData) async {
    await getMetalList(userData);
  }

  Future<void> getMetalList(Map<String, dynamic> userData) async {
    var ownerId =
        userData['onwerID']?.toString() ?? userData['userid'].toString();

    var formData = {
      'ownerid': ownerId,
      'select': "1",
    };
    print("FormData for API: $formData");

    String response = '';
    try {
      response = await constans.callApi(
        formData,
        "https://www.digicat.in/webroot/RiteshApi/digicat_order.php",
      );

      if (response.isEmpty) {
        print("Empty response from API");
        return;
      }

      Map<String, dynamic> responseData = jsonDecode(response);
      print("Decoded Response: $responseData");

      if (responseData['data'] == null || responseData['data'] is! List) {
        print("API returned no data or invalid format");
        return;
      }

      List<Map<String, dynamic>> tempList =
          List<Map<String, dynamic>>.from(responseData['data']);

      setState(() {
        mainList = tempList;
        data = tempList;
      });

      print("Fetched ${tempList.length} orders for ownerid: $ownerId");
    } catch (e) {
      print("Error fetching Metal List: $e\nResponse: $response");
    }
  }

  Future<void> deleteOrder(String id, Map<String, dynamic> client) async {
    var formData = {
      'id': id,
      'delete': "1",
    };

    try {
      String response = await constans.callApi(formData,
          "https://www.digicat.in/webroot/RiteshApi/digicat_order.php");
      print("Delete response: $response");

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Order Form Delete Successfully")),
      );

      setState(() {
        mainList.removeWhere((element) => element['id'] == id);
        data.removeWhere((element) => element['id'] == id);
      });
    } catch (e) {
      print("Error deleting order: $e");
    }
  }

  void onSubmitSearch(String value) {
    setState(() {
      data = mainList.where((client) {
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
      drawer: Drawer(child: SideNavigation(type: 0, setState: () {})),
      backgroundColor: const Color(0xFFF6F6F6),
      appBar: AppBar(
        leading: IconButton(
          icon: Image.asset(
            color: Colors.white,
            'assets/menu.png',
            height: 20,
          ),
          onPressed: () => _scaffoldKey.currentState?.openDrawer(),
        ),
        title: null,
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
                Expanded(
                  child: data.isEmpty
                      ? const Center(
                          child: Text(
                            "No Data Found",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        )
                      : SingleChildScrollView(
                          child: Column(
                            children: data.map((client) {
                              return GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => MaxWidthContainer(
                                        child: OrderScreen(data: client),
                                      ),
                                    ),
                                  ).then((_) => getUserData());
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
                                                              "https://digicat.in/webroot/uploads/products/${StaticData.unique_id}/order/${client['image1link']}",
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
                                                  "https://digicat.in/webroot/uploads/products/${StaticData.unique_id}/order/${client['image1link']}",
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
                                                    "Date: ${formatDate(client['thisdate'])}",
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
                                                                      .pop();
                                                                },
                                                              ),
                                                              TextButton(
                                                                child:
                                                                    const Text(
                                                                  "Delete",
                                                                  style: TextStyle(
                                                                      color: Colors
                                                                          .red),
                                                                ),
                                                                onPressed: () {
                                                                  deleteOrder(
                                                                      client[
                                                                          'id'],
                                                                      client);
                                                                  Navigator.of(
                                                                          context)
                                                                      .pop();
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
                                                  "Adv. Amount: ${client['adv_rcvd'] ?? ''}",
                                                  style: const TextStyle(
                                                      fontSize: 12)),
                                              Text(
                                                  "Item: ${client['item'] ?? ''}",
                                                  style: const TextStyle(
                                                      fontSize: 12)),
                                              Text(
                                                  "Ref SKU: ${client['refsku'] ?? ''}",
                                                  style: const TextStyle(
                                                      fontSize: 12)),
                                              Text(
                                                  "Del Date: ${client['deldate'] ?? ''}",
                                                  style: const TextStyle(
                                                      fontSize: 12)),
                                              const SizedBox(height: 6),
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.end,
                                                children: [
                                                  GestureDetector(
                                                      onTap: () async {
                                                        await generateAndOpenPdfadv(
                                                            context, client);
                                                      },
                                                      child: Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .all(8.0),
                                                        child: Container(
                                                          child: Icon(Icons
                                                              .picture_as_pdf),
                                                        ),
                                                      )),
                                                ],
                                              ),
                                              Row(
                                                children: [
                                                  Container(
                                                    padding: const EdgeInsets
                                                        .symmetric(
                                                        horizontal: 10,
                                                        vertical: 6),
                                                    decoration: BoxDecoration(
                                                      color: Colors
                                                          .deepPurple.shade50,
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              20),
                                                    ),
                                                    child: Text(
                                                      "Metal: ${client['metal'] ?? ''} | Col: ${client['color'] ?? ''}",
                                                      style: const TextStyle(
                                                          fontWeight:
                                                              FontWeight.w500,
                                                          color: Colors
                                                              .deepPurple),
                                                    ),
                                                  ),
                                                  SizedBox(
                                                    width: 30,
                                                  ),
                                                  GestureDetector(
                                                      onTap: () async {
                                                        await generateAndOpenPdf(
                                                            context, client);
                                                      },
                                                      child: Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .all(8.0),
                                                        child: Container(
                                                          child: Icon(Icons
                                                              .picture_as_pdf),
                                                        ),
                                                      )),
                                                ],
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
                          ),
                        ),
                ),
              ],
            ),
    );
  }
}
