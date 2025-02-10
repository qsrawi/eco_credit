import 'package:eco_credit/add_waste_collection.dart';
import 'package:eco_credit/home_screen.dart';
import 'package:eco_credit/notification.dart';
import 'package:eco_credit/profile.dart';
import 'package:flutter/material.dart';

class ERecycleHub extends StatelessWidget {
  final int id;
  final String role;

  const ERecycleHub({super.key, required this.id, required this.role});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: MainScreen(id: id, role: role),
    );
  }
}

class MainScreen extends StatefulWidget {
  final int id;
  final String role;

  const MainScreen({super.key, required this.id, required this.role});

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;
  List<Widget> _widgetOptions = [];
  List<BottomNavigationBarItem> _navBarItems = [];

  @override
  void initState() {
    super.initState();
    initializeScreenOptions();
  }

  void initializeScreenOptions() {
    _widgetOptions = [
      HomeScreen(),
      HomeScreen(showCompleted: true),
      NotificationsScreen(),
      ProfileScreen(),
    ];

    _navBarItems = [
      const BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
      const BottomNavigationBarItem(icon: Icon(Icons.reorder), label: 'Collections'),
      const BottomNavigationBarItem(icon: Icon(Icons.notifications), label: 'Notifications'),
      const BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
    ];

    // Include AddWasteCollectionScreen and its navigation item only if role is not 'Picker'
    if (widget.role != "Picker") {
      _widgetOptions.insert(2, AddWasteCollectionScreen());  // Insert at the correct position
      _navBarItems.insert(2, const BottomNavigationBarItem(icon: Icon(Icons.add), label: 'Add'));
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: IndexedStack(
          index: _selectedIndex,
          children: _widgetOptions,
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: _navBarItems,
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.blue,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
      ),
    );
  }
}
