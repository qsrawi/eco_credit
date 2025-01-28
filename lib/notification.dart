import 'package:eco_credit/notification_card.dart';
import 'package:flutter/material.dart';

class NotificationsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Example data grouped by days
    Map<String, List<Widget>> groupedNotifications = {
      'Today': [
        NotificationCard(
          title: 'Collection Completed',
          description: 'You Complete waste collection of Cartoon for Omar.',
          icon: Icons.check_circle,
          iconColor: Colors.green,
        ),
        NotificationCard(
          title: 'Waste Accepted',
          description: 'You Accept waste Collection of Iron For Khalid',
          icon: Icons.timelapse,
          iconColor: Colors.blue,
        ),
      ],
      'Yesterday': [
        NotificationCard(
          title: 'Waste Accepted',
          description: 'You Accept waste Collection of Iron For Khalid',
          icon: Icons.timelapse,
          iconColor: Colors.blue,
        ),
      ],
      'Earlier': [
        NotificationCard(
          title: 'Waste Rejected',
          description: 'You Reject collection waste of Plastic for Othman.',
          icon: Icons.error,
          iconColor: Colors.red,
        ),
      ],
    };

    return Scaffold(
      appBar: AppBar(
        title: Text('Notifications'),
      ),
      body: ListView(
        children: groupedNotifications.entries.expand((entry) => [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text(entry.key, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ),
          ...entry.value,
        ]).toList(),
      ),
    );
  }
}
