import 'package:flutter/material.dart';
import 'waste_collection_statistics_card.dart'; // Ensure this is the correct path

class ProfileScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profile'),
        actions: [
          IconButton(
            icon: Icon(Icons.settings),
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
          ListTile(
            title: Text('Full Name'),
            subtitle: Text('Mohmmad Ahmad'),
            leading: Icon(Icons.person),
          ),
          ListTile(
            title: Text('Email'),
            subtitle: Text('MohAhmad@email.com'),
            leading: Icon(Icons.email),
          ),
          ListTile(
            title: Text('Phone'),
            subtitle: Text('+1 234 567 8900'),
            leading: Icon(Icons.phone),
          ),
          ListTile(
            title: Text('Location'),
            subtitle: Text('123 Al-Wakalat St, Sweifieh, Amman'),
            leading: Icon(Icons.map),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Container(
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: <Widget>[
            CircleAvatar(
              radius: 50,
              backgroundImage: AssetImage('assets/images/prof1.jpg'), // Placeholder image URL
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    'Mohmmad Ahmad',
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
