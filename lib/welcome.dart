import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'login_Screen/Log_in.dart';
import 'Constants.dart';

class WelcomePage extends StatefulWidget {
  const WelcomePage({Key? key}) : super(key: key);
  @override
  WelcomePageState createState() => WelcomePageState();
}

class WelcomePageState extends State<WelcomePage> {
  bool showText = false;
  @override
  void initState() {
    super.initState();
    Timer(Duration(seconds: 2), () {
      setState(() {
        showText = true;
      });
    });
    Timer(Duration(seconds: 4), () {
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => Log_in()));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.only(left: 30.0, right: 30),
        child: Center(
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            Image.asset(
              Constants.logo,
              width: 220,
            ),
            SizedBox(
              height: 20,
            ),
            AnimatedOpacity(
              opacity: showText ? 1.0 : 0.0,
              duration: Duration(seconds: 2),
              child: const Text(
                "Welcome to Lattakia University Services!",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'serif',
                ),
              ),
            ),
            SizedBox(
              height: 30,
            ),
            // Container(
            //   child: ElevatedButton(
            //     onPressed: () {
            //       Navigator.push(context,
            //           MaterialPageRoute(builder: (context) => Log_in()));
            //     },
            //     style: ElevatedButton.styleFrom(
            //       backgroundColor: Constants.primaryColor,
            //       fixedSize: const Size(350, 45),
            //       elevation: 5,
            //       // shape: RoundedRectangleBorder(
            //       //     borderRadius: BorderRadius.circular(10)),
            //     ),
            //     child: const Text(
            //       'Continue',
            //       style: TextStyle(
            //         fontSize: 20,
            //         fontFamily: "Arial",
            //         color: Colors.white,
            //       ),
            //     ),
            //   ),
            // ),
          ]),
        ),
      ),
    );
  }
}
