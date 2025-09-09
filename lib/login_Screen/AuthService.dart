import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:log_in/login_Screen/log_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:log_in/Constants.dart';

class AuthService {
  static Future<Map<String, dynamic>> login({
    required String id,
    required String password,
    required String email,
  }) async {
    final url = Uri.parse('${Constants.baseUrl}/login');
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final body = {
      'unique_id': id,
      'password': password,
      'email' : email,
    };

    try {
      final response = await http.post(
        url,
        headers: {
          'Accept': 'application/json',
        },
        body: body,
      );
      final data = json.decode(response.body);

      if (response.statusCode == 200) {
        await prefs.setString('token', data['Token']);
        await prefs.setString('role', data['User']["role"]);
        await prefs.setString('id', data['User']["unique_id"]);
        await prefs.setBool('success', true);
        return { 
          'success': true,
          'message': data['message'],
          'Token': data['Token'],
          'User': data['User'],
        };
      } else {
        await prefs.setBool('success', false);
        return {
          'success': false,
          'message': data['message'] ?? 'فشل في تسجيل الدخول',
        };
      }
    } catch (e) {
      await prefs.setBool('success', false);
      return {
        'success': false,
        'message': 'حدث خطأ أثناء الاتصال بالسيرفر',
      };
    }
  }

  static Future<void> logout(BuildContext context) async {
    String? token = await getToken();
    final url = Uri.parse("${Constants.baseUrl}/logout");
    try {
      final response = await http.post(url, headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json'
      });
      final data = jsonDecode(response.body);
      if (response.statusCode == 201) {
        await clearToken();
        Constants.showMessage(
            context, data['message'], const Color.fromRGBO(33, 33, 33, 1));
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (context) => Log_in()));
      }
    } catch (e) {
      Constants.showMessage(
          context, "Failed to logout please try again later", Colors.red);
    }
  }

  static Future<void> saveToken(String token) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', token);
  }

  static Future<void> clearToken() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
  }

  static Future<String?> getToken() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  static Future<String?> getId() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('id');
  }

  static Future<String?> getRole() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('role');
  }
}
