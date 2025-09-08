import 'package:flutter/material.dart';

// ويدجت مسؤول عن إنشاء حقول إدخال الخيارات (Choices) الخاصة بالتصويت
class PollChoies extends StatefulWidget {
  const PollChoies({super.key});

  @override
  State<PollChoies> createState() => PollChoiesState();
}

// الحالة الداخلية (State) لويدجت PollChoies
class PollChoiesState extends State<PollChoies> {
  /* قائمة الـ TextEditingController لإدارة النصوص المدخلة من المستخدم
   تبدأ بخانتين على الأقل (لأن أي تصويت يحتاج حد أدنى خيارين)*/
  List<TextEditingController> _controllers = [
    TextEditingController(),
    TextEditingController()
  ];

// إضافة خيار جديد (حقل نص إضافي)
  void _addChoies() {
    setState(() {
      _controllers.add(TextEditingController());
    });
  }

// حذف خيار معين (بشرط يبقى عندنا على الأقل خيارين)
  void _removeChoies(index) {
    if (_controllers.length > 2) {
      setState(() {
        _controllers.removeAt(index);
      });
    }
  }

// إرجاع قائمة النصوص المدخلة (مع إزالة النصوص الفارغة)
  List<String> getChoices() {
    return _controllers
        .map((c) => c.text.trim())
        .where((text) => text.isNotEmpty)
        .toList();
  }

// إعادة تعيين الخيارات إلى حالتها الأصلية (خانتين فقط وفارغتين)
  void resetChoices() {
    setState(() {
      _controllers = [TextEditingController(), TextEditingController()];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      // توليد الحقول بناءً على عدد الـ controllers الحالي
      children: List.generate(_controllers.length, (index) {
        return Padding(
          padding: const EdgeInsets.only(
            right: 10,
            top: 10,
          ),
          child: Row(
            children: [
              Expanded(
                // حقل إدخال النص (الخيار)
                child: TextFormField(
                  maxLength: 125, // الحد الأقصى لطول النص
                  maxLines: null, // يسمح بكتابة عدة أسطر
                  controller: _controllers[index],
                  style: const TextStyle(fontSize: 18),
                  decoration: InputDecoration(
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                    border: OutlineInputBorder(
                        borderSide:
                            const BorderSide(color: Colors.black, width: 10),
                        borderRadius: BorderRadius.circular(10)),
                    floatingLabelBehavior: FloatingLabelBehavior.always,
                    hintText: "Choice ${index + 1}", // تلميح يوضح رقم الخيار
                    hintStyle: const TextStyle(
                        color: Colors.grey,
                        fontSize: 20,
                        fontWeight: FontWeight.w600),
                    counterText: "", // يخفي العداد الافتراضي لطول النص
                    fillColor: Colors.white,
                    filled: true,
                  ),
                ),
              ),
              // زر الإضافة يظهر فقط في آخر خيار
              if (index == _controllers.length - 1)
                (IconButton(
                  onPressed: _addChoies,
                  icon: const Icon(Icons.add),
                )),

              // زر الحذف يظهر إذا كان عندنا أكثر من خيارين
              if (_controllers.length > 2 && index >= 2)
                (IconButton(
                  onPressed: () => _removeChoies(index),
                  icon: const Icon(
                    Icons.remove,
                    color: Colors.red,
                  ),
                ))
            ],
          ),
        );
      }),
    );
  }
}
