import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class Notification_content extends StatelessWidget {
  final String name;
  final String content;
  final String imageUrl;
  final String date;
  const Notification_content({
    super.key,
    required this.name,
    required this.content,
    required this.date,
    required this.imageUrl,
  });
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: IconButton(
          icon:const Icon(Icons.arrow_back, size: 30),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text(
          "Notification Content",
          style: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.bold,
            fontFamily: 'serif',
          ),
        ),
      ),
      body: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Center(
            child: Container(
              width: 340,
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
              child:Padding(
                padding: EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                              radius: 20,
                              backgroundImage:  NetworkImage(imageUrl),
                              child:  const Icon(Icons.person)  ,
                            ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("$name",
                                style:const TextStyle(fontSize: 20)),
                            Text( DateFormat('dd/MM/yyyy').format(DateTime.parse(date)) ,
                        style: const TextStyle(color: Colors.grey, fontSize: 14),)
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    Padding(
                      padding:const EdgeInsets.only(left: 10),
                      child: Text(
                        "$content",
                        style:const TextStyle(fontSize: 20),
                      ),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
