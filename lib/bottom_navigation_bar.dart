import 'package:flutter/material.dart';
import 'package:university_services/settings.dart';
import 'package:university_services/profile/myprofile.dart';
import './home_Screen/homePage.dart';

// void _navigateToPage(BuildContext context, int index, List widgets) {
//   Navigator.push(context, MaterialPageRoute(builder: (_) => widgets[index]));
// }

class bottomNavigationBar extends StatefulWidget {
  bottomNavigationBar({Key? key}) : super(key: key);
  @override
  _bottomNavigationBarState createState() => _bottomNavigationBarState();
}

class _bottomNavigationBarState extends State<bottomNavigationBar> {
  List widgets = [HomePage(), Settings(), MyProfile()];
  int selectedIndex = 0;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.white,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.black,
        showUnselectedLabels: true,
        iconSize: 30,
        type: BottomNavigationBarType.fixed,
        landscapeLayout: BottomNavigationBarLandscapeLayout.spread,
        onTap: (value) {
          setState(() {
            selectedIndex = value;
          });
        },
        currentIndex: selectedIndex,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            label: 'home',
            activeIcon: Icon(Icons.home),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'settings',
            // activeIcon: Icon(Icons.settings_accessibility),
            activeIcon: Icon(Icons.settings),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_2_outlined),
            label: 'profile',
            activeIcon: Icon(Icons.person_2, color: Colors.blue),
          ),
        ],
      ),
      body: widgets.elementAt(selectedIndex),
    );
  }
}
