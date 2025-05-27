import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class Announcement {
  final String doctor_name;
  final String date;
  final String content;
  Announcement(
      {required this.doctor_name, required this.date, required this.content});
  factory Announcement.fromJson(Map<String, dynamic> json) {
    return Announcement(
      doctor_name: json['doctor_name'],
      date: json['date'],
      content: json['content'],
    );
  }
}

class AnnouncementList extends StatefulWidget {
  AnnouncementList({Key? key}) : super(key: key);
  @override
  _AnnouncementListState createState() => _AnnouncementListState();
}

class _AnnouncementListState extends State<AnnouncementList> {
  List<Announcement> announcements = [];
  bool isLoading = true;
  @override
  void initState() {
    super.initState();
    fetchAnnouncement();
  }

  Future<void> fetchAnnouncement() async {
    final url =
        Uri.parse('http://api.com/api/announcements'); // استبدل بالرابط الحقيقي
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final List jsonData = json.decode(response.body);
        setState(() {
          announcements =
              jsonData.map((item) => Announcement.fromJson(item)).toList();
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
        : announcements.isEmpty
            ? Center(
                child: Text('No Announcement'),
              )
            : Scaffold(
                backgroundColor: Colors.white,
                appBar: AppBar(
                  automaticallyImplyLeading: false,
                  title: const Text(
                    'Announcement',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  backgroundColor: Colors.white,
                  leading: IconButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    icon: const Icon(Icons.arrow_back,
                        size: 30, color: Colors.blue),
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
                      itemCount: announcements.length,
                      itemBuilder: (content, index) {
                        final item = announcements[index];
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
                                      size: 20, color: Colors.blue),
                                  const SizedBox(
                                    height: 10,
                                  ),
                                  Text(
                                    item.doctor_name,
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
