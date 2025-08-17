import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'profileservice.dart';
import 'profileimage.dart';

class MyProfile extends StatefulWidget {
  const MyProfile({super.key});

  @override
  State<MyProfile> createState() => _MyProfileState();
}

class _MyProfileState extends State<MyProfile> {
  Uint8List? _image;
  Map<String, dynamic>? userData;
  bool isLoading = true;
  final ProfileService _profileService = ProfileService();
  final String baseUrl = 'http://your-domain.com/storage/';

  @override
  void initState() {
    super.initState();
    loadProfileData();
  }

  void loadProfileData() async {
    final data = await _profileService.fetchProfile(1);
    if (data != null) {
      setState(() {
        userData = data;
        isLoading = false;
      });
    }
  }

  void selectImage() async {
    final img = await pickImage(ImageSource.gallery);
    if (img == null) return;

    setState(() {
      _image = img;
    });

    bool success = await _profileService.uploadProfileImage(img, 'profile.jpg');
    if (success) {
      loadProfileData();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Profile image updated successfully")),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to upload image")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading || userData == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final user = userData!;
    final String imagePath = user['profile_image'] ?? 'default.png';

    ImageProvider profileImage;
    if (_image != null) {
      profileImage = MemoryImage(_image!);
    } else if (imagePath != 'default.png') {
      profileImage = NetworkImage(baseUrl + imagePath);
    } else {
      profileImage = const AssetImage('images/default.png');
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: const Center(
          child: Text(
            'My Profile',
            style: TextStyle(
                fontSize: 24, color: Colors.white, fontWeight: FontWeight.w600),
          ),
        ),
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.chevron_left, size: 40, color: Colors.white),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(15),
        child: SingleChildScrollView(
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Expanded(
                      child: ListTile(
                        title: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 5),
                          child: Text(user['name']?.toString() ?? 'N/A'),
                        ),
                        titleTextStyle: const TextStyle(fontSize: 24),
                        subtitleTextStyle: const TextStyle(
                            fontSize: 14, color: Color(0xff616161)),
                        subtitle: Text(
                            "Created at: ${user['created_at']?.toString() ?? 'N/A'}"),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Stack(
                      children: [
                        CircleAvatar(
                          radius: 64,
                          backgroundImage: profileImage,
                        ),
                        Positioned(
                          bottom: -6,
                          right: 45,
                          child: IconButton(
                            onPressed: selectImage,
                            icon: const Icon(Icons.photo_camera_rounded),
                          ),
                        )
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: 10),
                const Text("User Details", style: TextStyle(fontSize: 24)),
                const SizedBox(height: 5),

                // Student or Admin details
                if (user.containsKey('student_id')) ...[
                  ListTile(
                    title: const Text('Student ID'),
                    subtitle: Text(user['student_id'] ?? 'N/A'),
                  ),
                  ListTile(
                    title: const Text('Year'),
                    subtitle: Text(user['year'] ?? 'N/A'),
                  ),
                  ListTile(
                    title: const Text('Department'),
                    subtitle: Text(user['department'] ?? 'N/A'),
                  ),
                ] else if (user.containsKey('position')) ...[
                  ListTile(
                    title: const Text('Position'),
                    subtitle: Text(user['position'] ?? 'N/A'),
                  ),
                ],

                const SizedBox(height: 10),
                const Text("Contact Information",
                    style: TextStyle(fontSize: 24)),
                const SizedBox(height: 5),
                ListTile(
                  title: const Text('Email'),
                  subtitle: Text(user['email'] ?? 'N/A'),
                ),
              ]),
        ),
      ),
    );
  }
}
