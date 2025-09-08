// نموذج (Model) يمثل تصويت (Poll)
class Poll {
  final int id; // رقم التصويت
  final String question; // نص السؤال
  final int userId; // رقم المستخدم الذي أنشأ التصويت
  final String createdBy; // اسم منشئ التصويت
  final DateTime endsAt; // وقت انتهاء التصويت
  final List<Option> options; // قائمة الخيارات داخل التصويت
  final String status; // حالة التصويت (voted, not_voted, ...)
  bool isStopped; // هل تم إيقاف التصويت من الإدمن؟

  Poll({
    required this.id,
    required this.question,
    required this.userId,
    required this.createdBy,
    required this.endsAt,
    required this.options,
    required this.status,
    this.isStopped = false,
  });

  // تحويل البيانات القادمة من الـ API إلى كائن Poll
  factory Poll.fromJson(Map<String, dynamic> json) {
    // print(json);
    return Poll(
      id: json['id'],
      question: json['question'],
      userId: json['user_id'],
      // قد يأتي الاسم داخل createdBy أو يكون غير موجود
      createdBy: json['created_by']?['name'] ?? "غير معروف",
      endsAt: DateTime.parse(json['ends_at']),
      // تحويل قائمة الخيارات من  List<Option> الى JSON
      options: (json['options'] as List<dynamic>? ?? [])
          .map((o) => Option.fromJson(o))
          .toList(),
      status: json['status'] ?? "not_voted",
      isStopped: false,
    );
  }
}

// نموذج (Model) يمثل خيار واحد داخل التصويت
class Option {
  final int? id; // رقم الخيار
  final int? pollId; // رقم التصويت المرتبط به
  final String optionText; // نص الخيار
  final int votesCount; // عدد الأصوات التي حصل عليها الخيار

  Option({
    this.id,
    this.pollId,
    required this.optionText,
    required this.votesCount,
  });

  factory Option.fromJson(Map<String, dynamic> json) {
    return Option(
      id: json['id'] ?? 0,
      pollId: json['poll_id'] ?? 0,
      // يدعم سواء كان النص باسم "option_text" أو "option"
      optionText: json['option_text'] ?? json['option'] ?? "بدون نص",
      // يدعم سواء كان عدد الأصوات باسم "votes_count" أو "votes"
      votesCount: json['votes_count'] ?? json['votes'] ?? 0,
    );
  }
  // تحويل الكائن Option إلى JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'poll_id': pollId,
      'option_text': optionText,
      'votes_count': votesCount,
    };
  }
}
