import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http_parser/http_parser.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_sound/flutter_sound.dart';
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
  bool isRecording = false;
  bool isPlaying = false;
  String? voiceNotePath;

  FlutterSoundRecorder recorder = FlutterSoundRecorder();
  FlutterSoundPlayer player = FlutterSoundPlayer();

  @override
  void initState() {
    super.initState();
    initPlayer(); // already opens player
    initRecorder(); // already opens recorder
    if (widget.data.isNotEmpty) {
      initData();
    }
    getAllOptions();
  }

  Future<void> initPlayer() async {
    await player.openPlayer();
  }

  Future<void> initRecorder() async {
    await recorder.openRecorder();
  }

  // Future<void> playVoiceNote() async {
  //   if (voiceNotePath == null) return;

  //   if (player.isOpen == true) {
  //     await player.openPlayer(); // ensure player is open
  //   }

  //   if (!isPlaying) {
  //     await player.startPlayer(
  //       fromURI: voiceNotePath,
  //       codec: Codec.aacMP4,
  //       whenFinished: () {
  //         setState(() => isPlaying = false);
  //       },
  //     );
  //     setState(() => isPlaying = true);
  //   } else {
  //     await player.stopPlayer();
  //     setState(() => isPlaying = false);
  //   }
  // }
  Future<void> playVoiceNote() async {
    if (voiceNotePath == null) return;

    // Open player if not already open
    bool isPlayerOpen = await player.isOpen(); // await the Future
    if (!isPlayerOpen) {
      await player.openPlayer();
    }

    if (!isPlaying) {
      await player.startPlayer(
        fromURI: voiceNotePath,
        codec: Codec.aacMP4,
        whenFinished: () {
          setState(() => isPlaying = false);
        },
      );
      setState(() => isPlaying = true);
    } else {
      await player.stopPlayer();
      setState(() => isPlaying = false);
    }
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

  Future<String> getVoiceNotePath() async {
    final directory = await getApplicationDocumentsDirectory();
    final path =
        '${directory.path}/voice_note_${DateTime.now().millisecondsSinceEpoch}.aac';
    return path;
  }

  // Future<void> playVoiceNote() async {
  //   if (voiceNotePath == null) return;

  //   if (!isPlaying) {
  //     await player.startPlayer(
  //       fromURI: voiceNotePath,
  //       codec: Codec.aacMP4,
  //       whenFinished: () {
  //         setState(() => isPlaying = false);
  //       },
  //     );
  //     setState(() => isPlaying = true);
  //   } else {
  //     await player.stopPlayer();
  //     setState(() => isPlaying = false);
  //   }
  // }

  // Future<void> recordVoiceNote() async {
  //   // Request microphone permission
  //   var micStatus = await Permission.microphone.request();
  //   if (!micStatus.isGranted) return;

  //   if (!isRecording) {
  //     // Start recording
  //     await recorder.openRecorder();
  //     voiceNotePath = await getVoiceNotePath(); // safe path
  //     await recorder.startRecorder(toFile: voiceNotePath);
  //     isRecording = true;
  //   } else {
  //     // Stop recording
  //     await recorder.stopRecorder();
  //     isRecording = false;
  //     setState(() {}); // update UI to show recorded file
  //   }
  // }

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
    recorder.closeRecorder();
    player.closePlayer();
    deliveryDateController.dispose();
    super.dispose();
  }

  Future<void> recordVoiceNote() async {
    var status = await Permission.microphone.request();
    if (!status.isGranted) return;

    if (!isRecording) {
      final dir = await getApplicationDocumentsDirectory();
      voiceNotePath =
          '${dir.path}/voice_note_${DateTime.now().millisecondsSinceEpoch}.aac';

      await recorder.startRecorder(toFile: voiceNotePath, codec: Codec.aacMP4);
      setState(() => isRecording = true);
    } else {
      await recorder.stopRecorder();
      setState(() => isRecording = false);
    }
  }

  Widget buildVoiceNotePicker(
    String label,
    String? recordedFilePath,
    bool isRecording,
    bool isPlaying,
    VoidCallback onRecordPressed,
    VoidCallback onPlayPressed,
  ) {
    String displayText;

    if (isRecording) {
      displayText = "Recording...";
    } else if (recordedFilePath != null) {
      displayText = recordedFilePath.split('/').last; // show file name
    } else {
      displayText = "No voice note yet";
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 5)],
      ),
      child: Row(
        children: [
          Icon(Icons.mic, color: Colors.deepPurple),
          const SizedBox(width: 12),
          Expanded(child: Text(displayText)),
          IconButton(
            icon: Icon(isRecording ? Icons.stop : Icons.fiber_manual_record,
                color: Colors.deepPurple),
            onPressed: onRecordPressed,
          ),
          if (!isRecording && recordedFilePath != null)
            IconButton(
              icon: Icon(isPlaying ? Icons.stop : Icons.play_arrow,
                  color: Colors.deepPurple),
              onPressed: onPlayPressed,
            ),
        ],
      ),
    );
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

