import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';
import 'notification_content.dart';
import '../Constants.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../bottom_navigation_bar.dart';

class Notifications extends StatefulWidget {
  Notifications({Key? key}) : super(key: key);
  @override
  _NotificationsState createState() => _NotificationsState();
}

class _NotificationsState extends State<Notifications> {

List<Map<String,dynamic>> notifications=[];
bool isLoading=true;

String? _shortenText(String? string, int limit) {
    List<String> words = string!.split(' ');
    if (words.length < limit){
      return string;}
    else{
      return words.sublist(0, limit).join(' ') + '...';}
  }

  @override
  void initState(){
    super.initState();
    fetchNotifications();
  }

  Future<void> fetchNotifications() async{
    final url = Uri.parse('${Constants.baseUrl}/notifications');
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('Token');

    setState(() {
      isLoading=true;
    });
    try{
      final response =await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        }
      );
      if(response.statusCode == 200 || response.statusCode==201){
        final data= json.decode(response.body);
        setState(() {
          notifications=data.cast<Map<String, dynamic>>();
        });
      }
    }catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("An error occurred while fetching data"))
      );
    }finally{
      setState(() {
        isLoading=false;
      });
    }
  }

  @override
  Widget build(BuildContext build) {

    return Scaffold(
      bottomNavigationBar:const BottomNavigation(currentIndex: -1,),
      appBar: AppBar(
        title: const Text(
          "Notifications",
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            fontFamily: 'serif',
          ),
        ),
        leading: IconButton(
          onPressed:() => Navigator.pop(context),
          icon:const Icon(Icons.arrow_back,
          size: 30,),
        ),
      ),
      body:isLoading
      ? const Center(child: CircularProgressIndicator(),)
      :notifications.isEmpty
        ?const Center(child: Text("No notifications available"))
        :ListView.separated(
          itemCount: notifications.length,
          separatorBuilder: (context, index) =>const Divider(),
          itemBuilder: (context, index) {
            final item=notifications[index];
            final name=item['data'] ['user'] ?['name'] ?? '';
            final img= item['data'] ['user'] ?['profile_image'];
            final content=item['data'] ?['content'] ?? '';
            final created_at_str = item['created_at'];
            final created_at = created_at_str != null ? DateTime.tryParse(created_at_str) : null;
            final formattedDate = created_at != null ? DateFormat('HH-MM a   dd-MM-yyyy').format(created_at) : '';
            // لتمييز لون الاشعارات غير المقروءة 
            Color cardColor = item['read_at'] == null ? const Color.fromARGB(255, 237, 238, 239) : Colors.white;
            return Card( 
              elevation: 0.5, // ظل خفيف
              color: cardColor,
              child: ListTile(
              leading: CircleAvatar(
                              radius: 20,
                              backgroundImage: (img != null && img.isNotEmpty)? NetworkImage(img) : null,
                              child: (img == null || img.isEmpty )? const Icon(Icons.person) :null ,
                            ),
              title: Text("$name",
                  style:const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black87)),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("${_shortenText(content, 6)}"),
                  const SizedBox(
                    height: 5,
                  ),
                  Text(
                        formattedDate,
                        style: const TextStyle(color: Colors.grey, fontSize: 14),)
                ],
              ),
              
              isThreeLine: true,
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => Notification_content(
                          name: name ,
                          content: content,
                          imageUrl: img,
                          date: formattedDate,
                        )));
              },
            ),
            );
          },
        ),
    );
  }
}