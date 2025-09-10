import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:university_services/Constants.dart';
import 'package:university_services/bottom_navigation_bar.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'profileservice.dart';
import 'profileimage.dart';
import 'package:http/http.dart' as http;

class MyProfile extends StatefulWidget {
  const MyProfile({super.key});

  @override
  State<MyProfile> createState() => _MyProfileState();
}

class _MyProfileState extends State<MyProfile> {
  Uint8List? _image;
  bool isLoading = true;
  String? name;
  String? email;
  int? year;
  String? department;
  int? id;
  String? role;
  String? position;
  String? profile_image;
  final ProfileService _profileService = ProfileService();
  final String baseUrl = 'http://your-domain.com/storage/';

  @override
  void initState() {
    super.initState();
    loadProfileData();
  }

  Future<void> fetchProfile() async {
    String fetchUrl = '${Constants.baseUrl}/profile';
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? role = await prefs.getString("role");
    String? token = await prefs.getString("Token");
    try {
      final response = await http.get(Uri.parse(fetchUrl), headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json'
      });
      final data = jsonDecode(response.body);
      if (response.statusCode == 200) {
        if (role == "student") {
          prefs.setString('department', data["department"]);
          prefs.setInt('year', data["year"]);
        } else {
          prefs.setString('position', data["position"]);
        }
        if (data["profile_image"] != null) {
          prefs.setString('profile_img', data["profile_image"]);
        }
      } else {
        Constants.showMessage(context, data["message"], Colors.red);
      }
    } catch (e) {}
  }

  void loadProfileData() async {
    await fetchProfile();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    id = await prefs.getInt("id");
    role = await prefs.getString("role");
    name = await prefs.getString("name");
    email = await prefs.getString("email");
    profile_image = await prefs.getString("profile_img");
    if (role == "student") {
      department = await prefs.getString("department");
      year = await prefs.getInt("year");
    }
    if (role == "admin") {
      position = await prefs.getString("position");
    }

    setState(() {
      isLoading = false;
    });
  }

  // Open image picker and upload selected profile image
  void selectImage() async {
    final Uint8List? img = await pickImage(ImageSource.gallery);
    if (img == null) return; // نتأكد من وجود الصورة

    setState(() {
      _image = img;
    });

    bool success = await _profileService.uploadProfileImage(
      imageBytes: img,
      filename: 'profile.jpg',
      email: email ?? '',
    );

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
    final String imagePath = profile_image ?? 'default.png';
// Decide which image to display: new picked image, server image, or default asset
    ImageProvider profileImage;
    if (_image != null) {
      profileImage = MemoryImage(_image!);
    } else if (imagePath != 'default.png') {
      profileImage = NetworkImage(baseUrl + imagePath);
    } else {
      profileImage = const AssetImage('assets/imgs/default.png');
    }

    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.blue,
          title: Text(
            'My Profile',
            style: TextStyle(
                fontSize: 24, color: Colors.black, fontWeight: FontWeight.w600),
          ),
          centerTitle: true,
          leading: IconButton(
              onPressed: () {
                Navigator.pop(context);
              },
              icon: Icon(Icons.abc)),
        ),
        body: isLoading == true
            ? Center(
                child: CircularProgressIndicator(
                  color: Constants.primaryColor,
                ),
              )
            : Padding(
                padding: const EdgeInsets.all(15),
                child: SingleChildScrollView(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Row(
                          // User name and profile image section
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Expanded(
                              child: ListTile(
                                title: Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 5),
                                  child: Text(
                                    name?.toString() ?? 'N/A',
                                    style: TextStyle(fontSize: 20),
                                  ),
                                ),
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
                                    icon:
                                        const Icon(Icons.photo_camera_rounded),
                                  ),
                                )
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        const Text("User Details:",
                            style: TextStyle(fontSize: 24)),
                        const SizedBox(height: 5),
                        // Display student or admin details
                        ListTile(
                          title: const Text('ID:'),
                          subtitle: Text(id.toString()),
                        ),
                        if (role == "student") ...[
                          ListTile(
                            title: const Text('Year:'),
                            subtitle: Text(year?.toString() ?? 'N/A'),
                          ),
                          ListTile(
                            title: const Text('Department:'),
                            subtitle: Text(department ?? 'N/A'),
                          ),
                        ] else if (role == "admin") ...[
                          ListTile(
                            title: const Text('Position:'),
                            subtitle: Text(position ?? 'N/A'),
                          ),
                        ],
                        ListTile(
                          title: const Text('Role:'),
                          subtitle: Text(role ?? 'N/A'),
                        ),
                        const SizedBox(height: 10),
                        const Text("Contact Information:",
                            style: TextStyle(fontSize: 24)),
                        const SizedBox(height: 5),
                        ListTile(
                          title: const Text('Email:'),
                          subtitle: Text(email ?? 'N/A'),
                        ),
                      ]),
                ),
              ));
  }
}
