import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:log_in/objection_Screens/admin/view_objection.dart';
import '../../Constants.dart';

class ChooseSub extends StatefulWidget {
  const ChooseSub({super.key});

  @override
  State<ChooseSub> createState() => _ChooseSubState();
}

class _ChooseSubState extends State<ChooseSub> {
  Future<void> fetchSubjects() async {
    if (year == null || term == null) return;
    final response =
        await http.get(Uri.parse('${Constants.baseUrl}/api/objections'));

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
  String? year;
  String? term;
  String? subject;
  List<String> subjectlist = [];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            backgroundColor: Constants.primaryColor,
            title: const Text("Grade Objection"),
            centerTitle: true,
            actions: [
              IconButton(
                onPressed: () {},
                icon: const Icon(Icons.settings),
              ),
            ]),
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
          child: Container(
            padding:
                const EdgeInsets.only(left: 20, right: 20, top: 0, bottom: 30),
            margin: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
              color: const Color.fromARGB(255, 157, 205, 231),
            ),
            alignment: Alignment.center,
            child: Column(
              children: [
                const SizedBox(
                  height: 30,
                ),
                Container(
                  padding: const EdgeInsets.only(right: 10, left: 10, top: 10),
                  decoration: BoxDecoration(
                      color: const Color.fromARGB(232, 255, 255, 255),
                      borderRadius: BorderRadius.circular(15)),
                  child: DropdownButton<String>(
                    value: year,
                    hint: const Text("Select year"),
                    isExpanded: true,
                    items: const [
                      DropdownMenuItem<String>(
                          value: "first", child: Text("First year")),
                      DropdownMenuItem<String>(
                          value: "second", child: Text("Second year")),
                      DropdownMenuItem<String>(
                          value: "third", child: Text("Third year")),
                      DropdownMenuItem<String>(
                          value: "fourth", child: Text("Fourth year")),
                      DropdownMenuItem<String>(
                          value: "fifth", child: Text("Fifth year")),
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
                const SizedBox(
                  height: 30,
                ),
                Container(
                  padding: const EdgeInsets.only(right: 10, left: 10, top: 10),
                  decoration: BoxDecoration(
                      color: const Color.fromARGB(232, 255, 255, 255),
                      borderRadius: BorderRadius.circular(15)),
                  child: DropdownButton<String>(
                    value: term,
                    hint: const Text("Select term"),
                    isExpanded: true,
                    items: const [
                      DropdownMenuItem<String>(
                          value: "first", child: Text("First term")),
                      DropdownMenuItem<String>(
                          value: "second", child: Text("Second term"))
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
                const SizedBox(
                  height: 30,
                ),
                Container(
                  padding: const EdgeInsets.only(right: 10, left: 10, top: 10),
                  decoration: BoxDecoration(
                      color: const Color.fromARGB(232, 255, 255, 255),
                      borderRadius: BorderRadius.circular(15)),
                  child: DropdownButton<String>(
                    value: subject,
                    hint: const Text("Select subject"),
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
                const SizedBox(
                  height: 30,
                ),
                ElevatedButton(
                    onPressed: EnableButton
                        ? () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => ViewObjections()),
                            );
                          }
                        : null,
                    child: const Text(
                      "Continue",
                      style: TextStyle(color: Colors.black),
                    ))
              ],
            ),
          ),
        ));
  }
}
