import 'package:flutter/material.dart';
import 'package:log_in/complaint_Screen/add_complaint.dart';
import 'package:log_in/objection_Screens/select_subject.dart';
import '../complaint_Screen/view_complaints.dart';
import '../objection_Screens/student/submit_objection.dart';
import '../announcment Screen/AnnList.dart';
import '../Constants.dart';
import '../bottom_navigation_bar.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../announcment Screen/notifications.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

// متحولات لرسم الدوائر المتداخلة بالشبكة 
double circleSize = 35;
double overlap = 10;
String? name;

// صف يحوي اسم و صورة المستخدم لاستخدامه لرسم الدوائر المتداخلة بكل خلية بالشبكة 
class User{
  String? name;
  String? img;
  User(this.name, this.img);
  factory User.fromJson(Map<String,dynamic> json){
    return User(
      json ['name'],
      json['profile_image']
    );
  }
}
List<User> AnnPublishers=[];
// تابع لجلب اخر خمس مستخدمين على الأكثر متفاعلين في قسم الإعلانات 
  Future<List<User>> fetchLastFivePublishersFromAnnouncement() async{
    final prefs= await SharedPreferences.getInstance();
    final token =prefs.getString('Token');
    name =prefs.getString('name');
    final url=Uri.parse("${Constants.baseUrl}/announcements");
    try{
      final response=await http.get(
        url,
        headers: {
          'Content-Type':'application/json',
          'Authorization':'Bearer $token'
        }
      );
      if(response.statusCode==200){
        List<dynamic> announcements= json.decode(response.body);
        //نستخدم set لمنع تكرار المستخدم
        Set<int> seenUserIds={};
        AnnPublishers.clear(); // مهم جداً حتى لا تتكرر البيانات عند إعادة التحميل
        for (var ann in announcements){
          var publishJson=ann['user'];
          if(publishJson==null) continue;
          int userId=ann['user']['id'];
          if(!seenUserIds.contains(userId)){
            seenUserIds.add(userId);
            AnnPublishers.add(User.fromJson(publishJson));
          }
          //نحتاج خمس مستخدمين على الأكثر
          if(AnnPublishers.length>5) break;
        }
        return AnnPublishers;
      }
      else return [];
    }catch(e){
      print('$e');
      return [];
    }
  }


class HomePage extends StatefulWidget {
  const HomePage ({Key? key}) : super(key: key);
  @override
  HomePageState createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
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

void loadPublishers() async {
  AnnPublishers = await fetchLastFivePublishersFromAnnouncement();
  setState(() {});
}

  @override
  void initState(){
    super.initState();
    loadPublishers();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: Bottom_navigation_bar(),
      appBar: AppBar(
          backgroundColor: Colors.white,
          automaticallyImplyLeading: false,
          title: const Padding(
            padding: EdgeInsets.only(top: 15),
            child: Text(
              '   Latakia University',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          actions: [
            IconButton(
              onPressed: () {
                Navigator.push(
                  context,MaterialPageRoute(builder: (context) => Notifications())
                );
              },
              icon: const Icon(Icons.notifications_active_outlined, size: 30,),
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
                  height: 5,
                ),
                Container(
                  padding: const EdgeInsets.all(10),
                  child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                     Text(
                      "Welcome $name 👋",
                      style:const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.blueGrey, ),),
                    const SizedBox(height: 10),
                    const Text(
                     "Don't wait for the perfect moment — create it yourself ✨✨",
                     style: TextStyle(
                     fontStyle: FontStyle.italic,
                     fontSize: 15,
                     color: Colors.blueGrey, ),),],),),

                const SizedBox(height: 50),
                Expanded(
                  child: GridView.builder(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 8,
                      mainAxisSpacing: 40,
                      mainAxisExtent: 125,
                    ),
                    itemCount: list.length,
                    itemBuilder: (context, index) {
                      return Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(30),
                          border: Border.all(color:const Color(0xffd5d5d5)),
                          boxShadow:[
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.4),
                              blurRadius: 6,
                              offset:const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                const SizedBox(width: 20,),
                                Icon(
                                  icon[index],
                                  size: 30,
                                  color: Constants.primaryColor,
                                ),
                                const SizedBox(width: 10,),
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
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                const SizedBox(width: 20,),
                                SizedBox(
                                  width: AnnPublishers.length * (circleSize - overlap) + overlap,
                                  height: circleSize,
                                  child: Stack(
                                  children: List.generate(AnnPublishers.length,(index){
                                    double leftPos = index * (circleSize - overlap);
                                    User user = AnnPublishers[index];
                                    final hasImage = user.img != null && user.img!.isNotEmpty;
                                    return Positioned(
                                      left: leftPos,
                                      child: CircleAvatar(
                                       radius: circleSize/2,
                                       backgroundColor: hasImage ? Colors.transparent : const Color.fromARGB(255, 186, 186, 186),// لون خلفية افتراضي 
                                       backgroundImage: hasImage ? NetworkImage(user.img!) : null,
                                       child: !hasImage
                                      ? Text(
                                      user.name!.substring(0, 1).toUpperCase(),
                                      style: const TextStyle(
                                      color: Colors.black,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                   ),): null
                                    ));
                                  } )
                                ),
                                ),
                                Spacer(),
                                OutlinedButton(
                                  onPressed: () {
                                    setState(() {
                                      switch (index) {
                                        case 0:
                                          Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      AnnouncementList()));
                                          break;
                                        case 1:
                                          () async{
                                            final prefs =await SharedPreferences.getInstance();
                                            final role= prefs.getString('role');
                                            if (role =='admin'){
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(builder: (context) => ViewComp())
                                              );
                                            }
                                            else{
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(builder: (context) => AddComp())
                                              );
                                            };
                                          }(); break;
                                        case 2:
                                          Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      SelectSub()));
                                          break;
                                        // case 3:
                                        //   Navigator.push(
                                        //       context,
                                        //       MaterialPageRoute(
                                        //           builder: (context) =>
                                        //               Vote()));
                                        //  break;
                                      }
                                    });
                                  },
                                  style: OutlinedButton.styleFrom(
                                      shape: const CircleBorder(),
                                      side: const BorderSide(color: Colors.blue, width: 2),
                                      ),
                                  child: const Icon(Icons.add,
                                      size: 20,
                                      color: Colors.black,
                                      ),
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
