import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class OrderScreen extends StatefulWidget {
  @override
  _OrderScreenState createState() => _OrderScreenState();
}

class _OrderScreenState extends State<OrderScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController itemController = TextEditingController();
  final TextEditingController metalController = TextEditingController();
  final TextEditingController colorController = TextEditingController();
  final TextEditingController enamelColorController = TextEditingController();
  final TextEditingController rhodiumController = TextEditingController();
  final TextEditingController findingsController = TextEditingController();

  File? imageFromGallery;
  File? imageFromCamera;

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F6),
      appBar: AppBar(
        title: Text('Create Order'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              buildInputCard("Order Ref", Icons.account_box, itemController),
              buildInputCard("Plating", Icons.widgets, itemController),
              buildInputCard("Rhodium", Icons.where_to_vote_outlined, rhodiumController),
              buildInputCard("Findings", Icons.width_full, itemController),
              buildInputCard("Pcs", Icons.width_normal, itemController),
              buildInputCard("Gross wt", Icons.width_wide_sharp, itemController),

              buildInputCard("Item", Icons.widgets, itemController),
              buildInputCard("Metal", Icons.precision_manufacturing, metalController),
              buildInputCard("Color", Icons.palette, colorController),
              buildInputCard("Size", Icons.account_tree, colorController),
              buildInputCard("Enamel Color", Icons.brush, enamelColorController),
              buildCommentBox("Stone description", itemController),
              buildCommentBox("Item description", itemController),
              sectionTitle("Images"),
              buildImagePicker("Image 1", imageFromGallery, () => pickImage(ImageSource.gallery, false)),
              const SizedBox(height: 16),
              buildImagePicker("Image 2", imageFromCamera, () => pickImage(ImageSource.camera, true)),

              const SizedBox(height: 30),

              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Order submitted")));
                  };
                },
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple,
                    minimumSize: const Size(100, 40),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    )),
                child: const Text('Submit Form',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.normal,
                      color: Color(0xFFFFFFFF),
                    )),
              ),
              // ElevatedButton(
              //   onPressed: () {
              //     if (_formKey.currentState!.validate()) {
              //       ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Order submitted")));
              //     }
              //   },
              //   style: ElevatedButton.styleFrom(
              //     padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 32),
              //     shape: RoundedRectangleBorder(
              //       borderRadius: BorderRadius.circular(12),
              //     ),
              //   ),
              //   child: const Text("Submit Order", style: TextStyle(fontSize: 16)),
              // ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildInputCard(String label, IconData icon, TextEditingController controller,
      {TextInputType keyboardType = TextInputType.text}) {
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
        decoration: InputDecoration(
          icon: Icon(icon, color: Colors.deepPurple),
          labelText: label,
          border: InputBorder.none,
        ),
        validator: (value) => value == null || value.isEmpty ? 'Required' : null,
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
            decoration: const InputDecoration.collapsed(hintText: "Type here..."),
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
          child: Image.file(image, fit: BoxFit.cover, width: double.infinity),
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
