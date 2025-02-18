import 'package:flutter/material.dart';

class DryCleanNotificationCard extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;
  final Color iconColor;

  const DryCleanNotificationCard({
    required this.title,
    required this.description,
    required this.icon,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.all(8),
      child: ListTile(
        leading: Icon(icon, color: iconColor),
        title: Text(title, style: TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(description),
      ),
    );
  }
}