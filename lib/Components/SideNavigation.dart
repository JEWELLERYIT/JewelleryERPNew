// import 'dart:convert';
// import 'dart:io';

// import 'package:digicat/Pages/HomeDashBoard.dart';
// import 'package:digicat/Pages/SavedCatalogScreen.dart';
import 'dart:convert';
import 'package:flutter/material.dart';
import '../Constants/Functions.dart';
import '../Constants/StaticConstant.dart';
import '../Pages/LoginPage.dart';
import '../Pages/MaxWidthContainer.dart';
import 'package:url_launcher/url_launcher.dart';

class SideNavigation extends StatefulWidget {
  final VoidCallback setState;
  final int type;

  SideNavigation({required this.setState, required this.type});

  @override
  _SideNavigation createState() => _SideNavigation();
}

class _SideNavigation extends State<SideNavigation> {
  Constans constans = Constans();

  String userName = "";
  String userEmail = "";
  int companyId = 0 ;
  void setUserData() async {
    String? jsonString = await constans.getData(StaticConstant.userData);
    print("User Details ------ $jsonString");
    final Map<String, dynamic> jsonMap = jsonDecode(jsonString!);

    setState(() {
      // userName = jsonMap['username'];
    });
  }

  @override
  void initState() {
    super.initState();

    // String companyLogo = constans.getCompanyImageUrl(userData['image']);

    setUserData();
  }

  void _openInChrome(BuildContext context) async {
    const String url = 'https://digicat.in/pages/terms_of_use';

    final Uri emailUri = Uri.parse(url);

    try {
      if (await canLaunchUrl(emailUri)) {
        await launchUrl(emailUri);
      } else {
        throw 'Could not launch email client';
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('There is no email client installed.')),
      );
    }
  }

  void showLogoutAlert() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Digicat"),
          content: const Text(
              'Are you sure you want to log out? You will need to log in again to access your account.'),
          actions: <Widget>[
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const MaxWidthContainer(
                      child: LoginPage(
                        title: '',
                      ),
                    ),
                  ),
                      (route) => false, // Remove all previous routes
                );

              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Container(
          width: double.infinity,
          color: Colors.white,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Drawer Header
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 30),
                  Center(
                    child: Image.asset(
                      'assets/login_logo.jpeg', // Replace with your image path
                      height: 30, // Adjust the height as needed
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.fromLTRB(20, 10, 0, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          userName,
                          style: const TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        Text(userEmail)
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              // The scrollable content
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context, false);
                  showLogoutAlert();
                },
                style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4C5564),
                    minimumSize: const Size(100, 40),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    )),
                child: const Text('Logout',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.normal,
                      color: Color(0xFFFFFFFF),
                    )),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
