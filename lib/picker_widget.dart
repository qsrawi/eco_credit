import 'package:flutter/material.dart';

class PickerWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Placeholder for picker selection
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text('Select Picker', style: TextStyle(fontWeight: FontWeight.bold)),
        ),
        ListTile(
          leading: CircleAvatar(
            backgroundImage: NetworkImage('https://example.com/image1.jpg'),  // Replace with actual image URL
          ),
          title: Text('Ahmed Mohammad'),
          subtitle: Text('Jabal Amman'),
          onTap: () {
            // Handle picker selection
          },
        ),
        ListTile(
          leading: CircleAvatar(
            backgroundImage: NetworkImage('https://example.com/image2.jpg'),  // Replace with actual image URL
          ),
          title: Text('Khalid Ahmed'),
          subtitle: Text('Abdoun'),
          onTap: () {
            // Handle picker selection
          },
        ),
      ],
    );
  }
}
