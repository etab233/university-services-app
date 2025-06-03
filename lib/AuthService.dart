import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:log_in/Constants.dart';

class AuthService {
  static Future<String> login(String id, String password, String email) async {
    final url = Uri.parse('${Constants.baseUrl}/api/login');
    final response = await http.post(url, headers: {
      'Accept': 'application/json'
    }, body: {
      'unique_id': id,
      'password': password,
      'email': email,
    });
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['token'];
    } else {
      return 'This account is not found';
    }
  }
}
