import 'package:flutter/material.dart';
import 'package:university_services/login_Screen/register.dart';
import 'forgotPassword.dart';
import 'AuthService.dart';
import '../Constants.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Log_in extends StatefulWidget {
  const Log_in({Key? key}) : super(key: key);
  @override
  _Log_inState createState() => _Log_inState();
}

class _Log_inState extends State<Log_in> {
  final TextEditingController _idController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final _formkey = GlobalKey<FormState>();
  bool isLoading = false;
  bool obscureText = true;
  void _showSnackbar(String message, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  // تابع لتخزين بيانات المستخدم محليّاً
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

  void _login() async {
    // التحقق من الفورم
    //داخل كل حقل validator يشتغل كل  validate التابع 
    // إذا وجد حقل واحد على الأقل غير صالح يتوقف تسجيل الدخول ولا يكمل 
    if (!_formkey.currentState!.validate()) return;

    setState(() => isLoading = true);
    try {
      final id = _idController.text.trim();
      final password = _passwordController.text.trim();
      final result = await AuthService.login(
        id: id,
        password: password,
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
            MaterialPageRoute(builder: (context) =>const MainScreen()),
          );
        }
      }
    } catch (e) {
      _showSnackbar('حدث خطأ أثناء محاولة تسجيل الدخول', isError: true);
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.only(left: 15, right: 15),
            child: Form(
              key: _formkey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const SizedBox(
                    height: 30,
                  ),
                  Image.asset(
                    width: 280,
                    height: 130,
                    Constants.university,
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  const Align(
                    alignment: Alignment.topLeft,
                    child: Text(
                      "Login:",
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
                          borderSide:
                              const BorderSide(color: Color(0xff000000))),
                      focusedBorder: const OutlineInputBorder(
                        borderSide: BorderSide(
                          color: Constants.primaryColor,
                        ),
                      ),
                      focusedErrorBorder: const OutlineInputBorder(
                          borderSide:
                              BorderSide(color: Constants.primaryColor)),
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
                    controller: _passwordController,
                    obscureText: obscureText,
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
                          borderSide:
                              const BorderSide(color: Color(0xff000000)),
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
                              obscureText = !obscureText;
                            });
                          },
                          icon: Icon(obscureText == true
                              ? Icons.visibility_off
                              : Icons.visibility),
                        )),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => ForgotPassword()),
                        );
                      },
                      child: const Text(
                        "Forgotten Password?",
                        style: TextStyle(
                          color: Color.fromRGBO(117, 117, 117, 1),
                        ),
                      )),
                  const SizedBox(
                    height: 10,
                  ),
                  isLoading
                      ? const CircularProgressIndicator(
                          color: Constants.primaryColor,
                        )
                      : ElevatedButton(
                          onPressed: _login,
                          style: ElevatedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15)),
                            backgroundColor: Constants.primaryColor,
                            foregroundColor: Color(0xffffffff),
                            elevation: 5,
                          ),
                          child: Padding(
                              padding: EdgeInsets.only(
                                  left: 14, right: 14, top: 7, bottom: 7),
                              child: const Text(
                                "Log in",
                                style: TextStyle(
                                    fontSize: 20, fontWeight: FontWeight.bold),
                              )),
                        ),
                  SizedBox(
                    height: 15,
                  ),
                  ElevatedButton(
                    onPressed: () => Navigator.push(context,
                        MaterialPageRoute(builder: (context) => Register())),
                    style: ElevatedButton.styleFrom(
                      // backgroundColor: Constants.primaryColor/,
                      foregroundColor: Color(0xffffffff),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                        side: BorderSide(color: Colors.blue, width: 2),
                      ),
                      elevation: 5,
                    ),
                    child: Padding(
                      padding: EdgeInsets.all(7),
                      child: const Text(
                        "Sign Up",
                        style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue),
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
      // bottomNavigationBar: Padding(
      //   padding: EdgeInsets.all(15),
      //   child: ElevatedButton(
      //     onPressed: () => Navigator.push(
      //         context, MaterialPageRoute(builder: (context) => Register())),
      //     style: ElevatedButton.styleFrom(
      //       // backgroundColor: Constants.primaryColor/,
      //       foregroundColor: Color(0xffffffff),
      //       shape: RoundedRectangleBorder(
      //         borderRadius: BorderRadius.circular(15),
      //         side: BorderSide(color: Colors.blue, width: 2),
      //       ),
      //       elevation: 5,
      //     ),
      //     child: Padding(
      //       padding: EdgeInsets.all(7),
      //       child: const Text(
      //         "Sign Up",
      //         style: TextStyle(
      //             fontSize: 20,
      //             fontWeight: FontWeight.bold,
      //             color: Colors.blue),
      //       ),
      //     ),
      //   ),
      // ),
    );
  }
}
