import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;
import 'package:university_services/login_Screen/AuthService.dart';
import 'package:university_services/objection_Screens/admin/view_accepted_objections.dart';
import 'package:university_services/objection_Screens/admin/card_element.dart';
import '../../bottom_navigation_bar.dart';
import 'dart:convert';
import '../../Constants.dart';

class Objections {
  final int objection_id;
  final String student_id;
  final String student_name;
  final int grade;
  final String test_hall;
  final String lecturer_name;
  final String date;
  Objections(this.objection_id, this.student_id, this.student_name, this.grade,
      this.test_hall, this.lecturer_name, this.date);
  factory Objections.fromJson(Map<String, dynamic> json) {
    return Objections(
        json["id"],
        json['student_id'],
        json['name'],
        json['grade'],
        json['test_hall'],
        json['lecturer_name'],
        json['created_at']);
  }
}

class ViewObjections extends StatefulWidget {
  final String subject;
  const ViewObjections({required this.subject});
  @override
  _ViewObjectionsState createState() => _ViewObjectionsState();
}

class _ViewObjectionsState extends State<ViewObjections> {
  List<Objections> objections = [];
  bool isLoading = true;
  final _formkey = GlobalKey<FormState>();
  TextEditingController _gradeController = TextEditingController();
  @override
  void initState() {
    super.initState();
    fetchObjections(widget.subject);
  }

  Future<void> deleteObjection(int id) async {
    final url = Uri.parse("${Constants.baseUrl}/objections/$id");
    try {
      final token = await AuthService.getToken();
      final response = await http.delete(url, headers: {
        'Content-Type': 'json/application',
        'Authorization': 'Bearer $token'
      });
      final data = jsonDecode(response.body);
      if (response.statusCode == 200) {
        Navigator.pop(context);
        setState(() {
          isLoading = true;
        });
        await fetchObjections(widget.subject);
        Constants.showMessage(context, data["message"], Colors.green);
      }
      if (response.statusCode == 404 || response.statusCode == 403)
        Constants.showMessage(context, data["message"], Colors.red);
    } catch (e) {
      Constants.showMessage(context, "Failed deleting objection", Colors.red);
    }
  }

  Future<void> acceptObjection(int id) async {
    final url = Uri.parse('${Constants.baseUrl}/objections/$id/accept');
    try {
      final token = await AuthService.getToken();
      int? new_grade = int.tryParse(_gradeController.text);
      final response = await http.post(url,
          headers: {
            'Content-Type': 'application/json',
            'Authorization': "Bearer $token",
          },
          body: jsonEncode({"new_grade": new_grade}));
      final data = jsonDecode(response.body);
      if (response.statusCode == 200) {
        Navigator.pop(context);
        setState(() {
          isLoading = true;
        });
        await fetchObjections(widget.subject);
        Constants.showMessage(context, data["message"], Colors.green);
      }
      if (response.statusCode == 403 || response.statusCode == 404) {
        Navigator.pop(context);
        Constants.showMessage(context, data["message"], Colors.red);
      }
      if (response.statusCode == 422) {
        Constants.showMessage(
            context, data["errors"]["new_grade"][0], Colors.red);
      }
    } catch (e) {
      Constants.showMessage(context,
          "Failed to connect server please try again later", Colors.red);
    }
  }

