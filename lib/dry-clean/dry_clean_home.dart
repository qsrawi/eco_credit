import 'package:eco_credit/dry-clean/dry_clean_collections.dart';
import 'package:eco_credit/notification_icon.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DryCleanHomeScreen extends StatefulWidget {
  final bool showCompleted;

  const DryCleanHomeScreen({super.key, this.showCompleted = false});

  @override
  // ignore: library_private_types_in_public_api
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<DryCleanHomeScreen> {
  int notificationCount = 5; // Example count, replace with actual data source
  // late final ApiService _apiService = ApiService();

  @override
  void initState() {
    super.initState();
  }

  // Future<void> _fetchStatistics() async {
  //   SharedPreferences prefs = await SharedPreferences.getInstance();
  //   int? pickerId = prefs.getInt('id');
  //   String role = prefs.getString('role') ?? '';
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: FutureBuilder(
          future: SharedPreferences.getInstance(),
          builder: (BuildContext context, AsyncSnapshot<SharedPreferences> snapshot) {
            if (snapshot.hasData) {
              String role = snapshot.data!.getString('role') ?? 'Default Role';
              return getTitleWidget(role);
            } else {
              return Text("Loading..."); // Or any other placeholder
            }
          },
        ),
        actions: [
          NotificationIcon(notificationCount: notificationCount), // Use NotificationIcon here
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: DryCleanCollectionTabs(showCompleted: widget.showCompleted),
          ),
        ],
      ),
    );
  }
}

Widget getTitleWidget(String role) {
  IconData iconData;
  Color color;
  String text;

  switch (role) {
    case "DCAdmin":
      iconData = Icons.admin_panel_settings;
      color = Colors.red;
      text = "آدمن";
      break;
    case "Donater":
      iconData = Icons.nature_people;
      color = Colors.green;
      text = "متبرع";
      break;
    default:
      iconData = Icons.error;
      color = Colors.grey;
      text = "Unknown Role";
  }

  return Row(
    mainAxisSize: MainAxisSize.min,
    mainAxisAlignment: MainAxisAlignment.start, // Aligns the Row content to the start, which is the right in RTL
    textDirection: TextDirection.rtl, // Ensures content is right-to-left
    children: <Widget>[
      Text(text, textAlign: TextAlign.right), // Ensures the text is right-aligned
      SizedBox(width: 8), // Space between text and icon
      Icon(iconData, size: 20, color: color), // You can adjust the size as needed
    ],
  );
}