import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:log_in/announcment%20Screen/addAnn.dart';
import 'dart:convert';
import '../Constants.dart';
import 'package:intl/intl.dart';
import '../bottom_navigation_bar.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Announcement {
  final String name;
  final String date;
  final String content;
  final int id;
  final int annid;

  Announcement({required this.name, required this.date, required this.content, required this.id, required this.annid});

  factory Announcement.fromJson(Map<String, dynamic> json) {
    return Announcement(
      name: json['user']['name'],
      date: json['created_at'],
      content: json['content'],
      id:json['user']['id'],
      annid: json['id'],
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
  String? role;
  int? user_id;

  @override
  void initState() {
    super.initState();
    initData();
  }

  void initData() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('Token');
    final userRole = prefs.getString('role');
    final id=int.parse(prefs.getString('id')!);

    if (mounted) {
      setState(() {
        role = userRole;
        user_id=id;
      });
    }
    if (token != null && token.isNotEmpty) {
      await fetchAnnouncement(token);
    }
  }

  Future<void> fetchAnnouncement(String token) async {
    final url = Uri.parse('${Constants.baseUrl}/announcements');
    try {
      final response = await http.get(
        url,
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      if (response.statusCode == 200) {
        final List<dynamic> jsonData = json.decode(response.body);
        setState(() {
          announcements = jsonData.map((item) => Announcement.fromJson(item)).toList();
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

  Future<void> deleteAnnouncement(int annId)async{
    final prefs=await SharedPreferences.getInstance();
    final token=prefs.getString('Token');
    final url = Uri.parse('${Constants.baseUrl}/admin/announcements/$annId');
    try{
      final response= await http.delete(
        url,
        headers: {
          'Accept': 'application/json',
        'Authorization': 'Bearer $token',
        }
      );
      if(response.statusCode==200 || response.statusCode==201){
        await fetchAnnouncement(token!);
        setState(() {
          announcements.removeWhere((item) => item.annid == annId);
          final data=json.decode(response.body);
          final message=data['message'];
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('$message')),
      );
        }
        );
      }
    }catch(e){
      ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('حدث خطأ أثناء الحذف')),
    );
    }
  }

  final DateFormat formatter = DateFormat('HH:mm - dd/MM/yyyy');

  @override
  Widget build(BuildContext context) {
    return isLoading
        ? const Center(child: CircularProgressIndicator())
        : announcements.isEmpty
            ? const Center(child: Text('No Announcement'))
            : Scaffold(
                backgroundColor: Colors.white,
                appBar: AppBar(
                  automaticallyImplyLeading: false,
                  title: const Text('Announcements',
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                  backgroundColor: Colors.white,
                  leading: IconButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    icon: const Icon(Icons.arrow_back, size: 30, color: Constants.primaryColor),
                  ),
                  actions: [
                    if (role == 'admin')
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.blue),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => AddAnnouncement()),
                          );
                        },
                      ),
                  ],
                ),
                body: Stack(
                  children: [
                    Positioned.fill(
                      child: Column(
                        children: [
                          Expanded(flex: 3, child: Container(color: const Color(0xffffffff))),
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
                          DateTime parsedDate = DateTime.parse(item.date);
                          return Container(
                            margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
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
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    const Icon(Icons.person,
                                        size: 22, color: Constants.primaryColor),
                                    const SizedBox(width: 8),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                      Text(
                                        item.name,
                                        style: const TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.w600,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    Text(
                                      formatter.format(parsedDate),
                                      style: const TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey,
                                          fontStyle: FontStyle.italic),
                                    )
                                      ],
                                    ),
                                    const Spacer(),
                                    if(user_id==item.id && role=='admin')
                                       PopupMenuButton<String>(
                                        onSelected: (value) {
                                          if(value=='edit'){

                                          }
                                          else if(value=='delete'){
                                            showDialog(
                                              context: context,
                                              builder: (BuildContext context){
                                                return AlertDialog(
                                                  content: const Text("Are you sure you want to delete it?"),
                                                  actions: [
                                                    TextButton(
                                                      onPressed: () => Navigator.of(context).pop(),
                                                      child:const Text("cancel")),
                                                    TextButton(
                                                      onPressed: () {
                                                         Navigator.of(context).pop();
                                                         deleteAnnouncement(item.annid);
                                                      },
                                                      child:const Text("Yes")),
                                                  ],
                                                );
                                              }
                                            );

                                          }
                                        },
                                        itemBuilder:(BuildContext context) =>[
                                          const PopupMenuItem(value: 'edit',child: Text('edit')),
                                          const PopupMenuItem(value: 'delete', child: Text('delete')),
                                        ],
                                        icon:const Icon(Icons.more_vert),
                                       )
                                  ],
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  item.content,
                                  textAlign: TextAlign.right,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    height: 1.4,
                                    color: Colors.black87,
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
                bottomNavigationBar: Bottom_navigation_bar(),
              );
  }
}
