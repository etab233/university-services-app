import 'package:flutter/material.dart';
import 'package:log_in/objection_Screens/student/submit_objection.dart';
import 'package:log_in/profile/myprofile.dart';
import './home_Screen/homePage.dart';

void _navigateToPage(BuildContext context, int index, List x) {
  Navigator.push(context, MaterialPageRoute(builder: (_) => x[index]));
}

class Bottom_navigation_bar extends StatefulWidget {
  Bottom_navigation_bar({Key? key}) : super(key: key);
  @override
  _Bottom_navigation_barState createState() => _Bottom_navigation_barState();
}

class _Bottom_navigation_barState extends State<Bottom_navigation_bar> {
  List Widgets = [HomePage(), Objection(), MyProfile()];
  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      backgroundColor: Colors.white,
      selectedItemColor: Colors.blue,
      unselectedItemColor: Colors.black,
      showUnselectedLabels: true,
      iconSize: 30,
      type: BottomNavigationBarType.fixed,
      landscapeLayout: BottomNavigationBarLandscapeLayout.spread,
      onTap: (index) => _navigateToPage(context, index, Widgets),
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home_outlined),
          label: 'home',
          activeIcon: Icon(Icons.home),
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.add_box_outlined),
          label: 'add',
          activeIcon: Icon(Icons.add),
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person_2_outlined),
          label: 'profile',
          activeIcon: Icon(Icons.person_2, color: Colors.blue),
        ),
      ],
    );
  }
}
