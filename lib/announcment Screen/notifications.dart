import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:log_in/AuthService.dart';
import 'notification_content.dart';
import '../Constants.dart';

class Notifications extends StatefulWidget {
  Notifications({Key? key}) : super(key: key);
  @override
  _NotificationsState createState() => _NotificationsState();
}

class _NotificationsState extends State<Notifications> {
  List<Map<String, dynamic>> notifications = [];

  String? _shortenText(String? string, int limit) {
    List<String> words = string!.split(' ');
    if (words.length < 5) {
      return string;
    } else {
      return words.sublist(0, limit).join(' ') + '...';
    }
  }

  @override
  void initState() {
    super.initState();
    fetchNotifications();
  }

  Future<void> fetchNotifications() async {
    final url = Uri.parse('${Constants.baseUrl}/notifications');
    try {
      final token = await AuthService.getToken();
      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Baerer $token',
          'Content-Type': 'application/json',
        },
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          notifications = data.cast<Map<String, dynamic>>();
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text("An error occurred while fetching data")));
    }
  }

  Future<void> deleteNotification(String id) async {
    final url = Uri.parse('${Constants.baseUrl}/announcement/$id');
    try {
      final token = await AuthService.getToken();
      final response = await http.delete(
        url,
        headers: {
          'Authorization': 'Baerer $token',
          'Content-Type': 'application/json',
        },
      );
      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Successfully deleted")));
      } else {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text("Failed to delete")));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Unable to connect. Please try again")));
    }
  }

  @override
  Widget build(BuildContext build) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Notifications",
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            fontFamily: 'serif',
          ),
        ),
        leading: const Icon(
          Icons.notifications,
          size: 30,
        ),
      ),
      body: ListView.separated(
        itemCount: notifications.length,
        separatorBuilder: (context, index) => const Divider(),
        itemBuilder: (context, index) {
          final item = notifications[index];
          final name = item['name'];
          final img = item['profile_image'];
          final content = item['content'];
          final createdAt = DateTime.tryParse(item['created_at'] ?? '');
          final formattedDate = createdAt != null
              ? DateFormat('yyyy-MM-dd').format(createdAt)
              : '';
          final id = item['id'].toString();
          return ListTile(
            leading: CircleAvatar(
              radius: 20,
              backgroundImage: img != null ? NetworkImage(img) : null,
              child: img == null ? const Icon(Icons.person) : null,
            ),
            title: Text("$name",
                style:
                    const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("${_shortenText(content, 4)}"),
                const SizedBox(
                  height: 5,
                ),
                Text(
                  formattedDate,
                  style: const TextStyle(color: Colors.grey, fontSize: 14),
                )
              ],
            ),
            trailing: PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert),
              onSelected: (value) async {
                await deleteNotification(id);
                setState(() {
                  notifications.removeAt(index);
                });
              },
              itemBuilder: (BuildContext context) => [
                const PopupMenuItem(
                  value: 'delete',
                  child: Text("Delete Notification"),
                ),
              ],
            ),
            isThreeLine: true,
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => Notification_content(
                            name: name ?? '',
                            content: content ?? '',
                            date: formattedDate,
                            imageUrl: img,
                          )));
            },
          );
        },
      ),
    );
  }
}
