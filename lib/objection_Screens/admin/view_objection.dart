import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../Constants.dart';

class Objections {
  final String student_name;
  final String date;
  final String content;
  Objections(
      {required this.student_name, required this.date, required this.content});
  factory Objections.fromJson(Map<String, dynamic> json) {
    return Objections(
      student_name: json['student_name'],
      date: json['date'],
      content: json['content'],
    );
  }
}

class ViewObjections extends StatefulWidget {
  ViewObjections({Key? key}) : super(key: key);
  @override
  _ViewObjectionsState createState() => _ViewObjectionsState();
}

class _ViewObjectionsState extends State<ViewObjections> {
  List<Objections> objections = [];
  bool isLoading = true;
  @override
  void initState() {
    super.initState();
    fetchObjections();
  }

  Future<void> fetchObjections() async {
    final url = Uri.parse('${Constants.baseUrl}/api/objections');
    try {
      final response = await http.get(url);
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
    return isLoading
        ? Center(child: CircularProgressIndicator())
        : objections.isEmpty
            ? Center(
                child: Text('No Objections'),
              )
            : Scaffold(
                backgroundColor: Colors.white,
                appBar: AppBar(
                  //automaticallyImplyLeading: false,
                  title: const Text(
                    'Objections',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
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
                            child: Container(color: Color(0xffffffff))),
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
                          decoration: BoxDecoration(
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
                                      size: 20, color: Constants.primaryColor),
                                  const SizedBox(
                                    height: 10,
                                  ),
                                  Text(
                                    item.student_name,
                                    style: TextStyle(
                                      fontSize: 20,
                                    ),
                                  ),
                                  Spacer(),
                                  Text(
                                    item.date,
                                    style: TextStyle(
                                        fontSize: 12, color: Colors.grey),
                                  )
                                ],
                              ),
                              const SizedBox(
                                height: 10,
                              ),
                              Text(item.content, textAlign: TextAlign.right),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ]),
              );
  }
}
