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
    profile = ApiService().fetchGeneratorsProfile(1); // Assuming '1' is the ID you want to fetch
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
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
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          }
          if (snapshot.hasData) {
            return buildProfile(snapshot.data!);
          } else {
            return Center(child: Text("No data available"));
          }
        },
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
          title: const Text('Full Name'),
          subtitle: Text(profile.name ?? 'Unknown'),
          leading: const Icon(Icons.person),
        ),
        ListTile(
          title: const Text('Email'),
          subtitle: Text(profile.email ?? 'Unknown'),
          leading: const Icon(Icons.email),
        ),
        ListTile(
          title: const Text('Phone'),
          subtitle: Text(profile.phone ?? 'Unknown'),
          leading: const Icon(Icons.phone),
        ),
        ListTile(
          title: const Text('Location'),
          subtitle: Text('Add Location parsing logic here'), // Assuming location needs special handling
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
              : AssetImage('assets/images/carton.jpg') as ImageProvider<Object>,
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
                    'Generator ID: #${profile.manualId}',
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
