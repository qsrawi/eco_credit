import 'dart:io';
import 'package:multi_select_flutter/multi_select_flutter.dart';
import 'package:eco_credit/login/login.dart';
import 'package:eco_credit/services/api_service.dart';
import 'package:eco_credit/upload-photo-section.dart';
import 'package:flutter/material.dart';

class RegisterPage extends StatefulWidget {
  final String type;

  RegisterPage({required this.type});

  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();

  File? _collectionImage;
  bool _obscureText = true;
  String? _selectedOption;
  String? _selectedWasteType;
  String? _selectedLocation;
  String? _selectedPreferdWasteGroup;
  List<dynamic> _selectedValues = [];
  List<Map<String, String>> _userOptions = [
    {'label': 'منشأة', 'value': 'Generator'},
    {'label': 'بطل البيئة', 'value': 'Picker'},
  ];
  List<Map<String, String>> _locationOptions = [];
  final List<Map<String, String>> _typesOptions = [
    {'label': 'كرتون', 'value': '3'},
    {'label': 'بلاستك', 'value': '1'},
    {'label': 'ورق', 'value': '2'},
    {'label': 'معادن', 'value': '4'},
    {'label': 'خشب', 'value': '5'},
    {'label': 'زجاج', 'value': '6'},
  ];
  final List<Map<String, String>> _preferdWasteGroupOptions = [
    {'label': 'صنف واحد', 'value': '1'},
    {'label': 'عدة أصناف', 'value': '2'},
    {'label': 'جميع الانواع', 'value': '3'}
  ];
  final List<MultiSelectItem<dynamic>> _items = [
    MultiSelectItem('1', 'بلاستك'),
    MultiSelectItem('2', 'ورق'),
    MultiSelectItem('3', 'كرتون'),
    MultiSelectItem('4', 'معادن'),
    MultiSelectItem('5', 'خشب'),
    MultiSelectItem('6', 'زجاج')
  ];

  void setImage(File image) {
    setState(() {
      _collectionImage = image; // Updates the image in the state
    });
  }
  
