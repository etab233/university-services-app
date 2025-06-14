import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import '../../bottom_navigation_bar.dart';
import '../../Constants.dart';

class AddComp extends StatefulWidget {
  const AddComp({super.key});
  @override
  State<AddComp> createState() => _AddCompState();
}

class _AddCompState extends State<AddComp> {
  final _ContentController = TextEditingController();
  final _TitleController = TextEditingController();
  final url = Uri.parse('${Constants.baseUrl}/addcomp');
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

  Future<void> SendComp() async {
    final postUrl = Uri.parse('${Constants.baseUrl}/complaint');
    final title = _TitleController.text;
    final content = _ContentController.text;
    if (content.trim().isEmpty || title.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: content.trim().isEmpty
              ? const Text("please write a content for your complaint")
              : const Text("please write a title for your complaint")));
    } else {
      try {
        final response = await http.post(
          postUrl,
          headers: {
            'Content-Type': 'application/json',
          },
          body: json.encode({
            'title': title,
            'content': content,
            'date': DateTime.now().toIso8601String(),
            'userID': 1,
          }),
        );
        if (response.statusCode == 200 || response.statusCode == 201) {
          ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Complaint sent successfully!")));
          _ContentController.clear();
          Navigator.of(context).pop();
        } else {
          ScaffoldMessenger.of(context)
              .showSnackBar(const SnackBar(content: Text("Sending failed")));
        }
      } catch (e) {
        //print("Error while SendComping: $e");
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("An error occurred while sending")));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 152, 203, 245),
      bottomNavigationBar: Bottom_navigation_bar(),
      appBar: AppBar(
        title: Text(
          "Whats your problem?",
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
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 400,
              height: 400,
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
                      const SizedBox(
                        width: 15,
                      ),
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
                          )
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  Expanded(
                    child: TextField(
                      maxLength: 25,
                      controller: _TitleController,
                      decoration: InputDecoration(
                        enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide:
                                const BorderSide(color: Color(0xff000000))),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(
                            color: Constants.primaryColor,
                          ),
                        ),
                        counterText: "",
                        labelText: "Title",
                        // hintText: "Complaint title",
                        labelStyle: TextStyle(fontSize: 20),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  Expanded(
                    flex: 3,
                    child: TextField(
                      expands: true,
                      maxLength: 255,
                      maxLines: null,
                      controller: _ContentController,
                      decoration: InputDecoration(
                          enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide:
                                  const BorderSide(color: Color(0xff000000))),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(
                              color: Constants.primaryColor,
                            ),
                          ),
                          labelText: "Content",
                          labelStyle: TextStyle(fontSize: 20)
                          // hintText: "Write the complaint",
                          ),
                    ),
                  ),
                ],
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
                  Container(
                    height: 45,
                    width: 120,
                    child: ElevatedButton(
                      onPressed: () {
                        showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                content: const Text(
                                    "Are you sure you want to discard complaint?"),
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
                                      Navigator.pop(context);
                                    },
                                    child: const Text("Yes"),
                                  ),
                                ],
                              );
                            });
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            const Color.fromARGB(255, 252, 184, 179),
                        foregroundColor: Colors.black,
                        elevation: 10,
                      ),
                      child: Text("Discard",
                          style: TextStyle(
                              fontSize: 20,
                              color: const Color.fromARGB(255, 247, 16, 0))),
                    ),
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  Container(
                    height: 45,
                    width: 120,
                    child: ElevatedButton(
                      onPressed: () {
                        SendComp();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Constants.primaryColor,
                        foregroundColor: Colors.black,
                        elevation: 5,
                      ),
                      child: Text("Send",
                          style: TextStyle(fontSize: 20, color: Colors.white)),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
