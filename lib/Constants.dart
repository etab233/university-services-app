import 'package:flutter/material.dart';

class Constants {
  static const Color primaryColor = Colors.blue;
  static const String logo = "assets/imgs/logo.png";
  static const String university = "assets/imgs/university.png";
  // static const baseUrl = 'http://192.168.1.110:8000/api';
  static const baseUrl = 'http://127.0.0.1:8000/api';
  // static const baseUrl = 'http://10.0.2.2:8000/api';

  static void showMessage(BuildContext context, String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          textAlign: TextAlign.right,
        ),
        backgroundColor: color,
      ),
    );
  }
}
