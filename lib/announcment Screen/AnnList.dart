import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:university_services/announcment%20Screen/add_edit_Ann.dart';
import 'dart:convert';
import '../Constants.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Announcement {
  final String name; //اسم صاحب الإعلان
  final DateTime created_at, updated_at; // تاريخ النشر والتعديل
  final String content; //محتوى الإعلان
  final int userid; // رقم تعريف المستخدم
  final int annid; // رقم تعريف الإعلان
  final String? imageUrl;
  // باني بوسطاء
  Announcement(
      {required this.name,
      required this.created_at,
      required this.updated_at,
      required this.content,
      required this.userid,
      required this.annid,
      this.imageUrl});

  // factory named constructor
  // Announcement إلى كائن من النوع API  تحول البيانات القادمة من
  factory Announcement.fromJson(Map<String, dynamic> json) {
    return Announcement(
      name: json['user']['name'],
      created_at: DateTime.parse(json['created_at']),
      updated_at: DateTime.parse(json['updated_at']),
      content: json['content'],
      userid: json['user']['id'],
      annid: json['id'],
      imageUrl: json['user']['profile_image'],
    );
  }
}

class AnnouncementList extends StatefulWidget {
  AnnouncementList({Key? key}) : super(key: key);

  @override
  _AnnouncementListState createState() => _AnnouncementListState();
}

class _AnnouncementListState extends State<AnnouncementList> {
  List<Announcement> announcements = [];
  bool isLoading = true;
  String? role;
  int? user_id;

  @override
  void initState() {
    super.initState();
    initData();
  }

  void initData() async {
    final prefs = await SharedPreferences
        .getInstance(); // الوصول للبيانات المخزنة في الجهاز
    final token = prefs.getString('Token'); // استرجاع التوكن
    final userRole = prefs.getString('role'); // استرجاع الدور
    final id = prefs.getInt('id'); //استرجاع المعرف الخاص بالمستخدم ح

    // إذا الويدجيت لسا موجود بالشجرة أي ظاهر على الشاشة  => حديث البيانات و إعادة بناء الواجهة
    if (mounted) {
      setState(() {
        role = userRole;
        user_id = id;
      });
    }
    // إذا المستخدم مسجل دخول => نستدعي  تابع لجلب البيانات  له
    if (token != null && token.isNotEmpty) {
      await fetchAnnouncement(token);
    }
  }

  // دالة غير متزامنة لجلب الإعلانات من السيرفر وتحديث الواجهة
  Future<void> fetchAnnouncement(String token) async {
    // قبل جلب البيانات يتم إظهار مؤشر تحميل
    setState(() {
      isLoading = true;
    });

    final url = Uri.parse('${Constants.baseUrl}/announcements');
    try {
      final response = await http.get(
        url,
        headers: {
          'Accept': 'application/json', // إخبار السيرفر بصيغة الرد
          'Authorization': 'Bearer $token', // إرسال التوكن للمصادقة
        },
      );
      if (response.statusCode == 200) {
        final List<dynamic> jsonData = json.decode(response.body);
        setState(() {
          announcements =
              jsonData.map((item) => Announcement.fromJson(item)).toList();
          isLoading = false;
        });
      } else {
        throw Exception('Failed to fetch data');
      }
    } catch (e) {
      print('Error: $e');
      if (!mounted) return;
      setState(() {
        isLoading = false;
      });
    }
  }

