import 'package:eco_credit/services/api_service.dart';
import 'package:flutter/material.dart';
import 'waste_collection_statistics_card.dart';

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late Future<GeneratorResource> profile;

  @override
  void initState() {
    super.initState();
    profile = ApiService().fetchGeneratorsProfile(2); // Assuming '1' is the ID you want to fetch
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
                // Handle settings
              },
            ),
          ],
        ),
        body: FutureBuilder<GeneratorResource>(
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

  Widget buildProfile(GeneratorResource profile) {
    return ListView(
      children: <Widget>[
        _buildProfileHeader(profile),
        WasteCollectionStatisticsCard(
          pending: 3, // These should ideally come from the API
          completed: 121,
          inProgress: 2,
          cancelled: 1,
        ),
        ListTile(
          title: const Text('الاسم الكامل'),
          subtitle: Text(profile.name ?? 'Unknown'),
          leading: const Icon(Icons.person),
        ),
        ListTile(
          title: const Text('الأيميل'),
          subtitle: Text(profile.email ?? 'Unknown'),
          leading: const Icon(Icons.email),
        ),
        ListTile(
          title: const Text('الموبايل'),
          subtitle: Text(profile.phone ?? 'Unknown'),
          leading: const Icon(Icons.phone),
        ),
        ListTile(
          title: const Text('الموقع'),
          subtitle: Text(profile.locationName ?? 'Unknown'), // Assuming location needs special handling
          leading: const Icon(Icons.map),
        ),
      ],
    );
  }

  Widget _buildProfileHeader(GeneratorResource profile) {
    return Container(
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: <Widget>[
          CircleAvatar(
            radius: 50,
            backgroundImage: profile.image != null 
              ? NetworkImage(profile.image!) as ImageProvider<Object>
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
                  Text(
                    'رقم المنشأه: #${profile.manualId}',
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
