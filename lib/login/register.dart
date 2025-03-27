import 'dart:io';
import 'package:google_fonts/google_fonts.dart';
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
    {'label': 'بلاستيك', 'value': '1'},
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
    MultiSelectItem('1', 'بلاستيك'),
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
          const SnackBar(content: Text('فشل تحميل المواقع')),
        );
      });
    }
  }

    @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('إنشاء حساب'),
        backgroundColor: Color(0xFFE8F5E9),
        elevation: 0,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFFE8F5E9), Color(0xFFC8E6C9)],
            ),
          ),
        ),
      ),
      body: Container(
        height: MediaQuery.of(context).size.height,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFE8F5E9), Color(0xFFC8E6C9)],
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: <Widget>[
              SizedBox(height: MediaQuery.of(context).padding.top + 20),
              UploadPhotoSection(onImageSelected: setImage),
              SizedBox(height: 20),
              // Update all form fields with new styling
              _buildRoleDropdown(),
              SizedBox(height: 15),
              _buildTextField(_nameController, 'أسم المستخدم', Icons.person),
              SizedBox(height: 15),
              _buildTextField(_emailController, 'الأيميل', Icons.email),
              SizedBox(height: 15),
              _buildPasswordField(),
              SizedBox(height: 15),
              _buildTextField(_phoneController, 'رقم الهاتف', Icons.phone),
              SizedBox(height: 15),
              _buildTextField(_addressController, 'العنوان', Icons.location_on),
              SizedBox(height: 15),
              if (widget.type == 'erecycleHUB') _buildLocationDropdown(),
              SizedBox(height: 15),
              // Add other conditional fields with updated styling
              _buildWasteTypeSection(),
              SizedBox(height: 30),
              _buildRegisterButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, IconData icon) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Color(0xFF2E7D32)),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide.none,
        ),
        filled: true,
        fillColor: Colors.white.withOpacity(0.9),
        contentPadding: EdgeInsets.symmetric(vertical: 15, horizontal: 20),
      ),
    );
  }

  Widget _buildPasswordField() {
    return TextFormField(
      controller: _passwordController,
      obscureText: _obscureText,
      decoration: InputDecoration(
        labelText: 'رقم السر',
        prefixIcon: Icon(Icons.lock, color: Color(0xFF2E7D32)),
        suffixIcon: IconButton(
          icon: Icon(_obscureText ? Icons.visibility_off : Icons.visibility,
            color: Color(0xFF2E7D32)),
          onPressed: () => setState(() => _obscureText = !_obscureText),
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide.none,
        ),
        filled: true,
        fillColor: Colors.white.withOpacity(0.9),
        contentPadding: EdgeInsets.symmetric(vertical: 15, horizontal: 20),
      ),
    );
  }

  Widget _buildRoleDropdown() {
    return widget.type == 'erecycleHUB'
        ? DropdownButtonFormField<String>(
            decoration: _dropdownDecoration('اختر قسم'),
            value: _selectedOption,
            onChanged: (String? newValue) => setState(() => _selectedOption = newValue),
            items: _userOptions.map((option) => DropdownMenuItem<String>(
              value: option['value'],
              child: Text(option['label']!,
                style: GoogleFonts.cairo(fontWeight: FontWeight.w500)),
            )).toList(),
          )
        : SizedBox.shrink();
  }

  Widget _buildLocationDropdown() {
    return DropdownButtonFormField<String>(
      decoration: _dropdownDecoration('المنطقة'),
      value: _selectedLocation,
      onChanged: (String? newValue) => setState(() => _selectedLocation = newValue),
      items: _locationOptions.map((option) => DropdownMenuItem<String>(
        value: option['value'],
        child: Text(option['label']!,
          style: GoogleFonts.cairo(fontWeight: FontWeight.w500)),
      )).toList(),
    );
  }

  InputDecoration _dropdownDecoration(String label) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(Icons.arrow_drop_down, color: Color(0xFF2E7D32)),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: BorderSide.none,
      ),
      filled: true,
      fillColor: Colors.white.withOpacity(0.9),
      contentPadding: EdgeInsets.symmetric(vertical: 2, horizontal: 20),
    );
  }

  Widget _buildRegisterButton() {
    return Material(
      borderRadius: BorderRadius.circular(15),
      elevation: 4,
      child: InkWell(
        onTap: _handleRegistration,
        borderRadius: BorderRadius.circular(15),
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(vertical: 15),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            gradient: LinearGradient(
              colors: [Color(0xFF43A047), Color(0xFF2E7D32)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.person_add, color: Colors.white),
              SizedBox(width: 10),
              Text('إنشاء حساب',
                style: GoogleFonts.cairo(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _handleRegistration() async {
    if (_emailController.text.isEmpty || 
        !_emailController.text.contains('@') || 
        !_emailController.text.contains('.') ||
        _emailController.text.indexOf('@') > _emailController.text.lastIndexOf('.')) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.error, color: Colors.white),
              SizedBox(width: 8),
              Text('بريد إلكتروني غير صحيح'),
            ],
          ),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 3),
          action: SnackBarAction(
            label: 'مثال',
            textColor: Colors.white,
            onPressed: () {
              _emailController.text = 'example@domain.com';
            },
          ),
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

    final password = _passwordController.text;
    if (!_isPasswordStrong(password)) {
      _showPasswordRequirementsDialog();
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

    final phoneDigits = _phoneController.text.replaceAll(RegExp(r'[^0-9]'), '');
    if (phoneDigits.length < 10) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Row(
            children: [
              Icon(Icons.error, color: Colors.white),
              SizedBox(width: 8),
              Text('رقم الهاتف يجب أن يحتوي على 10 أرقام على الأقل'),
            ],
          ),
          backgroundColor: Colors.red,
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

    final nameParts = _nameController.text.trim().split(' ');
    if (nameParts.length < 2) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Row(
            children: [
              Icon(Icons.error, color: Colors.white),
              SizedBox(width: 8),
              Text('الاسم يجب أن يحتوي على كلمتين على الأقل'),
            ],
          ),
          backgroundColor: Colors.red,
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

    widget.type == "dry_clean"
    ? _selectedOption = "Donater"
    : _selectedOption;

    var response = await ApiService.register(collectionData, _collectionImage, _selectedOption.toString());
    if (response != null && response.statusCode == 200) {
      print('Collection created successfully!');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Row(
            children: [
              Icon(Icons.check_circle, color: Colors.white), // Success icon
              SizedBox(width: 8), // Spacing between icon and text
              Text('تم إنشاء الحساب بنجاح'),
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
  }

  Widget _buildWasteTypeSection() {
    return Column(
      children: [
        if (widget.type == 'erecycleHUB' && _selectedOption != 'Generator')
          Column(
            children: [
              DropdownButtonFormField<String>(
                decoration: _dropdownDecoration('نوع المجموعة المختارة'),
                value: _selectedPreferdWasteGroup,
                onChanged: (String? newValue) => setState(() => _selectedPreferdWasteGroup = newValue),
                items: _preferdWasteGroupOptions.map((option) => DropdownMenuItem<String>(
                  value: option['value'],
                  child: Text(option['label']!,
                    style: GoogleFonts.cairo(fontWeight: FontWeight.w500)),
                )).toList(),
              ),
              SizedBox(height: 15),
            ],
          ),
        
        if (widget.type == 'erecycleHUB' && 
            ((_selectedOption == 'Generator') || 
            (_selectedOption == 'Picker' && _selectedPreferdWasteGroup == '1')))
          Column(
            children: [
              DropdownButtonFormField<String>(
                decoration: _dropdownDecoration('المجموعة المختارة'),
                value: _selectedWasteType,
                onChanged: (String? newValue) => setState(() => _selectedWasteType = newValue),
                items: _typesOptions.map((option) => DropdownMenuItem<String>(
                  value: option['value'],
                  child: Text(option['label']!,
                    style: GoogleFonts.cairo(fontWeight: FontWeight.w500)),
                )).toList(),
              ),
              SizedBox(height: 15),
            ],
          ),
        
        if (widget.type == 'erecycleHUB' && 
            (_selectedOption == 'Picker' && _selectedPreferdWasteGroup == '2'))
          Column(
            children: [
              MultiSelectDialogField(
                items: _items,
                title: Text("المجموعة المختارة", 
                  style: GoogleFonts.cairo(fontWeight: FontWeight.bold)),
                selectedColor: Color(0xFF2E7D32),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.9),
                  borderRadius: BorderRadius.all(Radius.circular(15)),
                  border: Border.all(color: Color(0xFF2E7D32)),
                ),
                buttonIcon: Icon(Icons.arrow_drop_down, color: Color(0xFF2E7D32)),
                buttonText: Text("اختر مجموعة",
                  style: GoogleFonts.cairo(
                    color: Colors.black54,
                    fontSize: 16
                  )),
                onConfirm: (results) => setState(() => _selectedValues = results),
              ),
              SizedBox(height: 15),
            ],
          ),
      ],
    );
  }

  bool _isPasswordStrong(String password) {
    // Minimum 8 characters
    if (password.length < 8) return false;
    
    // At least one uppercase letter
    if (!password.contains(RegExp(r'[A-Z]'))) return false;
    
    // At least one lowercase letter
    if (!password.contains(RegExp(r'[a-z]'))) return false;
    
    // At least one number
    if (!password.contains(RegExp(r'[0-9]'))) return false;
    
    // At least one special character
    if (!password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) return false;
    
    return true;
  }

  void _showPasswordRequirementsDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.warning, color: Colors.orange),
            SizedBox(width: 10),
            Text('متطلبات كلمة المرور', style: GoogleFonts.cairo()),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('يجب أن تحتوي كلمة المرور على:', style: GoogleFonts.cairo()),
            SizedBox(height: 10),
            _buildRequirementItem('8 أحرف على الأقل'),
            _buildRequirementItem('حرف كبير واحد على الأقل (A-Z)'),
            _buildRequirementItem('حرف صغير واحد على الأقل (a-z)'),
            _buildRequirementItem('رقم واحد على الأقل (0-9)'),
            _buildRequirementItem('رمز خاص واحد على الأقل (!@#\$% إلخ)'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('حسناً', style: GoogleFonts.cairo(color: Color(0xFF2E7D32))),
          ),
        ],
      ),
    );
  }

  Widget _buildRequirementItem(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(Icons.check_circle, color: Color(0xFF2E7D32), size: 18),
          SizedBox(width: 8),
          Text(text, style: GoogleFonts.cairo(fontSize: 14)),
        ],
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.error, color: Colors.white),
            SizedBox(width: 8),
            Text(message),
          ],
        ),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}

