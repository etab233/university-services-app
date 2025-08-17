import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:log_in/login_Screen/AuthService.dart';

import '../../bottom_navigation_bar.dart';
import 'dart:convert';
import '../../Constants.dart';

class Objections {
  final String student_id;
  final String student_name;
  final int grade;
  final String test_hall;
  final String lecturer_name;
  final String date;
  Objections(this.student_id, this.student_name, this.grade, this.test_hall,
      this.lecturer_name, this.date);
  factory Objections.fromJson(Map<String, dynamic> json) {
    return Objections(json['student_id'], json['name'], json['grade'],
        json['test_hall'], json['lecturer_name'], json['created_at']);
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
  @override
  void initState() {
    super.initState();
    fetchObjections(widget.subject);
  }

  Future<void> fetchObjections(String subject) async {
    final url = Uri.parse('${Constants.baseUrl}/admin/objections/submissions')
        .replace(queryParameters: {'subject_name': subject});
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
      print('Error: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      bottomNavigationBar: Bottom_navigation_bar(),
      appBar: AppBar(
        //automaticallyImplyLeading: false,
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
                              border: Border.all(color: Colors.black),
                            ),
                            child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      const Icon(Icons.person,
                                          size: 20,
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
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceAround,
                                    children: [
                                      const Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: [
                                            Text(
                                              "id:",
                                              style: TextStyle(
                                                fontSize: 20,
                                              ),
                                            ),
                                            SizedBox(
                                              height: 10,
                                            ),
                                            Text(
                                              "grade:",
                                              style: TextStyle(
                                                fontSize: 20,
                                              ),
                                            ),
                                            SizedBox(
                                              height: 10,
                                            ),
                                            Text(
                                              "lecturer name:",
                                              style: TextStyle(
                                                fontSize: 20,
                                              ),
                                            ),
                                            SizedBox(
                                              height: 10,
                                            ),
                                            Text(
                                              "test hall:",
                                              style: TextStyle(
                                                fontSize: 20,
                                              ),
                                            ),
                                            SizedBox(
                                              height: 10,
                                            ),
                                          ]),
                                      Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: [
                                            Text(
                                              "${item.student_id}",
                                              style: const TextStyle(
                                                fontSize: 20,
                                              ),
                                            ),
                                            const SizedBox(
                                              height: 10,
                                            ),
                                            Text(
                                              "${item.grade}",
                                              style: const TextStyle(
                                                fontSize: 20,
                                              ),
                                            ),
                                            const SizedBox(
                                              height: 10,
                                            ),
                                            Text(
                                              item.lecturer_name,
                                              style: const TextStyle(
                                                fontSize: 20,
                                              ),
                                            ),
                                            const SizedBox(
                                              height: 10,
                                            ),
                                            Text(
                                              item.test_hall,
                                              style: const TextStyle(
                                                fontSize: 20,
                                              ),
                                            ),
                                            const SizedBox(
                                              height: 10,
                                            ),
                                          ])
                                    ],
                                  ),
                                ]));
                      },
                    ),
                  ),
                ]),
    );
  }
}
