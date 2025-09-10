import 'dart:async';
import 'package:flutter/material.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import '../login_Screen/AuthService.dart';
import 'PollService.dart';
import 'polls.dart';

/* يعرض تفاصيل الاستبيان: السؤال، الخيارات، نسبة التصويت، الوقت المتبقي.
 كما يحتوي على التحكم بوقف/حذف التصويت (للإدمن).*/
class PollCard extends StatefulWidget {
  final Poll poll; // بيانات التصويت
  final VoidCallback onDelete; // دالة عند الحذف
  final Future<bool> Function(int) onVote; // دالة عند التصويت
  final DateTime? duration; // مدة التصويت (وقت الانتهاء)
  final bool isStopped; // هل التصويت متوقف؟
  final VoidCallback onStop; // دالة عند الإيقاف
  const PollCard(
      {super.key,
      required this.poll,
      required this.duration,
      required this.onDelete,
      required this.onVote,
      required this.onStop,
      this.isStopped = false});
  @override
  State<PollCard> createState() => _PollCardState();
}

class _PollCardState extends State<PollCard> {
  Timer? _timer; // تايمر لحساب الوقت المتبقي
  int? selectedIndex; // الخيار الذي حدده المستخدم
  bool isStudent = false; // هل المستخدم طالب؟
  bool isAdmin = false; // هل المستخدم إدمن؟
  bool isEnded = false; // هل انتهى الاستبيان؟
  bool isLoadingResults = false; // هل يتم تحميل النتائج؟
  bool hasVoted = false; // هل صوت المستخدم بالفعل؟
  late bool _isStopped; // هل التصويت متوقف؟
  List<Option> pollOptions = []; // قائمة الخيارات مع النتائج
  @override
  void initState() {
    super.initState();
    pollOptions = widget.poll.options;
    hasVoted = widget.poll.status == 'voted'; // إذا كان المستخدم صوت سابقاً
    _isStopped = widget.isStopped;
    _loadRole(); // جلب دور المستخدم (طالب/إدمن)

    // بدء تايمر لحساب الوقت المتبقي للتصويت
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      final now = DateTime.now();
      if (!isEnded && widget.duration!.isBefore(now)) {
        setState(() {
          // إذا انتهى الوقت
          isEnded = true;
          _timer?.cancel();
          _fetchResults(); // جلب النتائج بعد انتهاء الوقت
        });
      } else {
        setState(() {}); // تحديث واجهة المستخدم كل ثانية
      }
    });

    // بعد تحميل الواجهةإذا كان المستخدم إدمن يجلب النتائج مباشرة
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (isAdmin) {
        _fetchResults();
      }
    });
  }

  // تحميل دور المستخدم من AuthService
  void _loadRole() async {
    try {
      final role = await AuthService.getRole();
      if (!mounted) return;
      setState(() {
        isStudent = role == 'student';
        isAdmin = role == 'admin';
      });
      if (isAdmin) {
        _fetchResults(); //  الإدمن يشوف النتائج مباشرة
      }
    } catch (e) {
      // تجاهل الخطأ هنا
    }
  }

  // جلب نتائج التصويت من PollService
  Future<void> _fetchResults() async {
    if (isLoadingResults) return;
    setState(() => isLoadingResults = true);
    try {
      final data = await PollService.getPollResults(widget.poll.id);
      setState(() {
        pollOptions = List<Option>.from(data['options'] as List);
      });
    } catch (e) {
      debugPrint("فشل في جلب النتائج: $e");
    } finally {
      if (!mounted) return;
      setState(() => isLoadingResults = false);
    }
  }

  // حساب الوقت المتبقي على انتهاء التصويت
  String getTime(DateTime duration) {
    if (_isStopped || isEnded) return "00:00:00:00";
    final now = DateTime.now();
    final difference = duration.difference(now);
    if (difference.isNegative) {
      return "00:00:00:00";
    }
    final days = difference.inDays.toString().padLeft(2, '0');
    final hours = (difference.inHours % 24).toString().padLeft(2, '0');
    final minutes = (difference.inMinutes % 60).toString().padLeft(2, '0');
    final seconds = (difference.inSeconds % 60).toString().padLeft(2, '0');
    return "$days:$hours:$minutes:$seconds";
  }

  // حساب عدد الأصوات الكلي
  int get totalvotes => pollOptions.fold(0, (a, b) => a + (b.votesCount));

  // التصويت لخيار محدد
  Future<void> vote() async {
    if (hasVoted || selectedIndex == null) return;
    final ok = await widget.onVote(selectedIndex!);
    if (ok) {
      setState(() => hasVoted = true); // تحديث الحالة
      await _fetchResults(); // تحديث النتائج من السيرفر
    }
  }

  @override
  void dispose() {
    _timer?.cancel(); // إيقاف المؤقت عند التخلص من الواجهة
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 10),
      elevation: 5,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(17),
      ),
      child: Padding(
        padding: const EdgeInsets.only(right: 20, left: 20, top: 20, bottom: 5),
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              // صف فيه (اسم منشئ التصويت + قائمة خيارات الأدمن)
              Row(children: [
                const Icon(Icons.person, size: 20, color: Colors.blue),
                Padding(
                  padding: const EdgeInsets.only(left: 5),
                  child: Text(
                    widget.poll.createdBy,
                    style: const TextStyle(
                      fontSize: 16,
                    ),
                  ),
                ),

                // قائمة منبثقة (لوقف أو حذف التصويت)
                if (isAdmin)
                  Expanded(
                      child: Align(
                    alignment: Alignment.topRight,
                    child: PopupMenuButton(
                        icon:
                            Icon(Icons.more_vert, size: 20, color: Colors.blue),
                        onSelected: (value) {
                          if (value == "delete poll") {
                            widget.onDelete();
                          } else if (value == "stop poll" && !_isStopped) {
                            // تأكيد إيقاف التصويت
                            showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: const Text('Confirm Stop poll'),
                                content: const Text(
                                    'Are you sure you want to stop this poll?'),
                                actions: [
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.of(context).pop(), // Cancel
                                    child: const Text('Cancel'),
                                  ),
                                  TextButton(
                                    onPressed: () async {
                                      await PollService.stopPoll(
                                          widget.poll.id);
                                      setState(() {
                                        _timer?.cancel();
                                        isEnded = true;
                                        _isStopped = true;
                                      });
                                      Navigator.of(context).pop();
                                      widget.onStop();
                                    },
                                    child: const Text(
                                      'Stop',
                                      style: TextStyle(color: Colors.red),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }
                        },
                        itemBuilder: (context) {
                          // الإدمن فقط يرى خيارات التحكم(الحذف والايقاف)
                          if (isAdmin) {
                            return [
                              PopupMenuItem(
                                  value: "stop poll",
                                  enabled: !isEnded,
                                  child: const Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Icon(Icons.volume_off),
                                      Text("Stop poll"),
                                    ],
                                  )),
                              const PopupMenuItem(
                                  value: "delete poll",
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Icon(Icons.delete, color: Colors.red),
                                      Text("Delete poll",
                                          style: TextStyle(color: Colors.red)),
                                    ],
                                  )),
                            ];
                          } else {
                            return <PopupMenuEntry>[];
                          }
                        }),
                  )),
              ]),
              const SizedBox(
                height: 10,
              ),

              // السؤال
              Text(widget.poll.question,
                  style: const TextStyle(
                      fontSize: 20, fontWeight: FontWeight.w600)),
              const SizedBox(
                height: 10,
              ),
              // عرض الخيارات
              ...List.generate(pollOptions.length, (index) {
                final option = pollOptions[index];
                final percent =
                    totalvotes == 0 ? 0.0 : (option.votesCount) / totalvotes;
                //عدلت الshowResults
                final showResults = isAdmin | hasVoted | isEnded;

                // إظهار أزرار الاختيار إذا لم تنتهي المدة والطالب لم يصوت
                if (!showResults && isStudent && !_isStopped) {
                  return Row(
                    children: [
                      Expanded(
                          child: RadioListTile(
                              title: Text(option.optionText),
                              value: index,
                              groupValue: selectedIndex,
                              onChanged: (val) {
                                setState(() {
                                  selectedIndex = val;
                                });
                              })),
                      // زر التصويت يظهر عند آخر خيار
                      if (index == pollOptions.length - 1 && !hasVoted)
                        (ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            elevation: 5,
                          ),
                          onPressed: () {
                            vote();
                          },
                          child: const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 5),
                              child: Text(
                                "Vote",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w400,
                                ),
                              )),
                        ))
                    ],
                  );
                } else {
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 11),
                        child: Text(option.optionText),
                      ),
                      Row(children: [
                        Expanded(
                            child: Tooltip(
                          message: " ${option.votesCount} votes",
                          child: LinearPercentIndicator(
                              width: 229,
                              lineHeight: 8,
                              percent: percent,
                              barRadius: const Radius.circular(17),
                              progressColor: Colors.blue),
                        )),
                        Text("${(percent * 100).toStringAsFixed(1)}% ")
                      ]),
                    ],
                  );
                }
              }),
              const SizedBox(
                height: 20,
              ),

              // عرض العداد الزمني إذا لم ينتهي التصويت
              if (!isEnded && !_isStopped)
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    const Icon(
                      Icons.alarm_outlined,
                      size: 20,
                    ),
                    Text(
                      " ${getTime(widget.duration!)}",
                      style: const TextStyle(fontSize: 13),
                    )
                  ],
                )
            ]),
      ),
    );
  }
}