  @override
  void initState() {
    super.initState();
    if (_userOptions.isNotEmpty) {
      _selectedOption = _userOptions[1]['value'];
    }
    if (_typesOptions.isNotEmpty) {
      _selectedWasteType = _typesOptions[0]['value'];
    }
    if (_preferdWasteGroupOptions.isNotEmpty) {
      _selectedPreferdWasteGroup = _preferdWasteGroupOptions[0]['value'];
    }
    // Set user options based on the type
    if (widget.type == 'dry_clean') {

      _userOptions = [
        {'label': 'ادمن', 'value': 'DCAdmin'},
        {'label': 'متبرع', 'value': 'Donater'},
      ];
    } else if (widget.type == 'erecycleHUB') {
      _userOptions = [
        {'label': 'منشأة', 'value': 'Generator'},
        {'label': 'بطل البيئة', 'value': 'Picker'},
      ];

      // Fetch locations from API
      final apiService = ApiService();
      apiService.getLookups("Location").then((locations) {
        if (mounted) {
          setState(() {
            _locationOptions = locations.map<Map<String, String>>((location) {
              return {
                'label': location.value ?? 'Unknown Location',
                'value': location.lkpID?.toString() ?? ''
              };
            }).toList();
          _selectedLocation = _locationOptions.first['value'];

          });
          // _selectedOption = '1';  // To keep track of the selected dropdown item
          // _selectedWasteType = '1';
        }
      }).catchError((error) {
        print('Error fetching locations: $error');
        // Optional: Show error to user
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('فشل تحميل المواقع')),
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('إنشاء حساب'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: <Widget>[
            UploadPhotoSection(onImageSelected: setImage),
            SizedBox(height: 10),
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(
                labelText: 'اختر قسم',
                border: OutlineInputBorder(),
                hintText: 'اختر من القائمة', // Add hint text
              ),
              value: _selectedOption,
              onChanged: (String? newValue) {
                setState(() {
                  _selectedOption = newValue;
                  // Reset preferred waste group when option changes to '1'
                  if (newValue == 'Generator') {
                    _selectedPreferdWasteGroup = null;
                  }
                });
              },
              items: [
                // Default option
                DropdownMenuItem<String>(
                  value: null,
                  child: Container(
                    height: 40,
                    alignment: Alignment.centerLeft,
                    child: const Text(
                      'اختر من القائمة',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),
                ),
                ..._userOptions.map<DropdownMenuItem<String>>((Map<String, String> option) {
                  return DropdownMenuItem<String>(
                    value: option['value'],
                    child: Container(
                      height: 40,
                      alignment: Alignment.centerLeft,
                      child: Text(
                        option['label'] ?? 'غير معروف',
                        style: const TextStyle(fontSize: 16),
                      ),
                    ),
                  );
                }).toList(),
              ],
              validator: (value) => value == null ? 'يجب اختيار قسم' : null,
            ),
            SizedBox(height: 10),
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'أسم المستخدم',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            SizedBox(height: 10),
            TextFormField(
              controller: _emailController,
              decoration: const InputDecoration(
                labelText: 'الأيميل',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            SizedBox(height: 10),
            TextFormField(
              controller: _passwordController,
              decoration: InputDecoration(
                labelText: 'رقم السر',
                border: OutlineInputBorder(),
                suffixIcon: IconButton(
                  icon: Icon(_obscureText ? Icons.visibility_off : Icons.visibility),
                  onPressed: () {
                    setState(() {
                      _obscureText = !_obscureText;
                    });
                  },  // Toggle password visibility
                ),
              ),
              obscureText: _obscureText,
            ),
            SizedBox(height: 10),
            TextFormField(
              controller: _phoneController,
              decoration: const InputDecoration(
                labelText: 'رقم الهاتف',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.phone,
            ),
            SizedBox(height: 10),
            TextFormField(
              controller: _addressController,
              decoration: const InputDecoration(
                labelText: 'العنوان',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.streetAddress,
            ),
            SizedBox(height: 10),
            DropdownButtonFormField<String>(
              value: _selectedLocation,
              onChanged: (String? newValue) {
                setState(() {
                  _selectedLocation = newValue;
                });
              },
              items: _locationOptions.map<DropdownMenuItem<String>>((Map<String, String> option) {
                return DropdownMenuItem<String>(
                  value: option['value'],
                  child: Container(
                          height: 40, // Set a fixed height for each dropdown item
                          alignment: Alignment.centerLeft,
                          child: Text(
                            option['label'] ?? 'Unknown', // Handle null case
                            style: TextStyle(fontSize: 16),
                          ),
                        ),
                );
              }).toList(),
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.green.withOpacity(0.1),
                contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: Colors.green),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: Colors.green),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: Colors.green, width: 2),
                ),
                labelText: 'المنطقة',
                labelStyle: TextStyle(color: Colors.black54),
                hintText: 'اختر المنطقة',
              ),
              icon: Icon(Icons.arrow_drop_down, color: Colors.green),
              iconSize: 30,
              style: TextStyle(color: Colors.black),
              dropdownColor: Colors.green[50],
              borderRadius: BorderRadius.circular(10),
              menuMaxHeight: 400, // Set a fixed maximum height for the dropdown menu

            ),
            SizedBox(height: 10),
            if (_selectedOption != 'Generator') // Changed condition here
              Column(
                children: [
                  DropdownButtonFormField<String>(
                    value: _selectedPreferdWasteGroup,  // Make sure this variable is declared in your state
                    onChanged: (String? newValue) {
                      setState(() {
                        _selectedPreferdWasteGroup = newValue;  // Changed to update the correct variable
                      });
                    },
                    items: _preferdWasteGroupOptions.map<DropdownMenuItem<String>>((Map<String, String> option) {
                      return DropdownMenuItem<String>(
                        value: option['value'],
                        child: Container(
                          height: 40,
                          alignment: Alignment.centerLeft,
                          child: Text(
                            option['label'] ?? 'Unknown',
                            style: TextStyle(fontSize: 16),
                          ),
                        ),
                      );
                    }).toList(),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.green.withOpacity(0.1),
                      contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(color: Colors.green),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(color: Colors.green),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(color: Colors.green, width: 2),
                      ),
                      labelText: 'نوع المجموعة المختارة',
                      labelStyle: TextStyle(color: Colors.black54),
                      hintText: 'اختر نوع',
                    ),
                    icon: Icon(Icons.arrow_drop_down, color: Colors.green),
                    iconSize: 30,
                    style: TextStyle(color: Colors.black),
                    dropdownColor: Colors.green[50],
                    borderRadius: BorderRadius.circular(10),
                  ),
                  SizedBox(height: 10),
                ],
              ),
            if ((_selectedOption == 'Generator') || (_selectedOption == 'Picker' && _selectedPreferdWasteGroup == '1')) // Changed condition here
              Column(
                children: [
                  DropdownButtonFormField<String>(
                    value: _selectedWasteType,
                    onChanged: (String? newValue) {
                      setState(() {
                        _selectedWasteType = newValue;
                      });
                    },
                    items: _typesOptions.map<DropdownMenuItem<String>>((Map<String, String> option) {
                      return DropdownMenuItem<String>(
                        value: option['value'],
                        child: Container(
                                height: 40, // Set a fixed height for each dropdown item
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  option['label'] ?? 'Unknown', // Handle null case
                                  style: TextStyle(fontSize: 16),
                                ),
                              ),
                      );
                    }).toList(),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.green.withOpacity(0.1),
                      contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(color: Colors.green),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(color: Colors.green),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(color: Colors.green, width: 2),
                      ),
                      labelText: 'المجموعة المختارة',
                      labelStyle: TextStyle(color: Colors.black54),
                      hintText: 'اختر مجموعة',
                    ),
                    icon: Icon(Icons.arrow_drop_down, color: Colors.green),
                    iconSize: 30,
                    style: TextStyle(color: Colors.black),
                    dropdownColor: Colors.green[50],
                    borderRadius: BorderRadius.circular(10),
                  ),
                  SizedBox(height: 10),
                ]
              ),
            if ((_selectedOption == 'Picker' && _selectedPreferdWasteGroup == '2')) // Changed condition here
              Column(
                children: [
                  MultiSelectDialogField(
                    items: _items,
                    title: Text("المجموعة المختارة"),
                    selectedColor: Colors.green,
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.1),
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                      border: Border.all(
                        color: Colors.green,
                        width: 2,
                      ),
                    ),
                    buttonIcon: Icon(
                      Icons.arrow_drop_down,
                      color: Colors.green,
                    ),
                    buttonText: Text(
                      "اختر مجموعة",
                      style: TextStyle(
                        color: Colors.black54,
                        fontSize: 16
                      )
                    ),
                    onConfirm: (results) {
                      setState(() {
                        _selectedValues = results;
                      });
                    },
                  ),
                  SizedBox(height: 30),
                ]
              ),
            ElevatedButton(
              onPressed: () async {
                if (_emailController.text.isEmpty) {
                  print('No Eco Champion');
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('الايميل غير موجود'),
                      backgroundColor: Colors.red, // Red for error
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                  return;
                }

                if (_passwordController.text.isEmpty) {
                  print('No Eco Champion');
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('رقم السر غير موجود'),
                      backgroundColor: Colors.red, // Red for error
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                  return;
                }

                if (_phoneController.text.isEmpty) {
                  print('No Eco Champion');
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('الهاتف غير موجود'),
                      backgroundColor: Colors.red, // Red for error
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                  return;
                }

                if (_nameController.text.isEmpty) {
                  print('No Eco Champion');
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('اسم المتسخدم غير موجود'),
                      backgroundColor: Colors.red, // Red for error
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                  return;
                }

                Map<String, dynamic> collectionData = {
                  'Name': _nameController.text,
                  'Password': _passwordController.text,
                  'Email': _emailController.text,
                  'Phone': _phoneController.text,
                  'WasteTypeID': _selectedWasteType,
                  'LocationID': _selectedLocation,
                  'Address': _addressController.text,
                  'PreferdWasteGroupID': _selectedPreferdWasteGroup,
                  'WasteGroupIDs': _selectedPreferdWasteGroup == '1' ? [_selectedWasteType] : _selectedValues,
                };

                var response = await ApiService.register(collectionData, _collectionImage, _selectedOption.toString());
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
                  _nameController.clear();
                  _passwordController.clear();
                  _emailController.clear();
                  _phoneController.clear();
                  _addressController.clear();
                  _collectionImage = null;
                  _selectedLocation = null;
                  _selectedWasteType = null;
                  _selectedOption = null;

                  // Navigate to HomeScreen
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => LoginPage(type: widget.type)),
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
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.black,
                backgroundColor: Colors.green,
                minimumSize: Size.fromHeight(50),
              ),
              child: const Text('إنشاء حساب'),
            ),
          ],
        ),
      ),
    );
  }
}