// ---------------------- UPLOAD VOICE NOTE ----------------------
  // Future<String> uploadVoiceNote(
  //     Map<String, dynamic> userData, File voiceFile) async {
  //   var request = http.MultipartRequest(
  //     'POST',
  //     Uri.parse('https://www.digicat.in/webroot/RiteshApi/erp_orderimage.php'),
  //   );

  //   request.fields['companyid'] = userData['companyid'];

  //   request.files.add(
  //     await http.MultipartFile.fromPath(
  //       'vnotelink', // backend expects this field
  //       voiceFile.path,
  //       contentType: MediaType('audio', 'aac'),
  //     ),
  //   );

  //   var response = await request.send();

  //   if (response.statusCode == 200) {
  //     final responseBody = await response.stream.bytesToString();
  //     final decodedJson = json.decode(responseBody);

  //     // If backend returns path, use it
  //     String uploadedPath = decodedJson["file"] ?? "";

  //     // If backend does not return path, construct relative path manually
  //     if (uploadedPath.isEmpty) {
  //       uploadedPath = "uploads/erp/${userData['companyid']}/order/" +
  //           voiceFile.path.split('/').last;
  //     }

  //     print("Voice note uploaded to: $uploadedPath");
  //     return uploadedPath;
  //   } else {
  //     print("Voice note upload failed: ${response.statusCode}");
  //     return "";
  //   }
  // }
  // Future<String> uploadVoiceNote(
  //     Map<String, dynamic> userData, File voiceFile) async {
  //   var request = http.MultipartRequest(
  //     'POST',
  //     Uri.parse('https://www.digicat.in/webroot/RiteshApi/erp_orderaudio.php'),
  //   );

  //   // Add company ID field
  //   request.fields['companyid'] = userData['companyid'];

  //   // Attach the voice note file
  //   request.files.add(
  //     await http.MultipartFile.fromPath(
  //       'vnotelink', // name of the field in backend
  //       voiceFile.path,
  //       contentType: MediaType('audio', 'aac'), // optional but recommended
  //     ),
  //   );

  //   // Send request
  //   var response = await request.send();

  //   if (response.statusCode == 200) {
  //     print(
  //         "====================================================Success ho gya bhai${response.s}");
  //     final responseBody = await response.stream.bytesToString();
  //     final decodedJson = json.decode(responseBody);

  //     // Return file path from backend if provided, else empty string
  //     return decodedJson["file"] ?? "";
  //   } else {
  //     print("Voice note upload failed: ${response.statusCode}");
  //     return "";
  //   }
  // }
  // Future<String> uploadVoiceNote(
  //     Map<String, dynamic> userData, File voiceFile) async {
  //   try {
  //     // Create multipart request (same endpoint as images)
  //     var request = http.MultipartRequest(
  //       'POST',
  //       Uri.parse(
  //           'https://www.digicat.in/webroot/RiteshApi/erp_orderimage.php'),
  //     );

  //     // Add company ID field
  //     request.fields['companyid'] = userData['companyid'];

  //     // Attach voice note file
  //     request.files.add(await http.MultipartFile.fromPath(
  //       'vnotelink', // use 'image' like image upload, backend may be expecting this
  //       voiceFile.path,
  //       contentType: MediaType('audio', 'aac'), // specify audio type
  //     ));

  //     // Debug info
  //     print("Preparing to upload voice note:");
  //     print("File path: ${voiceFile.path}");
  //     print("File size: ${await voiceFile.length()} bytes");
  //     print("MultipartFile prepared: ${voiceFile.path.split('/').last}");
  //     print("Request fields: ${request.fields}");
  //     print("Number of files attached: ${request.files.length}");

  //     // Send request
  //     var response = await request.send();
  //     final responseBody = await response.stream.bytesToString();

  //     print("Response status: ${response.statusCode}");
  //     print("Raw response body: $responseBody");

  //     final decodedJson = json.decode(responseBody);
  //     print("Decoded JSON: $decodedJson");

  //     // Return file path from backend if provided, else construct manually
  //     String uploadedPath = decodedJson["file"] ?? "";
  //     if (uploadedPath.isEmpty) {
  //       uploadedPath = "uploads/erp/${userData['companyid']}/order/" +
  //           voiceFile.path.split('/').last;
  //       print("Voice note path constructed manually: $uploadedPath");
  //     }

  //     return uploadedPath;
  //   } catch (e) {
  //     print("Voice note upload exception: $e");
  //     return "";
  //   }
  // }
  Future<String> uploadVoiceNote(
      Map<String, dynamic> userData, File voiceFile) async {
    try {
      // Correct endpoint for audio upload
      var request = http.MultipartRequest(
        'POST',
        Uri.parse(
            'https://www.digicat.in/webroot/RiteshApi/erp_orderaudio.php'),
      );

      // Add fields (must include companyid and fileName)
      request.fields['companyid'] = userData['companyid'].toString();
      request.fields['fileName'] = voiceFile.path.split('/').last;

      // Attach the voice note file — use key "audio"
      request.files.add(await http.MultipartFile.fromPath(
        'audio',
        voiceFile.path,
        contentType: MediaType('audio', 'mpeg'), // works for mp3, m4a, aac
      ));

      print("🎤 Uploading voice note...");
      print("File path: ${voiceFile.path}");
      print("Company ID: ${userData['companyid']}");
      print("Request fields: ${request.fields}");

      // Send the request
      var response = await request.send();
      final responseBody = await response.stream.bytesToString();

      print("Response status: ${response.statusCode}");
      print("Raw response body: $responseBody");

      if (response.statusCode == 200) {
        final decoded = json.decode(responseBody);

        if (decoded["success"] == true) {
          print("✅ Voice upload success: ${decoded['file']}");
          return decoded["file"];
        } else {
          print("⚠️ Upload failed: ${decoded['message']}");
          return "";
        }
      } else {
        print("❌ Server error: ${response.statusCode}");
        return "";
      }
    } catch (e) {
      print("Voice note upload exception: $e");
      return "";
    }
  }

