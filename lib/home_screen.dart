import 'package:eco_credit/collection_tabs.dart';
import 'package:eco_credit/notification_icon.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  final bool showCompleted;

  HomeScreen({this.showCompleted = false});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int notificationCount = 5; // Example count, replace with actual data source

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("eRecycleHub"),
        actions: [
          NotificationIcon(notificationCount: notificationCount), // Use NotificationIcon here
        ],
      ),
      body: CollectionTabs(showCompleted: widget.showCompleted),
    );
  }
}
