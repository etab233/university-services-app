import 'package:flutter/material.dart';
import 'package:university_services/bottom_navigation_bar.dart';
import 'AuthService.dart';
import '../Constants.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Register extends StatefulWidget {
  const Register({Key? key}) : super(key: key);
  @override
  _RegisterState createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  final TextEditingController _idController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final _formkey = GlobalKey<FormState>();
  bool isLoading = false;
  bool obscureText1 = true;
  bool obscureText2 = true;

  void _showSnackbar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Future<void> saveUserData({
    required String token,
    required String role,
    required String name,
    required int id,
    String? profileImgUrl,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('Token', token);
    await prefs.setString('role', role);
    await prefs.setString('name', name);
    await prefs.setInt('id', id);
    if (profileImgUrl != null) {
      await prefs.setString('profile_img', profileImgUrl);
    }
  }

  void _signup() async {
    if (!_formkey.currentState!.validate()) return;

    setState(() => isLoading = true);

    try {
      final id = _idController.text.trim();
      final password = _passwordController.text.trim();
      final email = _emailController.text.trim().isNotEmpty
          ? _emailController.text.trim()
          : null;

      final result = await AuthService.login(
        id: id,
        password: password,
        email: email,
      );

      _showSnackbar(result['message'], isError: !result['success']);

      if (result['success']) {
        if (result['Token'] != null) {
          final user = result['User'];
          await saveUserData(
            token: result['Token'],
            role: user['role'],
            name: user['name'],
            profileImgUrl: user['profile_image'],
            id: user['id'],
          );

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => bottomNavigationBar()),
          );
        }
      }
    } catch (e) {
      _showSnackbar('حدث خطأ أثناء محاولة تسجيل الدخول', isError: true);
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 40,
        leading: IconButton(
            onPressed: () => Navigator.pop(context),
            icon: Icon(
              Icons.arrow_back,
              color: Colors.blue,
              size: 30,
            )),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.only(left: 15, right: 15),
          child: Form(
            key: _formkey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Image.asset(
                  width: 280,
                  height: 130,
                  Constants.university,
                ),
                const Align(
                  alignment: Alignment.topLeft,
                  child: Text(
                    "Sign up:",
                    style: TextStyle(
                      color: Constants.primaryColor,
                      fontSize: 35,
                      fontWeight: FontWeight.bold,
                      // fontFamily: 'serif',
                    ),
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                TextFormField(
                  controller: _idController,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Enter your id";
                    }
                    if (!RegExp(r'^[0-9]+$').hasMatch(value)) {
                      return "Number is invalid";
                    }
                    return null;
                  },
                  decoration: InputDecoration(
                    labelText: "Id Number",
                    enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: Color(0xff000000))),
                    focusedBorder: const OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Constants.primaryColor,
                      ),
                    ),
                    focusedErrorBorder: const OutlineInputBorder(
                        borderSide: BorderSide(color: Constants.primaryColor)),
                    errorBorder: const OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.red)),
                    prefixIcon: const Icon(
                      Icons.badge,
                      size: 28,
                      color: Constants.primaryColor,
                    ),
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                TextFormField(
                  controller: _emailController,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  validator: (value) {
                    if (value == null || value.isEmpty)
                      return "Enter your Email";
                    if (!value.contains('@')) return "invalid Email";
                    return null;
                  },
                  decoration: InputDecoration(
                    labelText: "Email",
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: Color(0xff000000)),
                    ),
                    focusedBorder: const OutlineInputBorder(
                        borderSide: BorderSide(color: Constants.primaryColor)),
                    focusedErrorBorder: const OutlineInputBorder(
                        borderSide: BorderSide(color: Constants.primaryColor)),
                    errorBorder: const OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.red)),
                    prefixIcon: const Icon(
                      Icons.email,
                      size: 28,
                      color: Constants.primaryColor,
                    ),
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                TextFormField(
                  controller: _passwordController,
                  obscureText: obscureText1,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Enter your password";
                    }
                    if (value.length < 8) {
                      return "at least 8 characters";
                    }
                    return null;
                  },
                  decoration: InputDecoration(
                      labelText: "Password",
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: Color(0xff000000)),
                      ),
                      focusedBorder: const OutlineInputBorder(
                          borderSide:
                              BorderSide(color: Constants.primaryColor)),
                      focusedErrorBorder: const OutlineInputBorder(
                          borderSide:
                              BorderSide(color: Constants.primaryColor)),
                      errorBorder: const OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.red)),
                      prefixIcon: const Icon(
                        Icons.lock,
                        size: 28,
                        color: Constants.primaryColor,
                      ),
                      suffixIcon: IconButton(
                        onPressed: () {
                          setState(() {
                            obscureText1 = !obscureText1;
                          });
                        },
                        icon: Icon(obscureText1 == true
                            ? Icons.visibility_off
                            : Icons.visibility),
                      )),
                ),
                const SizedBox(
                  height: 20,
                ),
                TextFormField(
                  obscureText: obscureText2,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Confirm your password";
                    }
                    if (value != _passwordController.text) {
                      return "Password do not match";
                    }
                    return null;
                  },
                  decoration: InputDecoration(
                      labelText: "Confirm Password",
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: Color(0xff000000)),
                      ),
                      focusedBorder: const OutlineInputBorder(
                          borderSide:
                              BorderSide(color: Constants.primaryColor)),
                      focusedErrorBorder: const OutlineInputBorder(
                          borderSide:
                              BorderSide(color: Constants.primaryColor)),
                      errorBorder: const OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.red)),
                      prefixIcon: const Icon(
                        Icons.lock,
                        size: 28,
                        color: Constants.primaryColor,
                      ),
                      suffixIcon: IconButton(
                        onPressed: () {
                          setState(() {
                            obscureText2 = !obscureText2;
                          });
                        },
                        icon: Icon(obscureText2 == true
                            ? Icons.visibility_off
                            : Icons.visibility),
                      )),
                ),
                const SizedBox(
                  height: 20,
                ),
                isLoading
                    ? const CircularProgressIndicator(
                        color: Constants.primaryColor,
                      )
                    : Container(
                        width: 140,
                        height: 40,
                        child: ElevatedButton(
                            onPressed: _signup,
                            style: ElevatedButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15)),
                              backgroundColor: Constants.primaryColor,
                              foregroundColor: Color(0xffffffff),
                              elevation: 5,
                            ),
                            child: Padding(
                                padding: EdgeInsets.all(5),
                                child: const Text(
                                  "Sign up",
                                  style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold),
                                ))),
                      ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
