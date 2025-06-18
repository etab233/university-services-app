import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:log_in/AuthService.dart';
import '../bottom_navigation_bar.dart';
import 'dart:convert';
import '../../Constants.dart';

class Complaints {
  final String student_name;
  final String title;
  final String content;
  final String date;
  Complaints(this.student_name, this.title, this.content, this.date);
  factory Complaints.fromJson(Map<String, dynamic> json) {
    return Complaints(
        json['student_name'], json['title'], json['content'], json['date']);
  }
}

class ViewComp extends StatefulWidget {
  const ViewComp();
  @override
  _ViewCompState createState() => _ViewCompState();
}

class _ViewCompState extends State<ViewComp> {
  List<Complaints> complaints = [];
  bool isLoading = true;
  @override
  void initState() {
    super.initState();
    fetchcomplaints();
  }

  Future<void> fetchcomplaints() async {
    final url = Uri.parse('${Constants.baseUrl}/complaints');
    try {
      final token = await AuthService.getToken();
      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Baerer $token',
          'Content-Type': 'application/json',
        },
      );
      if (response.statusCode == 200) {
        final List jsonData = json.decode(response.body);
        setState(() {
          complaints =
              jsonData.map((item) => Complaints.fromJson(item)).toList();
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
    return isLoading
        ? const Center(child: CircularProgressIndicator())
        : complaints.isEmpty
            ? const Center(
                child: Text('No complaints'),
              )
            : Scaffold(
                backgroundColor: Colors.white,
                bottomNavigationBar: Bottom_navigation_bar(),
                appBar: AppBar(
                  title: Text(
                    "Complaints",
                    style: const TextStyle(
                        fontSize: 24, fontWeight: FontWeight.bold),
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
                body: Stack(children: [
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
                    padding: const EdgeInsets.all(10),
                    child: ListView.builder(
                      itemCount: complaints.length,
                      itemBuilder: (content, index) {
                        final item = complaints[index];
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
                                  Container(
                                    padding: const EdgeInsets.only(right: 10),
                                    width: double.infinity,
                                    child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.end,
                                        children: [
                                          Text(
                                            item.title,
                                            textDirection: TextDirection.rtl,
                                            style: const TextStyle(
                                                fontSize: 20,
                                                fontWeight: FontWeight.w500),
                                          ),
                                          const SizedBox(
                                            height: 10,
                                          ),
                                          Text(
                                            item.content,
                                            textDirection: TextDirection.rtl,
                                            style: const TextStyle(
                                              fontSize: 18,
                                            ),
                                          ),
                                          const SizedBox(
                                            height: 10,
                                          ),
                                        ]),
                                  ),
                                ]));
                      },
                    ),
                  ),
                ]),
              );
  }
}
