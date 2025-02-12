import 'dart:convert';
import 'package:eco_credit/e_recycle_hub.dart';
import 'package:eco_credit/services/api_service.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class WasteCollectionCard extends StatelessWidget {
  final int collectionID;
  final String role;
  final String status; // حالة الجمع
  final int statusID; // حالة الجمع
  final String title; // العنوان
  final String name; // الاسم
  final String pickerName; // اسم الجامع
  final String collectionTypeName; // نوع الجمع
  final String imageUrl; // صورة مُكودة بنظام Base64
  final String timeAgo; // منذ
  final double collectionSize; // حجم الجمع
  final String description;

  const WasteCollectionCard({
    required this.collectionID,
    required this.role,
    required this.status,
    required this.statusID,
    required this.title,
    required this.collectionTypeName,
    required this.name,
    required this.pickerName,
    required this.imageUrl,
    required this.timeAgo,
    required this.collectionSize,
    required this.description,
  });

  void _showDetails(BuildContext context) {
    final imageBytes = base64Decode(imageUrl);
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Image.memory(imageBytes, width: 300, height: 300, fit: BoxFit.cover),
              SizedBox(height: 20),
              Text(description, style: TextStyle(fontSize: 16)),
              SizedBox(height: 10),
              Text(
                'حجم الجمع: $collectionSize كغ', // "كغ" stands for kilograms in Arabic
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                textAlign: TextAlign.right,
              )
            ],
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Close'),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _showDetails(context),
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: collectionTypeName == 'للبيع' ? Colors.red : Colors.green,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      collectionTypeName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  Text(
                    status,
                    style: TextStyle(
                      color: status == 'بالانتظار' ? Colors.orange : Colors.green,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Image.memory(
                base64Decode(imageUrl),
                width: double.infinity,
                height: 100,
                fit: BoxFit.cover,
              ),
              const SizedBox(height: 10),
              Align(
                alignment: Alignment.centerRight,
                child: Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ),
              const SizedBox(height: 5),
              Align(
                alignment: Alignment.centerRight,
                child: Text(
                  '$name - $timeAgo',
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 14,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Align(
                alignment: Alignment.centerRight,
                child: Text(
                  'الجمع: $pickerName',
                  style: const TextStyle(
                    color: Colors.blue,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
              if (role == "Picker" && statusID == 1) ...[
                const SizedBox(height: 10),// Add space before the buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    ElevatedButton(
                      onPressed: () async {
                      SharedPreferences prefs = await SharedPreferences.getInstance();
                      int userId = prefs.getInt('id') ?? 1;
                      String userType = prefs.getString('role') ?? 'Generator';
                      
                        CollectionModel model = CollectionModel(
                          collectionID: collectionID,
                          collectionStatusID: 2,
                        );
                        ApiService apiService = ApiService();
                        await apiService.updateCollection(model);
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(builder: (context) => ERecycleHub(id: userId, role: userType)),
                          (route) => false, // Remove all previous routes
                        );
                      },
                      child: const Text('رفض', style: TextStyle(color: Colors.red)),
                      style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.resolveWith<Color>(
                          (Set<MaterialState> states) {
                            if (states.contains(MaterialState.pressed)) {
                              return Colors.white.withOpacity(0.9); // Light opacity when pressed
                            }
                            return Colors.white; // Default non-pressed state
                          }
                        ),
                        foregroundColor: MaterialStateProperty.all<Color>(Colors.red),
                        padding: MaterialStateProperty.all<EdgeInsets>(
                          const EdgeInsets.symmetric(horizontal: 75, vertical: 10)
                        ),
                        shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                          RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8), // Smaller border radius
                            side: BorderSide(color: Colors.red, width: 0.8), // Red border color
                          )
                        ),
                        overlayColor: MaterialStateProperty.resolveWith<Color>(
                          (Set<MaterialState> states) {
                            if (states.contains(MaterialState.hovered) || states.contains(MaterialState.pressed)) {
                              return Colors.red.withOpacity(0.1); // Hover and click effect color
                            }
                            return Colors.transparent; // Default is transparent
                          }
                        ),
                      ),
                    ),
                    const SizedBox(width: 10), // Space between buttons
                    ElevatedButton(
                    onPressed: () async {
                      SharedPreferences prefs = await SharedPreferences.getInstance();
                      int userId = prefs.getInt('id') ?? 1;
                      String userType = prefs.getString('role') ?? 'Generator';
                      // Create the updated model
                      CollectionModel model = CollectionModel(
                        collectionID: collectionID,
                        collectionStatusID: 3, // Assuming 3 is the new status
                      );

                      // Call the API to update the collection
                      ApiService apiService = ApiService();
                      await apiService.updateCollection(model);
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(builder: (context) => ERecycleHub(id: userId, role: userType)),
                        (route) => false, // Remove all previous routes
                      ); // Pass `true` to indicate success
                    },
                      child: const Text('قبول', style: TextStyle(color: Colors.white)),
                      style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.resolveWith<Color>(
                          (Set<MaterialState> states) {
                            if (states.contains(MaterialState.pressed)) {
                              return Colors.green.withOpacity(0.9); // Light opacity when pressed
                            }
                            return Colors.green; // Default non-pressed state
                          }
                        ),
                        foregroundColor: MaterialStateProperty.all<Color>(Colors.white),
                        padding: MaterialStateProperty.all<EdgeInsets>(
                          const EdgeInsets.symmetric(horizontal: 75, vertical: 10)
                        ),
                        shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                          RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8), // Smaller border radius
                            side: BorderSide(color: Colors.green, width: 0.8), // Matching border color
                          )
                        ),
                        overlayColor: MaterialStateProperty.resolveWith<Color>(
                          (Set<MaterialState> states) {
                            if (states.contains(MaterialState.hovered) || states.contains(MaterialState.pressed)) {
                              return Colors.green.withOpacity(0.1); // Hover and click effect color
                            }
                            return Colors.transparent; // Default is transparent
                          }
                        ),
                      ),
                    ),
                  ],
                ),
              ]
            ],
          ),
        ),
      ),
    );
  }
}
