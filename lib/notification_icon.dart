import 'package:eco_credit/notification.dart';
import 'package:flutter/material.dart';

class NotificationIcon extends StatelessWidget {
  final int notificationCount;

  NotificationIcon({required this.notificationCount});

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        IconButton(
          icon: const Icon(Icons.notifications),
          color: const Color(0xFF3F9A25),
          onPressed: () {
            // Navigate to the NotificationsScreen
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => NotificationsScreen()),
            );
          },
        ),
        notificationCount > 0
            ? Positioned(
                right: 0,
                top: 8,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(8.5),
                  ),
                  constraints: const BoxConstraints(
                    minWidth: 17,
                    minHeight: 17,
                  ),
                  child: Text(
                    notificationCount.toString(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              )
            : Container() // If no notifications, show nothing
      ],
    );
  }
}
