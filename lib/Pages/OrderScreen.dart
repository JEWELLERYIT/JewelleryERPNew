import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

import '../Constants/Functions.dart';
import '../Constants/StaticConstant.dart';

class OrderScreen extends StatefulWidget {
  @override
  _OrderScreenState createState() => _OrderScreenState();
}

class _OrderScreenState extends State<OrderScreen> {
  final _formKey = GlobalKey<FormState>();

  bool _isLoading = false;

  Constans constans = Constans();
  final TextEditingController orderRefController = TextEditingController();
  final TextEditingController itemController = TextEditingController();
  final TextEditingController metalController = TextEditingController();
  final TextEditingController colorController = TextEditingController();
  final TextEditingController sizeController = TextEditingController();
  final TextEditingController refSKUController = TextEditingController();
  final TextEditingController cRefController = TextEditingController();
  final TextEditingController platingController = TextEditingController();
  final TextEditingController rhodiumController = TextEditingController();
  final TextEditingController findingsController = TextEditingController();
  final TextEditingController pcsController = TextEditingController();
  final TextEditingController grossWTController = TextEditingController();
  final TextEditingController stoneDescriptionController =
      TextEditingController();
  final TextEditingController itemDescriptionController =
      TextEditingController();

  final TextEditingController enamelColorController = TextEditingController();

  File? imageFromGallery = null;
  File? imageFromCamera = null;

  Future<void> pickImage(ImageSource source, bool fromCamera) async {
    final pickedFile = await ImagePicker().pickImage(source: source);

    if (pickedFile != null) {
      setState(() {
        if (fromCamera) {
          imageFromCamera = File(pickedFile.path);
        } else {
          imageFromGallery = File(pickedFile.path);
        }
      });
    }
  }

  Future<String> uploadImage(
      Map<String, dynamic> userData, File _imageFIle) async {
    var request = http.MultipartRequest(
      'POST',
      Uri.parse('https://www.digicat.in/webroot/RiteshApi/erp_orderimage.php'),
    );
    request.fields['companyid'] = userData['companyid'];

    request.files.add(
      await http.MultipartFile.fromPath(
        'image', // name of the field in backend
        _imageFIle.path,
      ),
    );

    var response = await request.send();

    if (response.statusCode == 200) {
      final responseBody = await response.stream.bytesToString();
      final decodedJson = json.decode(responseBody);

      return decodedJson["file"];
    } else {
      return "";
    }
  }

