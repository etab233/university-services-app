import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:university_services/login_Screen/createNewPassword.dart';
import '../Constants.dart';

class CodeVerification extends StatefulWidget {
  CodeVerification({Key? key}) : super(key: key);
  @override
  _CodeVerificationState createState() => _CodeVerificationState();
}

class _CodeVerificationState extends State<CodeVerification> {
  final TextEditingController _codeController = TextEditingController();
  final _formkey = GlobalKey<FormState>();
  bool isLoading = false;
  bool isEnabled = false;
  void validateInput(String value) {
    setState(() {
      isEnabled = value.isNotEmpty && int.tryParse(value) != null;
    });
  }

  Future<void> codeVer(int code) async {
    if (_formkey.currentState!.validate()) {
      setState(() {
        isLoading = true;
      });
      final url = Uri.parse('${Constants.baseUrl}/codeVerification');
      final response = await http.post(
        url,
        headers: {'Accept': 'application/json'},
        body: {
          code: _codeController.text.trim(),
        },
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => NewPassword()));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Incorrect code')),
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
        title: const Text(
          'Code Verification',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: Icon(
              Icons.arrow_back,
              size: 30,
              color: Constants.primaryColor,
            )),
      ),
      body: SingleChildScrollView(
        child: Form(
          key: _formkey,
          child: Center(
            child: Column(
              //crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(
                  height: 20,
                ),
                Container(
                  width: 350,
                  child: const Text(
                    "We've sent a verification code to you. Please enter it below",
                    style: TextStyle(
                      fontSize: 18,
                    ),
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                Container(
                  width: 350,
                  child: TextFormField(
                      controller: _codeController,
                      onChanged: validateInput,
                      decoration: InputDecoration(
                          labelText: "Verfication Code",
                          focusedErrorBorder: const OutlineInputBorder(
                              borderSide:
                                  BorderSide(color: Constants.primaryColor)),
                          errorBorder: const OutlineInputBorder(
                              borderSide:
                                  BorderSide(color: Constants.primaryColor)),
                          enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide:
                                  const BorderSide(color: Color(0xff000000))),
                          focusedBorder: const OutlineInputBorder(
                            borderSide: BorderSide(
                              color: Constants.primaryColor,
                            ),
                          ),
                          prefixIcon: Icon(
                            Icons.numbers,
                            size: 28,
                            color: Colors.blue,
                          )),
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      keyboardType: TextInputType.number,
                      validator: (String? value) {
                        if (value == null || value.isEmpty) {
                          return "Enter verification code";
                        }
                        if (int.tryParse(value) == null) {
                          return "Please Enter a valid input";
                        }
                        return null;
                      }),
                ),
                const SizedBox(
                  height: 20,
                ),
                Container(
                  width: 350,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: isEnabled
                        ? () {
                            if (_formkey.currentState?.validate() ?? false) {
                              codeVer(
                                  int.tryParse(_codeController.text.trim())!);
                            }
                          }
                        : null,

                    // : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Constants.primaryColor,
                      foregroundColor: Colors.white,
                      elevation: 5,
                    ),
                    child: const Text(
                      'Confirm',
                      style: TextStyle(
                        fontSize: 20,
                      ),
                    ),
                  ),
                ),
                const SizedBox(
                  height: 15,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
