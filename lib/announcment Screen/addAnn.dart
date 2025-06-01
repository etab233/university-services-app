import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:log_in/bottom_navigation_bar.dart';
import 'notifications.dart';

void main() => runApp(AddAnnouncement());

class AddAnnouncement extends StatefulWidget {
  AddAnnouncement({Key? key}) : super(key: key);
  @override
  _AddAnnouncementState createState() => _AddAnnouncementState();
}

class _AddAnnouncementState extends State<AddAnnouncement> {
  final _AddController = TextEditingController();
  final url = Uri.parse('http://your-laravel-backend.com/api/user-profile/123');
  String? name;
  String? profile_img_url;
  DateTime? date;

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          name = data['name'];
          profile_img_url = data['imageProfile'];
          date = DateTime.parse(data['created_at']);
        });
      } else {
        setState(() {
          name = null;
          profile_img_url = null;
          date = null;
        });
      }
    } catch (e) {
      print("Error fetching user profile: $e");
    }
  }

  Future<void> publish() async {
    final postUrl = Uri.parse('https://jsonplaceholder.typicode.com/posts');
    final content = _AddController.text;
    if (content.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content:
              const Text("please write your announcement before publish")));
    } else {
      try {
        final response = await http.post(
          postUrl,
          headers: {
            'Content-Type': 'application/json',
          },
          body: json.encode({
            'content': content,
            'date': DateTime.now().toIso8601String(),
            'userID': 1,
          }),
        );
        if (response.statusCode == 200 || response.statusCode == 201) {
          ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Published Successfully !")));
          _AddController.clear();
        } else {
          ScaffoldMessenger.of(context)
              .showSnackBar(const SnackBar(content: Text("Failed to publish")));
        }
      } catch (e) {
        //print("Error while publishing: $e");
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text("An error occurred while publishing")));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: const Color(0xff00bbd4),
        appBar: AppBar(
          title: const Text(
            "What's new ?",
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              fontFamily: 'serif',
            ),
          ),
          leading: const Icon(
            Icons.campaign,
            size: 30,
          ),
          actions: [
            IconButton(
              icon: Icon(Icons.notifications, size: 30),
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => Notifications(),
                    ));
              },
            ),
          ],
          backgroundColor: Colors.cyan,
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              Center(
                child: Container(
                  width: 320,
                  height: 400,
                  margin: const EdgeInsets.only(top: 30),
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
                  child: Padding(
                    padding: const EdgeInsets.all(20),
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
                            const SizedBox(
                              width: 15,
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("$name",
                                    style: const TextStyle(fontSize: 20)),
                                Text(
                                  date != null
                                      ? DateFormat('dd/MM/yyyy').format(date!)
                                      : '',
                                  style: const TextStyle(
                                      color: Colors.grey, fontSize: 14),
                                )
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(left: 10),
                            child: TextField(
                              maxLength: 255,
                              maxLines: null,
                              expands: true,
                              keyboardType: TextInputType.multiline,
                              controller: _AddController,
                              decoration: const InputDecoration(
                                hintText: "Write Here",
                                border: InputBorder.none,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              Padding(
                padding: const EdgeInsets.only(right: 17),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                content:
                                    const Text("Delete this Announcement ?"),
                                actions: [
                                  TextButton(
                                    onPressed: () {
                                      Navigator.pop(context);
                                    },
                                    child: const Text("Yes"),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      Navigator.pop(context);
                                      publish();
                                    },
                                    child: const Text("No"),
                                  ),
                                ],
                              );
                            });
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.black,
                        elevation: 10,
                      ),
                      child: const Padding(
                        padding: EdgeInsets.all(10),
                        child: Text("Cancel", style: TextStyle(fontSize: 18)),
                      ),
                    ),
                    const SizedBox(
                      width: 10,
                    ),
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
                                    child: const Text("No"),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      Navigator.pop(context);
                                      publish();
                                    },
                                    child: const Text("Yes"),
                                  ),
                                ],
                              );
                            });
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
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
      ),
    );
  }
}
