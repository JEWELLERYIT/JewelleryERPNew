import 'package:flutter/material.dart';

import 'Pages/MaxWidthContainer.dart';
import 'Pages/SplashScreen.dart';
void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Digicat',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.white),
        useMaterial3: true,
      ),
      debugShowCheckedModeBanner: false,
      home: const MaxWidthContainer(
        child: SplashScreen(title: 'Flutter Demo Home Page'),
      ),
    );
  }
}