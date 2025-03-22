import 'dart:io';

import 'package:eco_credit/login/login.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

void main() {
  runApp(MyApp());
  HttpOverrides.global = MyHttpOverrides();
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: HomePage(),
      debugShowCheckedModeBanner: false,  // Add this line to remove the debug banner
    );
  }
}

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'ecoCredit',
          style: GoogleFonts.lato(
            textStyle: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            color: Color(0xFF3F9A25), // Solid green color
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Container(
        constraints: const BoxConstraints.expand(),
        color: const Color(0xFF3F9A25), // Solid green background
        child: SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: screenSize.height,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                ImageCard(
                  imagePath: 'assets/images/dryclean.png',
                  label: 'FERRARI Dry Clean',
                  onTap: () => navigateToLogin(context, 'dry_clean'),
                  height: screenSize.height * 0.3,
                ),
                SizedBox(height: screenSize.height * 0.02),
                ImageCard(
                  imagePath: 'assets/images/erecycleHUB.png',
                  label: 'eRecycleHUB',
                  onTap: () => navigateToLogin(context, 'erecycleHUB'),
                  height: screenSize.height * 0.3,
                ),
                SizedBox(height: screenSize.height * 0.4),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: Container(
        color: Colors.white.withOpacity(0.5),
        padding: const EdgeInsets.all(10),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.copyright, size: 14),
            SizedBox(width: 5),
            Text('2025 All rights reserved', style: TextStyle(fontSize: 12)),
          ],
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

  const ImageCard({
    required this.imagePath,
    required this.label,
    required this.onTap,
    required this.height,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white,
      margin: const EdgeInsets.all(16),
      child: InkWell(
        onTap: onTap,
        child: Container(
          height: height,
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Expanded(
                child: Image.asset(imagePath, fit: BoxFit.contain),
              ),
              const SizedBox(height: 8),
              Text(label, style: const TextStyle(fontSize: 16)),
            ],
          ),
        ),
      ),
    );
  }
}

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback = (X509Certificate cert, String host, int port) => true;
  }
}