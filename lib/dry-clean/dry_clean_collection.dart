import 'dart:convert';
import 'dart:typed_data';
import 'package:eco_credit/dry-clean/dry_clean.dart';
import 'package:eco_credit/services/dry_clean_service.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class dryCleanCollectionCard extends StatelessWidget {
  final int id;
  final String role;
  final double size;
  final String locationName;
  final List<String> typesNames;
  final String image;
  final String timeAgo;
  final String description;
  final String donationStatusName;
  final String donaterName;

  const dryCleanCollectionCard({
    required this.id,
    required this.role,
    required this.size,
    required this.locationName,
    required this.typesNames,
    required this.image,
    required this.timeAgo,
    required this.donationStatusName,
    required this.description,
    required this.donaterName,
  });

  void _showDetails(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              getImageWidget(image, 150),
              const SizedBox(height: 20),
              Text(description, style: const TextStyle(fontSize: 16)),
              const SizedBox(height: 10),
              Text(
                'عدد الملابس: $size حبة تقريبا',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                textAlign: TextAlign.right,
              )
            ],
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('إغلاق'),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        );
      },
    );
  }

 Widget build(BuildContext context) {
  return GestureDetector(
    onTap: () => _showDetails(context),
    child: Padding(
      padding: const EdgeInsets.all(8.0), // Add padding around the card
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(  // Change from Row to Column to stack elements vertically
            crossAxisAlignment: CrossAxisAlignment.stretch, // Ensures the card stretches to fill the width
            children: <Widget>[
              Row(  // This Row contains the main content
                mainAxisAlignment: MainAxisAlignment.end, // Align everything to the right
                children: <Widget>[
                  Expanded(  // Ensure Column for text does not overflow
                    child: Column(  // Contains all text data
                      crossAxisAlignment: CrossAxisAlignment.end, // Align text to the right
                      children: <Widget>[
                        Text(
                          donationStatusName,
                          style: TextStyle(
                            color: donationStatusName == 'بانتظار الاستلام' ? Colors.orange : Colors.green,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          typesNames.join(', '),
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          timeAgo,
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'اسم المتبرع: $donaterName',
                          style: const TextStyle(
                            color: Colors.blue,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10), // Add spacing between data and image
                  // Image on the far right
                  Container(
                    padding: const EdgeInsets.all(4.0), // Add padding around the image
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8.0),
                      color: Colors.grey[200], // Optional: Add a background color
                    ),
                    child: getImageWidget(image, 80),
                  ),
                ],
              ),
              // Conditional button block here
              if (role == "DCAdmin" && donationStatusName == 'بانتظار الاستلام') ...[
                const SizedBox(height: 10),// Add space before the buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                const SizedBox(height: 10),// Add space before the buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    ElevatedButton(
                      onPressed: () async {
                      SharedPreferences prefs = await SharedPreferences.getInstance();
                      int userId = prefs.getInt('id') ?? 1;
                      String userType = prefs.getString('role') ?? 'Generator';
                      
                        DonationUpdateModel model = DonationUpdateModel(
                          id: id,
                          donationStatusID: 2,
                        );
                        DryCleanApiService apiService = DryCleanApiService();
                        await apiService.updateDonation(model);
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(builder: (context) => DryClean(id: userId, role: userType)),
                          (route) => false, // Remove all previous routes
                        );
                      },
                      child: const Text('تجاهل', style: TextStyle(color: Colors.red)),
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
                          const EdgeInsets.symmetric(horizontal: 60, vertical: 5)
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
                       DonationUpdateModel model = DonationUpdateModel(
                          id: id,
                          donationStatusID: 3,
                        );

                      // Call the API to update the collection
                      DryCleanApiService apiService = DryCleanApiService();
                      await apiService.updateDonation(model);
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(builder: (context) => DryClean(id: userId, role: userType)),
                        (route) => false, // Remove all previous routes
                      ); // Pass `true` to indicate success
                    },
                      child: const Text('تم الاستلام', style: TextStyle(color: Colors.white)),
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
                          const EdgeInsets.symmetric(horizontal: 60, vertical: 5)
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
              ],
                ),
              ],
            ],
          ),
        ),
      ),
    ),
  );
}
}


Widget getImageWidget(String image, double size) {
  // Check if the image string contains a base64 data prefix
  if (image.startsWith('assets/images')) {
    // Assuming it's an asset path
    return Image.asset(
      image,
      width: 80,
      height: 80,
      fit: BoxFit.cover,
    );
  } else {
    // Assuming it's a base64 string after 'data:image/jpeg;base64,'
    return Image.memory(
      base64Decode(image),
      width: size,
      height: size,
      fit: BoxFit.cover,
    );
  }
}

Widget _buildImageFromBase64(String base64String) {
  Uint8List bytes;

  try {
    if (base64String.startsWith('data:image')) {
      // Remove the prefix from the base64 string
      base64String = base64String.split(',')[1];
    }
    bytes = base64Decode(base64String);
  } catch (e) {
    // Handle the error of an invalid base64 string
    return const Text('Invalid image data');
  }

  return Image.memory(
    bytes,
    width: double.infinity,
    height: 100,
    fit: BoxFit.cover,
  );
}