import 'package:flutter/material.dart';

class SaleOrDonationSelector extends StatefulWidget {
  final Function(int) onSelected;

  SaleOrDonationSelector({Key? key, required this.onSelected}) : super(key: key);

  @override
  _SaleOrDonationSelectorState createState() => _SaleOrDonationSelectorState();
}

class _SaleOrDonationSelectorState extends State<SaleOrDonationSelector> {
  bool isForSale = false; // Tracks whether the item is for sale
  int? selectedCollectionTypeId; // To store the ID based on the selection

  void _updateSelection(bool forSale) async {
    await Future.delayed(Duration(milliseconds: 100)); // Simulated delay for a realistic interaction
    int id = forSale ? 1 : 2; // Assigns 1 for sale, 2 for donation
    setState(() {
      isForSale = forSale;
      selectedCollectionTypeId = id; // Update the state with the new ID
    });
    widget.onSelected(id); // Call the callback with the new ID
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(top: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // For Sale Option
          GestureDetector(
            onTap: () => _updateSelection(true),
            child: AnimatedContainer(
              duration: Duration(milliseconds: 300),
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isForSale ? Colors.green : Colors.grey[200],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: isForSale ? Colors.green : Colors.grey,
                ),
              ),
              child: Text(
                'للبيع؟',
                style: TextStyle(
                  fontSize: 14,
                  color: isForSale ? Colors.white : Colors.grey[800],
                ),
              ),
            ),
          ),
          // For Donation Option
          GestureDetector(
            onTap: () => _updateSelection(false),
            child: AnimatedContainer(
              duration: Duration(milliseconds: 300),
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: !isForSale ? Colors.blue : Colors.grey[200],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: !isForSale ? Colors.blue : Colors.grey,
                ),
              ),
              child: Text(
                'للتبرع؟',
                style: TextStyle(
                  fontSize: 14,
                  color: !isForSale ? Colors.white : Colors.grey[800],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}