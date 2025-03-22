import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

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
    {'id': 1, 'icon': 'assets/icons/Plastic.svg', 'label': 'بلاستيك', 'color': Colors.green},
    {'id': 2, 'icon': 'assets/icons/Paper.svg', 'label': 'ورق', 'color': Colors.green},
    {'id': 3, 'icon': 'assets/icons/Cartoon.svg', 'label': 'كرتون', 'color': Colors.green},
    {'id': 4, 'icon': 'assets/icons/Iron.svg', 'label': 'معادن', 'color': Colors.green},
    {'id': 5, 'icon': 'assets/icons/Wood.svg', 'label': 'خشب', 'color': Colors.green},
    {'id': 6, 'icon': 'assets/icons/Glass.svg', 'label': 'زجاج', 'color': Colors.green},
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: <Widget>[
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
          child: Text(
            'نوع المواد القابلة للتدوير',
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
                    SvgPicture.asset(
                      wasteTypes[index]['icon'],
                      height: 30,
                      color: wasteTypes[index]['color'],
                    ),
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