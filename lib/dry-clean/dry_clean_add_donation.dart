import 'dart:io';
import 'package:eco_credit/dry-clean/dry_clean.dart';
import 'package:eco_credit/dry-clean/dry_clean_donation_type.dart';
import 'package:eco_credit/services/dry_clean_service.dart';
import 'package:eco_credit/upload-photo-section.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DryCleanAddDonationScreen extends StatefulWidget {
  const DryCleanAddDonationScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _DryCleanAddDonationScreenState createState() => _DryCleanAddDonationScreenState();
}

class _DryCleanAddDonationScreenState extends State<DryCleanAddDonationScreen> {
  // bool _isSellChecked = false;
  // bool _isDonateChecked = false;
  File? _collectionImage;
  List<int?>? _donationTypeIds;
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _sizeController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _latitudController = TextEditingController();
  final TextEditingController _longitudeController = TextEditingController();

  @override
  void dispose() {
    _descriptionController.dispose(); // Proper cleanup
    super.dispose();
  }

  void setImage(File image) {
    setState(() {
      _collectionImage = image; // Updates the image in the state
    });
  }

  void setDonationTypeId(List<int> donationTypeId) {
    setState(() {
      _donationTypeIds = donationTypeId; // Updates the image in the state
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('أضافة مجموعة جديدة'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () async {
            // Retrieve values from SharedPreferences
            SharedPreferences prefs = await SharedPreferences.getInstance();
            int someId = prefs.getInt('id') ?? 0; // Provide a default value in case it's null
            String someRole = prefs.getString('role') ?? ''; // Provide a default value in case it's null

            // Navigate to ERecycleHub with the retrieved values
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => DryClean(id: someId, role: someRole),
              ),
            );
          },
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: LinearProgressIndicator(
                value: 0.33,  // Adjust value based on current step
                backgroundColor: Colors.grey[300],
                valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
              ),
            ),
            const SizedBox(height: 20),
            UploadPhotoSection(onImageSelected: setImage),
            _buildSizeInput(),
            _buildLocationInput(),
            DonationTypeWidget(onSelected: setDonationTypeId),
            _buildDescriptionInput(),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20.0),
              child: ElevatedButton(
              onPressed: () async {
              SharedPreferences prefs = await SharedPreferences.getInstance();
              int userId = prefs.getInt('id') ?? 1;
              String userType = prefs.getString('role') ?? 'Generator';

                // Assuming _collectionImage is updated through setImage method as per previous discussions
                if (_sizeController.text.isEmpty) {
                  print('No Size');
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('لا يوجد حجم مختار'),
                      backgroundColor: Colors.red, // Red for error
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                  return;
                }

                if (_locationController.text.isEmpty) {
                  print('No Eco Champion');
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('اختر موقع'),
                      backgroundColor: Colors.red, // Red for error
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                  return;
                }

                // _donationTypeId ??= prefs.getString('DonationTypeID') as int?;

                Map<String, dynamic> collectionData = {
                  'Size': int.parse(_sizeController.text),
                  'Types': _donationTypeIds,
                  'DonationStatusID': 1,
                  'DonaterID': userId,
                  'Longitude': _longitudeController.text,
                  'Latitude': _latitudController.text,
                  'LocationName': _locationController.text,
                  'Description': _descriptionController.text,
                };

                var response = await DryCleanApiService.createDonation(collectionData, _collectionImage);
                if (response != null && response.statusCode == 200) {
                  print('Collection created successfully!');
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Row(
                        children: [
                          Icon(Icons.check_circle, color: Colors.white), // Success icon
                          SizedBox(width: 8), // Spacing between icon and text
                          Text('Collection added successfully!'),
                        ],
                      ),
                      backgroundColor: Colors.green, // Green for success
                      behavior: SnackBarBehavior.floating,
                    ),
                  );

                  // Clear the form data
                  _collectionImage = null;
                  _descriptionController.clear();
                  _sizeController.clear();
                  _locationController.clear();
                  _latitudController.clear();
                  _longitudeController.clear();

                  // Navigate to HomeScreen
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => DryClean(id: userId, role: userType)),
                    (route) => false, // Remove all previous routes
                  );
                } else {
                  print('Failed to submit collection. Status code: ${response?.statusCode}');
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Row(
                        children: [
                          Icon(Icons.error, color: Colors.white), // Error icon
                          SizedBox(width: 8), // Spacing between icon and text
                          Text('Failed to add collection!'),
                        ],
                      ),
                      backgroundColor: Colors.red, // Red for error
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                }
              },
                child: Text('أضافة المجموعة'),
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all<Color>(Colors.green),
                  foregroundColor: MaterialStateProperty.all<Color>(Colors.white),
                  padding: MaterialStateProperty.all<EdgeInsets>(
                    EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDescriptionInput() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: TextField(
        controller: _descriptionController, // Attach the controller here
        decoration: InputDecoration(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          labelText: 'وصف',
          hintText: 'ادخل وصف المجموعة',
          // Align label and hint text to the right
          alignLabelWithHint: true,
        ),
        textAlign: TextAlign.right, // Right-align the text
        maxLines: 3, // Allows for multi-line input
      ),
    );
  }

