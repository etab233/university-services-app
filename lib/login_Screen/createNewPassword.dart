import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'log_in.dart';
import '../Constants.dart';

class NewPassword extends StatefulWidget {
  const NewPassword({Key? key}) : super(key: key);
  @override
  _NewPasswordState createState() => _NewPasswordState();
}

class _NewPasswordState extends State<NewPassword> {
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final _formkey = GlobalKey<FormState>();
  bool isLoading = false;

  Future<void> resetPassword(String password) async {
    if (_formkey.currentState!.validate()) {
      setState(() {
        isLoading = true;
      });
      final url = Uri.parse('${Constants.baseUrl}/codeVerification');
      final response = await http.post(url,
          headers: {'Accept': 'application/json'},
          body: json.encode(
            {
              password: _passwordController.text.trim(),
            },
          ));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(data['message'])));
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => Log_in()));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error resetting password')),
        );
      }
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 60,
        title: Text(
          "Create New Password",
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        child: Form(
          key: _formkey,
          child: Center(
            child: Column(
              // mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SizedBox(
                  height: 20,
                ),
                Container(
                  width: 350,
                  child: Text(
                    "Create a new password that differing from a previous one",
                    style: TextStyle(fontSize: 18),
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
                Container(
                  width: 350,
                  child: TextFormField(
                    controller: _passwordController,
                    obscureText: true,
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
                          borderSide:
                              BorderSide(color: Constants.primaryColor)),
                      prefixIcon: const Icon(
                        Icons.lock,
                        size: 28,
                        color: Constants.primaryColor,
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
                Container(
                  width: 350,
                  child: TextFormField(
                    controller: _confirmPasswordController,
                    obscureText: true,
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "Confirm your password";
                      }
                      if (value != _passwordController.text) {
                        return "Passwords do not match. Please try again";
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
                          borderSide:
                              BorderSide(color: Constants.primaryColor)),
                      prefixIcon: const Icon(
                        Icons.lock,
                        size: 28,
                        color: Constants.primaryColor,
                      ),
                    ),
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                isLoading
                    ? const CircularProgressIndicator()
                    : Container(
                        width: 350,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: () async {
                            // if (_formkey.currentState!.validate()) {
                            //   setState(() {
                            //     isLoading = true;
                            //   });
                            // fun();
                            resetPassword(_passwordController.text.trim());
                            // }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Constants.primaryColor,
                            foregroundColor: Color(0xffffffff),
                            textStyle: const TextStyle(
                              fontSize: 18,
                              // fontWeight: FontWeight.bold,
                            ),
                            elevation: 5,
                          ),
                          child: const Text("Update password"),
                        ),
                      ),
                SizedBox(
                  height: 15,
                ),
                Container(
                  width: 350,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text(
                      'Go back',
                      style: TextStyle(
                        color: Constants.primaryColor,
                        fontSize: 18,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      // shape: RoundedRectangleBorder(
                      //     borderRadius: BorderRadius.circular(10)),
                      elevation: 5,
                      side: BorderSide(
                        width: 2,
                        color: Constants.primaryColor,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
