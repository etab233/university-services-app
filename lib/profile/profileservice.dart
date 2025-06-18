import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:http_parser/http_parser.dart';
import 'package:log_in/AuthService.dart';
import 'dart:typed_data';

import 'package:log_in/Constants.dart';

class ProfileService {
  Future<Map<String, dynamic>?> fetchProfile(int userId) async {
    try {
      final token = await AuthService.getToken();
      final response = await http.get(
        Uri.parse('${Constants.baseUrl}/profile'),
        headers: {
          'Authorization': 'Baerer $token',
          'Content-Type': 'application/json',
        },
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['record'];
      } else {
        print("Failed to load profile: ${response.statusCode}");
        return null;
      }
    } catch (e) {
      print("Error fetching profile: $e");
      return null;
    }
  }

  Future<bool> uploadProfileImage(Uint8List imageBytes, String filename) async {
    try {
      final token = await AuthService.getToken();
      final extension = filename.split('.').last.toLowerCase();
      final mediaType = (extension == 'png') ? 'png' : 'jpeg';

      var url = Uri.parse('${Constants.baseUrl}/profile');
      var request = http.MultipartRequest(
        'POST',
        url,
      );
      request.headers['Authorization'] = 'Bearer $token';
      request.files.add(
        http.MultipartFile.fromBytes(
          'image',
          imageBytes,
          filename: filename,
          contentType: MediaType('image', mediaType),
        ),
      );

      var response = await request.send();

      if (response.statusCode == 200) {
        print("Image uploaded successfully");
        return true;
      } else {
        print("Image upload failed: ${response.statusCode}");
        return false;
      }
    } catch (e) {
      print("Upload error: $e");
      return false;
    }
  }
}
