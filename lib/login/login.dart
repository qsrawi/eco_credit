import 'package:eco_credit/dry-clean/dry_clean.dart';
import 'package:eco_credit/dry-clean/dry_clean_order_status_page.dart';
import 'package:eco_credit/e_recycle_hub.dart';
import 'package:eco_credit/login/register.dart';
import 'package:eco_credit/services/api_service.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class LoginPage extends StatefulWidget {
  final String type;

  LoginPage({required this.type});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _obscureText = true;
  String? _selectedOption;  // To keep track of the selected dropdown item
  String message = '♻️ امنح المواد حياة جديدة بإعادة تدويرها';

  List<Map<String, String>> _userOptions = [];

  @override
  void initState() {
    super.initState();
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
        {'label': 'ادمن', 'value': 'Admin'},
      ];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('تسجيل الدخول'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(5),
              child: ClipOval(
                child: Image.asset(
                  'assets/images/header2.png', // Path to your image
                  width: 180, // Adjust the width as needed
                  height: 180, // Adjust the height as needed to keep the circle aspect
                  fit: BoxFit.cover, // Cover ensures the image covers the clip area
                ),
              ),
            ),
            Text(
              message,
              style: GoogleFonts.cairo(
                textStyle: const TextStyle(
                  color: Colors.black, // Text color
                  fontSize: 14, // Font size
                ),
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 10),
            TextFormField(
              controller: _emailController,
              decoration: const InputDecoration(
                labelText: 'الأيميل',
                border: OutlineInputBorder(),
                errorBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.red),
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.green),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.green),
                ),
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            SizedBox(height: 20),
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
            SizedBox(height: 20),
            DropdownButtonFormField<String>(
              decoration: InputDecoration(
                labelText: 'اختر قسم',
                border: OutlineInputBorder(),
              ),
              value: _selectedOption,
              onChanged: (String? newValue) {
                setState(() {
                  _selectedOption = newValue;
                });
              },
              items: _userOptions.map<DropdownMenuItem<String>>((Map<String, String> option) {
                return DropdownMenuItem<String>(
                  value: option['value'],
                  child: Text(option['label']!),
                );
              }).toList(),
            ),
            SizedBox(height: 30),
            ElevatedButton(
              onPressed: () async {
                // Check if the password is null or empty
                if (_passwordController.text.isEmpty) {
                  showDialog(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      title: Text('Error'),
                      content: Text('Please enter your password.'),
                      actions: <Widget>[
                        TextButton(
                          child: Text('OK'),
                          onPressed: () {
                            Navigator.of(ctx).pop(); // Dismiss the dialog
                          },
                        ),
                      ],
                    ),
                  );
                } else {
                  // Proceed with the login process if the password is not empty
                  try {
                    var loginResult = await ApiService.login(_emailController.text, _passwordController.text, _selectedOption);
                    if (loginResult.containsKey('id') && loginResult.containsKey('role')) {
                      // Check the widget type and navigate to the appropriate screen
                      if (widget.type == 'dry_clean') {
                        Navigator.of(context).pushReplacement(MaterialPageRoute(
                          builder: (context) => DryClean(id: loginResult['id'], role: loginResult['role']),
                        ));
                      } else if (widget.type == 'erecycleHUB') {
                        Navigator.of(context).pushReplacement(MaterialPageRoute(
                          builder: (context) => ERecycleHub(id: loginResult['id'], role: loginResult['role']),
                        ));
                      } else {
                        // Optionally handle other types or show an error
                        print('Unknown type, cannot navigate!');
                      }
                    } else {
                      // Handle the case where login does not return the expected data
                      print('Login failed or missing expected data (id or role).');
                    }
                  }catch (e) {
                    showDialog(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        title: Text('Login Error'),
                        content: const Text("الرجاء التأكد من كلمة المرور او البريد الالكتروني"),
                        actions: <Widget>[
                          TextButton(
                            child: Text('OK'),
                            onPressed: () {
                              Navigator.of(ctx).pop(); // Dismiss the dialog
                            },
                          ),
                        ],
                      ),
                    );
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.black,
                backgroundColor: Colors.green,
                minimumSize: Size.fromHeight(50),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,  // Minimize the row size to fit the content
                children: <Widget>[
                  Icon(Icons.open_in_browser, color: Colors.black),  // Add person icon, colored to match the text
                  SizedBox(width: 8),  // Space between icon and text
                  Text('تسجيل الدخول'),  // Button text
                ],
              ),
            ),
            SizedBox(height: 15),
            ElevatedButton(
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => RegisterPage(type: widget.type)));
              },
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.black,
                backgroundColor: Color.fromARGB(255, 73, 172, 76),
                minimumSize: Size.fromHeight(50),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,  // Minimize the row size to fit the content
                children: <Widget>[
                  Icon(Icons.person_add, color: Colors.black),  // Add person icon, colored to match the text
                  SizedBox(width: 8),  // Space between icon and text
                  Text('إنشاء حساب'),  // Button text
                ],
              ),
            ),
            if (widget.type == 'dry_clean')
              SizedBox(height: 15),
            if (widget.type == 'dry_clean')
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const OrderStatusPage()),
                  );       
                },style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.black,
                  backgroundColor: Colors.grey,
                  minimumSize: Size.fromHeight(50),
                ),
                child:  const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Icon(Icons.list_alt, color: Colors.black),
                    SizedBox(width: 8),  // Space between icon and text
                    Text('حالة الطلب'),  // Button text
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
