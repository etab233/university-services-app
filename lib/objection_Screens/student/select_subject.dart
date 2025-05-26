import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:log_in/objection_Screen/student/submit_objection.dart';
import 'package:http/http.dart' as http;

class SelectSub extends StatefulWidget {
  const SelectSub({super.key});

  @override
  State<SelectSub> createState() => _SelectSubState();
}

class _SelectSubState extends State<SelectSub> {
  Future<void> fetchSubjects() async {
    if (year == null || term == null) return;
    final response = await http.get(Uri.parse('here the backend url'));

    if (response.statusCode == 200) {
      setState(() {
        subjectlist = List<String>.from(json.decode(response.body));
      });
    } else {
      print("Failed to load subjects");
    }
  }

  void isNull() {
    EnableButton = (year != null && term != null && subject != null);
  }

  bool EnableTerm = false;
  bool EnableButton = false;
  int _currentIndex = 0;
  int? year;
  int? term;
  String? subject;
  List<String> subjectlist = [];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            backgroundColor: Colors.blue,
            title: Text("Grade Objection"),
            centerTitle: true,
            actions: [
              IconButton(
                onPressed: () {},
                icon: Icon(Icons.settings),
              ),
            ]),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _currentIndex,
          selectedItemColor: Colors.blue,
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
              activeIcon: Icon(Icons.person_2, color: Colors.blue),
            ),
          ],
        ),
        body: SingleChildScrollView(
          child: Container(
            padding:
                const EdgeInsets.only(left: 20, right: 20, top: 0, bottom: 30),
            margin: EdgeInsets.all(20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
              color: const Color.fromARGB(255, 157, 205, 231),
            ),
            alignment: Alignment.center,
            child: Column(
              children: [
                SizedBox(
                  height: 30,
                ),
                Container(
                  padding: const EdgeInsets.only(right: 10, left: 10, top: 10),
                  decoration: BoxDecoration(
                      color: Color.fromARGB(232, 255, 255, 255),
                      borderRadius: BorderRadius.circular(15)),
                  child: DropdownButton<int>(
                    value: year,
                    hint: const Text("Select year"),
                    isExpanded: true,
                    items: [
                      DropdownMenuItem<int>(
                          value: 1, child: Text("First year")),
                      DropdownMenuItem<int>(
                          value: 2, child: Text("Second year")),
                      DropdownMenuItem<int>(
                          value: 3, child: Text("Third year")),
                      DropdownMenuItem<int>(
                          value: 4, child: Text("Fourth year")),
                      DropdownMenuItem<int>(
                          value: 5, child: Text("Fifth year")),
                    ],
                    onChanged: (value) {
                      setState(() {
                        EnableTerm = true;
                        year = value;
                        term = null;
                        subject = null;
                        isNull();
                      });
                    },
                  ),
                ),
                SizedBox(
                  height: 30,
                ),
                Container(
                  padding: EdgeInsets.only(right: 10, left: 10, top: 10),
                  decoration: BoxDecoration(
                      color: Color.fromARGB(232, 255, 255, 255),
                      borderRadius: BorderRadius.circular(15)),
                  child: DropdownButton<int>(
                    value: term,
                    hint: Text("Select term"),
                    isExpanded: true,
                    items: [
                      DropdownMenuItem<int>(
                          value: 1, child: Text("First term")),
                      DropdownMenuItem<int>(
                          value: 2, child: Text("Second term"))
                    ],
                    onChanged: EnableTerm
                        ? (value) {
                            setState(() {
                              term = value;
                              subject = null;
                              fetchSubjects();
                              isNull();
                            });
                          }
                        : null,
                  ),
                ),
                SizedBox(
                  height: 30,
                ),
                Container(
                  padding: EdgeInsets.only(right: 10, left: 10, top: 10),
                  decoration: BoxDecoration(
                      color: Color.fromARGB(232, 255, 255, 255),
                      borderRadius: BorderRadius.circular(15)),
                  child: DropdownButton<String>(
                    value: subject,
                    hint: Text("Select subject"),
                    isExpanded: true,
                    items: subjectlist
                        .map((e) =>
                            DropdownMenuItem<String>(value: e, child: Text(e)))
                        .toList(),
                    onChanged: (value) {
                      setState(() {
                        subject = value;
                        isNull();
                      });
                    },
                  ),
                ),
                SizedBox(
                  height: 30,
                ),
                ElevatedButton(
                    onPressed: EnableButton
                        ? () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => Objection()),
                            );
                          }
                        : null,
                    child: Text(
                      "Continue",
                      style: TextStyle(color: Colors.black),
                    ))
              ],
            ),
          ),
        ));
  }
}
