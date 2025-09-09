import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../Constants.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../bottom_navigation_bar.dart';

class Complaints {
  final String student_name;
  final String title;
  final String content;
  final String date;
  final int compId;
  final String? imageUrl;

  Complaints(this.student_name, this.title, this.content, this.date,
      this.compId, this.imageUrl);
  factory Complaints.fromJson(Map<String, dynamic> json) {
    String date = json['created_at'];
    String dateFormat =
        DateFormat('hh:mm a - dd/MM/yyyy').format(DateTime.parse(date));
    return Complaints(
        json['user']['name'],
        json['subject'],
        json['description'],
        dateFormat,
        json['id'],
        json['user']['profile_image']);
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
    final url = Uri.parse('${Constants.baseUrl}/admin/complaints');
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('Token');
    try {
      final response = await http.get(url, headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      });
      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = json.decode(response.body);
        final List<dynamic> data = jsonData['complaints'];
        setState(() {
          complaints = data.map((item) => Complaints.fromJson(item)).toList();
          isLoading = false;
        });
      } else {
        throw Exception('Failed to fetch data');
      }
    } catch (e) {
      Constants.showMessage(context, "$e", Colors.red);
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> deleteComplaint(int compId) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('Token');
    final url = Uri.parse('${Constants.baseUrl}/admin/complaints/$compId');
    try {
      final response = await http.delete(url, headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      });
      if (response.statusCode == 200 || response.statusCode == 201) {
        fetchcomplaints();
        setState(() {
          complaints.removeWhere((item) => item.compId == compId);
          final data = json.decode(response.body);
          final message = data['message'];
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('$message'),
            backgroundColor: Colors.green,
          ));
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('حدث خطأ أثناء الحذف')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: const BottomNavigation(
        currentIndex: -1,
      ),
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          "Complaints",
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
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
          : complaints.isEmpty
              ? const Center(
                  child: Text(
                    'No complaints',
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
                    padding: const EdgeInsets.all(10),
                    child: ListView.builder(
                      itemCount: complaints.length,
                      itemBuilder: (context, index) {
                        final item = complaints[index];
                        return Container(
                            margin: const EdgeInsets.symmetric(
                                vertical: 8, horizontal: 12),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.3),
                                  spreadRadius: 2,
                                  blurRadius: 6,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      CircleAvatar(
                                        radius: 20,
                                        backgroundImage:
                                            (item.imageUrl != null &&
                                                    item.imageUrl!.isNotEmpty)
                                                ? NetworkImage(item.imageUrl!)
                                                : null,
                                        child: (item.imageUrl == null ||
                                                item.imageUrl!.isEmpty)
                                            ? const Icon(Icons.person)
                                            : null,
                                      ),
                                      const SizedBox(
                                        width: 5,
                                      ),
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            item.student_name,
                                            style: const TextStyle(
                                              fontSize: 20,
                                            ),
                                          ),
                                          Text(
                                            item.date,
                                            style: TextStyle(
                                                fontSize: 16,
                                                color: Colors.grey[600]),
                                          ),
                                        ],
                                      ),
                                      const Spacer(),
                                      IconButton(
                                        onPressed: () {
                                          showDialog(
                                              context: context,
                                              builder: (BuildContext context) {
                                                return AlertDialog(
                                                  content: const Text(
                                                      "Are you sure you want to delete it?"),
                                                  actions: [
                                                    TextButton(
                                                        onPressed: () =>
                                                            Navigator.of(
                                                                    context)
                                                                .pop(),
                                                        child: const Text(
                                                            "cancel")),
                                                    TextButton(
                                                        onPressed: () {
                                                          Navigator.of(context)
                                                              .pop(); // إغلاق مربع الحوار
                                                          deleteComplaint(item
                                                              .compId); // تنفيذ الحذف
                                                        },
                                                        child:
                                                            const Text("Yes")),
                                                  ],
                                                );
                                              });
                                        },
                                        icon: const Icon(
                                          Icons.delete,
                                          color: Colors.red,
                                        ),
                                      ),
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
                                            style: const TextStyle(
                                                fontSize: 20,
                                                fontWeight: FontWeight.w500),
                                          ),
                                          const SizedBox(
                                            height: 10,
                                          ),
                                          Text(
                                            item.content,
                                            //textDirection: TextDirection.rtl,
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
