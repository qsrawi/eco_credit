import 'dart:io';
import 'package:eco_credit/e_recycle_hub.dart';
import 'package:eco_credit/sale-or-donation-selector.dart';
import 'package:eco_credit/services/api_service.dart';
import 'package:eco_credit/upload-photo-section.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'picker_widget.dart';  // Assuming you have this file
import 'waste_type_widget.dart';  // Assuming you have this file

class AddWasteCollectionScreen extends StatefulWidget {
  @override
  _AddWasteCollectionScreenState createState() => _AddWasteCollectionScreenState();
}

class _AddWasteCollectionScreenState extends State<AddWasteCollectionScreen> {
  // bool _isSellChecked = false;
  // bool _isDonateChecked = false;
  File? _collectionImage;
  int? _pickerId;
  int? _wasteTypeId;
  int? _collectionTypeId = 2;
  final TextEditingController _descriptionController = TextEditingController();

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

  void setPickerId(int pickerId) {
    setState(() {
      _pickerId = pickerId; // Updates the image in the state
    });
  }

  void setWasteTypeId(int wasteTypeId) {
    setState(() {
      _wasteTypeId = wasteTypeId; // Updates the image in the state
    });
  }

  void setCollectionTypeId(int collectionTypeId) {
    setState(() {
      _collectionTypeId = collectionTypeId; // Updates the image in the state
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          '♻️ خطوة صغيرة منك في التدوير، تصنع أثر كبير على البيئة',
          style: GoogleFonts.cairo(
            textStyle: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              height: 1.4,
              letterSpacing: 0.5,
            ),
          ),
          textAlign: TextAlign.right,
        ),
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
                builder: (context) => ERecycleHub(id: someId, role: someRole),
              ),
            );
          },
        ),
      ),
body: LayoutBuilder(
  builder: (context, constraints) {
    return SingleChildScrollView(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          minHeight: constraints.maxHeight,
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: LinearProgressIndicator(
                  value: 0.33,
                  backgroundColor: Colors.grey[300],
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                ),
              ),
              const SizedBox(height: 20),
              UploadPhotoSection(
                onImageSelected: setImage,
                titleText: "إضافة صور المواد القابلة للتدوير",
              ),
              ConstrainedBox(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.4,
                  minHeight: 100,
                ),
                child: PickerWidget(onSelected: setPickerId),
              ),
              WasteTypeWidget(onSelected: setWasteTypeId),
              SaleOrDonationSelector(onSelected: setCollectionTypeId),
              _buildDescriptionInput(),
                         Padding(
              padding: const EdgeInsets.symmetric(vertical: 20.0),
              child: ElevatedButton(
              onPressed: () async {
              SharedPreferences prefs = await SharedPreferences.getInstance();
              int userId = prefs.getInt('id') ?? 1;
              String userType = prefs.getString('role') ?? 'Generator';

                // Assuming _collectionImage is updated through setImage method as per previous discussions
                if (_collectionImage == null) {
                  print('لا يوجد صورة مرفوعة');
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('لا يوجد صورة مرفوعة'),
                      backgroundColor: Colors.red, // Red for error
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                  return;
                }

                if (_pickerId == null) {
                  print('No Eco Champion');
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('اختر بطل بيئة'),
                      backgroundColor: Colors.red, // Red for error
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                  return;
                }

                _wasteTypeId ??= prefs.getInt('wasteTypeID') ?? 1;

                Map<String, dynamic> collectionData = {
                  'GeneratorID': userId,
                  'PickerID': _pickerId,
                  'CollectionStatusID': 1,
                  'CollectionTypeID': _collectionTypeId,
                  'WasteTypeID': _wasteTypeId,
                  'Description': _descriptionController.text,
                };

                var response = await ApiService.createCollectionWithImage(collectionData, _collectionImage);
                if (response != null && response.statusCode == 200) {
                  print('Collection created successfully!');
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Row(
                        children: [
                          Icon(Icons.check_circle, color: Colors.white), // Success icon
                          SizedBox(width: 8), // Spacing between icon and text
                          Text('♻️ معًا نجعل التدوير عادة، والبيئة أكثر نظافة !'),
                        ],
                      ),
                      backgroundColor: Colors.green, // Green for success
                      behavior: SnackBarBehavior.floating,
                    ),
                  );

                  // Clear the form data
                  _descriptionController.clear();
                  _collectionImage = null;
                  _pickerId = null;
                  _collectionTypeId = null;
                  _wasteTypeId = null;

                  // Navigate to HomeScreen
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => ERecycleHub(id: userId, role: userType)),
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
      ),
    );
  },
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
          hintText: 'ادخل وصف مجموعة النفايات',
          // Align label and hint text to the right
          alignLabelWithHint: true,
        ),
        textAlign: TextAlign.right, // Right-align the text
        maxLines: 3, // Allows for multi-line input
      ),
    );
  }

}