  Future<void> uploadForm(Map<String, dynamic> userData, String image1Path,
      String image2Path) async {
    final now = DateTime.now();
    final formattedDate = DateFormat('yyyy-MM-dd HH:mm').format(now);
    var formData = {
      'companyid': userData['companyid'],
      "clouduserid": userData['username'],
      "clientname": "",
      "orderref": orderRefController.text,
      "item": itemController.text,
      "metal": metalController.text,
      "color": colorController.text,
      "size": sizeController.text,
      "refsku": refSKUController.text,
      "cref": cRefController.text,
      "enamalcolor": enamelColorController.text,
      "rhodium": rhodiumController.text,
      "findings": findingsController.text,
      "stonedesc": stoneDescriptionController.text,
      "itemdesc": itemDescriptionController.text,
      "image1link": image1Path,
      "image2link": image2Path,
      "add": "1",
      "vrdate": formattedDate,
      "pcs": pcsController.text,
      "grosswt": grossWTController.text
    };

    String response = await constans.callApi(
        formData, "https://www.digicat.in/webroot/RiteshApi/erp_order.php");
    final Map<String, dynamic> jsonResponse = json.decode(response);

    if (jsonResponse["response"] == true &&
        jsonResponse["status_code"] == 200 &&
        jsonResponse["data"]?["new_id"] != 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Order Form Submitted Successfully")),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Order Submission Failed")),
      );
    }
  }

  void submitForm() async {
    setState(() {
      _isLoading = true;
    });

    String? userData = await Constans().getData(StaticConstant.userData);

    String image1Path = "";
    String image2Path = "";

    if (imageFromGallery != null) {
      image1Path = await uploadImage(jsonDecode(userData!), imageFromGallery!);
    }
    if (imageFromCamera != null) {
      image2Path = await uploadImage(jsonDecode(userData!), imageFromCamera!);
    }

    print("Image 1 Path $image1Path , Image 2 Path $image2Path ");

    uploadForm(jsonDecode(userData!), image1Path, image2Path);

    setState(() {
      _formKey.currentState!.reset();
      orderRefController.clear();
      itemController.clear();
      metalController.clear();
      colorController.clear();
      sizeController.clear();
      refSKUController.clear();
      cRefController.clear();
      platingController.clear();
      rhodiumController.clear();
      findingsController.clear();
      pcsController.clear();
      grossWTController.clear();
      stoneDescriptionController.clear();
      itemDescriptionController.clear();
      // Optionally reset image state too
      imageFromGallery = null;
      imageFromCamera = null;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Order Form")),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  buildInputCard(
                      "Order Ref*", Icons.account_box, orderRefController,
                      isRequired: true),
                  buildInputCard("Item*", Icons.widgets, itemController,
                      isRequired: true),
                  buildInputCard(
                      "Metal*", Icons.precision_manufacturing, metalController,
                      isRequired: true),
                  buildInputCard("Color*", Icons.palette, colorController,
                      isRequired: true),
                  buildInputCard("Size", Icons.account_tree, sizeController),
                  buildInputCard(
                      "Ref SKU", Icons.account_tree, refSKUController),
                  buildInputCard("C-Ref", Icons.account_tree, cRefController),
                  buildInputCard("Plating", Icons.widgets, platingController),
                  buildInputCard("Rhodium", Icons.where_to_vote_outlined,
                      rhodiumController),
                  buildInputCard(
                      "Findings", Icons.width_full, findingsController),
                  buildInputCard(
                    "Pcs",
                    Icons.numbers,
                    pcsController,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    isRequired: true,
                  ),
                  buildInputCard(
                    "Gross wt",
                    Icons.scale,
                    grossWTController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,3}')),
                    ],
                    isRequired: true,
                  ),

                  buildCommentBox(
                      "Stone description", stoneDescriptionController),
                  buildCommentBox(
                      "Item description", itemDescriptionController),
                  sectionTitle("Images"),
                  buildImagePicker("Image 1", imageFromGallery,
                      () => pickImage(ImageSource.gallery, false)),
                  const SizedBox(height: 16),
                  buildImagePicker("Image 2", imageFromCamera,
                      () => pickImage(ImageSource.gallery, true)),
                  const SizedBox(height: 30),
                  ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        submitForm();
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepPurple,
                      minimumSize: const Size(100, 40),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                    ),
                    child: const Text(
                      'Submit Form',
                      style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.normal,
                          color: Color(0xFFFFFFFF)),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Loader
          if (_isLoading)
            Container(
              color: Colors.black54,
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),
        ],
      ),
    );
  }
  Widget buildInputCard(
      String label,
      IconData icon,
      TextEditingController controller, {
        TextInputType keyboardType = TextInputType.text,
        List<TextInputFormatter>? inputFormatters,
        bool isRequired = false,
      }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 5)],
      ),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        inputFormatters: inputFormatters,
        decoration: InputDecoration(
          icon: Icon(icon, color: Colors.deepPurple),
          labelText: label,
          border: InputBorder.none,
        ),
        validator: isRequired
            ? (value) {
          if (value == null || value.trim().isEmpty) {
            return '$label is required';
          }
          return null;
        }
            : null,
      ),
    );
  }


  Widget buildCommentBox(String label, TextEditingController controller) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 5)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          TextFormField(
            controller: controller,
            maxLines: 5,
            decoration:
                const InputDecoration.collapsed(hintText: "Type here..."),
          ),
        ],
      ),
    );
  }

  Widget buildImagePicker(String label, File? image, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 150,
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 5)],
        ),
        child: image != null
            ? ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.file(image,
                    fit: BoxFit.cover, width: double.infinity),
              )
            : Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.image_outlined, color: Colors.grey, size: 40),
                    const SizedBox(height: 8),
                    Text(label, style: const TextStyle(color: Colors.grey)),
                  ],
                ),
              ),
      ),
    );
  }

  Widget sectionTitle(String title) {
    return Container(
      alignment: Alignment.centerLeft,
      margin: const EdgeInsets.only(top: 24, bottom: 12),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: Colors.deepPurple,
        ),
      ),
    );
  }
}
