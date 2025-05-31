import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:http_parser/http_parser.dart';
import 'dart:typed_data';

class ProfileService {
  Future<Map<String, dynamic>?> fetchProfile(int userId) async {
    try {
      final response = await http.get(
        Uri.parse('https://api.jsonbin.io/v3/qs/683aacb38a456b7966a7a233'),
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
      final extension = filename.split('.').last.toLowerCase();
      final mediaType = (extension == 'png') ? 'png' : 'jpeg';

      var uri = Uri.parse('http://your-domain.com/api/upload-profile-image');
      var request = http.MultipartRequest('POST', uri);

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
