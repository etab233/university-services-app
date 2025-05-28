import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'login_Screen/Log_in.dart';
import 'Constants.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      color: Constants.primaryColor,
      debugShowCheckedModeBanner: false,
    );
  }
}

class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});
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
            const Text(
              "Here to Get Welcomed!",
              // textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                fontFamily: 'serif',
              ),
            ),
            SizedBox(
              height: 30,
            ),
            Container(
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => Log_in()));
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Constants.primaryColor,
                  fixedSize: const Size(350, 45),
                  elevation: 5,
                  // shape: RoundedRectangleBorder(
                  //     borderRadius: BorderRadius.circular(10)),
                ),
                child: const Text(
                  'Continue',
                  style: TextStyle(
                    fontSize: 20,
                    fontFamily: "Arial",
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ]),
        ),
      ),
    );
  }
}
