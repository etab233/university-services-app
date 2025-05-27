import 'package:flutter/material.dart';
import 'login_Screen/log_in.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'خدمات جامعية',
      home: Log_in(),
    );
  }
}
