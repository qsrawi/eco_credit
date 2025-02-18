import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class DonationTypeWidget extends StatefulWidget {
  final Function(List<int>) onSelected;

  const DonationTypeWidget({super.key, required this.onSelected});

  @override
  // ignore: library_private_types_in_public_api
  _DonationTypeWidgetState createState() => _DonationTypeWidgetState();
}

class _DonationTypeWidgetState extends State<DonationTypeWidget> {
  List<int> selectedDonationTypeIds = [];  // Now a list of selected IDs

  final List<Map<String, dynamic>> clothingTypes = [
    {'id': 1, 'icon': 'assets/icons/pants.svg', 'label': 'بناطيل', 'color': Colors.grey},  // Pants
    {'id': 2, 'icon': 'assets/icons/shirt.svg', 'label': 'قمصان', 'color': Colors.blue},  // Shirts
    {'id': 3, 'icon': 'assets/icons/jacket.svg', 'label': 'جاكيتات', 'color': Colors.brown},  // Coats & Jackets
    {'id': 4, 'icon': 'assets/icons/dress.svg', 'label': 'فساتين', 'color': Colors.pink},  // Dresses
    {'id': 5, 'icon': 'assets/icons/children_clothing.svg', 'label': 'ملابس أطفال', 'color': Colors.lightGreen},  // Children's Clothing
    {'id': 6, 'icon': 'assets/icons/shoe.svg', 'label': 'أحذية', 'color': Colors.black},  // Footwear
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
          itemCount: clothingTypes.length,
          itemBuilder: (context, index) {
            var item = clothingTypes[index];
            bool isSelected = selectedDonationTypeIds.contains(item['id']);
            return GestureDetector(
              onTap: () {
                setState(() {
                  if (isSelected) {
                    selectedDonationTypeIds.remove(item['id']);
                  } else {
                    selectedDonationTypeIds.add(item['id']);
                  }
                  widget.onSelected(List.from(selectedDonationTypeIds));  // Callback with a copy of the list
                });
              },
              child: Card(
                color: isSelected ? Colors.green[100] : null,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    SvgPicture.asset(
                      item['icon'],
                      height: 30,
                      color: item['color'],
                    ),
                    const SizedBox(height: 4),
                    Text(item['label'], style: TextStyle(color: item['color'])),
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