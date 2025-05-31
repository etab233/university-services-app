import 'package:flutter/material.dart';
import '../../home_Screen/homePage.dart';
import '../../Constants.dart';
import '../../bottom_navigation_bar.dart';

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

  //getting the duration value from the backend
  int duration = 5;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Constants.primaryColor,
          title:const Text(
            "Your Objection",
            style: TextStyle(fontSize: 24),
          ),
          centerTitle: true,
          actions: [IconButton(onPressed: () {}, icon:const Icon(Icons.settings))],
        ),
        bottomNavigationBar: Bottom_navigation_bar(),
        body: SingleChildScrollView(
          padding:const EdgeInsets.all(20),
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
            const SizedBox(
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
            const SizedBox(
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
            const SizedBox(
              height: 20,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                MaterialButton(
                    height: 45,
                    onPressed: () {
                      Navigator.push(context,
                          MaterialPageRoute(builder: (context) => HomePage()));
                    },
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15)),
                    color:const Color.fromARGB(255, 252, 184, 179),
                    child:const Text(
                      "Cancel",
                      style: TextStyle(
                          fontSize: 16,
                          color: const Color.fromARGB(255, 247, 16, 0)),
                    )),
                const SizedBox(
                  width: 20,
                ),
                MaterialButton(
                    height: 45,
                    onPressed: () {
                      _SendObjection();
                      _showMessage();
                      Navigator.push(context,
                          MaterialPageRoute(builder: (context) => HomePage()));
                    },
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15)),
                    color: Constants.primaryColor,
                    child:const Text(
                      "Send Objection",
                      style: TextStyle(fontSize: 16, color: Colors.white),
                    )),
              ],
            ),
            const SizedBox(
              height: 10,
            ),
            Text(
              "$duration days left",
              textAlign: TextAlign.center,
            ),
          ]
          ),
        )
        );
  }
}
