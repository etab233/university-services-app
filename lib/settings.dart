import 'package:flutter/material.dart';
import 'package:log_in/Constants.dart';
import 'package:log_in/bottom_navigation_bar.dart';
import 'package:log_in/login_Screen/AuthService.dart';
import 'package:log_in/login_Screen/forgotPassword.dart';

class Settings extends StatefulWidget {
  const Settings({super.key});

  @override
  State<Settings> createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  bool isSwitched1 = true;
  bool isSwitched2 = true;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Settings",
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
        leading: IconButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            icon: Icon(
              Icons.arrow_back,
              size: 30,
              color: Constants.primaryColor,
            )),
      ),
      body: SingleChildScrollView(
          child: Column(
        children: [
          ListTile(
            title: Text(
              "Change Password",
              style: TextStyle(fontSize: 18),
            ),
            leading: Icon(
              Icons.lock,
              color: Constants.primaryColor,
            ),
            onTap: () {
              Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => ForgotPassword()));
            },
          ),
          Divider(),
          ListTile(
            title: Text("Notifications"),
            leading: Icon(
              Icons.notifications,
              color: Constants.primaryColor,
            ),
            trailing: Switch(
              value: isSwitched1,
              onChanged: (value) {
                setState(() {
                  isSwitched1 = value;
                });
              },
              activeColor: Constants.primaryColor,
              activeTrackColor: Colors.blue.withOpacity(0.4),
              inactiveThumbColor: Colors.blueGrey,
              inactiveTrackColor: Colors.blueGrey.withOpacity(0.4),
            ),
          ),
          Divider(),
          ListTile(
            leading: Icon(
              Icons.dark_mode,
              color: Colors.blue,
            ),
            title: Text("Dark mode"),
            trailing: Switch(
              value: isSwitched2,
              activeColor: Colors.blue,
              activeTrackColor: Colors.blue.withOpacity(0.4),
              inactiveThumbColor: Colors.blueGrey,
              inactiveTrackColor: Colors.blueGrey.withOpacity(0.4),
              onChanged: (value) {
                setState(() {
                  isSwitched2 = value;
                });
              },
            ),
          ),
          Divider(),
          ListTile(
              title: Text(
                "Log out",
                style: TextStyle(
                  fontSize: 18,
                ),
              ),
              leading: Icon(
                Icons.logout,
                color: Colors.red,
              ),
              onTap: () {
                bool isLoading = false;
                showDialog(
                    context: context,
                    builder: (context) {
                      return StatefulBuilder(builder: (context, setState) {
                        return AlertDialog(
                            title: Text(
                              "Ensure Logout",
                              style: TextStyle(fontSize: 22),
                            ),
                            content: isLoading
                                ? Center(
                                    heightFactor: 1,
                                    child: CircularProgressIndicator(
                                      color: Constants.primaryColor,
                                    ),
                                  )
                                : Text("Are you sure you want to logout?"),
                            actions: isLoading
                                ? []
                                : [
                                    ElevatedButton(
                                        onPressed: () {
                                          Navigator.pop(context);
                                        },
                                        child: Text(
                                          "No",
                                          style: TextStyle(
                                              color: Constants.primaryColor),
                                        )),
                                    ElevatedButton(
                                        onPressed: () {
                                          setState(() {
                                            isLoading = true;
                                          });
                                          AuthService.logout(context);
                                        },
                                        child: Text(
                                          "yes",
                                          style: TextStyle(
                                              color: Constants.primaryColor),
                                        ))
                                  ]);
                      });
                    });
              })
        ],
      )),
    );
  }
}
