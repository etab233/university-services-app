import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../home_Screen/home.dart';
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
  Future<void> codeVer(String email) async {
    if (_formkey.currentState!.validate()) {
      setState(() {
        isLoading = true;
      });
      final url = Uri.parse('https://api.example.com/api/codeVerification');
      final response = await http.post(
        url,
        headers: {'Accept': 'application/json'},
        body: {
          email: _codeController.text.trim(),
        },
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => Home()));
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
        automaticallyImplyLeading: false,
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
                const Text(
                  'You have received a code\n copy it here please!',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 20,
                  ),
                ),
                const SizedBox(
                  height: 40,
                ),
                Container(
                  width: 310,
                  child: TextFormField(
                    controller: _codeController,
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
                    ),
                  ),
                ),
                const SizedBox(
                  height: 30,
                ),
                Container(
                  width: 310,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => CodeVerification(),
                          ));
                    },
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
                Container(
                  width: 310,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text(
                      'Go Back',
                      style: TextStyle(
                        color: Constants.primaryColor,
                        fontSize: 20,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.white,
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
