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
  final Map<String, dynamic> data; // accept JSON here

  const OrderScreen({Key? key, required this.data}) : super(key: key);

  @override
  _OrderScreenState createState() => _OrderScreenState();
}

class _OrderScreenState extends State<OrderScreen> {
  final _formKey = GlobalKey<FormState>();

  String image1Url = "";
  String image2Url = "";

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();

    if (widget.data.isNotEmpty) {
      initData();
    }

    getAllOptions();
  }

  void initData() {
    final data = widget.data;

    orderRefController.text = data['orderref']?.toString() ?? '';
    sizeController.text = data['size']?.toString() ?? '';
    refSKUController.text = data['refsku']?.toString() ?? '';
    cRefController.text = data['cref']?.toString() ?? '';

    rhodiumController.text = data['rhodium']?.toString() ?? '';
    pcsController.text = data['pcs']?.toString() ?? '';
    grossWTController.text = data['grosswt']?.toString() ?? '';
    stoneDescriptionController.text = data['stonedesc']?.toString() ?? '';
    itemDescriptionController.text = data['itemdesc']?.toString() ?? '';
    enamelColorController.text = data['enamalcolor']?.toString() ?? '';
    image1Url = "${data['image1link']!}" ?? '';
    image2Url = "${data['image2link']!}" ?? '';

    final String? deldateString = data['deldate']?.toString();


    setState(() {
      hasStamp = data['stamp']?.toString(); // null-safe
      stampDateController.text = data['stamp']?.toString() ?? '';
      hasHUid = data['huid'] == "true";
      hasIGI = data['igi'] == "true";
      deliversGold = data['isgold'] == "true";
      deliversStone = data['isstone'] == "true";
      deliversDiamond = data['isdiamond'] == "true";

      deliveryDate = (deldateString != null &&
              deldateString.isNotEmpty &&
              deldateString != '0000-00-00')
          ? DateTime.tryParse(deldateString)
          : null;

      final DateFormat formatter = DateFormat('dd-MM-yyyy');

      if (deliveryDate != null) {
        deliveryDateController.text = formatter.format(deliveryDate!);
      } else {
        deliveryDateController.text = '';
      }
    });

    print("hasStamp ${data['stamp']?.toString()}");

  }

  String? _safeSelect(List<String> list, String? value) {
    if (value == null) return null;
    return list
            .firstWhere(
              (e) => e.trim().toLowerCase() == value.trim().toLowerCase(),
              orElse: () => '',
            )
            .isNotEmpty
        ? value
        : null;
  }

  void getAllOptions() async {
    try {
      String? rawUserData = await Constans().getData(StaticConstant.userData);

      if (rawUserData == null) {
        throw Exception("User data not found in local storage.");
      }

      var formData = {'companyid': 1005}; // or userData['companyid']

      String response = await constans.callApi(
        formData,
        "https://www.digicat.in/webroot/RiteshApi/erp_ordermaster.php",
      );

      final Map<String, dynamic> jsonResponse = jsonDecode(response);
      print("API Response: $formData $jsonResponse");

      if (jsonResponse["response"] == true &&
          jsonResponse["status_code"] == 200) {
        // Extract and assign each list

        setState(() {
          itemList = (jsonResponse["item"] as List)
              .map<String>((item) => item['name'].toString())
              .toList();

          itemMetal = (jsonResponse["metal"] as List)
              .map<String>((item) => item['name'].toString())
              .toList();

          itemColor = (jsonResponse["color"] as List)
              .map<String>((item) => item['name'].toString())
              .toList();

          itemPlating = (jsonResponse["plating"] as List)
              .map<String>((item) => item['name'].toString())
              .toList();

          itemFindings = (jsonResponse["finding"] as List)
              .map<String>((item) => item['name'].toString())
              .toList();
        });

        final data = widget.data;

        final item = data['item']?.toString();
        final metal = data['metal']?.toString();
        final color = data['color']?.toString();
        final findings = data['findings']?.toString();
        final plating = data['plating']?.toString();

        setState(() {
          selectedItem = _safeSelect(itemList, item);
          selectedMetal = _safeSelect(itemMetal, metal);
          selectedColor = _safeSelect(itemColor, color);
          selectedFindings = _safeSelect(itemFindings, findings);
          selectedPlating = _safeSelect(itemPlating, plating);
        });
        // Optionally update UI with setState if in a stateful widget
        // setState(() {});
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Failed to load options")),
        );
      }
    } catch (e) {
      print("Error in getAllOptions: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: ${e.toString()}")),
      );
    }
  }

  Constans constans = Constans();

  final TextEditingController orderRefController = TextEditingController();

  // final TextEditingController itemController = TextEditingController();
  // final TextEditingController metalController = TextEditingController();
  // final TextEditingController colorController = TextEditingController();
  final TextEditingController sizeController = TextEditingController();
  final TextEditingController refSKUController = TextEditingController();
  final TextEditingController cRefController = TextEditingController();

  // final TextEditingController platingController = TextEditingController();
  final TextEditingController rhodiumController = TextEditingController();

  // final TextEditingController findingsController = TextEditingController();
  final TextEditingController pcsController = TextEditingController();
  final TextEditingController grossWTController = TextEditingController();
  final TextEditingController stoneDescriptionController =
      TextEditingController();
  final TextEditingController itemDescriptionController =
      TextEditingController();

  final TextEditingController enamelColorController = TextEditingController();

  File? imageFromGallery = null;
  File? imageFromCamera = null;

  String? selectedItem;
  String? selectedMetal;
  String? selectedColor;
  String? selectedPlating;
  String? selectedFindings;

  List<String> itemList = [];
  List<String> itemMetal = [];
  List<String> itemColor = [];
  List<String> itemPlating = [];
  List<String> itemFindings = [];

  String? hasStamp;
  bool hasHUid = false;
  bool hasIGI = false;
  bool deliversGold = false;
  bool deliversStone = false;
  bool deliversDiamond = false;

  DateTime? deliveryDate;
  final TextEditingController deliveryDateController = TextEditingController();
  final TextEditingController stampDateController = TextEditingController();

  @override
  void dispose() {
    deliveryDateController.dispose();
    super.dispose();
  }

  Future<void> pickImage(ImageSource source, bool fromCamera) async {
    final pickedFile = await ImagePicker().pickImage(source: source);

    if (pickedFile != null) {
      setState(() {
        if (fromCamera) {
          imageFromCamera = File(pickedFile.path);
          image2Url = "";
        } else {
          imageFromGallery = File(pickedFile.path);
          image1Url = "";
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
      "orderref": orderRefController.text,
      "deldate": deliveryDate,
      "stamp": hasStamp,
      "huid": hasHUid,
      "igi": hasIGI,
      "isgold": deliversGold,
      "isstone": deliversStone,
      "isdiamond": deliversDiamond,
      "item": selectedItem,
      "metal": selectedMetal,
      "color": selectedColor,
      "size": sizeController.text,
      "refsku": refSKUController.text,
      "cref": cRefController.text,
      "enamalcolor": enamelColorController.text,
      "rhodium": rhodiumController.text,
      "findings": selectedFindings,
      "plating": selectedPlating,
      "stonedesc": stoneDescriptionController.text,
      "itemdesc": itemDescriptionController.text,
      "image1link": image1Path,
      "image2link": image2Path,
      "vrdate": formattedDate,
      "pcs": pcsController.text == "" ? "0" : pcsController.text,
      "grosswt": grossWTController.text == "" ? "0" : grossWTController.text,
    };

    if (widget.data.containsKey('id') &&
        widget.data['id'].toString().isNotEmpty) {
      formData['id'] = widget.data['id'];
      formData['edit'] = "1";
    } else {
      formData['add'] = "1";
      formData['companyid'] = userData['companyid'];
      formData["clouduserid"] = userData['username'];
      formData["clientname"] = "";
    }

    print('formData Request $formData');

    String response = await constans.callApi(
        formData, "https://www.digicat.in/webroot/RiteshApi/erp_order.php");

    final Map<String, dynamic> jsonResponse = json.decode(response);
    print("API Request : $response , $jsonResponse");

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
    // setState(() {
    //   _isLoading = true;
    // });

    String? userData = await Constans().getData(StaticConstant.userData);

    String image1Path = "";
    String image2Path = "";

    if (imageFromGallery != null) {
      image1Path = await uploadImage(jsonDecode(userData!), imageFromGallery!);
    } else {
      image1Path = image1Url;
    }
    if (imageFromCamera != null) {
      image2Path = await uploadImage(jsonDecode(userData!), imageFromCamera!);
    } else {
      image2Path = image2Url;
    }
    uploadForm(jsonDecode(userData!), image1Path, image2Path);

    setState(() {
      _formKey.currentState!.reset();
      orderRefController.clear();
      // itemController.clear();
      // metalController.clear();
      // colorController.clear();
      sizeController.clear();
      refSKUController.clear();
      cRefController.clear();
      // platingController.clear();
      rhodiumController.clear();
      // findingsController.clear();
      pcsController.clear();
      grossWTController.clear();
      stoneDescriptionController.clear();
      itemDescriptionController.clear();
      deliveryDateController.clear();

      // Optionally reset image state too
      imageFromGallery = null;
      imageFromCamera = null;
      _isLoading = false;
    });

    setState(() {
      selectedItem = null;
      selectedMetal = null;
      selectedColor = null;
      selectedPlating = null;
      selectedFindings = null;
      deliveryDate = null;

      hasStamp = "";
      hasHUid = false;
      hasIGI = false;
      deliversGold = false;
      deliversStone = false;
      deliversDiamond = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final jobno = widget.data['jobno'];

    bool showSubmitBtn = false;
    if (jobno == null || jobno == '0') {
      // Show widget
      showSubmitBtn = true;
    }

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
                  // buildInputCard("Item*", Icons.widgets, itemController,
                  //     isRequired: true),

                  buildDropdownCard<String>(
                    label: 'Item*',
                    icon: Icons.person,
                    selectedValue: selectedItem,
                    items: itemList,
                    onChanged: (value) {
                      setState(() {
                        selectedItem = value;
                      });
                    },
                    isRequired: true,
                  ),

                  buildDropdownCard<String>(
                    label: 'Metal*',
                    icon: Icons.precision_manufacturing,
                    selectedValue: selectedMetal,
                    items: itemMetal,
                    onChanged: (value) {
                      setState(() {
                        selectedMetal = value;
                      });
                    },
                    isRequired: true,
                  ),
                  // buildInputCard(
                  //     "Metal*", Icons.precision_manufacturing, metalController,
                  //     isRequired: true),
                  // buildInputCard("Color*", Icons.palette, colorController,
                  //     isRequired: true),

                  buildDropdownCard<String>(
                    label: 'Color*',
                    icon: Icons.precision_manufacturing,
                    selectedValue: selectedColor,
                    items: itemColor,
                    onChanged: (value) {
                      setState(() {
                        selectedColor = value;
                      });
                    },
                    isRequired: true,
                  ),
                  buildInputCard("Size", Icons.account_tree, sizeController),
                  buildInputCard(
                      "Ref SKU", Icons.account_tree, refSKUController),
                  buildInputCard("C-Ref", Icons.account_tree, cRefController),
                  buildDropdownCard<String>(
                    label: 'Plating',
                    icon: Icons.widgets,
                    selectedValue: selectedPlating,
                    items: itemPlating,
                    onChanged: (value) {
                      setState(() {
                        selectedPlating = value;
                      });
                    },
                    isRequired: false,
                  ),
                  // buildInputCard("Plating", Icons.widgets, platingController),
                  buildInputCard("Enamal", Icons.where_to_vote_outlined,
                      enamelColorController),
                  buildDropdownCard<String>(
                    label: 'Findings',
                    icon: Icons.widgets,
                    selectedValue: selectedFindings,
                    items: itemFindings,
                    onChanged: (value) {
                      setState(() {
                        selectedFindings = value;
                      });
                    },
                    isRequired: false,
                  ),
                  // buildInputCard(
                  //     "Findings", Icons.width_full, findingsController),
                  buildInputCard(
                    "Pcs",
                    Icons.numbers,
                    pcsController,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    isRequired: false,
                  ),
                  buildInputCard(
                    "Gross wt",
                    Icons.scale,
                    grossWTController,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(
                          RegExp(r'^\d+\.?\d{0,3}')),
                    ],
                    isRequired: false,
                  ),
                  buildCommentBox(
                      "Stone description", stoneDescriptionController),
                  buildCommentBox(
                      "Item description", itemDescriptionController),
                  sectionTitle("Images"),
                  buildImagePicker("Image 1", imageFromGallery,
                      () => pickImage(ImageSource.gallery, false), image1Url),
                  const SizedBox(height: 16),
                  buildImagePicker("Image 2", imageFromCamera,
                      () => pickImage(ImageSource.gallery, true), image2Url),
                  const SizedBox(height: 30),

                  TextFormField(
                    controller: deliveryDateController,
                    readOnly: true,
                    decoration: const InputDecoration(
                      labelText: 'Delivery Date',
                      suffixIcon: Icon(Icons.calendar_today),
                    ),
                    onTap: () async {
                      FocusScope.of(context)
                          .requestFocus(FocusNode()); // Close keyboard

                      DateTime? pickedDate = await showDatePicker(
                        context: context,
                        initialDate: deliveryDate ?? DateTime.now(),
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2100),
                      );

                      if (pickedDate != null) {
                        setState(() {
                          deliveryDate = pickedDate;
                          deliveryDateController.text =
                              "${pickedDate.day.toString().padLeft(2, '0')}-${pickedDate.month.toString().padLeft(2, '0')}-${pickedDate.year}";
                        });
                      }
                    },
                  ),
                  TextFormField(
                    controller: stampDateController,

                    decoration: const InputDecoration(labelText: 'Stamp'),
                    onChanged: (value) {
                      setState(() {
                        hasStamp = value;
                      });
                    },
                  ),
                  SwitchListTile(
                    title: const Text('HUID'),
                    value: hasHUid,
                    onChanged: (value) {
                      setState(() {
                        hasHUid = value;
                      });
                    },
                  ),
                  SwitchListTile(
                    title: const Text('IGI'),
                    value: hasIGI,
                    onChanged: (value) {
                      setState(() {
                        hasIGI = value;
                      });
                    },
                  ),

                  SwitchListTile(
                    title: const Text('We Deliver Gold'),
                    value: deliversGold,
                    onChanged: (value) {
                      setState(() {
                        deliversGold = value;
                      });
                    },
                  ),

                  SwitchListTile(
                    title: const Text('We Deliver Stone'),
                    value: deliversStone,
                    onChanged: (value) {
                      setState(() {
                        deliversStone = value;
                      });
                    },
                  ),

                  SwitchListTile(
                    title: const Text('We Deliver Diamond'),
                    value: deliversDiamond,
                    onChanged: (value) {
                      setState(() {
                        deliversDiamond = value;
                      });
                    },
                  ),

                  Visibility(
                    visible: showSubmitBtn,
                    child: ElevatedButton(
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          print("Click");

                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: const Text("Confirm Submit"),
                                content: const Text(
                                    "Are you sure you want to submit this order?"),
                                actions: [
                                  TextButton(
                                    child: const Text("Cancel"),
                                    onPressed: () {
                                      Navigator.of(context)
                                          .pop(); // Close the dialog
                                    },
                                  ),
                                  TextButton(
                                    child: const Text("Submit",
                                        style: TextStyle(
                                            color: Colors.deepPurple)),
                                    onPressed: () {
                                      submitForm(); // Call your function after closing
                                      Navigator.of(context)
                                          .pop(); // Close the dialog
                                    },
                                  ),
                                ],
                              );
                            },
                          );
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
                          color: Color(0xFFFFFFFF),
                        ),
                      ),
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

  Widget buildDropdownCard<T>({
    required String label,
    required IconData icon,
    required T? selectedValue,
    required List<T> items,
    required void Function(T?) onChanged,
    bool isRequired = false,
    String? Function(T?)? validator,
    String Function(T)? itemToString,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 5)],
      ),
      child: DropdownButtonFormField<T>(
        value: selectedValue,
        isExpanded: true,
        icon: const Icon(Icons.arrow_drop_down),
        decoration: InputDecoration(
          icon: Icon(icon, color: Colors.deepPurple),
          labelText: label,
          border: InputBorder.none,
        ),
        validator: isRequired
            ? (value) {
                if (value == null) {
                  return '$label is required';
                }
                return null;
              }
            : validator,
        onChanged: onChanged,
        items: items.map((T value) {
          return DropdownMenuItem<T>(
            value: value,
            child: Text(
                itemToString != null ? itemToString(value) : value.toString()),
          );
        }).toList(),
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

  Widget buildImagePicker(
      String label, File? image, VoidCallback onTap, String url) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 150,
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 5)],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: url.isNotEmpty
              ? Image.network(
                  "https://digicat.in/webroot/RiteshApi/$url",
                  fit: BoxFit.cover,
                  width: double.infinity,
                  errorBuilder: (context, error, stackTrace) =>
                      _buildPlaceholder(label),
                )
              : image != null
                  ? Image.file(
                      image,
                      fit: BoxFit.cover,
                      width: double.infinity,
                    )
                  : _buildPlaceholder(label),
        ),
      ),
    );
  }

  Widget _buildPlaceholder(String label) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.image_outlined, color: Colors.grey, size: 40),
          const SizedBox(height: 8),
          Text(label, style: const TextStyle(color: Colors.grey)),
        ],
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
