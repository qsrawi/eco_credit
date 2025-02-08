import 'dart:convert';
import 'package:flutter/material.dart';

class WasteCollectionCard extends StatelessWidget {
  final String status;
  final String title;
  final String name;
  final String imageUrl; // This is expected to be a Base64 encoded string of the image
  final String timeAgo;

  const WasteCollectionCard({
    required this.status,
    required this.title,
    required this.name,
    required this.imageUrl,
    required this.timeAgo,
  });

  @override
  Widget build(BuildContext context) {
    // Decoding the Base64 string to bytes
    final imageBytes = base64Decode(imageUrl);

    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          ClipRRect(
            borderRadius: const BorderRadius.only(topLeft: Radius.circular(10), topRight: Radius.circular(10)),
            child: Image.memory(
              imageBytes,
              height: 150,
              fit: BoxFit.cover,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  status,
                  style: TextStyle(
                    color: status == 'بالانتظار' ? Colors.orange : Colors.green,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 5),
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 5),
                  child: Text(
                    '$name - $timeAgo',
                    style: const TextStyle(
                      color: Colors.grey,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
