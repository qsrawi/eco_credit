import 'package:flutter/material.dart';

class WasteTypeWidget extends StatefulWidget {
  final Function(int) onSelected;

  WasteTypeWidget({Key? key, required this.onSelected}) : super(key: key);

  @override
  _WasteTypeWidgetState createState() => _WasteTypeWidgetState();
}

class _WasteTypeWidgetState extends State<WasteTypeWidget> {
  int? selectedIndex;
  int? selectedWasteTypeId;

  final List<Map<String, dynamic>> wasteTypes = [
    {'id': 1, 'icon': Icons.delete, 'label': 'بلاستك', 'color': Colors.blueAccent},
    {'id': 2, 'icon': Icons.description, 'label': 'ورق', 'color': Colors.brown},
    {'id': 3, 'icon': Icons.archive, 'label': 'كرتون', 'color': Colors.orange},
    {'id': 4, 'icon': Icons.build, 'label': 'معادن', 'color': Colors.grey},
    {'id': 5, 'icon': Icons.deck, 'label': 'خشب', 'color': Colors.green},
    {'id': 6, 'icon': Icons.broken_image, 'label': 'زجاج', 'color': Colors.blue},
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: <Widget>[
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
          child: Text(
            'نوع المجموعة',
            textAlign: TextAlign.right,
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            childAspectRatio: 1.0,
          ),
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          itemCount: wasteTypes.length,
          itemBuilder: (context, index) {
            return GestureDetector(
              onTap: () {
                setState(() {
                  selectedIndex = index;
                  selectedWasteTypeId = wasteTypes[index]['id'];  
                  setState(() {
                      selectedWasteTypeId = wasteTypes[index]['id'];
                    });
                    widget.onSelected(wasteTypes[index]['id']);
                });
              },
              child: Card(
                color: selectedIndex == index ? Colors.green[100] : null,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Icon(wasteTypes[index]['icon'], size: 30, color: wasteTypes[index]['color']),
                    SizedBox(height: 4),
                    Text(wasteTypes[index]['label'], style: TextStyle(color: wasteTypes[index]['color'])),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}