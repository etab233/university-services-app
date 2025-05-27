import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../home_Screen/home.dart';

class CodeVerification extends StatefulWidget {
  CodeVerification({Key? key}) : super(key: key);
  @override
  _CodeVerificationState createState() => _CodeVerificationState();
}

class _CodeVerificationState extends State<CodeVerification>{
  
  final TextEditingController _codeController = TextEditingController();
  final _formkey= GlobalKey<FormState>();
  bool isLoading=false;
  Future<void> codeVer(String email) async{
    if(_formkey.currentState!.validate()){
      setState(() {
        isLoading=true;});
        final url=Uri.parse('https://api.example.com/api/codeVerification');
    final response= await http.post(
      url,
      headers: {'Accept':'application/json'},
      body:{
        email:_codeController.text.trim(),
      },
    );
    if(response.statusCode==200){
      final data=json.decode(response.body);
      Navigator.push(context, MaterialPageRoute(builder: (context) =>Home()));
    }
    else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Incorrect code')),
      );
    }
    setState(() {
      isLoading=false;
    });
      }
    }

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
              'Code Verification',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 24,
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            const Text(
              'You have received a code\n copy it here please!',
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
                  labelText: "code vervication",
                  focusedErrorBorder:const OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.blue)),
                  errorBorder: const OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.blue)),
                  enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide:const BorderSide(color: Color(0xff000000))),
                  focusedBorder:const OutlineInputBorder(
                    borderSide: BorderSide(
                      color: Colors.blue,
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
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => CodeVerification(),
                      ));
                },
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    elevation: 20,
                    padding:const EdgeInsets.all(22)),
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
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child:const Text('Go back ',
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