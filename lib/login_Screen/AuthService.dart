import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:log_in/Constants.dart';

class AuthService {
  static Future<Map<String, dynamic>> login({
    required String id,
    required String password,
    String? email,
  }) async {
    final url = Uri.parse('${Constants.baseUrl}/login');

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
        
        return {
          'success': true,
          'message': data['message'],
          'Token': data['Token'],
          'User': data['User'],
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'فشل في تسجيل الدخول',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'حدث خطأ أثناء الاتصال بالسيرفر',
      };
    }
  }
}