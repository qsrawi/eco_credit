import 'dart:io';

import 'package:eco_credit/login/login.dart';
import 'package:flutter/material.dart';

void main() {
 // Your code
 
  runApp(MyApp());
   HttpOverrides.global = MyHttpOverrides();
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Obtain screen size for responsive layout
    var screenSize = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Color(0xFFD5E4E1),
      appBar: AppBar(
        title: Text('ecoCredit'),
        backgroundColor: Color(0xFFD5E4E1),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              ImageCard(
                imagePath: 'assets/images/dryclean.jpg', 
                label: 'Dry Clean', 
                onTap: () => navigateToLogin(context, 'dry_clean'),
                height: screenSize.height * 0.3, // 30% of screen height
              ),
              ImageCard(
                imagePath: 'assets/images/erecycleHUB.jpg', 
                label: 'eRecycleHUB', 
                onTap: () => navigateToLogin(context, 'erecycleHUB'),
                height: screenSize.height * 0.3, // 30% of screen height
              ),
            ],
          ),
        ),
      ),
    );
  }

  void navigateToLogin(BuildContext context, String type) {
    Navigator.push(context, MaterialPageRoute(builder: (context) => LoginPage(type: type)));
  }
}

class ImageCard extends StatelessWidget {
  final String imagePath;
  final String label;
  final VoidCallback onTap;
  final double height;

  ImageCard({
    required this.imagePath, 
    required this.label, 
    required this.onTap, 
    required this.height
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white,
      margin: EdgeInsets.all(16),
      child: InkWell(
        onTap: onTap,
        child: Container(
          height: height,
          padding: EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Expanded(
                child: Image.asset(imagePath, fit: BoxFit.contain),  // Adjust image fitting
              ),
              SizedBox(height: 8),
              Text(label, style: TextStyle(fontSize: 16)),
            ],
          ),
        ),
      ),
    );
  }
}


class MyHttpOverrides extends HttpOverrides{
  @override
  HttpClient createHttpClient(SecurityContext? context){
    return super.createHttpClient(context)
      ..badCertificateCallback = (X509Certificate cert, String host, int port)=> true;
  }
}