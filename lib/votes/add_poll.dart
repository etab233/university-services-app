import 'package:flutter/material.dart';
import 'package:university_services/Constants.dart';
import 'poll_choies.dart';
import 'votelist.dart';
import '../bottom_navigation_bar.dart';
import 'PollService.dart';
import 'polls.dart';

// واجهة إضافة تصويت جديد

class AddPoll extends StatefulWidget {
  final Function(Poll) onAddPoll;
  // دالة يتم استدعاؤها عند إضافة تصويت جديد بنجاح
  const AddPoll({super.key, required this.onAddPoll});

  @override
  State<AddPoll> createState() => _AddPollState();
}

class _AddPollState extends State<AddPoll> {
  //مفتاح للوصول للخيارات
  final GlobalKey<PollChoiesState> _pollChoicesKey =
      GlobalKey<PollChoiesState>();
  //controller للتحكم بحقل السؤال
  final TextEditingController _questionController = TextEditingController();
  //controller للتحكم بحقل مدة الاستبيان
  final TextEditingController _durationController = TextEditingController();
  @override
  void initState() {
    super.initState();
    // تنظيف الحقول عند بداية الواجهة
    _questionController.clear();
    _durationController.clear();
  }

  // التحقق من المدخلات وإرسال التصويت إلى الخادم
  void _submitPoll() async {
    final question = _questionController.text.trim(); //السؤال
    final duration = _durationController.text.trim(); //المدة
    final choices = _pollChoicesKey.currentState?.getChoices() ?? []; //الخيارات
    // التحقق من أن السؤال غير فارغ
    if (question.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please enter a question')));
      return;
    }

    // التحقق من وجود خيارين على الأقل
    if (choices.length < 2) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please enter at least two options')));
      return;
    }

    // التحقق من أن المدة رقم صحيح
    if (duration.isEmpty || int.tryParse(duration) == null) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please enter a valid duration')));
      return;
    }

    try {
      // استدعاء خدمة إنشاء تصويت
      final Poll? created = await PollService.createPoll(
        question: question,
        options: choices,
        duration: Duration(days: int.parse(duration)),
      );

      // التحقق من نجاح العملية
      if (created == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('فشل في إنشاء التصويت')),
        );
        return;
      }

      // إضافة الاستبيان للقائمة في واجهة عرض الاستبيانات
      widget.onAddPoll(created);

      // إظهار رسالة نجاح
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تم إنشاء التصويت بنجاح!')),
      );

      // العودة إلى الواجهة السابقة
      Navigator.of(context).pop();
    } catch (e) {
      // عرض رسالة خطأ عند الفشل
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('فشل في إنشاء التصويت: ${e.toString()}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      //العنوان
      appBar: AppBar(
        backgroundColor: Constants.primaryColor,
        title: Text(
          "Create Poll",
          style: TextStyle(
              color: Colors.black, fontSize: 24, fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
        leading: IconButton(
          onPressed: () {
            // الرجوع إلى واجهة عرض الاستبيانات
            Navigator.of(context).pushReplacement(MaterialPageRoute(
              builder: (context) => const VoteList(),
            ));
          },
          icon: const Icon(Icons.arrow_back, size: 30, color: Colors.black),
        ),
      ),

      // محتوى الواجهة
      body: Padding(
        padding: const EdgeInsets.all(15),
        child: SingleChildScrollView(
          child: Form(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                // العنوان الرئيسي
                RichText(
                  text: TextSpan(children: [
                    TextSpan(
                        text: 'Tell Us Whate You Think',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        )),
                  ]),
                ),
                // const SizedBox(
                //   height: 30,
                // ),
                // حقل السؤال
                TextFormField(
                  controller: _questionController,
                  maxLength: 255,
                  maxLines: null,
                  style: const TextStyle(fontSize: 18),
                  decoration: const InputDecoration(
                      border: InputBorder.none,
                      floatingLabelBehavior: FloatingLabelBehavior.always,
                      labelText: "Question:",
                      hintText: "Do you like polls?",
                      labelStyle: TextStyle(color: Colors.grey, fontSize: 20),
                      hintStyle: TextStyle(
                          color: Colors.grey,
                          fontSize: 20,
                          fontWeight: FontWeight.w600),
                      counterText: ""),
                ),

                const SizedBox(
                  height: 10,
                ),
                // container الخيارات ومدة التصويت
                Container(
                  padding: const EdgeInsets.all(10),
                  width: 500,
                  decoration: BoxDecoration(
                      color: const Color.fromARGB(255, 157, 205, 231),
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(color: Colors.black, width: 1)),
                  child: Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        //  إدخال الاختيارات
                        PollChoies(key: _pollChoicesKey),
                        const SizedBox(
                          height: 7,
                        ),

                        // عنوان مدة التصويت
                        const Text('Poll length',
                            textAlign: TextAlign.start,
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            )),
                        const SizedBox(
                          height: 5,
                        ),
                        // حقل إدخال مدة الاستبيان
                        SizedBox(
                          width: 231,
                          child: TextFormField(
                            controller: _durationController,
                            maxLines: 1,
                            style: const TextStyle(
                                color: Colors.black,
                                fontSize: 22,
                                fontWeight: FontWeight.w600),
                            decoration: InputDecoration(
                              contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 5),
                              border: OutlineInputBorder(
                                  borderSide: const BorderSide(
                                      color: Colors.black, width: 5),
                                  borderRadius: BorderRadius.circular(10)),
                              prefixIcon: const Icon(
                                Icons.alarm_outlined,
                                size: 28,
                              ),
                              hintText: "poll length(days)",
                              hintStyle: const TextStyle(
                                  color: Colors.grey,
                                  fontSize: 22,
                                  fontWeight: FontWeight.w600),
                              fillColor: Colors.white,
                              filled: true,
                            ),
                            keyboardType: TextInputType.number,
                            onChanged: (v) => int.tryParse(v) ?? 0,
                          ),
                        ),
                        const SizedBox(
                          height: 15,
                        ),

                        // زر إلغاء التصويت
                        Align(
                            alignment: Alignment.bottomCenter,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xffdcdbdb),
                                elevation: 5,
                              ),
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                              child: const Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 20),
                                  child: Text(
                                    "cancel poll",
                                    style: TextStyle(
                                      color: Colors.red,
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  )),
                            )),
                      ]),
                ),
                //),
                const SizedBox(
                  height: 15,
                ),
                // زر إرسال التصويت
                Align(
                  alignment: Alignment.bottomRight,
                  child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xff3da0f1),
                        textStyle: const TextStyle(
                          color: Colors.black,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                        elevation: 5,
                      ),
                      onPressed: () {
                        _submitPoll();
                      },
                      //tooltip: 'Create a vote',
                      child: const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 20),
                        child: Text(
                          "submit",
                          style: TextStyle(color: Colors.black),
                        ),
                      )),
                )
              ],
            ),
          ),
        ),
      ),
      // شريط التنقل السفلي
      bottomNavigationBar: Bottom_navigation_bar(),
    );
  }
}