  Future<void> fetchObjections(String subject) async {
    final url =
        Uri.parse('${Constants.baseUrl}/admin/objections/submissions/$subject');
    try {
      final token = await AuthService.getToken();
      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );
      if (response.statusCode == 200) {
        final List jsonData = json.decode(response.body);
        setState(() {
          objections =
              jsonData.map((item) => Objections.fromJson(item)).toList();
          isLoading = false;
        });
      } else {
        throw Exception('Failed to fetch data');
      }
    } catch (e) {
      Constants.showMessage(context, "Error: $e", Colors.red);
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          "${widget.subject} Objections",
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(Icons.arrow_back,
              size: 30, color: Constants.primaryColor),
        ),
        actions: [
          IconButton(
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            AcceptedObjections(subject: widget.subject)));
              },
              icon: Icon(
                Icons.fact_check,
                color: Colors.blue,
                size: 30,
              ))
        ],
      ),
      bottomNavigationBar: BottomNavigation(
        currentIndex: -1,
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(
              color: Constants.primaryColor,
            ))
          : objections.isEmpty
              ? const Center(
                  child: Text(
                    'No Objections',
                    style: TextStyle(fontSize: 18),
                  ),
                )
              : Stack(children: [
                  Positioned.fill(
                    child: Column(
                      children: [
                        Expanded(
                            flex: 3,
                            child: Container(color: const Color(0xffffffff))),
                        Expanded(
                          flex: 7,
                          child: Container(
                            decoration: const BoxDecoration(
                              gradient: LinearGradient(
                                colors: [Color(0xFFBFE4FA), Color(0xff6fb1d9)],
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                              ),
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(80),
                                topRight: Radius.circular(80),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: ListView.builder(
                      itemCount: objections.length,
                      itemBuilder: (content, index) {
                        final item = objections[index];
                        return Container(
                            margin: const EdgeInsets.all(10),
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              boxShadow: const [
                                BoxShadow(
                                    blurRadius: 5,
                                    offset: Offset.zero,
                                    color: Colors.black)
                              ],
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(17),
                            ),
                            child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      const Icon(Icons.person,
                                          size: 30,
                                          color: Constants.primaryColor),
                                      const SizedBox(
                                        width: 5,
                                      ),
                                      Text(
                                        item.student_name,
                                        style: const TextStyle(
                                          fontSize: 20,
                                        ),
                                      ),
                                      const Spacer(),
                                      Text(
                                        item.date,
                                        style: TextStyle(
                                            fontSize: 16,
                                            color: Colors.grey[600]),
                                      ),
                                      const SizedBox(
                                        width: 10,
                                      )
                                    ],
                                  ),
                                  const SizedBox(
                                    height: 10,
                                  ),
                                  Table(
                                    defaultVerticalAlignment:
                                        TableCellVerticalAlignment.middle,
                                    columnWidths: {
                                      0: FlexColumnWidth(),
                                      1: FlexColumnWidth(),
                                    },
                                    children: [
                                      BuildTableRow("Id:", item.student_id),
                                      BuildTableRow(
                                          "Grade:", item.grade.toString()),
                                      BuildTableRow(
                                          "Lecturer name:", item.lecturer_name),
                                      BuildTableRow(
                                          "Test hall:", item.test_hall),
                                    ],
                                  ),
                                  SizedBox(
                                    height: 10,
                                  ),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: [
                                      BuildButton(
                                          context,
                                          "reject",
                                          const Color.fromARGB(
                                              255, 252, 184, 179),
                                          Colors.red,
                                          "Reject Objection",
                                          Text(
                                              "Are you sure you want to reject this objection?"),
                                          "No",
                                          "yes",
                                          () => deleteObjection(
                                              item.objection_id)),
                                      BuildButton(
                                          context,
                                          "accept",
                                          const Color.fromARGB(
                                              255, 175, 240, 177),
                                          Colors.green,
                                          "Accept Objection",
                                          Form(
                                            key: _formkey,
                                            child: TextFormField(
                                              keyboardType:
                                                  TextInputType.number,
                                              controller: _gradeController,
                                              autovalidateMode: AutovalidateMode
                                                  .onUserInteraction,
                                              validator: (value) {
                                                if (value == null)
                                                  return "The field should not be empty";
                                                if (int.tryParse(value) == null)
                                                  return "Enter a valid input";
                                                if (int.tryParse(value)! >
                                                        100 ||
                                                    int.tryParse(value)! < 0)
                                                  return "The mark should be between [0,100]";
                                                return null;
                                              },
                                            ),
                                          ),
                                          "Cancel",
                                          "Accept", () {
                                        if (_formkey.currentState!.validate())
                                          acceptObjection(item.objection_id);
                                      })
                                    ],
                                  )
                                ]));
                      },
                    ),
                  ),
                ]),
    );
  }
}
