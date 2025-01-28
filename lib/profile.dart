import 'package:flutter/material.dart';
import 'waste_collection_statistics_card.dart'; // Ensure this is the correct path

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

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
      body: ListView(
        children: <Widget>[
          _buildProfileHeader(),
          WasteCollectionStatisticsCard(
            pending: 3,
            completed: 121,
            inProgress: 2,
            cancelled: 1,
          ),
          const ListTile(
            title: Text('Full Name'),
            subtitle: Text('سوبر ماركت النجمة '),
            leading: Icon(Icons.person),
          ),
          const ListTile(
            title: Text('Email'),
            subtitle: Text('MohAhmad@email.com'),
            leading: Icon(Icons.email),
          ),
          const ListTile(
            title: Text('Phone'),
            subtitle: Text('+1 234 567 8900'),
            leading: Icon(Icons.phone),
          ),
          const ListTile(
            title: Text('Location'),
            subtitle: Text('شارع الوكالات, صويفية, عمان'),
            leading: Icon(Icons.map),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Container(
      color: Colors.white,
      child: const Padding(
        padding: EdgeInsets.all(16.0),
        child: Row(
          children: <Widget>[
            CircleAvatar(
              radius: 50,
              backgroundImage: AssetImage('assets/images/2.jpeg'), // Placeholder image URL
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    'سوبر ماركت النجمة ',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'Generator ID: #G12345',
                    style: TextStyle(
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
