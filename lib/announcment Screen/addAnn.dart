import 'package:flutter/material.dart';

void main() => runApp(AddAnnouncement());

class AddAnnouncement extends StatefulWidget {
  AddAnnouncement({Key? key}) : super(key: key);
  @override
  _AddAnnouncementState createState() => _AddAnnouncementState();
}

class _AddAnnouncementState extends State<AddAnnouncement> {
  final _AddController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor:const Color(0xff00bbd4),
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
                    padding:const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        const Row(
                          children: [
                            CircleAvatar(
                              radius: 20,
                              child: Icon(
                                Icons.person,
                                size: 35,
                              ),
                            ),
                            SizedBox(
                              width: 15,
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("name",
                                    style: TextStyle(fontSize: 20)),
                                 Text(
                                  "22/8/2025.",
                                  style: TextStyle(
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
                padding:const EdgeInsets.only(right: 17),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        print(";");
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
                        print(";");
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
      ),
    );
  }
}
