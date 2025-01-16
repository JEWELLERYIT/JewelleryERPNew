import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../Constants/Functions.dart';
import '../Constants/StaticConstant.dart';
import 'FilterScreen.dart';
import 'HomeDashBoard.dart';
import 'LoginPage.dart';
import 'MaxWidthContainer.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key, required this.title});

  final String title;

  @override
  State<SplashScreen> createState() => _SplashScreen();
}

class _SplashScreen extends State<SplashScreen> {
  Color backgroundColor = Colors.yellow; // Initial bright color

  // SharedPreferences prefs =  SharedPreferences.getInstance() as SharedPreferences;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    Timer(
      const Duration(seconds: 2),
      () {
        authenticate();
      },
    );
  }

  Future<void> authenticate() async {
    // final hasBiometric = await hasBiometrics();
    String? userTOken = await Constans().getData(StaticConstant.userData);

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
          builder: (context) => const LoginPage(
            title: '',
          )),
    );
    // if (userTOken == null || userTOken == "null") {
    //   Navigator.pushReplacement(
    //     context,
    //     MaterialPageRoute(
    //         builder: (context) => const MaxWidthContainer(
    //           child: LoginPage(
    //                 title: '',
    //               ),
    //         )),
    //   );
    // } else {
    //   Navigator.pushReplacement(
    //     context,
    //     MaterialPageRoute(
    //         builder: (context) => MaxWidthContainer(
    //           child: FilterScreen(),
    //         )),
    //   );
    // }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Image.asset(
        'assets/splash.jpg',
        width: double.infinity,
        height: double.infinity,
        fit: BoxFit.fill, // fitXY equivalent
      ),
    );
  }
}
