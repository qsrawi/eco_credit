import 'package:eco_credit/add_waste_collection.dart';
import 'package:eco_credit/generators_list.dart';
import 'package:eco_credit/home_screen.dart';
import 'package:eco_credit/notification.dart';
import 'package:eco_credit/pickers_list.dart';
import 'package:eco_credit/profile.dart';
import 'package:flutter/material.dart';

class ERecycleHub extends StatelessWidget {
  final int id;
  final String role;

  const ERecycleHub({super.key, required this.id, required this.role});

  @override
  Widget build(BuildContext context) {
    // Remove MaterialApp wrapper
    return MainScreen(id: id, role: role);
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
  // bool _isNotificationsLoaded = false;

  @override
  void initState() {
    super.initState();
    initializeScreenOptions();
  }

  void initializeScreenOptions() {
    _widgetOptions = [
      HomeScreen(showCompleted: true),
      ProfileScreen(),
    ];

    _navBarItems = [
      const BottomNavigationBarItem(icon: Icon(Icons.reorder), label: 'Collections'),
      const BottomNavigationBarItem(icon: Icon(Icons.account_circle), label: 'Profile'),
    ];

    if (widget.role != "Admin") {
      _widgetOptions.insert(0, HomeScreen());  // Insert at the correct position
      _navBarItems.insert(0, const BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'));
    }

    if (widget.role == "Generator") {
      _widgetOptions.insert(2, AddWasteCollectionScreen());  // Insert at the correct position
      _navBarItems.insert(2, const BottomNavigationBarItem(icon: Icon(Icons.add), label: 'Add'));
    }

    if (widget.role == "Generator") {
      _widgetOptions.insert(3, NotificationsScreen());
      _navBarItems.insert(3, const BottomNavigationBarItem(icon: Icon(Icons.notifications), label: 'Notifications'));
    }

    if (widget.role == "Picker") {
      _widgetOptions.insert(2, NotificationsScreen());
      _navBarItems.insert(2, const BottomNavigationBarItem(icon: Icon(Icons.notifications), label: 'Notifications'));
    }

    if (widget.role == "Admin") {
      _widgetOptions.insert(1, const PickersListWidget());  // Insert at the correct position
      _navBarItems.insert(1, const BottomNavigationBarItem(icon: Icon(Icons.people), label: 'Pickers'));
    }

    if (widget.role == "Admin") {
      _widgetOptions.insert(2, const GeneratorsListWidget());  // Insert at the correct position
      _navBarItems.insert(2, const BottomNavigationBarItem(icon: Icon(Icons.group_add), label: 'Generators'));
    }
  }

  void _onItemTapped(int index) {
    if (widget.role == "Generator" && index == 3) {
      setState(() {
        _widgetOptions[3] = NotificationsScreen();
      });
    }
    if (widget.role == "Picker" && index == 2) {
      setState(() {
        _widgetOptions[2] = NotificationsScreen();
      });
    }
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
        selectedItemColor: const Color(0xFF3F9A25),
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
      ),
    );
  }
}