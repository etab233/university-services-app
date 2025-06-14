import 'package:flutter/material.dart';
import 'package:log_in/complaint_Screen/add_complaint.dart';
import 'package:log_in/complaint_Screen/view_complaints.dart';
import 'welcome.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'خدمات جامعية',
      home: AddComp(),
    );
  }
}
