import 'package:flutter/material.dart';
import 'package:log_in/announcment%20Screen/AnnList.dart';
import 'package:log_in/complaint_Screen/view_complaints.dart';
import 'package:log_in/objection_Screens/admin/select_%20subject.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:log_in/announcment%20Screen/addAnn.dart';
import 'package:log_in/complaint_Screen/add_complaint.dart';
import '../objection_Screens/student/select_subject.dart';
import '../Constants.dart';
import '../bottom_navigation_bar.dart';

class HomePage extends StatefulWidget {
  HomePage({Key? key}) : super(key: key);
  @override
  _HomePageState createState() => _HomePageState();
}

Future<String> getRole() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  // String? token = await prefs.getString('token');
  String? role = prefs.getString('role');
  return role!;
}

class _HomePageState extends State<HomePage> {
  final List<String> list = [
    'Announcement',
    'Complaint',
    'Grade \nObjection',
    'Votes'
  ];

  final List<IconData> icon = [
    Icons.announcement,
    Icons.report,
    Icons.grade,
    Icons.how_to_vote,
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: Bottom_navigation_bar(),
      appBar: AppBar(
          backgroundColor: Colors.white,
          automaticallyImplyLeading: false,
          title: const Padding(
            padding: EdgeInsets.only(top: 28),
            child: Text(
              'Latakia University',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          actions: [
            IconButton(
              onPressed: () {},
              icon: const Icon(Icons.notifications),
            ),
            IconButton(
              onPressed: () {},
              icon: const Icon(Icons.settings),
            ),
          ]),
      body: Stack(
        children: [
          Positioned.fill(
            child: Column(
              children: [
                Expanded(flex: 3, child: Container(color: Color(0xffffffff))),
                Expanded(
                  flex: 7,
                  child: Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Color(0xFFBFE4FA), Color(0xff6fb1d9)],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(80),
                        topRight: Radius.circular(80),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                const SizedBox(
                  height: 20,
                ),
                TextField(
                  decoration: InputDecoration(
                    labelText: 'Search',
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                      borderSide: const BorderSide(color: Color(0xff000000)),
                    ),
                    focusedBorder: const OutlineInputBorder(
                      borderSide: BorderSide(color: Constants.primaryColor),
                    ),
                    prefixIcon: const Icon(Icons.search),
                  ),
                ),
                const SizedBox(height: 50),
                Expanded(
                  child: GridView.builder(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 15,
                      mainAxisSpacing: 40,
                      mainAxisExtent: 125,
                    ),
                    itemCount: list.length,
                    itemBuilder: (context, index) {
                      return Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(30),
                          border: Border.all(color: Color(0xffd5d5d5)),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.4),
                              blurRadius: 6,
                              offset: Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                Icon(
                                  icon[index],
                                  size: 30,
                                  color: Constants.primaryColor,
                                ),
                                Text(
                                  "${list[index]}",
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                IconButton(
                                  onPressed: () async {
                                    String role = await getRole();
                                    switch (index) {
                                      case 0:
                                        print(role);
                                        if (role == "student")
                                          Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      AddAnnouncement()));
                                        else if (role == "admin")
                                          Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      AnnouncementList()));
                                        break;
                                      case 1:
                                        if (role == "student")
                                          Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      AddComp()));
                                        else if (role == "admin")
                                          Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      ViewComp()));
                                        break;
                                      case 2:
                                        if (role == "student")
                                          Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      SelectSub()));
                                        else if (role == "admin")
                                          Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      ChooseSub()));
                                        break;
                                      // case 3:
                                      //   if (role=="student")
                                      //     Navigator.push(
                                      //       context,
                                      //       MaterialPageRoute(
                                      //           builder: (context) =>
                                      //               Voting_Screen_for_Student()));
                                      //               else if(role=="admin")
                                      //               Navigator.push(
                                      //       context,
                                      //       MaterialPageRoute(
                                      //           builder: (context) =>
                                      //               Voting_Screen_for_admin()));
                                      //  break;
                                    }
                                  },
                                  icon: const Icon(Icons.add_circle,
                                      size: 35, color: Constants.primaryColor),
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
