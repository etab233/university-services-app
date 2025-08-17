import 'dart:typed_data';
import 'package:image_picker/image_picker.dart';

Future<Uint8List?> pickImage(ImageSource source) async {
  final ImagePicker picker = ImagePicker();
  final XFile? file = await picker.pickImage(source: source);

  if (file != null) {
    return await file.readAsBytes();
  }

  print('No image selected');
  return null;
}