// ---------------------- UPLOAD FORM ----------------------
  Future<void> uploadForm(
    Map<String, dynamic> userData,
    String image1Path,
    String image2Path, [
    String? voiceNotePath,
  ]) async {
    final now = DateTime.now();
    final formattedDate = DateFormat('yyyy-MM-dd HH:mm').format(now);

    var formData = {
      "orderref": orderRefController.text,
      "deldate": deliveryDate ?? "",
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
      "vnotelink": voiceNotePath ?? "",
      "vrdate": formattedDate,
      "pcs": pcsController.text.isEmpty ? "1" : pcsController.text,
      "grosswt": grossWTController.text.isEmpty ? "0" : grossWTController.text,
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

// ---------------------- SUBMIT FORM ----------------------
  void submitForm() async {
    setState(() {
      _isLoading = true;
    });

    String? userDataStr = await Constans().getData(StaticConstant.userData);
    final userData = jsonDecode(userDataStr!);

    String image1Path = "";
    String image2Path = "";
    String voicePath = "";

    if (imageFromGallery != null) {
      image1Path = await uploadImage(userData, imageFromGallery!);
    } else {
      image1Path = image1Url;
    }

    if (imageFromCamera != null) {
      image2Path = await uploadImage(userData, imageFromCamera!);
    } else {
      image2Path = image2Url;
    }

    // Upload voice note if it exists
    if (voiceNotePath != null && File(voiceNotePath!).existsSync()) {
      File voiceFile = File(voiceNotePath!);
      voicePath = await uploadVoiceNote(userData, voiceFile);
    }

    await uploadForm(userData, image1Path, image2Path, voicePath);

    // Reset form
    _formKey.currentState!.reset();
    orderRefController.clear();
    sizeController.clear();
    refSKUController.clear();
    cRefController.clear();
    rhodiumController.clear();
    pcsController.clear();
    grossWTController.clear();
    stoneDescriptionController.clear();
    itemDescriptionController.clear();
    deliveryDateController.clear();
    enamelColorController.clear();

    imageFromGallery = null;
    imageFromCamera = null;
    voiceNotePath = null;

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

      _isLoading = false;
    });
  }

  // Future<String> uploadVoiceNote(
  //     Map<String, dynamic> userData, File voiceFile) async {
  //   var request = http.MultipartRequest(
  //     'POST',
  //     Uri.parse('https://www.digicat.in/webroot/RiteshApi/erp_orderimage.php'),
  //   );

  //   // Add company ID field
  //   request.fields['companyid'] = userData['companyid'];

  //   // Attach voice note file
  //   request.files.add(
  //     await http.MultipartFile.fromPath(
  //       'vnotelink', // backend expects this field
  //       voiceFile.path,
  //       contentType: MediaType('audio', 'aac'), // optional but recommended
  //     ),
  //   );

  //   var response = await request.send();

  //   if (response.statusCode == 200) {
  //     print(
  //         "====================================================Success ho gya bhai");
  //     print(voiceFile.path);
  //     final responseBody = await response.stream.bytesToString();
  //     final decodedJson = json.decode(responseBody);

  //     // Backend should return uploaded file path
  //     return decodedJson["file"] ?? "";
  //   } else {
  //     print("Voice note upload failed: ${response.statusCode}");
  //     return "";
  //   }
  // }

  // Future<void> uploadForm(
  //     Map<String, dynamic> userData, String image1Path, String image2Path,
  //     [String? voiceNotePath]) async {
  //   final now = DateTime.now();
  //   final formattedDate = DateFormat('yyyy-MM-dd HH:mm').format(now);

  //   var formData = {
  //     "orderref": orderRefController.text,
  //     "deldate": deliveryDate, // make sure deliveryDate is not null
  //     "stamp": hasStamp,
  //     "huid": hasHUid,
  //     "igi": hasIGI,
  //     "isgold": deliversGold,
  //     "isstone": deliversStone,
  //     "isdiamond": deliversDiamond,
  //     "item": selectedItem,
  //     "metal": selectedMetal,
  //     "color": selectedColor,
  //     "size": sizeController.text,
  //     "refsku": refSKUController.text,
  //     "cref": cRefController.text,
  //     "enamalcolor": enamelColorController.text,
  //     "rhodium": rhodiumController.text,
  //     "findings": selectedFindings,
  //     "plating": selectedPlating,
  //     "stonedesc": stoneDescriptionController.text,
  //     "itemdesc": itemDescriptionController.text,
  //     "image1link": image1Path,
  //     "image2link": image2Path,
  //     "vnotelink": voiceNotePath ?? "",
  //     "vrdate": formattedDate,
  //     "pcs": pcsController.text.isEmpty ? "1" : pcsController.text,
  //     "grosswt": grossWTController.text.isEmpty ? "0" : grossWTController.text,
  //   };

  //   // Include voice note only if it exists
  //   // if (voiceNotePath != null && voiceNotePath.isNotEmpty) {
  //   //   formData["vnotelink"] = voiceNotePath;
  //   // }

  //   if (widget.data.containsKey('id') &&
  //       widget.data['id'].toString().isNotEmpty) {
  //     formData['id'] = widget.data['id'];
  //     formData['edit'] = "1";
  //   } else {
  //     formData['add'] = "1";
  //     formData['companyid'] = userData['companyid'];
  //     formData["clouduserid"] = userData['username'];
  //     formData["clientname"] = "";
  //   }

  //   print('formData Request $formData');

  //   String response = await constans.callApi(
  //       formData, "https://www.digicat.in/webroot/RiteshApi/erp_order.php");

  //   final Map<String, dynamic> jsonResponse = json.decode(response);
  //   print("API Request : $response , $jsonResponse");

  //   if (jsonResponse["response"] == true &&
  //       jsonResponse["status_code"] == 200 &&
  //       jsonResponse["data"]?["new_id"] != 0) {
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       const SnackBar(content: Text("Order Form Submitted Successfully")),
  //     );
  //   } else {
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       const SnackBar(content: Text("Order Submission Failed")),
  //     );
  //   }
  // }

  // void submitForm() async {
  //   setState(() {
  //     _isLoading = true;
  //   });

  //   String? userDataStr = await Constans().getData(StaticConstant.userData);
  //   final userData = jsonDecode(userDataStr!);

  //   String image1Path = "";
  //   String image2Path = "";
  //   String voicePath = "";

  //   if (imageFromGallery != null) {
  //     image1Path = await uploadImage(userData, imageFromGallery!);
  //   } else {
  //     image1Path = image1Url;
  //   }

  //   if (imageFromCamera != null) {
  //     image2Path = await uploadImage(userData, imageFromCamera!);
  //   } else {
  //     image2Path = image2Url;
  //   }

  //   // Upload voice note if it exists
  //   if (voiceNotePath != null && File(voiceNotePath!).existsSync()) {
  //     File voiceFile = File(voiceNotePath!);
  //     voicePath = await uploadVoiceNote(userData, voiceFile);
  //   }

  //   await uploadForm(userData, image1Path, image2Path, voicePath);

  //   // Reset form
  //   _formKey.currentState!.reset();
  //   orderRefController.clear();
  //   sizeController.clear();
  //   refSKUController.clear();
  //   cRefController.clear();
  //   rhodiumController.clear();
  //   pcsController.clear();
  //   grossWTController.clear();
  //   stoneDescriptionController.clear();
  //   itemDescriptionController.clear();
  //   deliveryDateController.clear();
  //   enamelColorController.clear();

  //   imageFromGallery = null;
  //   imageFromCamera = null;
  //   voiceNotePath = null;

  //   setState(() {
  //     selectedItem = null;
  //     selectedMetal = null;
  //     selectedColor = null;
  //     selectedPlating = null;
  //     selectedFindings = null;
  //     deliveryDate = null;

  //     hasStamp = "";
  //     hasHUid = false;
  //     hasIGI = false;
  //     deliversGold = false;
  //     deliversStone = false;
  //     deliversDiamond = false;

  //     _isLoading = false;
  //   });
  // }

  // Future<void> uploadForm(Map<String, dynamic> userData, String image1Path,
  //     String image2Path) async {
  //   final now = DateTime.now();
  //   final formattedDate = DateFormat('yyyy-MM-dd HH:mm').format(now);
  //   var formData = {
  //     "orderref": orderRefController.text,
  //     "deldate": deliveryDate,
  //     "stamp": hasStamp,
  //     "huid": hasHUid,
  //     "igi": hasIGI,
  //     "isgold": deliversGold,
  //     "isstone": deliversStone,
  //     "isdiamond": deliversDiamond,
  //     "item": selectedItem,
  //     "metal": selectedMetal,
  //     "color": selectedColor,
  //     "size": sizeController.text,
  //     "refsku": refSKUController.text,
  //     "cref": cRefController.text,
  //     "enamalcolor": enamelColorController.text,
  //     "rhodium": rhodiumController.text,
  //     "findings": selectedFindings,
  //     "plating": selectedPlating,
  //     "stonedesc": stoneDescriptionController.text,
  //     "itemdesc": itemDescriptionController.text,
  //     "image1link": image1Path,
  //     "image2link": image2Path,
  //     "vrdate": formattedDate,
  //     "pcs": pcsController.text == "" ? "1" : pcsController.text,
  //     "grosswt": grossWTController.text == "" ? "0" : grossWTController.text,
  //   };

  //   if (widget.data.containsKey('id') &&
  //       widget.data['id'].toString().isNotEmpty) {
  //     formData['id'] = widget.data['id'];
  //     formData['edit'] = "1";
  //   } else {
  //     formData['add'] = "1";
  //     formData['companyid'] = userData['companyid'];
  //     formData["clouduserid"] = userData['username'];
  //     formData["clientname"] = "";
  //   }

  //   print('formData Request $formData');

  //   String response = await constans.callApi(
  //       formData, "https://www.digicat.in/webroot/RiteshApi/erp_order.php");

  //   final Map<String, dynamic> jsonResponse = json.decode(response);
  //   print("API Request : $response , $jsonResponse");

  //   if (jsonResponse["response"] == true &&
  //       jsonResponse["status_code"] == 200 &&
  //       jsonResponse["data"]?["new_id"] != 0) {
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       const SnackBar(content: Text("Order Form Submitted Successfully")),
  //     );
  //   } else {
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       const SnackBar(content: Text("Order Submission Failed")),
  //     );
  //   }
  // }

  // void submitForm() async {
  //   // setState(() {
  //   //   _isLoading = true;
  //   // });

  //   String? userData = await Constans().getData(StaticConstant.userData);

  //   String image1Path = "";
  //   String image2Path = "";

  //   if (imageFromGallery != null) {
  //     image1Path = await uploadImage(jsonDecode(userData!), imageFromGallery!);
  //   } else {
  //     image1Path = image1Url;
  //   }
  //   if (imageFromCamera != null) {
  //     image2Path = await uploadImage(jsonDecode(userData!), imageFromCamera!);
  //   } else {
  //     image2Path = image2Url;
  //   }
  //   uploadForm(jsonDecode(userData!), image1Path, image2Path);

  //   setState(() {
  //     _formKey.currentState!.reset();
  //     orderRefController.clear();
  //     // itemController.clear();
  //     // metalController.clear();
  //     // colorController.clear();
  //     sizeController.clear();
  //     refSKUController.clear();
  //     cRefController.clear();
  //     // platingController.clear();
  //     rhodiumController.clear();
  //     // findingsController.clear();
  //     pcsController.clear();
  //     grossWTController.clear();
  //     stoneDescriptionController.clear();
  //     itemDescriptionController.clear();
  //     deliveryDateController.clear();

  //     // Optionally reset image state too
  //     imageFromGallery = null;
  //     imageFromCamera = null;
  //     _isLoading = false;
  //   });

  //   setState(() {
  //     selectedItem = null;
  //     selectedMetal = null;
  //     selectedColor = null;
  //     selectedPlating = null;
  //     selectedFindings = null;
  //     deliveryDate = null;

  //     hasStamp = "";
  //     hasHUid = false;
  //     hasIGI = false;
  //     deliversGold = false;
  //     deliversStone = false;
  //     deliversDiamond = false;
  //   });
  // }

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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: buildInputCard(
                          "Pcs",
                          Icons.numbers,
                          pcsController,
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly
                          ],
                          isRequired: false,
                        ),
                      ),
                      SizedBox(
                        width: 20,
                      ),
                      Expanded(
                        child: buildInputCard(
                          "Gross wt",
                          Icons.scale,
                          grossWTController,
                          keyboardType: const TextInputType.numberWithOptions(
                              decimal: true),
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(
                                RegExp(r'^\d+\.?\d{0,3}')),
                          ],
                          isRequired: false,
                        ),
                      ),
                    ],
                  ),
                  buildCommentBox(
                      "Stone description", stoneDescriptionController),
                  buildCommentBox(
                      "Item description", itemDescriptionController),
                  sectionTitle("Images"),
                  // buildImagePicker("Image 1", imageFromGallery,
                  //     () => pickImage(ImageSource.gallery, false), image1Url),
                  // const SizedBox(height: 16),
                  // buildImagePicker("Image 2", imageFromCamera,
                  //     () => pickImage(ImageSource.gallery, true), image2Url),
                  // const SizedBox(height: 30),
                  buildImagePicker("Image 1", imageFromGallery,
                      () => pickImage(ImageSource.gallery, false), image1Url),
                  const SizedBox(height: 16),
                  buildImagePicker("Image 2", imageFromCamera,
                      () => pickImage(ImageSource.gallery, true), image2Url),
                  const SizedBox(height: 16),
                  // buildVoiceNotePicker("Voice Note",
                  //     voiceNotePath, // String? variable to store recorded file path
                  //     () async {
                  //   await recordVoiceNote(); // function to handle recording
                  // }),
                  buildVoiceNotePicker(
                    "Voice Note",
                    voiceNotePath,
                    isRecording,
                    isPlaying,
                    () async => await recordVoiceNote(),
                    () async => await playVoiceNote(),
                  ),

                  const SizedBox(height: 30),

                  buildDateInputCard(
                    'Delivery Date',
                    deliveryDateController,
                    context,
                    initialDate: deliveryDate,
                    isRequired: true,
                  ),

                  buildInputCard(
                    'Stamp',
                    Icons.tab, // or any relevant icon
                    stampDateController,
                    keyboardType: TextInputType.text,
                    isRequired: false,
                  ),

                  // TextFormField(
                  //   controller: deliveryDateController,
                  //   readOnly: true,
                  //   decoration: const InputDecoration(
                  //     labelText: 'Delivery Date',
                  //     suffixIcon: Icon(Icons.calendar_today),
                  //   ),
                  //   onTap: () async {
                  //     FocusScope.of(context)
                  //         .requestFocus(FocusNode()); // Close keyboard

                  //     DateTime? pickedDate = await showDatePicker(
                  //       context: context,
                  //       initialDate: deliveryDate ?? DateTime.now(),
                  //       firstDate: DateTime(2000),
                  //       lastDate: DateTime(2100),
                  //     );

                  //     if (pickedDate != null) {
                  //       setState(() {
                  //         deliveryDate = pickedDate;
                  //         deliveryDateController.text =
                  //             "${pickedDate.day.toString().padLeft(2, '0')}-${pickedDate.month.toString().padLeft(2, '0')}-${pickedDate.year}";
                  //       });
                  //     }
                  //   },
                  // ),
                  // TextFormField(
                  //   controller: stampDateController,
                  //   decoration: const InputDecoration(labelText: 'Stamp'),
                  //   onChanged: (value) {
                  //     setState(() {
                  //       hasStamp = value;
                  //     });
                  //   },
                  // ),
                  SwitchListTile(
                    title: const Text('HUID?'),
                    value: hasHUid,
                    onChanged: (value) {
                      setState(() {
                        hasHUid = value;
                      });
                    },
                  ),
                  SwitchListTile(
                    title: const Text('IGI?'),
                    value: hasIGI,
                    onChanged: (value) {
                      setState(() {
                        hasIGI = value;
                      });
                    },
                  ),

                  SwitchListTile(
                    title: const Text('We Deliver Gold?'),
                    value: deliversGold,
                    onChanged: (value) {
                      setState(() {
                        deliversGold = value;
                      });
                    },
                  ),

                  SwitchListTile(
                    title: const Text('We Deliver Stone?'),
                    value: deliversStone,
                    onChanged: (value) {
                      setState(() {
                        deliversStone = value;
                      });
                    },
                  ),

                  SwitchListTile(
                    title: const Text('We Deliver Diamond?'),
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
    IconData? icon,
    TextEditingController controller, {
    TextInputType keyboardType = TextInputType.text,
    List<TextInputFormatter>? inputFormatters,
    bool isRequired = false,
  }) {
    pcsController.text = "1"; // set initial value
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

  Widget buildDateInputCard(
    String label,
    TextEditingController controller,
    BuildContext context, {
    DateTime? initialDate,
    DateTime? firstDate,
    DateTime? lastDate,
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
        readOnly: true,
        decoration: InputDecoration(
          labelText: label,
          border: InputBorder.none,
          suffixIcon: const Icon(Icons.calendar_today),
        ),
        onTap: () async {
          FocusScope.of(context).requestFocus(FocusNode()); // Close keyboard
          DateTime? pickedDate = await showDatePicker(
            context: context,
            initialDate: initialDate ?? DateTime.now(),
            firstDate: firstDate ?? DateTime(2000),
            lastDate: lastDate ?? DateTime(2100),
          );

          if (pickedDate != null) {
            controller.text =
                "${pickedDate.day.toString().padLeft(2, '0')}-${pickedDate.month.toString().padLeft(2, '0')}-${pickedDate.year}";
          }
        },
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
            maxLines: 3,
            decoration:
                const InputDecoration.collapsed(hintText: "Type here..."),
          ),
        ],
      ),
    );
  }

  // Widget buildVoiceNotePicker(
  //     String label, String? recordedFilePath, VoidCallback onRecordPressed,
  //     {bool isRecorded = false}) {
  //   return Container(
  //     margin: const EdgeInsets.only(bottom: 16),
  //     padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
  //     decoration: BoxDecoration(
  //       color: Colors.white,
  //       borderRadius: BorderRadius.circular(12),
  //       boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 5)],
  //     ),
  //     child: Row(
  //       children: [
  //         Icon(Icons.mic, color: Colors.deepPurple),
  //         const SizedBox(width: 12),
  //         Expanded(
  //           child: Text(recordedFilePath != null
  //               ? "Voice note recorded"
  //               : "No voice note yet"),
  //         ),
  //         IconButton(
  //           icon: Icon(
  //               isRecorded ? Icons.play_arrow : Icons.fiber_manual_record,
  //               color: Colors.deepPurple),
  //           onPressed: onRecordPressed,
  //         ),
  //       ],
  //     ),
  //   );
  // }

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
