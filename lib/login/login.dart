import 'package:eco_credit/dry-clean/dry_clean.dart';
import 'package:eco_credit/dry-clean/dry_clean_order_status_page.dart';
import 'package:eco_credit/e_recycle_hub.dart';
import 'package:eco_credit/login/register.dart';
import 'package:eco_credit/services/api_service.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class LoginPage extends StatefulWidget {
  final String type;
  LoginPage({required this.type});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> with SingleTickerProviderStateMixin {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _obscureText = true;
  String? _selectedOption;
  String message = '♻️ امنح المواد حياة جديدة بإعادة تدويرها';
  late AnimationController _controller;

  List<Map<String, String>> _userOptions = [];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 1000),
    );

    _controller.forward();

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
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget _buildAnimatedField(Widget child, int index) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset((1 - _controller.value) * (index.isEven ? -50 : 50), 0),
          child: Opacity(
            opacity: _controller.value,
            child: child,
          ),
        );
      },
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('تسجيل الدخول'),
        backgroundColor: const Color(0xFFE8F5E9), // Matching gradient start color
        elevation: 0, // Remove shadow
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
        height: MediaQuery.of(context).size.height, // Full screen height
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
              _buildLogo(),
              const SizedBox(height: 20),
              _buildMessage(),
              const SizedBox(height: 30),
              _buildForm(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLogo() {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 500),
      child: Container(
        key: ValueKey(widget.type),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.green.withOpacity(0.2),
              blurRadius: 15,
              spreadRadius: 5,
            )
          ],
        ),
        child: CircleAvatar(
          radius: 90,
          backgroundColor: Colors.white,
          child: Padding(
            padding: const EdgeInsets.all(15.0),
            child: Image.asset(
              'assets/images/header2.png',
              fit: BoxFit.contain,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMessage() {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      child: Text(
        message,
        key: ValueKey(message),
        textAlign: TextAlign.center,
        style: GoogleFonts.cairo(
          textStyle: const TextStyle(
            color: Color(0xFF2E7D32),
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildForm() {
    return Column(
      children: [
        _buildAnimatedField(
          _buildTextField(
            controller: _emailController,
            label: 'الأيميل',
            icon: Icons.email,
            keyboardType: TextInputType.emailAddress,
          ),
          0,
        ),
        const SizedBox(height: 20),
        _buildAnimatedField(
          _buildPasswordField(),
          1,
        ),
        const SizedBox(height: 20),
        _buildAnimatedField(
          _buildDropdown(),
          2,
        ),
        const SizedBox(height: 30),
        _buildAnimatedField(
          _buildLoginButton(),
          3,
        ),
        const SizedBox(height: 15),
        _buildAnimatedField(
          _buildRegisterButton(),
          4,
        ),
        if (widget.type == 'dry_clean') ...[
          const SizedBox(height: 15),
          _buildAnimatedField(
            _buildOrderStatusButton(),
            5,
          ),
        ],
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: const Color(0xFF2E7D32)),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide.none,
        ),
        filled: true,
        fillColor: Colors.white.withOpacity(0.9),
        contentPadding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
      ),
      keyboardType: keyboardType,
    );
  }

  Widget _buildPasswordField() {
    return TextFormField(
      controller: _passwordController,
      obscureText: _obscureText,
      decoration: InputDecoration(
        labelText: 'رقم السر',
        prefixIcon: const Icon(Icons.lock, color: Color(0xFF2E7D32)),
        suffixIcon: IconButton(
          icon: Icon(
            _obscureText ? Icons.visibility_off : Icons.visibility,
            color: const Color(0xFF2E7D32),
          ),
          onPressed: () => setState(() => _obscureText = !_obscureText),
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide.none,
        ),
        filled: true,
        fillColor: Colors.white.withOpacity(0.9),
        contentPadding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
      ),
    );
  }

  Widget _buildDropdown() {
    return DropdownButtonFormField<String>(
      decoration: InputDecoration(
        labelText: 'اختر قسم',
        prefixIcon: const Icon(Icons.category, color: Color(0xFF2E7D32)),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide.none,
        ),
        filled: true,
        fillColor: Colors.white.withOpacity(0.9),
        contentPadding: const EdgeInsets.symmetric(vertical: 2, horizontal: 20),
      ),
      value: _selectedOption,
      onChanged: (String? newValue) => setState(() => _selectedOption = newValue),
      items: _userOptions.map((option) => DropdownMenuItem<String>(
        value: option['value'],
        child: Text(option['label']!,
          style: GoogleFonts.cairo(fontWeight: FontWeight.w500)),
      )).toList(),
      dropdownColor: Colors.white,
    );
  }

  Widget _buildLoginButton() {
    return Material(
      borderRadius: BorderRadius.circular(15),
      elevation: 4,
      child: InkWell(
        onTap: _handleLogin,
        borderRadius: BorderRadius.circular(15),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 15),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            gradient: const LinearGradient(
              colors: [Color(0xFF43A047), Color(0xFF2E7D32)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.login, color: Colors.white),
              const SizedBox(width: 10),
              Text('تسجيل الدخول',
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

  Widget _buildRegisterButton() {
    return OutlinedButton(
      onPressed: () => Navigator.push(context,
        MaterialPageRoute(builder: (context) => RegisterPage(type: widget.type))),
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 15),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15)),
        side: const BorderSide(color: Color(0xFF2E7D32)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.person_add, color: Color(0xFF2E7D32)),
          const SizedBox(width: 10),
          Text('إنشاء حساب',
            style: GoogleFonts.cairo(
              color: const Color(0xFF2E7D32),
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderStatusButton() {
    return OutlinedButton(
      onPressed: () => Navigator.push(context,
        MaterialPageRoute(builder: (context) => const OrderStatusPage())),
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 15),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15)),
        side: const BorderSide(color: Color(0xFF2E7D32)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.list_alt, color: Color(0xFF2E7D32)),
          const SizedBox(width: 10),
          Text('حالة الطلب',
            style: GoogleFonts.cairo(
              color: const Color(0xFF2E7D32),
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  void _handleLogin() async {
    if (_passwordController.text.isEmpty) {
      _showErrorDialog('خطأ', 'الرجاء إدخال كلمة المرور');
      return;
    }

    // Show loading overlay
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF2E7D32)),
        ),
      ),
    );

    try {
      var loginResult = await ApiService.login(
        _emailController.text,
        _passwordController.text,
        _selectedOption
      );

      if (loginResult.containsKey('id') && loginResult.containsKey('role')) {
        Navigator.pop(context); // Ensure the loading overlay is closed on exception
        String? token = await FirebaseMessaging.instance.getToken();
        print("FCM Token: $token");

        if (token != null) {
          await ApiService.sendTokenToBackend(token);
        }
        _navigateAfterLogin(loginResult);
      } else {
        _showErrorDialog('خطأ', 'بيانات الدخول غير صحيحة');
      }
    } catch (e) {
      Navigator.pop(context); // Ensure the loading overlay is closed on exception
      _showErrorDialog('خطأ', 'الرجاء التأكد من البيانات المدخلة');
    }
  }

  void _navigateAfterLogin(Map<String, dynamic> loginResult) {
    Widget destination;
    if (widget.type == 'dry_clean') {
      destination = DryClean(id: loginResult['id'], role: loginResult['role']);
    } else if (widget.type == 'erecycleHUB') {
      destination = ERecycleHub(id: loginResult['id'], role: loginResult['role']);
    } else {
      return;
    }

    Navigator.pushReplacement(context,
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => destination,
        transitionsBuilder: (_, a, __, c) =>
          FadeTransition(opacity: a, child: c),
      ),
    );
  }

  void _showErrorDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, color: Colors.red, size: 50),
              const SizedBox(height: 15),
              Text(title,
                style: GoogleFonts.cairo(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF2E7D32),
                ),
              ),
              const SizedBox(height: 10),
              Text(message,
                textAlign: TextAlign.center,
                style: GoogleFonts.cairo(),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => Navigator.pop(ctx),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2E7D32),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
                ),
                child: Text('حسناً',
                  style: GoogleFonts.cairo(color: Colors.white)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}