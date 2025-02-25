import 'package:eco_credit/collection_tabs.dart';
import 'package:eco_credit/notification_icon.dart';
import 'package:eco_credit/services/api_service.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeScreen extends StatefulWidget {
  final bool showCompleted;

  HomeScreen({this.showCompleted = false});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int notificationCount = 5; // Example count, replace with actual data source
  late final ApiService _apiService = ApiService();
  Future<CollectionLightResource>? _futureStatistics;

  @override
  void initState() {
    super.initState();
    _fetchStatistics();
  }

  Future<void> _fetchStatistics() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int? pickerId = prefs.getInt('id'); // Assuming pickerId is stored in SharedPreferences
    String role = prefs.getString('role') ?? ''; // Provide a default value in case it's null

    if (pickerId != null && role == "Picker") {
      setState(() {
        _futureStatistics = _apiService.statistics(pickerId);
      });
    }
  }

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
          FutureBuilder(
            future: SharedPreferences.getInstance(),
            builder: (BuildContext context, AsyncSnapshot<SharedPreferences> snapshot) {
              if (snapshot.hasData && snapshot.data!.getString('role') == "Picker" && !widget.showCompleted) {
                return roleBasedCards(); // Render the cards if role is "Picker"
              } else {
                return SizedBox(); // Render nothing if role is not "Picker"
              }
            },
          ),
          Expanded(
            child: CollectionTabs(showCompleted: widget.showCompleted),
          ),
        ],
      ),
    );
  }

Widget roleBasedCards() {
  return FutureBuilder<CollectionLightResource>(
    future: _futureStatistics,
    builder: (context, snapshot) {
      if (snapshot.connectionState == ConnectionState.waiting) {
        return Center(child: CircularProgressIndicator());
      } else if (snapshot.hasError) {
        return Center(child: Text('Error: ${snapshot.error}'));
      } else if (!snapshot.hasData) {
        return Center(child: Text('No data available'));
      } else {
        // Extract the counts from the API response
        int completedTasks = snapshot.data!.todayPickups ?? 0;
        int pendingTasks = snapshot.data!.pending ?? 0;

        return Padding(
          padding: EdgeInsets.all(8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              InfoCard(
                title: "المهام المنجزة",
                count: completedTasks,
                iconData: Icons.directions_car,
                color: Colors.green,
              ),
              InfoCard(
                title: "قيد الانتظار",
                count: pendingTasks,
                iconData: Icons.hourglass_empty,
                color: Colors.amber,
              ),
            ],
          ),
        );
      }
    },
  );
}
}

class InfoCard extends StatelessWidget {
  final String title;
  final int count;
  final IconData iconData;
  final Color color;

  const InfoCard({
    required this.title,
    required this.count,
    required this.iconData,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2.0,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8.0),
              decoration: BoxDecoration(
                color: color.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(iconData, color: color),
            ),
            SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                ),
                Text(
                  count.toString(),
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

Widget getTitleWidget(String role) {
  IconData iconData;
  Color color;
  String text;

  switch (role) {
    case "Generator":
      iconData = Icons.business;
      color = Colors.red;
      text = "منشأة";
      break;
    case "Picker":
      iconData = Icons.eco;
      color = Colors.green;
      text = "بطل البيئة";
      break;
   case "Admin":
      iconData = Icons.admin_panel_settings;
      color = Colors.red;
      text = "آدمن";
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