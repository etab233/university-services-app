import 'dart:convert';
import 'package:flutter/material.dart';
<<<<<<< HEAD:lib/objection_Screens/student/submit_objection.dart
import 'package:log_in/login_Screen/AuthService.dart';
import '../../home_Screen/homepage.dart';
import '../../Constants.dart';
=======
import 'package:university_services/login_Screen/AuthService.dart';
import '../home_Screen/homePage.dart';
import '../Constants.dart';
import '../bottom_navigation_bar.dart';
>>>>>>> 4b6224479fd278443d8a0122472ba76d9606474e:lib/objection_Screens/submit_objection.dart
import 'package:http/http.dart' as http;

class Objection extends StatefulWidget {
  final String year;
  final String term;
  final String sub_name;
  const Objection(
      {super.key,
      required this.year,
      required this.term,
      required this.sub_name});
  State<StatefulWidget> createState() {
    return ObjectionState();
  }
}

class ObjectionState extends State<Objection> {
  int currentIndex=6;
  final TextEditingController _gradeController = TextEditingController();
  final TextEditingController _testHallController = TextEditingController();
  final TextEditingController _lecturerNameController = TextEditingController();
  bool isLoading = false;
  bool isLoading2 = false;
  String duration = "";
  Future<void> fetchDuration() async {
    final url =
        Uri.parse("${Constants.baseUrl}/objections/dates/${widget.sub_name}");
    final token = await AuthService.getToken();
    try {
      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );
      final data = await jsonDecode(response.body);
      if (response.statusCode == 200) {
        setState(() {
          duration = data['remaining'];
        });
      }
    } catch (e) {}
  }

  @override
  void initState() {
    super.initState();
    fetchDuration();
  }

  Future<void> submitObjection() async {
    setState(() {
      isLoading = true;
    });
    final url = Uri.parse("${Constants.baseUrl}/student/objections/submit");
    String testHall = _testHallController.text;
    String grade = _gradeController.text;
    String lecturerName = _lecturerNameController.text;
    final token = await AuthService.getToken();
    try {
      final response = await http.post(url,
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
          body: json.encode({
            'test_hall': testHall,
            'grade': grade,
            'lecturer_name': lecturerName,
            'subject_year': widget.year,
            'subject_term': widget.term,
            'subject_name': widget.sub_name
          }));
      final data = jsonDecode(response.body);
      if (response.statusCode == 200 || response.statusCode == 201) {
        Constants.showMessage(context, data['message'], Colors.green);
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => HomePage()),);
    
      } else if (data.containsKey('message')) {
        Constants.showMessage(context, data['message'], Colors.red);
      } else if (data.containsKey('errors')) {
        final errors = data['errors'] as Map<String, dynamic>;
        final error_message = errors.values.first[0];
        Constants.showMessage(context, error_message, Constants.primaryColor);
      } else {
        Constants.showMessage(context, "Unknown Error", Colors.red);
      }
    } catch (e) {
      Constants.showMessage(context, "Failed to connect server $e", Colors.red);
    }
    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
<<<<<<< HEAD:lib/objection_Screens/student/submit_objection.dart
          backgroundColor: Constants.primaryColor,
          title: const Text(
            "Your Objection",
            style: TextStyle(fontSize: 24),
          ),
          centerTitle: true,
          actions: [
            IconButton(onPressed: () {}, icon: const Icon(Icons.settings))
          ],
        ),
=======
            backgroundColor: Constants.primaryColor,
            title: const Text(
              "Your Objection",
              style: TextStyle(fontSize: 26, fontWeight: FontWeight.w600),
            ),
            centerTitle: true,
            leading: IconButton(
                onPressed: () => Navigator.pop(context),
                icon: Icon(
                  Icons.arrow_back,
                  size: 30,
                ))),
        bottomNavigationBar: Bottom_navigation_bar(),
>>>>>>> 4b6224479fd278443d8a0122472ba76d9606474e:lib/objection_Screens/submit_objection.dart
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
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
                    color: const Color.fromARGB(255, 252, 184, 179),
                    child: const Text(
                      "Cancel",
                      style: TextStyle(
                          fontSize: 16,
                          color: const Color.fromARGB(255, 247, 16, 0)),
                    )),
                const SizedBox(
                  width: 20,
                ),
                isLoading
                    ?const CircularProgressIndicator(
                        color: Constants.primaryColor,
                      )
                    : MaterialButton(
                        height: 45,
                        onPressed: () {
                          submitObjection();
                          // Constants.showMessage(
                          //     context, "Objection submitted", Colors.green);
                          // Navigator.push(
                          //     context,
                          //     MaterialPageRoute(
                          //         builder: (context) => HomePage()));
                        },
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15)),
                        color: Constants.primaryColor,
                        child: const Text(
                          "Send Objection",
                          style: TextStyle(fontSize: 16, color: Colors.white),
                        )),
              ],
            ),
            const SizedBox(
              height: 10,
            ),
            Text(
              "$duration",
              textAlign: TextAlign.center,
            ),
          ]),
        ));
  }
}
