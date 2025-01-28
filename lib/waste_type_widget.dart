import 'package:flutter/material.dart';

class WasteTypeWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Placeholder for waste type selection
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text('Waste Type', style: TextStyle(fontWeight: FontWeight.bold)),
        ),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          children: List.generate(4, (index) {
            // Placeholder for icons
            return Card(
              child: Center(child: Text('Item $index')),  // Replace with actual waste type icons and labels
            );
          }),
        ),
      ],
    );
  }
}
