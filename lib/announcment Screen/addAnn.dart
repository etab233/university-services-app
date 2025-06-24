import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:log_in/announcment%20Screen/AnnList.dart';
import '../Constants.dart';
import '../bottom_navigation_bar.dart';
import 'notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AddAnnouncement extends StatefulWidget {
  AddAnnouncement({Key? key}) : super(key: key);
  @override
  _AddAnnouncementState createState() => _AddAnnouncementState();
}

class _AddAnnouncementState extends State<AddAnnouncement> {
  final _AddController = TextEditingController();
  String? name;
  String? profile_img_url;
  DateTime? date;
  int? user_id;

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      name = prefs.getString('name') ?? 'No Name';
      profile_img_url = prefs.getString('profile_img_url');
      user_id = prefs.getInt('user_id');
    });
  }

  Future<bool> publish() async {
    final content = _AddController.text.trim();
    if (content.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("please write your announcement before publish"),
      ));
      return false;
    }

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('Token');
      final postUrl = Uri.parse('${Constants.baseUrl}/admin/announcements');
      final response = await http.post(
        postUrl,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({
          'content': content,
          'date': DateTime.now().toIso8601String(),
          'user_id': user_id,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final res = json.decode(response.body);
        final announcement = res['announcement'];
        setState(() {
          name = announcement['user']['name'];
          date = DateTime.parse(announcement['created_at']);
        });

        _AddController.clear();

        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(res['message']),
          backgroundColor: Colors.green,
        ));

        return true;
      } else {
        final res = json.decode(response.body);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(res['message']),
          backgroundColor: Colors.red,
        ));
        return false;
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("An error occurred while publishing"),
        backgroundColor: Colors.red,
      ));
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "What's new ?",
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            fontFamily: 'serif',
          ),
        ),
        leading: const Icon(Icons.campaign, size: 30),
        backgroundColor: Colors.cyan,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications, size: 30),
            onPressed: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => Notifications()));
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Center(
              child: Container(
                width: 320,
                height: MediaQuery.of(context).size.height * 0.5,
                margin: const EdgeInsets.only(top: 30),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(17),
                  boxShadow: [
                    BoxShadow(
                      blurRadius: 6,
                      color: Colors.grey.withOpacity(0.5),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 20,
                          backgroundImage: profile_img_url != null
                              ? NetworkImage(profile_img_url!)
                              : null,
                          child: profile_img_url == null
                              ? const Icon(Icons.person)
                              : null,
                        ),
                        const SizedBox(width: 15),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("$name", style: const TextStyle(fontSize: 20)),
                            Text(
                              date != null
                                  ? DateFormat('dd/MM/yyyy').format(date!)
                                  : '',
                              style: const TextStyle(
                                  color: Colors.grey, fontSize: 14),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Padding(
                      padding: const EdgeInsets.only(left: 10),
                      child: TextField(
                        maxLength: 255,
                        maxLines: null,
                        keyboardType: TextInputType.multiline,
                        controller: _AddController,
                        decoration: const InputDecoration(
                          hintText: "Write Here",
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.only(right: 17),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      if (_AddController.text.trim().isEmpty) {
                        Navigator.pop(context); // لا شيء يتم حذفه إذا الحقل فارغ
                      } else {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              content: const Text("Delete this Announcement ?"),
                              actions: [
                                TextButton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                  },
                                  child: const Text("No"),
                                ),
                                TextButton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                    _AddController.clear();
                                    setState(() {
                                      date = null;
                                    });
                                  },
                                  child: const Text("Yes"),
                                ),
                              ],
                            );
                          },
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.black,
                      elevation: 10,
                    ),
                    child: const Padding(
                      padding: EdgeInsets.all(10),
                      child: Text("Cancel", style: TextStyle(fontSize: 18)),
                    ),
                  ),
                  const SizedBox(width: 10),
                  ElevatedButton(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            content: const Text(
                                "Are you sure you want to publish this announcement"),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                                child: const Text("Return to Edit"),
                              ),
                              TextButton(
                                onPressed: () async {
                                  Navigator.pop(context);
                                  final success = await publish();
                                  if (success) {
                                    Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              AnnouncementList()),
                                    );
                                  }
                                },
                                child: const Text("Yes"),
                              ),
                            ],
                          );
                        },
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.black,
                      elevation: 10,
                    ),
                    child: const Padding(
                      padding: EdgeInsets.all(10),
                      child: Text("Publish", style: TextStyle(fontSize: 18)),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Bottom_navigation_bar(),
    );
  }
}
