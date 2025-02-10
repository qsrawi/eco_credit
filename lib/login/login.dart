import 'package:eco_credit/e_recycle_hub.dart';
import 'package:eco_credit/services/api_service.dart';
import 'package:flutter/material.dart';

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
            TextFormField(
              controller: _emailController,
              decoration: const InputDecoration(
                labelText: 'الأيميل',
                border: OutlineInputBorder(),
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
                      Navigator.of(context).pushReplacement(MaterialPageRoute(
                        builder: (context) => ERecycleHub(id: loginResult['id'], role: loginResult['role']),
                      ));
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
                backgroundColor: Colors.blue,
                minimumSize: Size.fromHeight(50),
              ),
              child: const Text('تسجيل الدخول'),
            ),
            SizedBox(height: 15),
            ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.black,
                backgroundColor: Colors.green,
                minimumSize: Size.fromHeight(50),
              ),
              child: const Text('إنشاء حساب'),
            ),
            if (widget.type == 'dry_clean')
              SizedBox(height: 15),
            if (widget.type == 'dry_clean')
              ElevatedButton(
                onPressed: () {},
                child: Text('Order Status'),
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.black,
                  backgroundColor: Colors.grey,
                  minimumSize: Size.fromHeight(50),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
