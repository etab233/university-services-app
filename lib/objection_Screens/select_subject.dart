import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:university_services/bottom_navigation_bar.dart';
import 'package:university_services/login_Screen/AuthService.dart';
import 'package:university_services/objection_Screens/admin/open_objection.dart';
import 'package:university_services/objection_Screens/admin/view_objection.dart';
import 'package:http/http.dart' as http;
import 'package:university_services/objection_Screens/submit_objection.dart';
import '../Constants.dart';

class SelectSub extends StatefulWidget {
  const SelectSub({super.key});

  @override
  State<SelectSub> createState() => _SelectSubState();
}

class _SelectSubState extends State<SelectSub> {
  bool isLoading = false;
  String? role;

  @override
  void initState() {
    super.initState();
    getRole();
  }

  Future<void> getRole() async {
    role = await AuthService.getRole();
    setState(() {});
  }

  Future<void> fetchSubjects() async {
    if (year == null || term == null) return;
    final token = await AuthService.getToken();
    setState(() {
      isLoading = true;
    });

    final url = Uri.parse('${Constants.baseUrl}/objections/subjects')
        .replace(queryParameters: {'year': year, 'term': term});
    try {
      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );
      if (response.statusCode == 200) {
        setState(() {
          final data = jsonDecode(response.body);
          subjectList = List<String>.from(data['subjects']);
          if (subjectList.isEmpty) {
            Constants.showMessage(
                context,
                "No available subjects to object on it.",
                const Color.fromARGB(172, 0, 0, 0));
          }
        });
      } else {
        Constants.showMessage(context, "Failed to fetch subjects", Colors.red);
      }
      setState(() {
        isLoading = false;
      });
    } catch (e) {
      Constants.showMessage(
          context, "Failed to connect server: $e", Colors.red);
      setState(() {
        isLoading = false;
      });
    }
  }

  void isNull() {
    EnableButton = (year != null && term != null && subject != null);
  }

  bool EnableTerm = false;
  bool EnableButton = false;
  // int _currentIndex = 0;
  String? year;
  String? term;
  String? subject;
  List<String> subjectList = [];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            backgroundColor: Constants.primaryColor,
            title: const Text(
              "Grade Objection",
              style: TextStyle(
                  fontSize: 26,
                  color: Colors.black,
                  fontWeight: FontWeight.w600),
            ),
            centerTitle: true,
            leading: IconButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                icon: Icon(
                  Icons.arrow_back,
                  color: Colors.black,
                  size: 30,
                )),
            actions: [
              if (role == "admin")
                IconButton(
                  onPressed: () {
                    Navigator.of(context).push(
                        MaterialPageRoute(builder: (context) => OpenOb()));
                  },
                  icon: const Icon(
                    Icons.add,
                    size: 30,
                    color: Colors.black,
                  ),
                )
            ]),
        bottomNavigationBar: BottomNavigation(
          currentIndex: -1,
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
                isLoading
                    ? CircularProgressIndicator(color: Constants.primaryColor)
                    : Container(
                        padding:
                            const EdgeInsets.only(right: 10, left: 10, top: 10),
                        decoration: BoxDecoration(
                            color: const Color.fromARGB(232, 255, 255, 255),
                            borderRadius: BorderRadius.circular(15)),
                        child: DropdownButton<String>(
                          value: subject,
                          hint: const Text("Select subject"),
                          isExpanded: true,
                          items: subjectList
                              .map((e) => DropdownMenuItem<String>(
                                  value: e, child: Text(e)))
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
                        ? () async {
                            final role = await AuthService.getRole();
                            if (role == "admin") {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => ViewObjections(
                                          subject: subject!,
                                        )),
                              );
                            } else if (role == "student") {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => Objection(
                                          year: year!,
                                          term: term!,
                                          sub_name: subject!,
                                        )),
                              );
                            }
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
