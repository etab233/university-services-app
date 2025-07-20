import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:log_in/Constants.dart';

class AuthService {
  static Future<Map<String, dynamic>> login({
    required String id,
    required String password,
    String? email,
  }) async {
    final url = Uri.parse('${Constants.baseUrl}/login');
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final body = {
      'unique_id': id,
      'password': password,
    };

    if (email != null) {
      body['email'] = email;
    }

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
        // String? token = await prefs.getString('token') ?? "token is NULL";
        // print(token);
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
