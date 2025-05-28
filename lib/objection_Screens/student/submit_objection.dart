import 'package:flutter/material.dart';
import '../../home_Screen/home.dart';
import '../../Constants.dart';

class Objection extends StatefulWidget {
  const Objection({
    super.key,
  });
  State<StatefulWidget> createState() {
    return ObjectionState();
  }
}

class ObjectionState extends State<Objection> {
  final TextEditingController _gradeController = TextEditingController();
  final TextEditingController _testHallController = TextEditingController();
  final TextEditingController _lecturerNameController = TextEditingController();
  void _SendObjection() {
    String testHall = _testHallController.text.trim();
    int? grade = int.tryParse(_gradeController.text.trim());
    String lecturerName = _lecturerNameController.text.trim();
  }

  void _showMessage() {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text("Objection Submitted")));
  }

  int _currentIndex = 0;
  //getting the duration value from the backend
  int duration = 5;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Constants.primaryColor,
          title: Text(
            "Your Objection",
            style: TextStyle(fontSize: 24),
          ),
          centerTitle: true,
          actions: [IconButton(onPressed: () {}, icon: Icon(Icons.settings))],
        ),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _currentIndex,
          selectedItemColor: Constants.primaryColor,
          unselectedItemColor: Colors.black,
          showUnselectedLabels: true,
          iconSize: 30,
          type: BottomNavigationBarType.fixed,
          landscapeLayout: BottomNavigationBarLandscapeLayout.spread,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
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
              activeIcon: Icon(Icons.person_2, color: Constants.primaryColor),
            ),
          ],
        ),
        body: SingleChildScrollView(
          padding: EdgeInsets.all(20),
          child: Column(children: [
            Container(
              height: 50,
              child: TextField(
                  controller: _gradeController,
                  maxLength: 30,
                  decoration: InputDecoration(
                    labelText: "Grade",
                    filled: true,
                    fillColor: Colors.white,
                    counterText: '',
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15)),
                  )),
            ),
            SizedBox(
              height: 20,
            ),
            Container(
              height: 50,
              child: TextField(
                controller: _testHallController,
                maxLength: 30,
                decoration: InputDecoration(
                  filled: true,
                  labelText: "Test Hall",
                  fillColor: Colors.white,
                  counterText: '',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15)),
                ),
              ),
            ),
            SizedBox(
              height: 20,
            ),
            Container(
              height: 50,
              child: TextField(
                controller: _lecturerNameController,
                maxLength: 30,
                decoration: InputDecoration(
                  labelText: "Lecturer Name",
                  filled: true,
                  fillColor: Colors.white,
                  counterText: '',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15)),
                ),
              ),
            ),
            SizedBox(
              height: 20,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                MaterialButton(
                    height: 45,
                    onPressed: () {
                      Navigator.push(context,
                          MaterialPageRoute(builder: (context) => Home()));
                    },
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15)),
                    color: Color.fromARGB(255, 252, 184, 179),
                    child: Text(
                      "Cancel",
                      style: TextStyle(
                          fontSize: 16,
                          color: const Color.fromARGB(255, 247, 16, 0)),
                    )),
                SizedBox(
                  width: 20,
                ),
                MaterialButton(
                    height: 45,
                    onPressed: () {
                      _SendObjection();
                      _showMessage();
                      Navigator.push(context,
                          MaterialPageRoute(builder: (context) => Home()));
                    },
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15)),
                    color: Constants.primaryColor,
                    child: Text(
                      "Send Objection",
                      style: TextStyle(fontSize: 16, color: Colors.white),
                    )),
              ],
            ),
            SizedBox(
              height: 10,
            ),
            Text(
              "$duration days left",
              textAlign: TextAlign.center,
            ),
          ]),
        ));
  }
}
