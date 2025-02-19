import 'package:eco_credit/dry-clean/dry_clean_notification_card.dart';
import 'package:eco_credit/services/api_service.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DryCleanNotificationsScreen extends StatefulWidget {
  const DryCleanNotificationsScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _DryCleanNotificationsScreenState createState() => _DryCleanNotificationsScreenState();
}

class _DryCleanNotificationsScreenState extends State<DryCleanNotificationsScreen> {
  late final ApiService _apiService = ApiService();
  late Future<List<NotificationListResource>> _notificationsFuture;

  @override
  void initState() {
    super.initState();
    loadInitialData();
  }

  void loadInitialData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int userId = prefs.getInt('id') ?? 1; // Default to 1 if not set
    String userType = prefs.getString('role') ?? 'Donater';
    _notificationsFuture = _apiService.fetchNotifications(userId, userType);
    setState(() {}); // This is optional, depends on if you need to update the UI after data is fetched
  }

  Map<String, List<Widget>> grouped = {
      'اليوم': <Widget>[],
      'البارحة': <Widget>[],
      'اقدم': <Widget>[]
  };

  Map<String, List<Widget>> groupNotifications(List<NotificationListResource> notifications) {
    final Map<String, List<Widget>> grouped = {
      'اليوم': <Widget>[],
      'البارحة': <Widget>[],
      'اقدم': <Widget>[],
    };
    
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));

    for (var notification in notifications) {
      final date = notification.createdDate;
      if (date == null) {
        grouped['اقدم']!.add(_buildNotificationCard(notification));
        continue;
      }

      final notificationDate = DateTime(date.year, date.month, date.day);
      if (notificationDate == today) {
        grouped['اليوم']!.add(_buildNotificationCard(notification));
      } else if (notificationDate == yesterday) {
        grouped['البارحة']!.add(_buildNotificationCard(notification));
      } else {
        grouped['اقدم']!.add(_buildNotificationCard(notification));
      }
    }

    grouped.removeWhere((key, value) => value.isEmpty);
    return grouped;
  }

  Widget _buildNotificationCard(NotificationListResource notification) {
    IconData icon;
    Color color;
    String title;

    switch (notification.notificationTypeID) {
      case 1:
        icon = Icons.error;
        color = Colors.red;
        title = 'مجموعة مرفوضة';
        break;
      case 2:
        icon = Icons.timelapse;
        color = Colors.blue;
        title = 'مجموعة مقبولة';
        break;
      case 5:
        icon = Icons.check_circle;
        color = Colors.green;
        title = 'مجموعة اكتملت';
        break;
      default:
        icon = Icons.notifications;
        color = Colors.grey;
        title = 'مجموعة';
    }

    return DryCleanNotificationCard(
      title: title,
      description: notification.description ?? 'No description available',
      icon: icon,
      iconColor: color,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('إشعارات'),
      ),
      body: FutureBuilder<List<NotificationListResource>>(
        future: _notificationsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No notifications found'));
          }

          final grouped = groupNotifications(snapshot.data!);
          
          return ListView(
            children: grouped.entries.expand((entry) => [
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Text(
                  entry.key,
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              ...entry.value,
            ]).toList(),
          );
        },
      ),
    );
  }
}