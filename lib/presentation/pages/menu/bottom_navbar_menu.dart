import 'package:ai_plant_app/presentation/pages/home/home_page.dart';
import 'package:ai_plant_app/presentation/pages/profile/profile_page.dart';
import 'package:ai_plant_app/presentation/pages/saved/saved_page.dart';
import 'package:flutter/material.dart';

class BottomNavbar extends StatefulWidget {
  const BottomNavbar({Key? key}) : super(key: key);

  @override
  _BottomNavbarState createState() => _BottomNavbarState();
}

class _BottomNavbarState extends State<BottomNavbar> {
  int _pageIndex = 0;

  final List<Widget> _pages = [
    HomePage(),
    SavedPage(),
    ProfilePage(),
  ];

  void _onItemTapped(int selectedIndex) {
    setState(() {
      _pageIndex = selectedIndex;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_pageIndex], // Display the current page based on _pageIndex
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _pageIndex,
        onTap: _onItemTapped,
        backgroundColor: Colors.white,
        selectedItemColor:
            Color(0xFF62C172), // Green color for the selected icon and label
        unselectedItemColor:
            Colors.grey, // Grey color for unselected icons and labels
        showSelectedLabels: true,
        showUnselectedLabels: true,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bookmark_border),
            label: 'Saved',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