  // حذف إعلان حسب رقم المعرف وإذا تم الحذف بنجاح تظهر رسالة وتتحدث القائمة
  Future<void> deleteAnnouncement(int annId) async {
    // استرجاع التوكن من التخزين المحلي
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('Token');
    final url = Uri.parse('${Constants.baseUrl}/admin/announcements/$annId');
    try {
      final response = await http.delete(url, headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      });
      // إذا تم الحذف بنجاح
      if (response.statusCode == 200 || response.statusCode == 201) {
        // تحديث قائمة الإعلانات بجلبها من السيرفر من جديد
        await fetchAnnouncement(token!);
        setState(() {
          // إزالة الإعلان الذي تم حذفه من القائمة المحلية
          announcements.removeWhere((item) => item.annid == annId);
          // فك تشفير رسالة الرد
          final data = json.decode(response.body);
          final message = data['message'];
          // عرض رسالة تأكيد الحذف
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('$message')),
          );
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('حدث خطأ أثناء الحذف')),
      );
    }
  }

  final DateFormat formatter = DateFormat('hh:mm a - dd/MM/yyyy');

  @override
  Widget build(BuildContext context) {
    // إذا كانت البيانات لا تزال تتحمل يتم عرض دائرة في منتصف الشاشة
    // No Announcement وإذا لا يوجد إعلانات يتم عرض
    // وإلا يتم عرض الإعلانات من قاعدة البيانات  وبناء الواجهة
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Announcements',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(Icons.arrow_back,
              size: 30, color: Constants.primaryColor),
        ),
        actions: [
          // يمكنه إضافة إعلان admin إذا كان المستخدم
          if (role == 'admin')
            IconButton(
              icon: const Icon(
                Icons.add,
                color: Colors.blue,
                size: 30,
              ),
              // إذا ضغط عليها ينتقل إلى واجهة إنشاء إعلان ونستنى المستخدم يرجع منا
              onPressed: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => Add_Edit_Announcement()),
                );
                // إذا المستخدم نشر إعلان و رجع من الصفحة => نعيد تحديث القائمة
                if (result == true) {
                  setState(() {
                    isLoading = true; // نعيد التحميل من جديد
                  });
                  final prefs = await SharedPreferences.getInstance();
                  final token = prefs.getString('Token');
                  if (token != null) {
                    await fetchAnnouncement(token); // جلب البيانات الجديدة
                  }
                }
              },
            ),
        ],
      ),
      body: Stack(
        children: [
          // خلفية بتدرج لوني
          Positioned.fill(
            child: Column(
              children: [
                Expanded(
                    flex: 3, child: Container(color: const Color(0xffffffff))),
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
          // نهاية أول عنصر الخلفية ونبدأ بقائمة الإعلانات
          isLoading
              ? const Center(
                  child: CircularProgressIndicator(
                  color: Constants.primaryColor,
                ))
              : announcements.isEmpty
                  ? const Center(
                      child: Text(
                      'No Announcements',
                      style: TextStyle(fontSize: 18),
                    ))
                  : Padding(
                      padding: const EdgeInsets.all(20),
                      // قائمة ديناميكية من الإعلانات
                      child: ListView.builder(
                        itemCount: announcements.length,
                        itemBuilder: (content, index) {
                          final item = announcements[index];
                          return Container(
                            margin: const EdgeInsets.symmetric(
                                vertical: 8, horizontal: 12),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.3),
                                  spreadRadius: 2,
                                  blurRadius: 6,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    CircleAvatar(
                                      radius: 20,
                                      backgroundImage: (item.imageUrl != null &&
                                              item.imageUrl!.isNotEmpty)
                                          ? NetworkImage(item.imageUrl!)
                                          : null,
                                      child: (item.imageUrl == null ||
                                              item.imageUrl!.isEmpty)
                                          ? const Icon(Icons.person)
                                          : null,
                                    ),
                                    const SizedBox(width: 8),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          item.name,
                                          style: const TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.w600,
                                          ),
                                          overflow: TextOverflow
                                              .ellipsis, // إذا كان الاسم طويل جدا
                                        ),
                                        // إذا كان تاريخ التعديل مختلف عن تاريخ الإنشاء  => تم التعديل => نعرض تاريخ التعديل
                                        // إذا كانا متساويان => لم يتم التعديل => نعرض تاريخ الإنشاء
                                        Text(
                                          item.updated_at
                                                  .isAfter(item.created_at)
                                              ? DateFormat(
                                                      'hh:mm a - dd-MM-yyyy')
                                                  .format(item.updated_at)
                                              : DateFormat(
                                                      'hh:mm a - dd-MM-yyyy')
                                                  .format(item.created_at),
                                          style: const TextStyle(
                                              color: Colors.grey, fontSize: 14),
                                        ),
                                      ],
                                    ),
                                    const Spacer(),
                                    // إذا كان المستخدن أدمن وهو صاحب الإعلان => يمكنه التعديل وحذف الإعلان الخاص به
                                    if (user_id == item.userid &&
                                        role == 'admin')
                                      PopupMenuButton<String>(
                                        onSelected: (value) async {
                                          if (value == 'edit') {
                                            final result = await Navigator.push(
                                                context,
                                                // مرر الإعلان الحالي لتقوم بملء محتوى الإعلان في الواجهة تلقائيًا
                                                MaterialPageRoute(
                                                    builder: (context) =>
                                                        Add_Edit_Announcement(
                                                            announcement:
                                                                item)));
                                            if (result == true) {
                                              final prefs =
                                                  await SharedPreferences
                                                      .getInstance();
                                              final token =
                                                  prefs.getString('Token');
                                              if (token != null) {
                                                await fetchAnnouncement(token);
                                                setState(() {});
                                              }
                                            }
                                          } else if (value == 'delete') {
                                            showDialog(
                                                context: context,
                                                builder:
                                                    (BuildContext context) {
                                                  return AlertDialog(
                                                    content: const Text(
                                                        "Are you sure you want to delete it?"),
                                                    actions: [
                                                      TextButton(
                                                          onPressed: () =>
                                                              Navigator.of(
                                                                      context)
                                                                  .pop(),
                                                          child: const Text(
                                                              "cancel")),
                                                      TextButton(
                                                          onPressed: () {
                                                            Navigator.of(
                                                                    context)
                                                                .pop(); // إغلاق مربع الحوار
                                                            deleteAnnouncement(item
                                                                .annid); // تنفيذ الحذف
                                                          },
                                                          child: const Text(
                                                              "Yes")),
                                                    ],
                                                  );
                                                });
                                          }
                                        },
                                        itemBuilder: (BuildContext context) => [
                                          const PopupMenuItem(
                                              value: 'edit',
                                              child: Text('edit')),
                                          const PopupMenuItem(
                                              value: 'delete',
                                              child: Text('delete')),
                                        ],
                                        icon: const Icon(Icons.more_vert),
                                      )
                                  ],
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  item.content,
                                  textAlign: TextAlign.right,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    height: 1.4,
                                    color: Colors.black87,
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
        ],
      ),
    );
  }
}
