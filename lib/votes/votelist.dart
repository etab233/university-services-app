import 'package:flutter/material.dart';
import 'PollService.dart';
import 'poll_card.dart';
import '../login_Screen/AuthService.dart';
import 'add_poll.dart';
import 'polls.dart';

// واجهة عرض جميع التصويتات (Votes)
class VoteList extends StatefulWidget {
  const VoteList({super.key});

  @override
  State<VoteList> createState() => _VoteListState();
}

class _VoteListState extends State<VoteList> {
  List<Poll> polls = []; // قائمة التصويتات
  bool loading = false; // مؤشر التحميل
  String? role; // دور المستخدم (admin / student)
  @override
  void initState() {
    super.initState();
    _loadRole(); // تحميل دور المستخدم
    loadPolls(); // تحميل التصويتات
  }

  // تحميل دور المستخدم من AuthService
  void _loadRole() async {
    final r = await AuthService.getRole();
    if (!mounted) return;
    setState(() => role = r);
  }

  // جلب التصويتات من السيرفر
  Future<void> loadPolls() async {
    try {
      final data = await PollService.getPolls();
      // هنا
      data.sort((a, b) => b.id.compareTo(a.id));
      if (!mounted) return;
      setState(() {
        polls = data;
        loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => loading = false);
      debugPrint(e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Votes',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(Icons.arrow_back, size: 30, color: Colors.blue),
        ),
        // زر لإنشاء استبيان خاص بالأدمن
        actions: role == 'admin'
            ? [
                IconButton(
                  icon: const Icon(Icons.add, color: Colors.blue, size: 40),
                  tooltip: 'Create a vote',
                  onPressed: () {
                    Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => AddPoll(
                        onAddPoll: (pollData) {
                          setState(() {
                            polls.add(pollData);
                          });
                        },
                      ),
                    ));
                  },
                ),
              ]
            : [],
      ),
      // جسم الصفحة
      body: Stack(children: [
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
        // محتوى الصفحة
        loading
            ? const Center(child: CircularProgressIndicator())
            : polls.isEmpty
                ? const Center(
                    child: Text('No votes!'),
                  )
                : Padding(
                    padding: const EdgeInsets.all(20),
                    child: ListView.builder(
                        itemCount: polls.length,
                        itemBuilder: (context, index) {
                          final item = polls[index];
                          // بطاقة تصويت (PollCard)
                          return PollCard(
                            key: ValueKey(item.id),
                            poll: item,
                            duration: item.endsAt,
                            //   status: item.status,
                            // عند التصويت
                            onVote: (choiceIndex) async {
                              final int? optionId = (choiceIndex >= 0 &&
                                      choiceIndex < item.options.length)
                                  ? item.options[choiceIndex].id
                                  : null;

                              if (optionId == null) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content: Text('خيار غير صالح')),
                                );
                                return false;
                              }

                              try {
                                final result =
                                    await PollService.vote(item.id, optionId!);
                                if (result['success'] == true) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                        content: Text(result['message'] ??
                                            'تم التصويت بنجاح')),
                                  );
                                  // البطاقة نفسها تحدث النتائج بدون إعادة تحميل
                                  return true;
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                        content: Text(result['message'] ??
                                            'فشل التصويت')),
                                  );
                                  // ممكن نعمل إعادة تحميل عند الفشل فقط
                                  return false;
                                }
                              } catch (e) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('خطأ: $e')),
                                );
                                return false;
                              }
                            },
                            isStopped: item.isStopped, // إيقاف التصويت
                            onStop: () {
                              setState(() {
                                item.isStopped = true;
                              });
                            },
                            // حذف التصويت (للأدمن فقط)
                            onDelete: () async {
                              showDialog(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: const Text('Confirm Delete'),
                                  content: const Text(
                                      'Are you sure you want to delete this poll?'),
                                  actions: [
                                    // إلغاء الحذف
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.of(context).pop(), // Cancel
                                      child: const Text('Cancel'),
                                    ),
                                    // تأكيد الحذف
                                    TextButton(
                                      onPressed: () async {
                                        await PollService.deletePoll(
                                            context, item.id);
                                        await loadPolls();
                                        Navigator.of(context).pop();
                                      },
                                      child: const Text(
                                        'Delete',
                                        style: TextStyle(color: Colors.red),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          );
                        }),
                  ),
      ]),
    );
  }
}
