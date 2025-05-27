import 'package:flutter/material.dart';
import 'codeVerification.dart';

class ForgotPassword extends StatefulWidget {
  ForgotPassword({Key? key}) : super(key: key);
  @override
  _ForgotPasswordState createState() => _ForgotPasswordState();
}

class _ForgotPasswordState extends State<ForgotPassword> {
  final TextEditingController _emailController = TextEditingController();
  final _formkey =GlobalKey<FormState>();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding:const EdgeInsets.only(
          left: 25,
        ),
        child: Form(
          key: _formkey,
          child: Column(
          //crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(
              height: 60,
            ),
            const Text(
              'Forgot Your Password?',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 24,
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            const Text(
              'Enter your email and \nwe will send you a code ',
              style: TextStyle(
                fontSize: 20,
              ),
            ),
            const SizedBox(
              height: 30,
            ),
            Container(
              width: 300,
              child: TextFormField(
                controller: _emailController,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                validator: (value) {
                  if (value == null || value.isEmpty) return "Enter your Email";
                  if (!value.contains('@')) return "invalid Email";
                  return null;
                },
                decoration: InputDecoration(
                  labelText: "Email",
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide:const BorderSide(color: Color(0xff000000)),
                  ),
                  focusedBorder:const OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.blue)),
                  focusedErrorBorder:const OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.blue)),
                  errorBorder: const OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.blue)),
                  prefixIcon:const Icon(
                    Icons.email,
                    size: 28,
                    color: Colors.blue,
                  ),
                ),
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            Container(
              width: 300,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => CodeVerification()),
                  );
                },
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    elevation: 20,
                    padding:const EdgeInsets.all(22)),
                child: const Text(
                  'Continue',
                  style: TextStyle(
                    fontSize: 20,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20,),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child:const Text('back to Log in',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.blue,
                  )),
            ),
          ],
        ),
        ),
      ),
    );
  }
}
