import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import '../../bottom_navigation_bar.dart';
import '../../Constants.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AddComp extends StatefulWidget {
  const AddComp({super.key});
  @override
  State<AddComp> createState() => _AddCompState();
}

class _AddCompState extends State<AddComp> {
  final _contentController = TextEditingController();
  final _titleController = TextEditingController();
  final url = Uri.parse('${Constants.baseUrl}/student/complaints');
  String? name, token;
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
      name = prefs.getString('name');
      profile_img_url = prefs.getString('profile_img');
      token = prefs.getString('Token');
      user_id = prefs.getInt('id');
    });
  }

  Future<bool> sendComp() async {
    final title = _titleController.text;
    final content = _contentController.text;

    if (token == null) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Please wait, loading user data...")));
      return false;
    }

    if (content.trim().isEmpty || title.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: content.trim().isEmpty
              ? const Text("please write a content for your complaint")
              : const Text("please write a title for your complaint")));
      return false;
    } else {
      try {
        final response = await http.post(
          url,
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token'
          },
          body: json.encode({
            'subject': title,
            'description': content,
            'created_at': DateTime.now().toIso8601String(),
            'user_id': user_id,
          }),
        );
        if (response.statusCode == 200 || response.statusCode == 201) {
          final res = json.decode(response.body);
          final message = res['message'];
          setState(() {
            date = DateTime.parse(res['created_at']);
          });
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text("$message"),
            backgroundColor: Colors.green,
          ));
          _contentController.clear();
          // إرجاع خطوة للوراء بعد عرض الرسالة بفترة قصيرة
          Future.delayed(const Duration(seconds: 2), () {
            Navigator.pop(context);
          });
          return true;
        } else {
          final res = json.decode(response.body);
          final message = res['messaage'];
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text("$message"),
            backgroundColor: Colors.red,
          ));
          return false;
        }
      } catch (e) {
        //print(e);
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("An error occurred while sending")));
        return false;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: Bottom_navigation_bar(),
      appBar: AppBar(
        title: const Text(
          "Whats your problem?",
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
      body: Stack(
        children: [
          Positioned.fill(
            child: Column(
              children: [
                Expanded(
                    flex: 3, child: Container(color: const Color(0xffffffff))),
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
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
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
                        crossAxisAlignment: CrossAxisAlignment.start,
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
                                    ? DateFormat('hh-mm a dd/MM/yyyy')
                                        .format(date!)
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
                      TextField(
                        maxLength: 25,
                        controller: _titleController,
                        decoration: InputDecoration(
                          labelText: "title",
                          enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: const BorderSide(color: Colors.grey)),
                          focusedBorder: const OutlineInputBorder(
                            borderSide: BorderSide(
                              color: Constants.primaryColor,
                            ),
                          ),
                          focusedErrorBorder: const OutlineInputBorder(
                              borderSide:
                                  BorderSide(color: Constants.primaryColor)),
                          errorBorder: const OutlineInputBorder(
                              borderSide:
                                  BorderSide(color: Constants.primaryColor)),
                        ),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      SizedBox(
                        height: 150,
                        child: TextField(
                          expands: true,
                          maxLength: 255,
                          maxLines: null,
                          controller: _contentController,
                          decoration: InputDecoration(
                            labelText: "content",
                            enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide:
                                    const BorderSide(color: Colors.grey)),
                            focusedBorder: const OutlineInputBorder(
                              borderSide: BorderSide(
                                color: Constants.primaryColor,
                              ),
                            ),
                            focusedErrorBorder: const OutlineInputBorder(
                                borderSide:
                                    BorderSide(color: Constants.primaryColor)),
                            errorBorder: const OutlineInputBorder(
                                borderSide:
                                    BorderSide(color: Constants.primaryColor)),
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
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
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
                          child: const Text("Discard",
                              style: TextStyle(
                                  fontSize: 20,
                                  color: Color.fromARGB(255, 247, 16, 0))),
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
                            sendComp();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Constants.primaryColor,
                            foregroundColor: Colors.black,
                            elevation: 5,
                          ),
                          child: const Text("Send",
                              style:
                                  TextStyle(fontSize: 20, color: Colors.white)),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
