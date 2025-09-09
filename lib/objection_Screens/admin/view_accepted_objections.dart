import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:university_services/login_Screen/AuthService.dart';
import 'package:university_services/objection_Screens/admin/card_element.dart';
import '../../../bottom_navigation_bar.dart';
import 'dart:convert';
import '../../../Constants.dart';

class AcceptedOb {
  final String student_id;
  final String student_name;
  final int grade;
  final int new_grade;
  AcceptedOb(this.student_id, this.student_name, this.grade, this.new_grade);
  factory AcceptedOb.fromJson(Map<String, dynamic> json) {
    return AcceptedOb(json['student_id'], json['name'], json['original_grade'],
        json['new_grade']);
  }
}

class AcceptedObjections extends StatefulWidget {
  final String subject;
  const AcceptedObjections({required this.subject});
  @override
  _AcceptedObjectionsState createState() => _AcceptedObjectionsState();
}

class _AcceptedObjectionsState extends State<AcceptedObjections> {
  List<AcceptedOb> objections = [];

  bool isLoading = true;
  @override
  void initState() {
    super.initState();
    fetchAcceptedObjections(widget.subject);
  }

  Future<void> fetchAcceptedObjections(String subject) async {
    final url =
        Uri.parse('${Constants.baseUrl}/objections/${widget.subject}/accepted');
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
              jsonData.map((item) => AcceptedOb.fromJson(item)).toList();
          isLoading = false;
        });
      } else {
        throw Exception('Failed to fetch data');
      }
    } catch (e) {
      if (!mounted) return;
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
      bottomNavigationBar: Bottom_navigation_bar(),
      appBar: AppBar(
        title: Text(
          "Accepted Objections",
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
                    'No Accepted Objections',
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
                                        width: 10,
                                      ),
                                      Text(
                                        item.student_name,
                                        style: const TextStyle(
                                          fontSize: 20,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(
                                    height: 10,
                                  ),
                                  Table(
                                    columnWidths: {
                                      0: FlexColumnWidth(),
                                      1: FlexColumnWidth()
                                    },
                                    defaultVerticalAlignment:
                                        TableCellVerticalAlignment.middle,
                                    children: [
                                      BuildTableRow("Id:", item.student_id),
                                      BuildTableRow(
                                          "Old grade:", item.grade.toString()),
                                      BuildTableRow("New grade:",
                                          item.new_grade.toString()),
                                    ],
                                  ),
                                  SizedBox(
                                    height: 10,
                                  )
                                ]));
                      },
                    ),
                  ),
                ]),
    );
  }
}