Widget _buildSizeInput() {
  return Padding(
    padding: const EdgeInsets.all(16.0),
    child: Directionality(
                textDirection: TextDirection.rtl,
    child: TextFormField(
              controller: _sizeController,
              decoration: const InputDecoration(
                labelText: 'عدد', // Arabic for 'Size'
                suffixText: 'قطع ملابس', 
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
    )
  );
}

 Widget _buildLocationInput() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: TextFormField(
          controller: _locationController,
          decoration: const InputDecoration(
            labelText: 'الموقع', // Arabic for 'Location'
            suffixIcon: Icon(Icons.share_location_sharp),
            border: OutlineInputBorder(),
          ),
          readOnly: true,
          onTap: () => _openMap(context),
        ),
      ),
    );
  }

void _openMap(BuildContext context) async {
  Position position = await _determinePosition();
  double long;
  double law;

  if (_longitudeController.text.isEmpty) {
    long = position.longitude;  // Use current latitude as fallback
  } else {
    long = double.tryParse(_longitudeController.text) ?? position.longitude;  // Try parsing, fallback to latitude if parsing fails
  }

  if (_latitudController.text.isEmpty) {
    law = position.latitude;  // Use current latitude as fallback
  } else {
    law = double.tryParse(_latitudController.text) ?? position.latitude;  // Try parsing, fallback to latitude if parsing fails
  }

  LatLng initialPosition = LatLng(law, long);

  Navigator.of(context).push(MaterialPageRoute(
    builder: (context) => Scaffold(
      body: FlutterMap(
        options: MapOptions(
          initialCenter: initialPosition,
          initialZoom: 13.0,
          onTap: (tapPosition, latlng) async {
            List<Placemark> placemarks = await placemarkFromCoordinates(latlng.latitude, latlng.longitude);
            String locationName = placemarks.isNotEmpty ? '${placemarks.first.name}, ${placemarks.first.locality}, ${placemarks.first.country}' : 'Unknown location';
            _locationController.text = locationName;
            // Optionally save the latitude and longitude
            _longitudeController.text = latlng.longitude.toString();
            _latitudController.text = latlng.latitude.toString();
            saveLocation(latlng.latitude, latlng.longitude, locationName);
            Navigator.of(context).pop();
          },
        ),
        children: [
          TileLayer(
            urlTemplate: "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
          ),
        ],
      ),
    ),
  ));
}

Future<Position> _determinePosition() async {
  bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
  if (!serviceEnabled) {
    _showDialog('الرجاء تفعيل خدمة الموقع');
    return Future.error('Location services disabled');
  }

  LocationPermission permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied) {
      _showDialog('تم رفض إذن الموقع');
      return Future.error('Location permissions denied');
    }
  }

  if (permission == LocationPermission.deniedForever) {
    _showDialog('الإذن مرفوض بشكل دائم');
    return Future.error('Permanent location permission denial');
  }

  return await Geolocator.getCurrentPosition(
    desiredAccuracy: LocationAccuracy.low, // Reduced accuracy requirement
    timeLimit: const Duration(seconds: 10), // Add timeout
  );
}

void _showDialog(String message) {
  showDialog(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text('Location Error'),
      content: Text(message),
      actions: <Widget>[
        TextButton(
          child: Text('OK'),
          onPressed: () => Navigator.of(ctx).pop(),
        ),
      ],
    ),
  );
}

  void saveLocation(double latitude, double longitude, String locationName) {}


}