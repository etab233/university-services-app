import 'package:flutter/material.dart';

import 'package:university_services/settings.dart';
import 'package:university_services/profile/myprofile.dart';
import './home_Screen/homePage.dart';

class BottomNavigation extends StatelessWidget {
  final int currentIndex;

  const BottomNavigation({
    Key? key,
    required this.currentIndex,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      backgroundColor: Colors.white,
      selectedItemColor: Colors.blue,
      unselectedItemColor: Colors.black,
      showUnselectedLabels: true,
      // إذا كان -1 خليها 0 بس منتحكم بالألوان يدوياً
      currentIndex: currentIndex == -1 ? 0 : currentIndex,
      onTap: (index) {
        if (index == currentIndex) return;

        switch (index) {
          case 0:
            Navigator.push(context,
                MaterialPageRoute(builder: (context) => const HomePage()));
            break;
          case 1:
            Navigator.push(context,
                MaterialPageRoute(builder: (context) => const Settings()));
            break;
          case 2:
            Navigator.push(context,
                MaterialPageRoute(builder: (context) => const MyProfile()));
            break;
        }
      },
      iconSize: 30,
      type: BottomNavigationBarType.fixed,
      items: [
        BottomNavigationBarItem(
          icon: const Icon(Icons.home_outlined),
          label: 'Home',
          activeIcon: Icon(
            Icons.home,
            color: currentIndex == 0 ? Colors.blue : Colors.black,
          ),
        ),
        BottomNavigationBarItem(
          icon: const Icon(Icons.settings_outlined),
          label: 'Settings',
          activeIcon: Icon(
            Icons.settings,
            color: currentIndex == 1 ? Colors.blue : Colors.black,
          ),
        ),
        BottomNavigationBarItem(
          icon: const Icon(Icons.person_2_outlined),
          label: 'Profile',
          activeIcon: Icon(
            Icons.person_2,
            color: currentIndex == 2 ? Colors.blue : Colors.black,
          ),
        ),
      ],
    );
  }
}
