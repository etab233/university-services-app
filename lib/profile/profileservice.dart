import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:university_services/Constants.dart';

class ProfileService {
  final String uploadUrl = '${Constants.baseUrl}/profile/update'; // رابط API

  Future<bool> uploadProfileImage({
    required Uint8List imageBytes,
    required String filename,
    required String email, // ممكن تحتاج لإرسال بيانات إضافية مثل email أو name
  }) async {
    try {
      final extension = filename.split('.').last.toLowerCase();
      final mediaType = (extension == 'png') ? 'png' : 'jpeg';

      var request = http.MultipartRequest('POST', Uri.parse(uploadUrl));

      // ✅ الحقول الأخرى إذا بدك ترسلها (مثلاً email)
      request.fields['email'] = email;

      // ✅ رفع الصورة
      request.files.add(
        http.MultipartFile.fromBytes(
          'profile_image', // نفس اسم الحقل في Laravel
          imageBytes,
          filename: filename,
          contentType: MediaType('image', mediaType),
        ),
      );

      // إرسال الطلب
      var response = await request.send();
      final respStr = await response.stream.bytesToString();

      if (response.statusCode == 200) {
        print("✅ Profile updated successfully");
        print("Server response: $respStr");
        return true;
      } else {
        print("❌ Failed to update profile: ${response.statusCode}");
        print("Server response: $respStr");
        return false;
      }
    } catch (e) {
      print("❌ Upload error: $e");
      return false;
    }
  }
}
