import 'dart:convert';

import 'package:eco_credit/main.dart';
import 'package:eco_credit/services/api_service.dart';
import 'package:eco_credit/services/dry_clean_service.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DryCleanProfileScreen extends StatefulWidget {
  const DryCleanProfileScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _DryCleanProfileScreenState createState() => _DryCleanProfileScreenState();
}

class _DryCleanProfileScreenState extends State<DryCleanProfileScreen> {
  Future<DonaterResource>? profile;
  int? userId;
  String? userType;

  @override
  void initState() {
    super.initState();
    loadInitialData();
  }

  void loadInitialData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int userId = prefs.getInt('id') ?? 1; // Default to 1 if not set
    userType = prefs.getString('role') ?? 'Donater';
    if(userType == "Donater") {
      profile = DryCleanApiService().fetchDenatorProfile(userId);
    } else {
      profile = DryCleanApiService().fetchAdminProfile(userId);
    }
    setState(() {}); // This is optional, depends on if you need to update the UI after data is fetched
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl, // Set text direction to RTL
      child: Scaffold(
        appBar: AppBar(
          title: const Text('ملف شخصي'),
          actions: [
          IconButton(
              icon: const Icon(Icons.settings),
              onPressed: () {
                final RenderBox overlay = 
                    Overlay.of(context).context.findRenderObject() as RenderBox;
                final RenderBox button = context.findRenderObject() as RenderBox;
                final RelativeRect position = RelativeRect.fromRect(
                  Rect.fromPoints(
                    button.localToGlobal(Offset.zero, ancestor: overlay),
                    button.localToGlobal(button.size.bottomRight(Offset.zero), ancestor: overlay),
                  ),
                  Offset.zero & overlay.size,
                );

                showMenu(
                  context: context,
                  position: position,
                  items: [
                    const PopupMenuItem<String>(
                      value: 'logout',
                      child: Row(
                        children: <Widget>[
                          Icon(Icons.exit_to_app),
                          SizedBox(width: 8),
                          Text('تسجيل الخروج')
                        ],
                      ),
                    ),
                    const PopupMenuItem<String>(
                      value: 'delete_account',
                      child: Row(
                        children: <Widget>[
                          Icon(Icons.delete, color: Colors.red),
                          SizedBox(width: 8),
                          Text('حذف الحساب', 
                            style: TextStyle(color: Colors.red)),
                        ],
                      ),
                    ),
                  ],
                ).then((value) {
                  if (value == 'logout') {
                    _logout(context);
                  } else if (value == 'delete_account') {
                    _showDeleteConfirmationDialog(context);
                  }
                });
              },
            ),
          ],
        ),
        body: FutureBuilder<DonaterResource>(
          future: profile,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return Center(child: Text("Error: ${snapshot.error}"));
            }
            if (snapshot.hasData) {
              return buildProfile(snapshot.data!);
            } else {
              return const Center(child: Text("No data available"));
            }
          },
        ),
      ),
    );
  }

  Widget buildProfile(DonaterResource profile) {
    Color getColor(String itemName) {
      switch (itemName) {
        case 'الأيميل':
          return Colors.blue;  // Blue for email
        case 'الموبايل':
          return Colors.green;  // Green for phone
        case 'الموقع':
          return Colors.orange;  // Orange for location
        case 'عدد الجموعات':
          return Colors.red;  // Red for collections
        case 'الاسم الكامل':
        default:
          return Colors.grey;  // Grey for others and default
      }
    }

    return ListView(
      children: <Widget>[
        _buildProfileHeader(profile), // Assuming this is defined elsewhere
        // DryCleanStatisticsCard(
        //   pending: profile.pending ?? 0,
        //   completed: profile.completed ?? 0,
        //   inProgress: profile.picked ?? 0,
        //   cancelled: profile.ignored ?? 0,
        // ),
        ListTile(
          title: const Text('الاسم الكامل'),
          subtitle: Text(profile.name ?? 'Unknown'),
          leading: const Icon(Icons.person, color: Colors.blue),
        ),
        ListTile(
          title: const Text('الأيميل'),
          subtitle: Text(profile.email ?? 'Unknown'),
          leading: const Icon(Icons.email, color: Colors.blue),
        ),
        ListTile(
          title: const Text('الموبايل'),
          subtitle: Text(profile.phone ?? 'Unknown'),
          leading: const Icon(Icons.phone, color: Colors.blue),
        ),
        ListTile(
          title: const Text('العنوان'),
          subtitle: Text(profile.address ?? 'Unknown'),
          leading: const Icon(Icons.map, color: Colors.blue),
        ),
        ListTile(
          title: const Text('عدد التبرعات'),
          subtitle: Text('${profile.donationCount ?? 0}'),
          leading: const Icon(Icons.list, color: Colors.blue),
        ),
      ],
    );
  }


  Widget _buildProfileHeader(DonaterResource profile) {
    return Container(
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: <Widget>[
          CircleAvatar(
            radius: 50,
            backgroundImage: profile.image != null 
              ? MemoryImage(base64Decode(profile.image!)) as ImageProvider<Object>
              : const AssetImage('assets/images/default.jpg') as ImageProvider<Object>,
          ),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    profile.name ?? 'Name not available',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  // if (userType == "Generator") ...[
                  //   Text(
                  //     'نوع المجموعة : ${profile.wasteTypeName}',
                  //     style: const TextStyle(
                  //       fontSize: 16,
                  //       color: Colors.grey,
                  //     ),
                  //   ),
                  // ],
                  Text(
                    'رقم المستخدم: #${profile.manualID}',
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  
}

void _logout(BuildContext context) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.clear(); // This clears all data in SharedPreferences
  Navigator.of(context).pushAndRemoveUntil(
    MaterialPageRoute(builder: (context) => MyApp()), // Navigates back to the initial route
    (Route<dynamic> route) => false,
  );
}

// Add this function
void _showDeleteConfirmationDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('تأكيد الحذف', textDirection: TextDirection.rtl),
        content: const Text('هل انت متاكد من انك تريد حذف حسابك؟', 
          textDirection: TextDirection.rtl),
        actions: <Widget>[
          TextButton(
            child: const Text('إلغاء', 
              style: TextStyle(color: Colors.grey)),
            onPressed: () => Navigator.of(context).pop(),
          ),
          TextButton(
            child: const Text('حذف', 
              style: TextStyle(color: Colors.red)),
            onPressed: () {
              Navigator.of(context).pop();
              _deleteAccount(context);
            },
          ),
        ],
        actionsAlignment: MainAxisAlignment.start,
        actionsPadding: const EdgeInsets.all(10),
      );
    },
  );
}

// Add your delete account logic here
void _deleteAccount(BuildContext context) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  int userId = prefs.getInt('id') ?? 1;
  String userType = prefs.getString('role') ?? 'Generator';

  ApiService.deleteUser(userId, userType);
  Navigator.of(context).pushAndRemoveUntil(
    MaterialPageRoute(builder: (context) => MyApp()), // Navigates back to the initial route
    (Route<dynamic> route) => false,
  );
}