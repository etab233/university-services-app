import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:university_services/login_Screen/log_in.dart';
import '../login_Screen/AuthService.dart';
import 'package:university_services/Constants.dart';
import 'polls.dart';

// خدمة مسؤولة عن التعامل مع API الخاصة بالتصويتات (Polls)
class PollService {
  // جلب جميع التصويتات من السيرفر
  static Future<List<Poll>> getPolls() async {
    final url = Uri.parse('${Constants.baseUrl}/admin/polls');
    final token = await AuthService.getToken();

// إرسال الطلب إلى API مع التوكن إذا كان موجود
    final response = await http.get(
      url,
      headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    // التحقق من نجاح الطلب
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return (data["polls"] as List).map((p) => Poll.fromJson(p)).toList();
    } else {
      throw Exception('فشل في جلب التصويتات');
    }
  }

  // إنشاء تصويت جديد (Admin فقط)
  static Future<Poll?> createPoll({
    required String question,
    required List<String> options,
    required Duration duration,
  }) async {
    final role = await AuthService.getRole();

    // التحقق من الصلاحية
    if (role != 'admin') {
      throw Exception("مسموح فقط للادمن بإنشاء التصويت");
    }

    final token = await AuthService.getToken();
    final url = Uri.parse('${Constants.baseUrl}/admin/polls');

    // البيانات المطلوبة لإنشاء تصويت
    final body = {
      "question": question,
      "options": options,
      "duration_days": duration.inDays,
    };

    // إرسال الطلب
    final response = await http.post(
      url,
      headers: {
        "Accept": "application/json",
        "Content-Type": "application/json",
        if (token != null) "Authorization": "Bearer $token"
      },
      body: jsonEncode(body),
    );

    // التحقق من نجاح العملية
    if (response.statusCode == 201) {
      final data = json.decode(response.body);
      return Poll.fromJson(data['poll']);
    } else {
      final data = json.decode(response.body);
      throw Exception(data['message'] ?? "فشل في إنشاء التصويت");
    }
  }

  // إرسال تصويت (مسموح فقط للطلاب)
  static Future<Map<String, dynamic>> vote(int pollId, int optionId) async {
    final role = await AuthService.getRole();

    // التحقق من الصلاحية
    if (role != 'student') {
      return {"success": false, "message": "عذراً، لا تملك الصلاحيات"};
    }

    final token = await AuthService.getToken();
    if (token == null) {
      throw Exception("المستخدم غير مسجل الدخول");
    }

    // إرسال الطلب إلى API
    final response = await http.post(
      Uri.parse('${Constants.baseUrl}/polls/$pollId/vote'),
      body: {'option_id': optionId.toString()},
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      },
    );

    final data = json.decode(response.body);

    if (response.statusCode == 200) {
      // في حال رجعت النتائج مباشرةً من نفس الـ API
      if (data['results'] is List) {
        final List<Option> options =
            (data['results'] as List).map((o) => Option.fromJson(o)).toList();
        return {
          "success": true,
          "message": data['message'] ?? "تم التصويت بنجاح",
          "options": options,
        };
      }

      // في حال لم ترجع النتائج مباشرة، نستدعي API منفصل
      final resultsData = await getPollResults(pollId);
      return {
        "success": true,
        "message": data['message'] ?? "تم التصويت بنجاح",
        "options": resultsData['options'], // List<Option>
      };
    } else {
      return {
        "success": false,
        "message": data['message'] ?? "فشل في إرسال التصويت",
      };
    }
  }

  // حذف التصويت (Admin فقط)
  static Future<void> deletePoll(BuildContext context, int pollId) async {
    try {
      final token = await AuthService.getToken();
      final url = Uri.parse('${Constants.baseUrl}/admin/polls/$pollId');

      final response = await http.delete(
        url,
        headers: {
          "Accept": "application/json",
          if (token != null) "Authorization": "Bearer $token",
        },
      );

      final data = json.decode(response.body);
      switch (response.statusCode) {
        case 200:
          {
            Constants.showMessage(context, data["message"], Colors.green);
            getPolls();
          }
        case 404:
          Constants.showMessage(context, data["message"], Colors.red);
        case 403:
          {
            Constants.showMessage(context, data["message"], Colors.red);
            Navigator.pushReplacement(
                context, MaterialPageRoute(builder: (context) => Log_in()));
          }
      }
    } catch (e) {
      Constants.showMessage(context, "Unknown Error $e", Colors.red);
    }
  }

  // إيقاف التصويت (Admin فقط)
  static Future<Map<String, dynamic>> stopPoll(int pollId) async {
    final role = await AuthService.getRole();
    if (role != 'admin') {
      return {"success": false, "message": "مسموح فقط للادمن بإنهاء التصويت"};
    }

    final token = await AuthService.getToken();
    final url = Uri.parse('${Constants.baseUrl}/admin/polls/stop/$pollId');

    final response = await http.post(
      url,
      headers: {
        "Accept": "application/json",
        if (token != null) "Authorization": "Bearer $token",
      },
    );

    return json.decode(response.body);
  }

  // جلب نتائج تصويت معيّن
  static Future<Map<String, dynamic>> getPollResults(int pollId) async {
    final token = await AuthService.getToken();
    final url = Uri.parse('${Constants.baseUrl}/polls/$pollId/results');

    final response = await http.get(
      url,
      headers: {
        "Accept": "application/json",
        if (token != null) "Authorization": "Bearer $token",
      },
    );

    final data = json.decode(response.body);

    // إذا كان الطلب ناجح
    if (response.statusCode == 200) {
      final List<Option> options =
          (data['results'] as List).map((o) => Option.fromJson(o)).toList();

      return {
        "poll_id": data['poll_id'],
        "question": data['question'],
        "options": options, // نرجع List<Option> باسم options
      };
    } else {
      throw Exception(data['message'] ?? "فشل في جلب النتائج");
    }
  }
}
